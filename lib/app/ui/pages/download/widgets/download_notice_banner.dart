import 'package:flutter/material.dart';

import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 横幅上的一枚动作键。
class DownloadNoticeAction {
  const DownloadNoticeAction({
    required this.label,
    required this.onPressed,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool emphasized;
}

/// 下载列表顶部的一条提示。
///
/// [signature] 标识「这一批问题」：同一批被关掉之后本会话内不再弹；问题集合
/// 变了（多了新的失败任务之类）签名跟着变，会重新出现。
class DownloadNotice {
  const DownloadNotice({
    required this.signature,
    required this.icon,
    required this.message,
    this.actions = const [],
    this.iconColor,
    this.onDismiss,
  });

  final String signature;
  final IconData icon;
  final Color? iconColor;
  final String message;
  final List<DownloadNoticeAction> actions;

  /// 关掉时除了「本会话不再弹」之外还要做的事（例如清掉「上次未完成」那批
  /// 的记账）。
  final VoidCallback? onDismiss;
}

/// 下载列表的通用提示横幅：同一时间只摆优先级最高的一条，右侧「+N」表示
/// 后面还排着几条。
///
/// [notices] 由调用方按优先级排好（下标越小越优先）。关掉的那条按
/// [DownloadNotice.signature] 记在本会话里，下一条自动顶上来。
///
/// 出入场：高度与玻璃材质一起从 0 长出来（`materialize` 走颜色通道，不套
/// Opacity，见 [GlassSurface.materialize]）；换条时先收走旧的再长出新的。
class DownloadNoticeBanner extends StatefulWidget {
  const DownloadNoticeBanner({super.key, required this.notices});

  final List<DownloadNotice> notices;

  /// 本会话关掉过的签名。进程活着就一直记着（页面关了再开也不再弹）。
  static final Set<String> _dismissed = <String>{};

  @visibleForTesting
  static void resetDismissedForTesting() => _dismissed.clear();

  @override
  State<DownloadNoticeBanner> createState() => _DownloadNoticeBannerState();
}

class _DownloadNoticeBannerState extends State<DownloadNoticeBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: GlassTokens.motionDuration,
    reverseDuration: const Duration(milliseconds: 180),
  );

  /// 当前摆着的那条（退场动画期间仍是旧的那条）。
  DownloadNotice? _shown;

  /// 退场结束后要换上的那条。
  DownloadNotice? _next;
  bool _swapping = false;

  List<DownloadNotice> get _visible => [
    for (final n in widget.notices)
      if (!DownloadNoticeBanner._dismissed.contains(n.signature)) n,
  ];

  @override
  void initState() {
    super.initState();
    _shown = _visible.firstOrNull;
    if (_shown != null) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DownloadNoticeBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sync() {
    final top = _visible.firstOrNull;
    if (_swapping) {
      _next = top;
      return;
    }
    if (top?.signature == _shown?.signature) {
      // 同一条，只是文案 / 回调换了（计数变化一类）：原地换内容。
      if (top != null) _shown = top;
      return;
    }
    if (_shown == null) {
      _shown = top;
      _controller.forward(from: 0);
      return;
    }
    _swapping = true;
    _next = top;
    _controller.reverse().whenCompleteOrCancel(() {
      if (!mounted) return;
      setState(() {
        _swapping = false;
        _shown = _next;
        _next = null;
      });
      if (_shown != null) _controller.forward(from: 0);
    });
  }

  void _dismiss(DownloadNotice notice) {
    DownloadNoticeBanner._dismissed.add(notice.signature);
    notice.onDismiss?.call();
    setState(_sync);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final notice = _shown;
        if (notice == null || _controller.isDismissed) {
          return const SizedBox.shrink();
        }
        final double v = _controller.status == AnimationStatus.reverse
            ? Curves.easeInCubic.transform(_controller.value)
            : GlassTokens.motionCurve.transform(_controller.value);
        final int more = (_visible.length - 1).clamp(0, 99);
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: v,
            child: IgnorePointer(
              ignoring: v < 0.5,
              child: _buildBody(context, notice, more, v),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    DownloadNotice notice,
    int more,
    double materialize,
  ) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: GlassSurface(
        height: 56,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        materialize: materialize,
        // 信息条不是控件：整只按下去没有任何事情发生，跟手形变在这里只会骗人
        // （看着像点中了什么，能点的其实只有右边那几个键）。
        liquidTouch: false,
        child: Row(
          children: [
            Icon(notice.icon, size: 20, color: notice.iconColor ?? cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notice.message,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (more > 0) ...[
              const SizedBox(width: 6),
              Text(
                '+$more',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(width: 6),
            GlassButtonGroup(
              materialize: materialize,
              children: [
                for (final action in notice.actions)
                  GlassTextActionButton(
                    label: action.label,
                    emphasized: action.emphasized,
                    onPressed: action.onPressed,
                  ),
                GlassIconButton(
                  icon: const Icon(Icons.close),
                  tooltip: t.download.notice.dismiss,
                  onPressed: () => _dismiss(notice),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
