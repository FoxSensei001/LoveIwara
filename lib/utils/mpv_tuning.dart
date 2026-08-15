import 'package:i_iwara/utils/logger_utils.dart';
import 'package:media_kit/media_kit.dart';

/// mpv 网络层调优。
///
/// 解决的是 issue #110 的**成因**而不是症状。
///
/// media_kit 在初始化时把 `network-timeout` 硬编码成 5 秒
/// （media_kit-1.2.6 real.dart:2394），而 mpv 自己的文档默认值是 60
/// （options.rst `--network-timeout`）。mpv 会把它换算成 FFmpeg 的 `timeout`
/// AVOption（微秒，stream_lavf.c:203-209），也就是 `rw_timeout`。5 秒没有数据
/// 就判定超时 → `avio` 返回 `AVERROR(EIO)` → `http.c` 拆掉连接重连 → 拆连接时
/// TLS 发 `close_notify` → 于是 `tls_mbedtls.c` 打出
/// `tcp: ffurl_write returned 0xffffd8ba`。
///
/// 换句话说：那条被当成"播放错误"弹给用户的日志，是我们自己用一个过短的超时
/// 制造出来的。把它调回接近 mpv 的默认值，噪音在源头就少了一大截。
///
/// 这里只碰 mpv 的**网络与缓冲**参数，不碰任何 UI 行为，也不改 Dart 侧逻辑。
///
/// 三个刻意不碰的东西：
/// - `demuxer-lavf-o`：media_kit 往里塞了 `protocol_whitelist=[...]`、
///   `seg_max_retry=5` 等（real.dart:2428-2433）。它是 keyvalue-list，
///   `setProperty` 会**整体替换**，会静默丢掉协议白名单，导致 Android 上
///   `content://` / `fd://` 播放失败。
/// - `keep-open` / `cache-pause`：media_kit 的 `completed` 检测和 mpv 自己的
///   卡顿判定分别依赖它们，改了会连带弄坏别的东西。
/// - `demuxer-readahead-secs`：在我们的配置下它是个**空操作**。options.rst
///   `--cache-secs` 写得很明确：cache 启用时 `cache-secs` 覆盖
///   `demuxer-readahead-secs`，而它的默认值"设得非常高"；media_kit 又强制
///   `cache: yes`（real.dart:2400）。所以写它只会让下一个读代码的人误以为
///   预读被调大了。
class MpvTuning {
  const MpvTuning._();

  /// mpv 文档默认值是 60，media_kit 改成了 5。取 30 是折中：
  /// 既让慢 CDN 有喘息时间、不再频繁自我重连，又不至于让真正断掉的 socket
  /// 拖太久才被发现。
  static const int defaultNetworkTimeoutSeconds = 30;

  /// FFmpeg http 重连参数（通过 mpv 的 `stream-lavf-o` 透传）。
  ///
  /// 生效路径已核对：mpv 在 stream_lavf.c:379-380 先设
  /// `reconnect=1` / `reconnect_delay_max=7`，随后 :382 调
  /// `mp_setup_av_network_options`，其最后一步 :217 是
  /// `mp_set_avdict(dict, lavf_opts->avopts)` —— `stream-lavf-o` **最后应用**，
  /// 所以我们的值会覆盖 mpv 的默认值。
  ///
  /// media_kit 没有设置过 `stream-lavf-o`（全包搜索无命中），因此这里不存在
  /// `demuxer-lavf-o` 那种"整体替换会丢东西"的风险。
  ///
  /// 未知选项是安全的：mpv 在 `avio_open2` 成功之后才调
  /// `mp_avdict_print_unset(log, MSGL_V, dict)`（stream_lavf.c:405），
  /// 也就是只在 verbose 级别把没被消费的键打出来，不会导致打开失败。
  static const List<String> _reconnectOptions = <String>[
    // FFmpeg 默认 0。mpv 已经设为 1，这里显式写出来，避免哪天 mpv 改默认值。
    'reconnect=1',
    // connect 阶段的 tcp/tls 错误也重连（FFmpeg 默认 0）。
    'reconnect_on_network_error=1',
    // FFmpeg 默认 120 秒，mpv 收到 7。对在线视频来说 5 秒足够，
    // 更长只是让用户干等。
    'reconnect_delay_max=5',
    // FFmpeg 默认 -1（无限重试）。给一个上限，避免它无声无息地一直转，
    // 把"该报失败了"这件事永远拖住。
    'reconnect_max_retries=6',
  ];

  /// 把网络调优应用到一个 [Player] 上。
  ///
  /// 失败只记日志、不抛异常 —— 调优是锦上添花，任何一项设置不成功都不该让
  /// 播放器初始化失败。
  ///
  /// [reconnectStreamed] 对应 FFmpeg 的 `reconnect_streamed`。
  /// **默认关闭，且暂时不要打开**：它会让 FFmpeg 对不可 seek 的响应也重连，
  /// 重连时带 `Range` 头；如果服务端忽略 `Range`，拿回来的是错位的数据 ——
  /// 这是这组参数里唯一可能产生**画面错误**而不只是延迟的一项。
  /// 打开它之前，先确认 iwara 的 CDN 对签名 URL 支持 `Range`：
  /// `curl -r 1000000-1000100 -v '<签名后的直链>'`，应当返回
  /// `206 Partial Content` 且带 `Content-Range`。
  static Future<void> apply(
    Player player, {
    int networkTimeoutSeconds = defaultNetworkTimeoutSeconds,
    bool reconnectStreamed = false,
    String tag = 'MpvTuning',
  }) async {
    if (player.platform is! NativePlayer) return;

    final NativePlayer platform = player.platform as NativePlayer;

    // `network-timeout` 与 `stream-lavf-o` 都是在**流打开时**读取的，
    // 所以在第一次 open 之前设置一次，就能覆盖之后所有的 open
    // （切清晰度、重试、播放列表下一个）。
    try {
      await platform.setProperty(
        'network-timeout',
        networkTimeoutSeconds.toString(),
      );
    } catch (e) {
      LogUtils.w('设置 network-timeout 失败: $e', tag);
    }

    try {
      final List<String> options = <String>[
        ..._reconnectOptions,
        if (reconnectStreamed) 'reconnect_streamed=1',
      ];
      await platform.setProperty('stream-lavf-o', options.join(','));
    } catch (e) {
      LogUtils.w('设置 stream-lavf-o 失败: $e', tag);
    }

    // 缓冲恢复前多攒 1 秒再起播（mpv 默认 1 秒）。弱网下能明显减少
    // "播一下又转圈"的来回抖动。
    try {
      await platform.setProperty('cache-pause-wait', '2');
    } catch (e) {
      LogUtils.w('设置 cache-pause-wait 失败: $e', tag);
    }

    LogUtils.i(
      'mpv 网络调优已应用: network-timeout=${networkTimeoutSeconds}s, '
      'reconnect_streamed=$reconnectStreamed',
      tag,
    );
  }
}
