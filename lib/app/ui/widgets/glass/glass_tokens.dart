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
///   - 传统档：半透明纯色 + 描边 + 投影，无 BackdropFilter。全平台一致、最省。
///     取值见 [fill] / [stroke] / [shadow]。
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

  /// 玻璃体外投影。[alphaScale] 供材质淡入用（见 [GlassSurface.materialize]）。
  ///
  /// 2026-08-24 整体收窄：旧值（16px 模糊 + 1px 扩散）比两个液态包自己标定的
  /// 投影重了好几圈——`liquid_glass_widgets` 的 Apple 基线只是「6% 不透明度 /
  /// 8px 模糊、零扩散」（见 `LiquidGlassSettings.shadowElevation` dartdoc）。
  /// 扩散半径尤其是罪魁：它把阴影的外轮廓整只推大，在 44 高的小胶囊上格外
  /// 显眼，这里直接去掉，只留模糊。
  static List<BoxShadow> shadow(ColorScheme cs, {double alphaScale = 1}) {
    final isDark = cs.brightness == Brightness.dark;
    return [
      // 接触阴影（近处轮廓）
      BoxShadow(
        color: Colors.black.withValues(
          alpha: (isDark ? 0.32 : 0.10) * alphaScale,
        ),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
      // 悬浮扩散阴影（外层弥散光）
      BoxShadow(
        color: Colors.black.withValues(
          alpha: (isDark ? 0.22 : 0.08) * alphaScale,
        ),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

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
  // 第三档材质（[GlassBackend.liquidWidgets]）。取值刻意与上面 easy 那一段
  // **对齐同一套观感**——同一份色调（[liquidTint]）、同一量级的模糊、同一条
  // 投影。两档并存时差别应该只在**手感**（果冻指示器、按压高光、交互折射），
  // 而不该读成「这个 App 里有两种玻璃」。

  /// 玻璃底下的背景模糊。
  ///
  /// 2026-08-24 从 14 压到 9：14 配上原来那份近乎不透明的白色 [liquidTint]，
  /// 胶囊身后**什么都透不出来**，读起来是一块塑料片而不是玻璃——「边框难看」
  /// 的一半原因在这儿：身子不透明的时候，边上剩下的那条线怎么画都像 Material
  /// 的 OutlinedButton 描边。Apple 的玻璃是**看得见背后在动**的。
  static const double widgetsBlur = 12;

  /// 玻璃「厚度」（shader 里的 3D 景深）。他们的默认值 30 在 44 高的小胶囊上
  /// 会鼓成气泡边，压到 22 才是「一片玻璃」而不是「一颗水珠」。
  static const double widgetsThickness = 22;

  /// 折射率。
  ///
  /// 2026-08-24 从 1.12 提到 1.34：折射只作用在**身后被采样的背景**上（不碰
  /// 胶囊里的图标文字），所以「把字拽花」的顾虑不成立。液态玻璃边缘那圈会
  /// 「动」的观感——背景在边上被挤压、拉出一条随内容变化的亮暗带——正是这个
  /// 数给的。1.12 太低，边上几乎不发生挤压，只好靠画一条死描边冒充边框。
  static const double widgetsRefractiveIndex = 1.34;

  /// 边缘「整圈发亮」的强度（仅 Premium/Impeller 路径生效）。
  ///
  /// 2026-08-24 先拉到 0.45 又退回默认 0：[lgw.LiquidGlassSettings.ambientRim]
  /// 的定位就是「不管光照朝向，整圈都垫亮」，真机上读出来是四条边一样白，
  /// 反而丢了液态玻璃该有的方向性——真实观感应该是**迎光那一侧（上沿）一条
  /// 亮高光，其余侧接近一条素描边**，这条由 [lgw.LiquidGlassSettings
  /// .fresnelStrength] 的物理 Fresnel 项自己算，包的默认值 1.0 已经是满格，
  /// 不用另外设。别再碰这个字段——上一次调它就是这次「边框纯白」反馈的根因。
  static const double widgetsAmbientRim = 0.0;

  /// 光源方向（弧度）。shader 里方向向量取 `(cos θ, -sin θ)`，π/2 正好是
  /// **正上方**。
  ///
  /// 包的默认值是 135°（左上 45°）——那是给大块面板用的，套在胶囊上会同时
  /// 点亮**四条边**：迎光项吃到上沿和左沿（两者与左上光的夹角都是 45°），
  /// 背光项还带 0.8 的补偿把下沿和右沿也点亮，读出来就是「整圈一样白、
  /// 没有方向」。改成正上方之后，左右两侧的法线与光垂直、拿不到高光，
  /// 「上沿一条亮边、两侧素」的层次才立得起来。
  static const double widgetsLightAngle = 1.5707963267948966; // pi / 2

  /// 边缘「新月形暗带」（meniscus）强度。
  ///
  /// 真玻璃的边比中间厚，光穿过更多材料会衰减，所以**边缘先有一条暗带，
  /// 亮高光才压在这条暗带上**——这条暗带就是「左右两侧那条实线」的来源。
  /// 包里这项默认 0（等于没有暗带），配上我们几乎纯白的 [liquidTint]，
  /// 白底页面上整只胶囊就只剩一圈同样亮的白，读起来「边框是纯白高亮、
  /// 没有方向」。
  ///
  /// shader 里这条按迎光/背光分权重（`dirScale` 在迎光侧 0.6、背光侧 1.4），
  /// 所以调它只会压暗左右/下沿，上沿的迎光高光基本不受影响——正是我们要的
  /// 「上沿亮、两侧一条线」。
  static const double widgetsEdgeAbsorption = 0.12;

  /// 「易读性白纱」（iOS 26 浅色模式玻璃的关键一味）。
  ///
  /// 这是**跟"提高色调不透明度"完全不同的一件事**：色调是往玻璃里掺一层不透明
  /// 的白，掺够了折射就没了；白纱是 shader 在渲染的**最后一步**把成品往白色
  /// 推（`mix(glass, white, w)`），而且亮度加权（[whitenGated]）——身后偏亮的
  /// 像素被推到纯白、暗的文字图标原样保留，所以**背后的内容仍然看得见轮廓，
  /// 只是整体发白**，折射与边缘光一条都不丢。
  ///
  /// 更关键的是顺序：shader 在白纱**之后**才画边缘光与 Fresnel，所以身子被
  /// 推得再白，那圈亮边依然是脆的——这正是 iOS 26 顶/底栏「一层白纱 + 一圈
  /// 清晰亮边」的做法。
  static double widgetsWhiten(ColorScheme cs) =>
      cs.brightness == Brightness.dark ? 0.10 : 0.45;

  /// 白纱是否按亮度加权。浅色下必须开（只推亮的、留住暗的文字）；深色下背景
  /// 整片是暗的，加权会把白纱整只算成 0，改成均匀薄薄一层。
  static bool widgetsWhitenGated(ColorScheme cs) =>
      cs.brightness != Brightness.dark;

  /// 边缘细线（rim）的宽度，逻辑像素。1.0 是 iOS 26 那条 hairline 的口径。
  static const double widgetsRimWidth = 1.0;

  /// 边缘细线的**方向性高光**。
  ///
  /// 只补 shader 补不上的那一件事：迎光高光的颜色由背景取样得来
  /// （`getHighlightColor`），白底页面上取到的就是白，白高光压在白玻璃上读
  /// 不出来。这里画的是**同一条高光的下限**——一条恒定的白，保证上沿在任何
  /// 背景下都有一道亮边。
  ///
  /// ⛔ 这条线只用白，**绝不掺黑**。2026-08-24 试过「上白下黑」，真机上读成
  /// Material 的 OutlinedButton 描边，用户直接判丑：玻璃的暗边是**折射与
  /// 新月暗带**（[widgetsEdgeAbsorption]）算出来的、随背景变化的软带，不是
  /// 一条画死的黑线。左右两侧那条「实线」交给 shader，这里不画。
  ///
  /// 竖直渐变，t=0 是上沿、t=1 是下沿；越往下越淡，到腰线以下基本没有。
  static LinearGradient widgetsRimGradient(
    ColorScheme cs, {
    double alphaScale = 1,
  }) {
    final bool isDark = cs.brightness == Brightness.dark;
    double a(double v) => v * alphaScale;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              Colors.white.withValues(alpha: a(0.72)),
              Colors.white.withValues(alpha: a(0.38)),
              Colors.white.withValues(alpha: a(0.22)),
              Colors.white.withValues(alpha: a(0.18)),
            ]
          : [
              Colors.white.withValues(alpha: a(0.95)),
              Colors.white.withValues(alpha: a(0.60)),
              Colors.white.withValues(alpha: a(0.40)),
              Colors.white.withValues(alpha: a(0.34)),
            ],
      stops: const [0.0, 0.28, 0.62, 1.0],
    );
  }

  /// 一块玻璃的完整参数。
  ///
  /// [materialize] 直接喂给他们的 `visibility`——那是这套 shader 自己的淡入
  /// 通道（同时缩放厚度与色调），**不需要也不能**再套 `Opacity`，理由与
  /// easy 档那条折射告警是同一条。
  static lgw.LiquidGlassSettings widgetsGlass(
    ColorScheme cs, {
    required Color tint,
    double materialize = 1,
    bool elevated = true,
  }) => lgw.LiquidGlassSettings(
    glassColor: tint,
    blur: widgetsBlur,
    thickness: widgetsThickness,
    refractiveIndex: widgetsRefractiveIndex,
    saturation: liquidSaturation,
    // 小胶囊上的色散只会在边缘留一圈彩虹边，关掉（他们自己的指示器也是 0）。
    chromaticAberration: 0,
    lightAngle: widgetsLightAngle,
    lightIntensity: lgw.GlassDefaults.lightIntensity,
    ambientRim: widgetsAmbientRim,
    whitenStrength: widgetsWhiten(cs),
    whitenGated: widgetsWhitenGated(cs),
    edgeAbsorption: widgetsEdgeAbsorption,
    visibility: materialize,
    // 用包自带的 Apple 标定投影（`shadowElevation` 的 1.0 档 = 6% 不透明度 /
    // 8px 模糊，无扩散），而不是我们那份更重的 [shadow]——那份现在只留给
    // 深色模式的手动补偿（见 LiquidWidgetsGlassBox），两边都用会在浅色下
    // 叠成双份投影。他们的 AdaptiveGlass 只在浅色下画这条，深色下自己跳过
    // （深色背景吃掉投影是 iOS 26 的口径）。
    shadowElevation: elevated ? materialize : 0.0,
  );

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
