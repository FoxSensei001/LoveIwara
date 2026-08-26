import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;

/// 「液态玻璃」风格的尺寸 / 颜色 token。
///
/// 设计来源：docs/mockups/telegram_chat_list_design.md（本地设计稿，已 gitignore）。
///
/// 材质有**三套后端**，由 `LiquidGlassScope` 决定用哪一套（见
/// `liquid_glass_material.dart` 的 `GlassBackend`）：
///   - 传统档：半透明纯色 + 描边，无 BackdropFilter、**无外投影**。全平台
///     一致、最省。取值见 [fill] / [stroke]。
///   - easy 档：`liquid_glass_easy` 的真折射透镜。取值见下方「真·液态玻璃
///     （liquid_glass_easy 后端）」段。浮出来的面板（菜单、下拉板）走这一档。
///   - widgets 档：`liquid_glass_widgets` 的 `AdaptiveGlass`。取值见下方
///     「真·液态玻璃（liquid_glass_widgets 后端）」段，刻意与 easy 档对齐同一
///     套观感。页面常驻 chrome（header 胶囊、按钮组、浮动底栏）走这一档。
/// 三档共用同一套**尺寸**与**动效**，所以切换后端不会改变布局，只改变材质。
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

  /// header 行下方再多渐隐多少距离（标准页面档：header 行 56 时的尾巴长度）。
  ///
  /// 只是给「卡片钻进 header 背后」留一条软边，不是一整片背景：2026-08-20
  /// 从 56 收到 24——56 那会儿蒙层的尾巴整整拖出 header 一大截，在内容上糊出
  /// 一条肉眼可见的白/黑带，读起来像 header 的阴影漏了出去。
  ///
  /// header 更高（多行）的场合别照抄这个数，用 [scrimFadeTail] 按比例算。
  static const double headerFadeExtent = 24;

  /// 蒙层尾巴 ÷「可淡出高度」的标定比例。
  ///
  /// 「可淡出高度」＝ header 总高 − 平台段（恒定不透明那一截：页面是状态栏，
  /// 弹窗是标题行）。整条淡出 = 可淡出高度 + 尾巴，其中尾巴占 24/56 ——
  /// 这不是拍脑袋，是从标准页面档（可淡出 56、尾巴 [headerFadeExtent] 24）
  /// 反解出来的：按这个比例，smoothstep 走到 **header 底缘**时恰好衰减到峰值
  /// 的两成出头（绝对不透明度 ≈0.16），剩下那一点由伸进内容区的尾巴收干净。
  ///
  /// 换句话说，页面和弹窗、单行和多行 header 从此是同一条过渡曲线，只是被
  /// 整体拉长/压短。**不要**给多行 header 配一段固定的短尾巴：那样平台段会
  /// 吃掉整个 header，两行的不透明度完全一样，只在 header 之外才突然开始渐变
  /// ——就是 2026-08-26 用户报的「阴影很突兀、像硬切一刀」。
  static const double scrimFadeTailRatio = headerFadeExtent / headerRowHeight;

  /// 按 [scrimFadeTailRatio] 算蒙层伸进内容区的尾巴长度。
  static double scrimFadeTail(double fadeableExtent) =>
      math.max(0, fadeableExtent) * scrimFadeTailRatio;

  /// 浮动 Tab 栏高度。
  static const double floatingTabBarHeight = 64;

  /// 浮动 Tab 栏距屏幕底部安全区的间距。
  static const double floatingTabBarBottomMargin = 4;

  /// 浮动 Tab 栏左右边距。
  static const double floatingTabBarSideMargin = 16;

  /// 浮动底栏旁的独立圆钮（搜索）直径。
  ///
  /// 与 [floatingTabBarHeight] 相等**不是巧合**：底栏由
  /// `liquid_glass_widgets` 的 `GlassTabBar.bottom` 画，它把这枚钮塞进一个
  /// 「高度 = 栏高」的槽位里（`Positioned(top: 0, bottom: 0)`），直径小于栏高
  /// 会被纵向拉成椭圆。改栏高时这里跟着走就行。
  static const double floatingActionSize = floatingTabBarHeight;

  /// 浮动底栏旁独立圆钮（搜索）的中心距屏幕右缘的水平距离。
  /// 回顶浮钮等与它共轴时用 [floatingActionCoAxisRight] 反推各自的 `right`。
  static const double floatingActionAxisRight =
      floatingTabBarSideMargin + floatingActionSize / 2;

  /// 让直径 [buttonSize] 的浮钮与浮动底栏旁的独立圆钮（搜索）中心共轴
  /// 所需的 `right` 偏移（仅移动端底栏可见时有意义，见
  /// [isFloatingBarInsetActive]）。
  static double floatingActionCoAxisRight(double buttonSize) =>
      floatingActionAxisRight - buttonSize / 2;

  /// **圆形**玻璃里挂角标（未读红点、在线绿点…）时，角标该距外接方框边缘
  /// 留多少，才能整只落在圆内。
  ///
  /// ⚠️ 这不是审美参数，是**液态档的硬约束**：两个液态后端都会把 child 按
  /// 自身形状裁掉（easy 的 lens 用 `ClipRRect`、widgets 的 `LiquidGlass` 用
  /// `ClipPath`，且都没有关掉裁切的口子）。而角标习惯上挂在方框的**角**上
  /// ——那个位置在内切圆之外，一进液态档就整只被裁没。传统档不裁，所以这个
  /// bug 只在开了液态的页面上现形（2026-08-23：热门视频/图库、订阅、侧栏身份
  /// 钮四处的绿点/红点缺角，正是这一条）。
  ///
  /// 角标按 45° 方向摆：圆心到角标中心的距离取 `(diameter - badgeSize) / 2`
  /// 时角标恰好内切，再换算回「距 [boxSize] 方框边缘的内缩」。
  ///
  /// - [diameter]：玻璃圆的直径（裁切用的那个圆）。
  /// - [badgeSize]：角标直径。
  /// - [boxSize]：角标定位所依据的方框边长；默认与 [diameter] 相同。头像自己
  ///   带的角标（[AvatarWidget] 的在线绿点）定位在**头像**的框上，比玻璃圆小
  ///   一圈，要把头像尺寸传进来。
  ///
  /// 结果可能为负（本来就装得下），调用方按 0 截断即可。
  static double circleBadgeInset({
    required double diameter,
    required double badgeSize,
    double? boxSize,
  }) {
    final double box = boxSize ?? diameter;
    return (box - badgeSize) / 2 - (diameter - badgeSize) / (2 * math.sqrt2);
  }

  /// 身份圆钮上未读红点的直径（[GlassAnimatedDot] 的默认值）。
  static const double identityBadgeSize = 9;

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

  /// 手指移出按钮多远仍算「按在这枚键上」：按下那一刻的按钮矩形往外扩这么多，
  /// 手指在这个圈里怎么动都还能触发，走出去才作废。见 `GlassTapArea`。
  ///
  /// 取值只有一条硬约束：**必须明显大于 [kTouchSlop]（18）**。滚动 / 翻页的
  /// 拖拽是在 18px 处宣布胜利、把 tap 判负的，容忍圈比它大才能保证「按住列表
  /// 里的玻璃钮往下滑」永远先算滚动，而不是先被这层吃掉。
  ///
  /// 96 ≈ 两根手指的宽度：40px 的小圆钮加上两边就是 232px 的容忍圈。
  ///
  /// 2026-08-24 从 48 翻倍到 96：真机上 48 太短了，按住一枚键随手蠕动两下就已经
  /// 滑出去、这一下白按。这套材质的玩法本来就是"按住不放拖着玩"，容忍圈得给得
  /// 比"手抖"宽出一大截；真要甩出去取消的人不会只甩这么点距离。
  static const double touchStaySlop = 96;

  // ---- 颜色 ----
  /// 玻璃体底色（半透明，随明暗主题翻转）。
  static Color fill(ColorScheme cs) =>
      cs.surfaceContainerLow.withValues(alpha: 0.80);

  /// 玻璃体按下时的底色。
  static Color pressedFill(ColorScheme cs) =>
      Color.alphaBlend(cs.onSurface.withValues(alpha: 0.08), fill(cs));

  /// 玻璃体内侧细描边。
  static Color stroke(ColorScheme cs) => cs.outlineVariant.withValues(
    alpha: cs.brightness == Brightness.dark ? 0.55 : 0.45,
  );

  /// ⛔ 传统档**不画外投影**。
  ///
  /// 这里原本有一个 `shadow(ColorScheme)` token（两层 BoxShadow：3px 接触
  /// 阴影 + 8px 弥散阴影），传统档的每一块玻璃、玻璃 toast、玻璃搜索框都往
  /// 外面吐一圈黑影。2026-08-26 整只删除：用户报「假玻璃档下所有玻璃件都带
  /// 一圈外散的阴影」——传统档的玻璃本来就是**贴在内容上的一层半透明膜**，
  /// 靠 [fill] + [stroke] 立起来就够了；再补一圈外投影只会把它读成一张
  /// 「浮在上面的卡片」，和液态档那种「内容从玻璃底下透出来」的观感正好相反。
  ///
  /// 两个液态档各有**自己**的投影通道，与本条无关，不要拿来顶替：
  ///   - easy 档：[liquidShadow]（喂给 `LiquidGlassAppearance.shadow`，
  ///     长在形变盒内、按下会跟着胀缩）。
  ///   - widgets 档：[widgetsGlass] 的 `shadowElevation`（包自己按 iOS 26
  ///     口径画，深色下自动跳过）。
  ///
  /// 要给传统档「立体感」请改 [fill] / [stroke]，**不要**再加 boxShadow。
  /// 见 `test/glass_style_guard_test.dart` 的零容忍闸门。

  /// 选中态高亮底色（Tab / 分段）。
  static Color selectedHighlight(ColorScheme cs) =>
      cs.secondaryContainer.withValues(alpha: 0.9);

  /// 浮动底栏那颗果冻指示器的色调。
  ///
  /// **不要拿 [selectedHighlight] 顶替**：那是一块「底色」（0.9 不透明度，垫在
  /// 图标下面）；而这颗指示器本身是一块真玻璃，浮在图标层**之上**靠折射与放大
  /// 标记选中项。给它 0.9 的填充等于把折射整个盖死，果冻感与磁透镜一起消失。
  /// 这里只是在玻璃里掺一点品牌色，让选中项偏暖一档。
  static Color tabIndicatorTint(ColorScheme cs) => cs.primary.withValues(
    alpha: cs.brightness == Brightness.dark ? 0.16 : 0.12,
  );

  /// 边缘渐变蒙层的基色。
  static Color scrimBase(ColorScheme cs) => cs.surface;

  // ---- 真·液态玻璃（liquid_glass_easy 后端）----
  //
  // 这一段只在 `GlassBackend.easyLens` 的子树里生效。调参前先读
  // docs/liquid_glass_easy.md——尤其是「一块 lens = 一次 backdrop 采样」和
  // 「lens 不要放进滚动容器」两条。

  /// chrome（按钮 / 按钮组 / 浮动底栏）那一档的玻璃色调。
  ///
  /// **刻意比浮出面板的 [liquidTint] 透明得多**：面板要托住整页文字，chrome
  /// 只托几枚图标，透明度可以给到真玻璃的量级。0.45 那档（面板的值）套到
  /// 胶囊上就是一块奶白塑料片，折射与边缘光全被盖死。
  static Color widgetsTint(ColorScheme cs) {
    final bool isDark = cs.brightness == Brightness.dark;
    // 深色模式反过来用**黑**：白纱（[widgetsWhiten]）在全暗背景上等于不生效，
    // 玻璃压到亮图片上时里头的浅色图标会糊掉，压暗的活只能由色调来干。
    // 包自己的 `backerColor`（Apple 的 dimming layer）看着更对口，但它在
    // **融合层那条路上被整只跳过**（会破坏 metaball 形变），而 header 一整行
    // 恰好都在融合层里——两条路会长得不一样，所以不用它。
    return isDark
        ? Colors.black.withValues(alpha: 0.24)
        : Colors.white.withValues(alpha: 0.10);
  }

  /// chrome 按下时的玻璃色调：与 [pressedFill] 同一口径（压深 8%）。
  static Color widgetsPressedTint(ColorScheme cs) {
    final Color base = widgetsTint(cs);
    return Color.alphaBlend(cs.onSurface.withValues(alpha: 0.08), base);
  }

  /// 浮出面板那一档的玻璃色调：使用清透的微白高光，避免灰色/纯色背景下发脏变浑浊。
  static Color liquidTint(ColorScheme cs) {
    final isDark = cs.brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.45);
  }

  /// 按下时的玻璃色调：与 [pressedFill] 同一口径（压深 8%）。
  static Color liquidPressedTint(ColorScheme cs) =>
      Color.alphaBlend(cs.onSurface.withValues(alpha: 0.08), liquidTint(cs));

  /// 玻璃底下的背景模糊。传统档没有这一项（当初刻意不用 BackdropFilter）；
  /// 液态档靠它把身后的高频细节化开，折射才不会糊成噪点。
  static const LiquidGlassBlur liquidBlur = LiquidGlassBlur(
    sigmaX: 14,
    sigmaY: 14,
  );

  /// 保持自然饱和度：避免提饱和导致灰色背景偏色发浑。
  static const double liquidSaturation = 1.0;

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
  ///
  /// 2026-08-24 先调亮又回调：把 `ambientIntensity` 拉到 1.8、外加
  /// `borderSolidity`/`lightSpread` 一起加大，结果是整圈边框被**均匀**点亮成
  /// 一条纯白描边——[OpticalBorder.ambientIntensity] 的定位就是「不看光照
  /// 方向、把整圈都垫亮」，[borderSolidity] 越高越会把这圈亮压向不透明的
  /// 实色，两个一起加等于把「会从背景取色的光学高光」硬生生做成了纯色边框，
  /// 真机上读出来是「上下左右一样白」，反而丢了液态玻璃该有的方向性——
  /// 真实观感应该是**上沿（迎光侧）一条亮高光，左右两侧接近一条素描边**。
  /// 现在只留一点点 ambient 垫光（1.0 默认基本读不出，给到 1.2 勉强够看），
  /// [borderSolidity] 退回 0（保持半透明、继续从背景取色），[lightSpread]
  /// 退回包默认 0.5（亮带收回到迎光那一侧，不再环绕大半圈）。
  static const LiquidGlassBorderType liquidBorderType = OpticalBorder(
    borderSaturation: 1.4,
    ambientIntensity: 1.2,
  );

  /// 接触阴影。与传统档的 [shadow] 表达同一件事（玻璃浮在内容之上），
  /// 但它长在 lens 的形变盒里，按下时会跟着一起胀/回弹。
  /// [alphaScale] 供材质淡入用（见 [GlassSurface.materialize]）。
  ///
  /// 2026-08-24 收窄：blur 16 是包自己默认值（3.5）的 4 倍多，且这是全 App
  /// **唯一**一处投影（[LiquidGlassBox] 不再叠外层 [shadow] 了，见调用点
  /// 注释），不用再兼顾「反正外面还有一层」。
  static LiquidGlassShadow liquidShadow(
    ColorScheme cs, {
    double alphaScale = 1,
  }) => LiquidGlassShadow(
    blur: 7,
    opacity: (cs.brightness == Brightness.dark ? 0.28 : 0.16) * alphaScale,
    offset: const Offset(0, 2),
  );

  // ---- 真·液态玻璃（liquid_glass_widgets 后端）----
  //
  // 第三档材质（[GlassBackend.liquidWidgets]）。使用 liquid_glass_widgets
  // 官方默认参数（thickness: 20, blur: 5, refractiveIndex: 1.2, chromaticAberration: 0.01 等），
  // 仅接入主题色调 [widgetsTint] 与淡入 [materialize] 控制。

  /// 一块玻璃的完整参数（采用官方默认标定）。
  ///
  /// [materialize] 直接喂给库自带的 `visibility` 淡入通道。
  static lgw.LiquidGlassSettings widgetsGlass(
    ColorScheme cs, {
    required Color tint,
    double materialize = 1,

    /// 包自己画不画投影。融合层那条路上它是对的；单块玻璃那条路上要关掉，
    /// 改由 `GlassOuterShadow` 画在形变层外面（见那个类）。
    bool shadow = true,
  }) => lgw.LiquidGlassSettings(
    glassColor: tint,
    visibility: materialize,
    // 显式给影子（而不是用他们的 shadowElevation 去缩放默认值）：
    // 见 [widgetsShadow] 里那段「为什么要自己给」。空表＝这块不吐影子。
    shadow: shadow ? widgetsShadow(alphaScale: materialize) : const [],
  );

  /// 真玻璃档的投影（iOS 26 口径：一层弥散 + 一层贴地接触）。
  ///
  /// # 为什么要自己给，而不是用包的 `shadowElevation`
  ///
  /// 包默认是 6%/blur 8 + 2%/blur 2。blur 越大，影子伸得越远，而**单块玻璃
  /// 是画在自己那层 RepaintBoundary 里的**——纹理只有布局那么大，伸出去的
  /// 部分会被合成器整段切掉（见 [glassClipExpansion]）。要让影子完整就得把
  /// 纹理外扩到 blur×3 那么多，而外扩是按面积收 GPU 内存的。
  ///
  /// 所以这里把 blur 收窄一档、不透明度补回来：看得见，但摊开得不远，
  /// 一个 16px 的外扩就装得下。
  ///
  /// ⚠️ 两个液态档的投影都**只在浅色下画**（深色背景本来就吃掉投影，包自己
  /// 按 iOS 26 的口径跳过）。传统档（假玻璃）一概不画，见上面那段 ⛔。
  static List<BoxShadow> widgetsShadow({double alphaScale = 1}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.07 * alphaScale),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03 * alphaScale),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  /// **单块**玻璃（不在融合层里）那层 RepaintBoundary 的裁剪外扩。
  ///
  /// 不给它，`AdaptiveGlass` 画的投影与跟手形变推出布局边界的那部分会在
  /// 层边缘被硬切——2026-08-26 报障「液态玻璃的按钮、分组、按钮组都没有
  /// 阴影」正是这条：影子画了，只是整圈都在纹理外面。融合层那边一直有外扩
  /// （[chromeBlendClipExpansion]），所以 header 里成组的那些一直有影子，
  /// 单块的（浮钮、弹窗里的键、`GlassChromeLayer(group: false)` 的胶囊）没有。
  ///
  /// 取值要盖住 [widgetsShadow] 的伸展（blur 6 → 约 10px，加 2px 偏移）
  /// 再留一点给按压形变。
  static const EdgeInsets glassClipExpansion = EdgeInsets.all(16);

  // ---- 相邻玻璃的融合（metaball）----

  /// 同一层玻璃里两块形状「开始互相吞并」的距离（逻辑像素）。
  ///
  /// 这是一个**手感旋钮**，要和调用点的间距一起看：
  ///   - 浮动底栏：胶囊与搜索圆钮间距 12，包自己给 10 —— 静止态刚好不粘连，
  ///     圆钮被拖近时长出液面颈部。
  ///   - header 行：三块 chrome 之间间距 8（各页 `SizedBox(width: 8)`），
  ///     照同一条口径取 8 —— 静止态是三块独立的玻璃，头像被按住往右拖、
  ///     跟手形变把这 8px 吃掉时才融成一坨。
  ///
  /// 调大会让静止态就粘在一起（读起来是「一条被切了两刀的长胶囊」），
  /// 调小则拖到贴住也不融合。改之前先确认间距有没有一起变。
  static const double chromeBlend = 8;

  /// 同一层玻璃里两块 chrome 之间该留的间距。
  ///
  /// 与 [chromeBlend] 是**同一个数**，不是巧合：融合的阈值就是「间距」本身
  /// ——静止态刚好不粘连，被按住拖近了才长出液面颈部。所以两者必须一起改。
  ///
  /// 收口成常量是因为它以前只写在 `GlassHeaderOverlay` 的文档里、靠各页手抄
  /// `SizedBox(width: 8)`。抄漏的地方（分页栏的翻页键原本是 4）在收进同一层
  /// 之后会直接糊成一坨——间距不再只是留白，它是材质的参数。
  static const double chromeGap = chromeBlend;

  /// 融合层的裁剪外扩：跟手形变会把玻璃推出布局边界，不外扩就会在 layer
  /// 边缘出现一道硬切。与浮动底栏（`GlassTabBar.bottom` 内部）同值。
  static const EdgeInsets chromeBlendClipExpansion = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 15,
  );

  // ---- 跟手形变（LiquidStretch）----
  //
  // easy 档那边对应的是 [liquidFlex]（lens 自己的 `touch`）；widgets 档这边
  // 走 `GlassButton.custom(style: transparent)` 借出来的 `LiquidStretch`
  // （见 [LiquidWidgetsGlassBox.interactive]）。两档表达的是同一件事：
  // **按住并拖动时整只玻璃跟着手指走、松手弹回**。

  /// 拖拽位移换算成形变量的系数。**这是一个手感旋钮**，三个参考点：
  ///   - `0.5`：包给**单枚按钮**的默认值；
  ///   - `0.15`：他们自己的 `GlassButtonGroup` 给成组宽胶囊的值，理由是
  ///     「full stretch looks too dramatic on a wide pill」；
  ///   - `0.35`：本 App 取值。真机比过——0.15 在 header 这条 340px 宽的工具条上
  ///     几乎看不出来（用户报的就是"长按没有跟着动"），而它要替代的
  ///     easy 档 `LiquidGlassFlex.subtle()` 本来能拉到 `maxPull = 60px`，
  ///     0.15 明显比原来还弱。
  static const double widgetsStretch = 0.35;

  /// 按下时整只玻璃的膨胀倍数（iOS 26 那一下「吸气」）。
  ///
  /// 取包默认值 1.05。比 easy 档 `subtle()` 的 `holdScale = 0.015` 明显一些
  /// ——真机上读起来是「碰一下胶囊会呼吸」，没有过；要更含蓄就往 1.02 调。
  static const double widgetsInteractionScale = 1.05;

  /// 拖拽阻尼：越大越「粘手」。取包默认值。
  static const double widgetsStretchResistance = 0.01;

  /// 分段指示器（趋势/最新/…那条滑块）的玻璃参数。
  ///
  /// 从他们标定过的 [lgw.AnimatedGlassIndicator.baseIndicatorSettings] 起手，
  /// 只覆盖厚度——那份基线是照 iOS 26 逐项对过的，我们没有比它更好的依据。
  static lgw.LiquidGlassSettings get widgetsIndicator =>
      lgw.AnimatedGlassIndicator.baseIndicatorSettings;

  /// 跟手形变（`LiquidGlassLens.touch`）。用 `.subtle()`——按钮组胶囊/菜单面板
  /// 都是「工具条 / 大面板」而不是单枚按钮，官方文档明确建议这一档给这类容器用，
  /// 默认档的拉伸量对它们来说太夸张。只在显式传 [LiquidGlassBox.touchFlex]
  /// 为真的容器上生效——不是每块玻璃都该动，见调用点注释。
  static const LiquidGlassTouch liquidFlex = LiquidGlassTouch(
    flex: LiquidGlassFlex.subtle(),
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
