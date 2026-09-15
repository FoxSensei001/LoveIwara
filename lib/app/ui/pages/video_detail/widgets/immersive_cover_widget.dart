import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/blurred_thumbnail_background.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// Quest 详情页里代替播放器的那块：剧院模式模糊底 + 封面 + 顶栏 + 播放钮 + 「接着看」。
///
/// # 视觉规范照 2D 播放器
///
/// 这块顶替的是 `MyVideoScreen`，观感要与它一致而不是与页面其余部分的玻璃 chrome 一致
/// （用户 2026-09-05：「按钮背景发白，没有按照 2D UI 的设计规范」）：
///
/// - **按钮**：黑 55% 底 + 白图标 + 18% 白细描边，与播放器里的中央播放钮、封面右下角
///   的起播钮、抽屉把手同一套（[ImmersiveCoverButton]）。⛔ 不用玻璃圆钮 —— Quest 上落到的
///   材质档是浅色的，压在封面上一片发白。
/// - **封面**：`BoxFit.contain`。宽图铺满宽、高图铺满高，不裁。
/// - **底**：剧院模式的模糊封面（[BlurredThumbnailBackground]），contain 留出的黑边
///   就有东西填。
/// - **文字**：压在上下两道渐变上，封面正中留净。
///
/// 纯展示件：数据与动作全由页面传入，自己不碰任何 controller。
class ImmersiveCover extends StatelessWidget {
  const ImmersiveCover({
    super.key,
    required this.thumbnailUrl,
    required this.title,
    required this.meta,
    required this.onBack,
    required this.onPlay,
    this.onOpenQueue,
    this.presenting = false,
  });

  final String thumbnailUrl;
  final String title;

  /// 「作者 · 时长」一类的一行小字；空串不画。
  final String meta;
  final VoidCallback onBack;
  final VoidCallback onPlay;

  /// 「接着看」入口；null 表示本页手上没有视频池，入口整只不出现。
  final VoidCallback? onOpenQueue;

  /// 已经按下「在空间中播放」、幕布还没接手的那段窗口。
  ///
  /// ⛔ 这段窗口**不短**：片源还没打开时要先取详情 / 取源（联网），之后还要查一遍本机
  /// 已下载的各档、再过通道交给原生。期间面板上这张封面一动不动，用户只会当成没点上、
  /// 于是连点好几次（2026-09-15 报障）。转圈 + 吃掉重复点击就是这枚钮的全部交代。
  final bool presenting;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final hasThumb = thumbnailUrl.isNotEmpty;
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 剧院模式的底：模糊放大的封面，比播放器里那份亮一些（这里没有画面盖着它）。
          BlurredThumbnailBackground(
            thumbnailUrl: hasThumb ? thumbnailUrl : null,
            blurSigma: 28,
            scale: 1.12,
            opacity: 0.45,
          ),
          // 封面本体：contain，宽图铺宽、高图铺高。
          if (hasThumb)
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.contain,
              fadeInDuration: const Duration(milliseconds: 200),
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          // 上下两道渐变，正中留净。
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000),
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0xB3000000),
                ],
                stops: [0.0, 0.30, 0.62, 1.0],
              ),
            ),
          ),
          // 顶栏：返回 + 标题
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                ImmersiveCoverButton.circle(
                  icon: Icons.arrow_back_rounded,
                  tooltip: t.common.back,
                  size: 44,
                  iconSize: 24,
                  onTap: onBack,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      shadows: [Shadow(color: Color(0xB3000000), blurRadius: 8)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // 正中：播放钮 + 一行说明
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ImmersiveCoverButton.circle(
                  icon: Icons.play_arrow_rounded,
                  tooltip: t.vrFormat.playInSpace,
                  size: 88,
                  iconSize: 50,
                  onTap: onPlay,
                  busy: presenting,
                ),
                const SizedBox(height: 12),
                Text(
                  presenting ? t.common.loading : t.vrFormat.playInSpace,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(color: Color(0xB3000000), blurRadius: 8)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // 底栏：作者 · 时长 | 接着看
          Positioned(
            left: 16,
            right: 12,
            bottom: 12,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    meta,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      shadows: [Shadow(color: Color(0xB3000000), blurRadius: 6)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onOpenQueue != null) ...[
                  const SizedBox(width: 12),
                  ImmersiveCoverButton.pill(
                    icon: Icons.playlist_play_rounded,
                    label: t.playbackQueue.openQueue,
                    tooltip: t.playbackQueue.openQueue,
                    onTap: onOpenQueue!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 封面 / 媒体区域上的按钮：黑 55% 底、白图标、18% 白细描边，hover 提亮、按下加深。
///
/// 与播放器里 `_buildPlayPauseIcon` / 起播钮 / 抽屉把手同一套观感。手势走 [GlassTapArea]
/// （48px 容忍圈、Quest 射线 hover 不会钉死），按压态自己画。
/// 公开给图库详情页复用（Quest 上横向清单角上的「在空间中浏览」入口）。
class ImmersiveCoverButton extends StatefulWidget {
  const ImmersiveCoverButton.circle({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.size,
    required this.iconSize,
    this.busy = false,
  }) : label = null;

  const ImmersiveCoverButton.pill({
    super.key,
    required this.icon,
    required String this.label,
    required this.tooltip,
    required this.onTap,
    this.busy = false,
  }) : size = 44,
       iconSize = 22;

  final IconData icon;
  final String? label;
  final String tooltip;
  final VoidCallback onTap;

  /// 这枚钮发起的事情还在路上：图标换成转圈，并且**不再接点击**。
  ///
  /// 「交给空间」那两条路（视频 present / 图库 presentGallery）都要等联网 + 查缓存 +
  /// 过通道，短的几百毫秒、长的好几秒。不给回执用户就会连点，而连点在原生侧是一次次
  /// 重新提交。
  final bool busy;

  /// 圆钮直径 / 药丸高度。
  final double size;
  final double iconSize;

  @override
  State<ImmersiveCoverButton> createState() => ImmersiveCoverButtonState();
}

class ImmersiveCoverButtonState extends State<ImmersiveCoverButton> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isPill = widget.label != null;
    final bg = _pressed
        ? Colors.black.withValues(alpha: 0.78)
        : _hovered
        ? Colors.black.withValues(alpha: 0.40)
        : Colors.black.withValues(alpha: 0.55);
    final border = Colors.white.withValues(alpha: _hovered ? 0.36 : 0.18);
    final radius = BorderRadius.circular(widget.size / 2);

    // 转圈直接占掉图标的位置：尺寸与图标一致，药丸不会因为状态切换变宽/跳动。
    final Widget glyph = widget.busy
        ? SizedBox(
            width: widget.iconSize,
            height: widget.iconSize,
            child: Center(
              child: SizedBox(
                width: widget.iconSize * 0.78,
                height: widget.iconSize * 0.78,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          )
        : Icon(widget.icon, color: Colors.white, size: widget.iconSize);

    final content = isPill
        ? Padding(
            padding: const EdgeInsets.only(left: 12, right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                glyph,
                const SizedBox(width: 6),
                Text(
                  widget.label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        : glyph;

    return Semantics(
      label: widget.tooltip,
      button: true,
      child: MouseRegion(
        cursor: widget.busy
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GlassTapArea(
          onTap: widget.busy ? null : widget.onTap,
          onPressedChanged: (pressed) => setState(() => _pressed = pressed),
          child: AnimatedScale(
            scale: _pressed ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              height: widget.size,
              width: isPill ? null : widget.size,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: radius,
                border: Border.all(color: border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
