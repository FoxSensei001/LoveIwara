import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

/// 「液态玻璃」风格的尺寸 / 颜色 token。
///
/// 设计来源：docs/mockups/telegram_chat_list_design.md（本地设计稿，已 gitignore）。
///
/// 材质有**两套后端**，由 `LiquidGlassScope` 决定用哪一套（见
/// `liquid_glass_material.dart`）：
///   - 传统档：半透明纯色 + 描边 + 投影，无 BackdropFilter。全平台一致、最省。
///     取值见 [fill] / [stroke] / [shadow]。
///   - 液态档：`liquid_glass_easy` 的真折射透镜。取值见本类下方「真·液态玻璃」段。
/// 两档共用同一套**尺寸**与**动效**，所以切换后端不会改变布局，只改变材质。
///
/// 「液态」的神在于**没有硬切**：任何 header 上的按钮组、分段胶囊、头像、
/// 徽标发生形变都要有过渡而不是被瞬间替换。形变过渡的原语和取值参见
/// `glass_morph.dart` 顶部的形变词汇表；[motionDuration] / [motionCurve]
/// 是所有形变共用的时值与曲线。
abstract final class GlassTokens {
  // ---- 尺寸 ----
  /// 玻璃胶囊 / 圆钮的标准高度。
  static const double pillHeight = 44;

  /// 胶囊组内单个图标按钮的占位尺寸。
  static const double groupIconButtonSize = 40;

  /// 图标尺寸。
  static const double iconSize = 22;

  /// 玻璃体描边宽度。测量「某块内容摆不摆得下」时要把左右两条描边算进去。
  static const double strokeWidth = 0.6;

  /// 顶部 header 行高度（不含状态栏）。
  static const double headerRowHeight = 56;

  /// header 行下方再多渐隐多少距离。
  ///
  /// 只是给「卡片钻进 header 背后」留一条软边，不是一整片背景：2026-08-20
  /// 从 56 收到 24——56 那会儿蒙层的尾巴整整拖出 header 一大截，在内容上糊出
  /// 一条肉眼可见的白/黑带，读起来像 header 的阴影漏了出去。
  static const double headerFadeExtent = 24;

  /// 浮动 Tab 栏高度。
  static const double floatingTabBarHeight = 64;

  /// 浮动 Tab 栏距屏幕底部安全区的间距。
  static const double floatingTabBarBottomMargin = 4;

  /// 浮动 Tab 栏左右边距。
  static const double floatingTabBarSideMargin = 16;

  /// 浮动底栏旁的独立圆钮直径。
  static const double floatingActionSize = 60;

  /// 浮动底栏旁独立圆钮（搜索）的中心距屏幕右缘的水平距离。
  /// 回顶浮钮等与它共轴时用 [floatingActionCoAxisRight] 反推各自的 `right`。
  static const double floatingActionAxisRight =
      floatingTabBarSideMargin + floatingActionSize / 2;

  /// 让直径 [buttonSize] 的浮钮与浮动底栏旁的独立圆钮（搜索）中心共轴
  /// 所需的 `right` 偏移（仅移动端底栏可见时有意义，见
  /// [isFloatingBarInsetActive]）。
  static double floatingActionCoAxisRight(double buttonSize) =>
      floatingActionAxisRight - buttonSize / 2;

  /// 页面列表需要在安全区之上额外让出的高度（浮动底栏 + 间距 + 少量呼吸）。
  static const double floatingBarReservedExtent =
      floatingTabBarHeight + floatingTabBarBottomMargin + 8;

  /// 底部渐变蒙层在浮动底栏之上再延伸多少。
  /// 与 [headerFadeExtent] 同一口径（2026-08-20 一并从 56 收到 24）。
  static const double bottomFadeExtent = 24;

  // ---- 动效 ----
  static const Duration pressDuration = Duration(milliseconds: 120);
  static const Duration motionDuration = Duration(milliseconds: 200);
  static const Curve motionCurve = Curves.easeOutCubic;

  /// 按钮组槽位入场：比 [motionDuration] 慢，宽度走缓入缓出，
  /// 「冒出来」的过程要能被看见，而不是头几帧就把大半宽度甩出来。
  static const Duration groupSlotEnterDuration = Duration(milliseconds: 300);

  /// 按钮组槽位出场：可以比入场干脆，但同样不许瞬时塌陷。
  static const Duration groupSlotExitDuration = Duration(milliseconds: 200);

  /// 槽位宽度收放曲线。easeOutCubic 会在开头猛冲，叠上外层胶囊的
  /// AnimatedSize 后宽度像瞬跳--缓入缓出让展开有起势。
  static const Curve groupSlotCurve = Curves.easeInOutCubic;

  /// 按钮组胶囊外壳的收放时长：比槽位略长，壳体「追着」内容走，
  /// 读起来是同一坨液态玻璃在形变，而不是两层动画各自为政。
  static const Duration groupMorphDuration = Duration(milliseconds: 340);

  /// 胶囊内容交接（分段胶囊↔下拉钮）：比常规 motion 长，因为它是**两段**
  /// 时序——前半程旧内容收掉、后半程新内容长出来，各占一半才不显得仓促。
  static const Duration capsuleMorphDuration = Duration(milliseconds: 300);

  /// 弹窗入场时长。Material 默认的 150ms 纯淡入在整页弹窗（搜索 / 筛选配置）
  /// 上读起来就是一次硬切，这里放慢到能看清「长出来」的程度。
  static const Duration dialogEnterDuration = Duration(milliseconds: 260);

  /// 弹窗出场时长：比入场干脆，退场不该让人等。
  static const Duration dialogExitDuration = Duration(milliseconds: 190);

  /// 弹窗入场曲线：末段减速，收得住。
  static const Curve dialogEnterCurve = Curves.easeOutCubic;

  /// 弹窗出场曲线：起步慢一拍再加速离场，避免「啪」地消失。
  static const Curve dialogExitCurve = Curves.easeInCubic;

  /// 弹窗「宽屏居中卡片 / 窄屏整页」的分界宽度。
  /// 与 `ResponsiveDialogWidget` 内部的判断保持同一口径。
  static const double dialogWideBreakpoint = 600;

  static const double pressedScale = 0.96;

  // ---- 颜色 ----
  /// 玻璃体底色（半透明，随明暗主题翻转）。
  static Color fill(ColorScheme cs) =>
      cs.surfaceContainerLow.withValues(alpha: 0.80);

  /// 玻璃体按下时的底色。
  static Color pressedFill(ColorScheme cs) =>
      Color.alphaBlend(cs.onSurface.withValues(alpha: 0.08), fill(cs));

  /// 玻璃体内侧细描边。
  static Color stroke(ColorScheme cs) => cs.outlineVariant.withValues(
    alpha: cs.brightness == Brightness.dark ? 0.45 : 0.35,
  );

  /// 玻璃体外投影。
  static List<BoxShadow> shadow(ColorScheme cs) => [
    BoxShadow(
      color: Colors.black.withValues(
        alpha: cs.brightness == Brightness.dark ? 0.40 : 0.10,
      ),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  /// 选中态高亮底色（Tab / 分段）。
  static Color selectedHighlight(ColorScheme cs) =>
      cs.secondaryContainer.withValues(alpha: 0.9);

  /// 边缘渐变蒙层的基色。
  static Color scrimBase(ColorScheme cs) => cs.surface;

  // ---- 真·液态玻璃（liquid_glass_easy 后端）----
  //
  // 这一段只在 `LiquidGlassScope(enabled: true)` 的子树里生效。调参前先读
  // docs/liquid_glass_easy.md——尤其是「一块 lens = 一次 backdrop 采样」和
  // 「lens 不要放进滚动容器」两条。

  /// 玻璃色调。**比传统档的 [fill] 透明得多**：0.80 的底色会把折射整个盖住，
  /// 玻璃就退化成一块磨砂板。但也不能一路降到 0.15——header 胶囊里的字要压在
  /// 滚动而过的封面图上，太透就读不清了。0.42/0.38 是「明显能看见背后在流动、
  /// 同时文字还立得住」的折中值，是本套材质里最该按真机效果回调的一个数。
  static Color liquidTint(ColorScheme cs) => cs.surfaceContainerLow.withValues(
    alpha: cs.brightness == Brightness.dark ? 0.38 : 0.42,
  );

  /// 按下时的玻璃色调：与 [pressedFill] 同一口径（压深 8%）。
  static Color liquidPressedTint(ColorScheme cs) =>
      Color.alphaBlend(cs.onSurface.withValues(alpha: 0.08), liquidTint(cs));

  /// 玻璃底下的背景模糊。传统档没有这一项（当初刻意不用 BackdropFilter）；
  /// 液态档靠它把身后的高频细节化开，折射才不会糊成噪点。
  static const LiquidGlassBlur liquidBlur = LiquidGlassBlur(
    sigmaX: 14,
    sigmaY: 14,
  );

  /// 轻微提饱和：真玻璃会把透过来的颜色压得更艳一点。
  static const double liquidSaturation = 1.12;

  /// 描边宽度。比传统档的 [strokeWidth]（0.6）粗——液态档的描边不是一条线，
  /// 而是 shader 画的边缘光带，太细就看不出「厚度」。
  static const double liquidBorderWidth = 1.2;

  /// 折射强度。44/64 这种小胶囊上 distortion 超过 ~0.18 就会把边缘的字拽变形，
  /// distortionWidth 也不能超过胶囊半高（22），否则整只胶囊都在畸变带里。
  static const LiquidGlassRefraction liquidRefraction = LiquidGlassRefraction(
    distortion: 0.12,
    distortionWidth: 18,
    chromaticAberration: 0.004,
  );

  /// 描边模式：Apple 风 SDF 边缘光（会从背景取色），而不是固定色描边。
  static const LiquidGlassBorderType liquidBorderType = OpticalBorder(
    borderSaturation: 1.4,
    ambientIntensity: 1.0,
  );

  /// 接触阴影。与传统档的 [shadow] 表达同一件事（玻璃浮在内容之上），
  /// 但它长在 lens 的形变盒里，按下时会跟着一起胀/回弹。
  static LiquidGlassShadow liquidShadow(ColorScheme cs) => LiquidGlassShadow(
    blur: 12,
    opacity: cs.brightness == Brightness.dark ? 0.40 : 0.14,
    offset: const Offset(0, 2),
  );
}

/// 浮动底栏当前遮挡掉的屏幕底部高度（含系统安全区）；底栏不可见时为 0。
///
/// Shell 在 build 里写、[RemoveFloatingBarInset] 之外的**根 Overlay 浮层**读。
/// Shell 让页面避开底栏靠的是把高度加进 `MediaQuery.padding.bottom`
/// （见 `home_shell_scaffold.dart`），但 toast 这类挂在根 Overlay 上的东西
/// 压根不在 Shell 子树里，拿到的是系统原始安全区，不借这个值就会正好压在
/// 底栏上。没人监听它，所以 build 期间直接赋值是安全的。
double glassBottomBarObstruction = 0;

/// 当前子树的 `MediaQuery.padding.bottom` 是否被 Shell 为浮动底栏抬高了
/// （即移动端浮动底栏正在覆盖此子树）。
///
/// 回顶浮钮据此决定水平位置：底栏可见时与旁边的搜索圆钮中心共轴
/// （[GlassTokens.floatingActionCoAxisRight]），否则用普通右边距。
bool isFloatingBarInsetActive(BuildContext context) {
  final mq = MediaQuery.of(context);
  return mq.padding.bottom > mq.viewPadding.bottom;
}

/// 把 Shell 为浮动底栏额外抬高的 `MediaQuery.padding.bottom` 还原成系统原始
/// 安全区（取 `viewPadding.bottom`）。
///
/// 用在**不被浮动底栏遮挡**、却处在 Shell 子树里的区域：例如页面 Scaffold 的
/// 抽屉（drawer / endDrawer）——它们从侧边滑出盖在底栏之上，不需要给底栏让位。
class RemoveFloatingBarInset extends StatelessWidget {
  const RemoveFloatingBarInset({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (mq.padding.bottom <= mq.viewPadding.bottom) return child;
    return MediaQuery(
      data: mq.copyWith(
        padding: mq.padding.copyWith(bottom: mq.viewPadding.bottom),
      ),
      child: child,
    );
  }
}
