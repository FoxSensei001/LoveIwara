import 'dart:async';
import 'dart:ffi';

import 'package:media_kit/media_kit.dart';

import 'package:i_iwara/app/services/logging/native_exit_info.dart';
import 'package:i_iwara/app/services/webdav/webdav_gateway.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 进程里所有还活着的 media_kit [Player]。
///
/// 应用里的 [Player] 一律经 [LivePlayers.create] 创建，这样退出时才能一次找全。
/// media_kit 自己没有可用的登记表（`NativeReferenceHolder` 只在 debug 下工作）。
///
/// 为什么需要：Windows 关窗走 `windowManager.destroy()`，原生侧只是
/// `PostQuitMessage`，之后引擎和插件的析构要好几秒，mpv 的音频线程在这期间
/// 一直出声——用户看到的就是「窗口没了，声音还在卡着放 3-5 秒」。
///
/// 第二个职责是闪退取证（2026-10-29）：「退出视频详情几秒后闪退」这类死法发生在
/// libmpv 里，Dart 一个异常都抓不到。所以每个播放器的创建、开始释放、释放后存活
/// 都同步写面包屑（[LogUtils.breadcrumb]），mpv 自己的 warn 以上日志转进 app.log，
/// 有播放器在场时定时记内存。下次闪退，app.log 的最后几行就能说明死在哪一步。
abstract final class LivePlayers {
  static final Set<Player> _players = <Player>{};
  static int _nextId = 0;
  static Timer? _memorySampler;

  static const String _tag = 'LivePlayers';

  // media_kit 1.2.6 的 dispose 在跑完**全部** release 回调后，再等 5 秒才
  // `mpv_terminate_destroy`；media_kit_video 也在 5 秒后才删 Surface 的 global
  // ref。这里从第一个回调开始计时，后面的回调（VideoController 要走一趟平台通道）
  // 在主线程忙时可能拖上一两秒，所以留到 8 秒，确保写这行时两步都已经过去。
  static const Duration _survivalCheckDelay = Duration(seconds: 8);

  // 有播放器在场时多久记一次内存；判断是不是低内存被杀要看死前的走势。
  static const Duration _memorySampleInterval = Duration(seconds: 30);

  // 单个播放器最多转多少行 mpv 日志。坏流能每帧报一次警告，后面的交给 LogService
  // 的去重和限流也会刷掉别的日志。
  static const int _mpvLogLineCap = 100;

  /// 创建并登记一个 [Player]；它被 dispose 时自动摘掉。
  ///
  /// [label] 写进面包屑，用来分辨是哪一类播放器（详情主播放器、本机派生……）。
  ///
  /// [mpvWarnings] 为 false 时只转 mpv 的 error/fatal 日志，不放宽级别。本机
  /// 派生这类无头播放器要批量开几百上千个，每个都转 warn 会把 app.log 刷满，
  /// warning 触发的强制落盘和限流还会挤掉别的日志。
  static Player create({
    required String label,
    PlayerConfiguration configuration = const PlayerConfiguration(),
    bool mpvWarnings = true,
  }) {
    final name = '#${++_nextId}($label)';
    LogUtils.breadcrumb(
      '创建播放器 $name，已在场 ${_players.length} 个，RSS ${LogUtils.currentRssMb()}MB',
      _tag,
    );
    final player = Player(
      configuration: mpvWarnings ? _withWarnLogs(configuration) : configuration,
    );
    _players.add(player);
    _forwardMpvLogs(player, name, warnings: mpvWarnings);
    _ensureMemorySampler();
    // 这个回调注册得最早，所以在 VideoController 释放 Surface 之前跑：此时
    // mpv 已经 stop、事件流已经关闭，真正销毁上下文还在 5 秒之后。
    player.platform?.release.add(() async {
      _players.remove(player);
      if (_players.isEmpty) {
        _memorySampler?.cancel();
        _memorySampler = null;
      }
      LogUtils.breadcrumb(
        '播放器 $name 已停止，开始释放（约 5 秒后销毁 mpv 上下文），'
        'RSS ${LogUtils.currentRssMb()}MB',
        _tag,
      );
      Timer(_survivalCheckDelay, () {
        LogUtils.breadcrumb(
          '播放器 $name 释放后 ${_survivalCheckDelay.inSeconds} 秒进程仍存活，'
          'RSS ${LogUtils.currentRssMb()}MB',
          _tag,
        );
      });
    });
    return player;
  }

  /// mpv 默认只把 error 级日志交给 media_kit；放宽到 warn，闪退前的异常征兆才
  /// 进得了 app.log。调用方要更详细的级别时不降。
  ///
  /// ⛔ PlayerConfiguration 没有 copyWith，这里逐字段照抄；media_kit 升级加了新
  /// 字段要同步补上，否则调用方传的值会被静默丢掉。
  static PlayerConfiguration _withWarnLogs(PlayerConfiguration c) {
    if (c.logLevel.index >= MPVLogLevel.warn.index) return c;
    return PlayerConfiguration(
      vo: c.vo,
      osc: c.osc,
      pitch: c.pitch,
      title: c.title,
      ready: c.ready,
      muted: c.muted,
      async: c.async,
      libass: c.libass,
      libassAndroidFont: c.libassAndroidFont,
      libassAndroidFontName: c.libassAndroidFontName,
      logLevel: MPVLogLevel.warn,
      bufferSize: c.bufferSize,
      protocolWhitelist: c.protocolWhitelist,
    );
  }

  /// 把 mpv 的 warn（[warnings] 为 false 时只要 error/fatal）以上日志转进
  /// app.log。事件流在 dispose 时由 media_kit 关闭，订阅随之结束，不用手动取消。
  ///
  /// 其它订阅方（提示中枢、Anime4K 兜底、图库播放器）都只认 error/fatal，
  /// 放宽级别不会让它们多弹提示。
  static void _forwardMpvLogs(
    Player player,
    String name, {
    required bool warnings,
  }) {
    var lines = 0;
    late final StreamSubscription<PlayerLog> sub;
    sub = player.stream.log.listen((log) {
      final level = log.level.trim().toLowerCase();
      if (level != 'error' &&
          level != 'fatal' &&
          !(warnings && level == 'warn')) {
        return;
      }
      if (++lines > _mpvLogLineCap) {
        LogUtils.w('播放器 $name 的 mpv 日志超过 $_mpvLogLineCap 行，后面的不再记录', 'mpv');
        unawaited(sub.cancel());
        return;
      }
      // ⛔ 网关地址里有进程 token 和 NAS 上的文件名，不能原样落日志。
      LogUtils.w(
        '$name [${log.prefix}] ${log.level}: ${WebDavGateway.redactIn(log.text)}',
        'mpv',
      );
    });
  }

  static void _ensureMemorySampler() {
    _memorySampler ??= Timer.periodic(_memorySampleInterval, (_) async {
      final system = await NativeMemoryInfo.describe();
      LogUtils.i(
        '内存采样：RSS ${LogUtils.currentRssMb()}MB，在场播放器 ${_players.length} 个'
        '${system != null ? '，$system' : ''}',
        _tag,
      );
    });
  }

  /// 立刻让所有播放器停声（静音 + 暂停），供退出流程第一步调用。
  ///
  /// 不走 [Player.pause] / [Player.setVolume]：它们排在 media_kit 的内部锁后面，
  /// 正在进行的 open / seek 会把它们拖住。`waitForInitialization: false` 的
  /// [NativePlayer.setProperty] 在第一个 await 之前就同步调完了
  /// `mpv_set_property_string`，函数返回时 mpv 已经静音。
  static void silenceAllSync() {
    for (final player in _players.toList()) {
      final platform = player.platform;
      if (platform is! NativePlayer || platform.disposed) continue;
      // ctx 要等 media_kit 异步 _create 完成才赋值，之前是 nullptr；libmpv
      // 不判空，拿空句柄调用会在原生层崩溃。
      if (platform.ctx == nullptr) continue;
      for (final property in const ['mute', 'pause']) {
        // 返回的 Future 不用等：属性在调用时已经写进 mpv；吞掉错误免得成为
        // 未处理异常（例如刚好被并发 dispose）。
        platform
            .setProperty(property, 'yes', waitForInitialization: false)
            .catchError((_) {});
      }
    }
  }
}
