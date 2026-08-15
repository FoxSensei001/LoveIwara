import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/player_notice.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 播放器右上角的轻量提示条（issue #110 中 SnackBar 方案的替代品）。
///
/// 三条硬约束，改动前请先理解：
/// 1. 永远 `IgnorePointer(ignoring: true)`——字面量 true，不允许从动画值推导。
///    参考同目录上层的 [ToolbarFadeVisibility]：淡出后的控件仍留在原位，一旦
///    `ignoring` 有任何一帧为 false，它就会变成一层看不见的点击拦截层，挡住
///    播放器的手势与播放条。这里的提示条从不接收输入，所以直接钉死为 true。
/// 2. 内部不允许出现 GestureDetector / InkWell / 任何可聚焦节点。MyVideoScreen
///    外层是 `FocusScope(autofocus: true)` + `Focus(onKeyEvent:)`，可聚焦的子节点
///    会抢走方向键，导致键盘快进失效。
/// 3. 自己持有 AnimationController，不复用工具栏那个。工具栏 3 秒后自动隐藏，
///    而“本视频没有声音”这类提示必须活得比它久。
///
/// 几何全部由调用方算好（fontSize / maxLines / maxWidth），本组件只负责渲染与
/// 淡入淡出，方便图库播放器等场景复用。
class PlayerNoticeChip extends StatefulWidget {
  const PlayerNoticeChip({
    super.key,
    required this.center,
    required this.fontSize,
    required this.maxLines,
    required this.maxWidth,
  });

  /// 只依赖 [PlayerNoticeCenter]，不依赖 MyVideoStateController——图库播放器
  /// 没有后者，但同样需要这套提示。
  final PlayerNoticeCenter center;
  final double fontSize;
  final int maxLines;
  final double maxWidth;

  @override
  State<PlayerNoticeChip> createState() => _PlayerNoticeChipState();
}

class _PlayerNoticeChipState extends State<PlayerNoticeChip>
    with SingleTickerProviderStateMixin {
  static const Duration _kFadeIn = Duration(milliseconds: 180);
  static const Duration _kFadeOut = Duration(milliseconds: 140);

  late final AnimationController _controller;
  late final CurvedAnimation _fade;
  Worker? _noticeWorker;

  /// 淡出期间继续保留最后一次的内容，否则 notice 被置空的瞬间文字就没了，
  /// 用户只能看到一个空壳在渐隐。
  PlayerNotice? _current;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _kFadeIn,
      reverseDuration: _kFadeOut,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _controller.addStatusListener(_onStatusChanged);

    // 挂载时槽位里可能已经有提示（例如页面重建），直接以完全显示的状态接上
    final initial = widget.center.notice.value;
    if (initial != null) {
      _current = initial;
      _controller.value = 1.0;
    }
    _bindNotice();
  }

  @override
  void didUpdateWidget(covariant PlayerNoticeChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.center, widget.center)) {
      _noticeWorker?.dispose();
      _bindNotice();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 系统「关闭动画」开关变化时本方法会重新触发，所以 else 分支必须把时长还原，
    // 否则用户关掉该开关后提示条会永远瞬现瞬灭
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.duration = Duration.zero;
      _controller.reverseDuration = Duration.zero;
    } else {
      _controller.duration = _kFadeIn;
      _controller.reverseDuration = _kFadeOut;
    }
  }

  @override
  void dispose() {
    _noticeWorker?.dispose();
    _noticeWorker = null;
    _controller.removeStatusListener(_onStatusChanged);
    _fade.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _bindNotice() {
    _noticeWorker = ever<PlayerNotice?>(widget.center.notice, _onNoticeChanged);
  }

  void _onNoticeChanged(PlayerNotice? notice) {
    if (!mounted) return;
    if (notice != null) {
      setState(() => _current = notice);
      _controller.forward();
    } else {
      // 不在这里清空 _current，交给 dismissed 状态回调，保证淡出全程有内容
      _controller.reverse();
    }
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.dismissed) return;
    if (!mounted || _current == null) return;
    setState(() => _current = null);
  }

  @override
  Widget build(BuildContext context) {
    final notice = _current;
    // 空态必须是真正不占位的 SizedBox.shrink()：Opacity(0) 仍会参与命中测试，
    // 透明 Container 仍会参与布局并撑开父级
    if (notice == null) return const SizedBox.shrink();

    // 用 Translations.of(context) 而非全局 t，语言实时切换时文案才会跟着变
    final t = slang.Translations.of(context);
    final message = _messageOf(t, notice.kind);

    // Semantics 必须包在 IgnorePointer 外层：container 为 true 才会独立成节点，
    // 默认的 container:false 会让 SemanticsConfiguration.absorb 把 label 和子节点
    // 自身的文本拼在一起，TalkBack 会把同一句话念两遍；excludeSemantics 则挡住
    // 里面 Text 的语义，只留下带前缀的这一条播报
    return Semantics(
      container: true,
      excludeSemantics: true,
      liveRegion: true,
      label: t.mediaPlayer.notice.semanticsPrefix(message: message),
      child: IgnorePointer(
        // 字面量 true，永远不要改成从动画值推导的表达式
        ignoring: true,
        child: FadeTransition(
          opacity: _fade,
          child: Container(
            constraints: BoxConstraints(maxWidth: widget.maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iconOf(notice.kind),
                  size: 16,
                  color: _accentOf(notice.level),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    message,
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.fontSize,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 只取本地化文案，绝不渲染 notice.detail——那是 mpv 原始日志，只供台账与
  /// 详情面板使用，直接摊给用户就退回了 issue #110 的老问题
  String _messageOf(slang.Translations t, PlayerNoticeKind kind) {
    switch (kind) {
      case PlayerNoticeKind.networkUnstable:
        return t.mediaPlayer.notice.networkUnstable;
      case PlayerNoticeKind.audioUnavailable:
        return t.mediaPlayer.notice.audioTrackUnavailable;
      case PlayerNoticeKind.hardwareDecodeFellBack:
        return t.mediaPlayer.notice.hardwareDecodeFellBack;
      case PlayerNoticeKind.videoDecodeProblem:
        return t.mediaPlayer.notice.videoDecodeProblem;
      case PlayerNoticeKind.repeatedProblems:
        return t.mediaPlayer.notice.repeatedPlaybackProblems;
      case PlayerNoticeKind.noVideoSource:
        return t.videoDetail.noVideoSourceFound;
      case PlayerNoticeKind.castNotSupported:
        return t.videoDetail.cast.currentPlatformNotSupported;
      case PlayerNoticeKind.castUrlUnavailable:
        return t.videoDetail.cast.unableToGetVideoUrl;
    }
  }

  IconData _iconOf(PlayerNoticeKind kind) {
    switch (kind) {
      case PlayerNoticeKind.networkUnstable:
        return Icons.wifi_tethering_error_rounded;
      case PlayerNoticeKind.audioUnavailable:
        return Icons.volume_off_rounded;
      case PlayerNoticeKind.hardwareDecodeFellBack:
        return Icons.memory_rounded;
      case PlayerNoticeKind.videoDecodeProblem:
        return Icons.broken_image_outlined;
      case PlayerNoticeKind.repeatedProblems:
        return Icons.warning_amber_rounded;
      case PlayerNoticeKind.noVideoSource:
        return Icons.videocam_off_outlined;
      case PlayerNoticeKind.castNotSupported:
      case PlayerNoticeKind.castUrlUnavailable:
        return Icons.cast_connected_rounded;
    }
  }

  Color _accentOf(PlayerNoticeLevel level) {
    switch (level) {
      case PlayerNoticeLevel.info:
        return Colors.lightBlueAccent;
      case PlayerNoticeLevel.warning:
        return Colors.amberAccent;
    }
  }
}
