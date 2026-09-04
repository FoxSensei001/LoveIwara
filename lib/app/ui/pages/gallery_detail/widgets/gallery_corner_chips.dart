import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_chrome_theme.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 大图页右下角那一撮小胶囊：缩放倍数、横竖屏。
///
/// 视频页与图片页共用同一副零件，只是摆的位置不同：
///   - 视频页：缩放牌浮在控件条**上方**（`GalleryVideoControlBar` 自己摆），
///     横竖屏那枚是条里的一枚键（条里有的是地方，不必再长一枚独立胶囊）；
///   - 图片页：没有控件条，两枚一起摆在胶片条上方的右下角。
///
/// 收在这里而不是各写一份：两页的这两枚键要长得一模一样，尺寸、圆角、材质淡入
/// 的口径分开写迟早对不上（缩放牌第一版 28 高按不准，改到 36 那次就只改了一处）。
const double kGalleryChipHeight = 36;

/// 缩放牌：显示当前倍数，点一下把画面复位。
///
/// # ⛔ 收起来时是**真的不建**，不是压成透明
///
/// 第一版只把内容的 alpha 压到 0，钮本身还挂在那儿——用户看到的是「界面收起来
/// 了它还在」。这里走 [GlassReveal]：退场跑完整只 child 都不建（那也是本项目对
/// 显隐的统一要求，见它的类文档）。
class GalleryScaleChip extends StatelessWidget {
  const GalleryScaleChip({
    super.key,
    required this.scale,
    required this.visible,
    required this.onReset,
  });

  /// 这一页当前被放大到多少倍（1.0 = 原始）。
  final double scale;

  /// 这一刻该不该在场。视频页拖进度时让给 Seek Preview。
  final bool visible;

  final VoidCallback onReset;

  /// 多大算「被缩放了」。留一点死区：PhotoView 的回弹会在 1.0 附近抖几帧。
  static const double _epsilon = 0.02;

  @override
  Widget build(BuildContext context) {
    final bool zoomed = (scale - 1.0).abs() > _epsilon;
    // ⛔ 深色底必须自己带着走。这枚牌原来长在控件条**里头**，靠那条自己包的
    // 深色 Theme 才是黑底白字；搬出来给图片页复用时忘了带上，于是浅色主题下
    // 直接长出一块灰白色方块浮在黑画面上（用户 2026-09-04 当场看出来了）。
    // 现在归 [GalleryDarkChrome] 一处供给，摆到哪儿都对。
    return GalleryDarkChrome(
      child: GlassReveal(
        visible: visible,
        slideFrom: const Offset(0, 0.5),
        builder: (context, materialize) => GlassChromeLayer(
          group: false,
          child: GlassSurface(
            height: kGalleryChipHeight,
            borderRadius: BorderRadius.circular(kGalleryChipHeight / 2),
            padding: const EdgeInsets.symmetric(horizontal: 11),
            materialize: materialize,
            liquidTouch: false,
            tooltip: slang.t.galleryDetail.zoomReset,
            // 恒可按：1.0 上按一下也当作「复位」（位置也会一并归零），
            // 比一枚灰着点不动的钮好读。
            onTap: onReset,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fit_screen_outlined,
                  size: 17,
                  color: Colors.white.withValues(
                    alpha: materialize * (zoomed ? 1.0 : 0.6),
                  ),
                ),
                // 倍数从 0 宽长出来、颜色同步浮现：一次形变，不是「忽然多出一段
                // 字」。⛔ 不用 Opacity——那会 saveLayer 把折射打断。
                TweenAnimationBuilder<double>(
                  duration: GlassTokens.motionDuration,
                  curve: GlassTokens.motionCurve,
                  tween: Tween<double>(begin: 0, end: zoomed ? 1 : 0),
                  builder: (context, t, child) => ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: t,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          '${scale.toStringAsFixed(1)}×',
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: materialize * t,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
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
}

/// 横竖屏牌：把系统屏幕转成横屏，转过去之后它变成「回到竖屏」。
///
/// 只在被 App 强制锁竖屏的手机上出现（判定在大图页那边做）。图片页用它，视频页
/// 用的是控件条里那枚同名的键——两处的图标与文案取自同一处，改一次两边都动。
class GalleryRotateChip extends StatelessWidget {
  const GalleryRotateChip({
    super.key,
    required this.visible,
    required this.landscape,
    required this.onToggle,
  });

  final bool visible;

  /// 此刻是不是已经在横屏里。决定这枚是「转过去」还是「回到竖屏」。
  final bool landscape;

  final VoidCallback onToggle;

  static IconData iconFor(bool landscape) =>
      landscape ? Icons.screen_lock_portrait : Icons.screen_rotation;

  static String tooltipFor(BuildContext context, bool landscape) {
    final t = slang.Translations.of(context);
    return landscape
        ? t.galleryDetail.backToPortrait
        : t.galleryDetail.rotateToLandscape;
  }

  @override
  Widget build(BuildContext context) {
    return GalleryDarkChrome(
      child: GlassReveal(
        visible: visible,
        slideFrom: const Offset(0, 0.5),
        builder: (context, materialize) => GlassChromeLayer(
          group: false,
          child: GlassSurface(
            height: kGalleryChipHeight,
            // 只有一枚图标，收成正圆：和缩放牌并排时是「一条 + 一颗」，
            // 不会被读成两个同样宽的空钮。
            borderRadius: BorderRadius.circular(kGalleryChipHeight / 2),
            padding: const EdgeInsets.symmetric(horizontal: 9),
            materialize: materialize,
            liquidTouch: false,
            tooltip: tooltipFor(context, landscape),
            onTap: onToggle,
            child: GlassAnimatedIcon(
              icon: Icon(
                iconFor(landscape),
                size: 18,
                color: Colors.white.withValues(alpha: materialize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
