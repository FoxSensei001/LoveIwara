import 'dart:ffi';

import 'package:media_kit/media_kit.dart';

/// 进程里所有还活着的 media_kit [Player]。
///
/// 应用里的 [Player] 一律经 [LivePlayers.create] 创建，这样退出时才能一次找全。
/// media_kit 自己没有可用的登记表（`NativeReferenceHolder` 只在 debug 下工作）。
///
/// 为什么需要：Windows 关窗走 `windowManager.destroy()`，原生侧只是
/// `PostQuitMessage`，之后引擎和插件的析构要好几秒，mpv 的音频线程在这期间
/// 一直出声——用户看到的就是「窗口没了，声音还在卡着放 3-5 秒」。
abstract final class LivePlayers {
  static final Set<Player> _players = <Player>{};

  /// 创建并登记一个 [Player]；它被 dispose 时自动摘掉。
  static Player create({
    PlayerConfiguration configuration = const PlayerConfiguration(),
  }) {
    final player = Player(configuration: configuration);
    _players.add(player);
    player.platform?.release.add(() async {
      _players.remove(player);
    });
    return player;
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
