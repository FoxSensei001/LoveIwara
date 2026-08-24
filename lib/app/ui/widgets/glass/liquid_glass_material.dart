import 'dart:ui' show clampDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
// 带前缀：两个包的公开面里 LiquidGlassScope / GlassSegmentedControl /
// GlassButtonGroup / GlassIconButton / GlassToast 等一大批名字与本仓库自己的
// 组件重名，不加前缀会一片 ambiguous_import。
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

// 真·液态玻璃后端的接线层：两个第三方包 + 传统档，共三档材质。
//
// # 为什么是「按子树开关」而不是「全局替换」
//
// 全 App 的玻璃材质只有一个定义处——`GlassSurface`。把它整只换掉，46 处调用点
// 会在同一个 commit 里全部变样，没法一处一处按真机效果收敛；而且折射透镜有两条
// 硬约束（见 docs/liquid_glass_easy.md）：
//
//   1. **一块 lens = 一次 backdrop 采样**。header 上三只胶囊就是三次。
//   2. **lens 不该放进滚动容器**：Android 的拉伸回弹会把滚动内容隔离进独立
//      合成层，lens 在两端会渲染成纯黑。
//
// 所以材质的选择权交给页面：把要液态化的那一块用 [LiquidGlassScope] 包起来，
// 子树里所有 `GlassSurface` 自动换档，其余地方保持传统档不动。
// 铺开的过程就是「多包几处 scope」，不是「再改一次材质」。
//
// # 包哪里
//
// 只包**浮在内容之上的那层 chrome**：header 行、浮动底栏、浮钮、底部动作坞。
// 不要包列表本体（约束 2）——`GlassHeaderOverlay.liquid` 已经替你把 `body`
// 单独关回传统档了。
//
// # ⛔ 别在调用点自己包 —— 三个「收口点」已经替你包好了
//
// 2026-08-24 之前是「谁想要液态谁自己包一层 scope」。听起来灵活，实际后果是
// **漏供不报错**：弹窗里明明已经换成 `GlassIconButton`/`GlassButtonGroup`/
// `GlassComposer*` 这些新组件，却因为读不到祖先 scope 而静默落回传统档，连
// `liquidTouch` 的长按蠕动一起没了。编译过、analyze 干净、单测全绿，只能靠人
// 一张张点开界面发现——同一件事被用户反复报障。
//
// 现在供档点收敛成三个，**所有实例都必然经过其中之一**：
//
//   1. 页面 chrome → `GlassHeaderOverlay(liquid: true)`
//   2. 弹窗 → `GlassDialogRoute`（即 `showAppDialog`，见 `glass_dialog_motion.dart`）
//   3. 弹层 → `showGlassBottomSheet` / `showGlassDraggableBottomSheet`
//
// 所以：**新写弹窗一律走 `showAppDialog`，新写弹层一律走那两个 show 函数**，
// 里头的玻璃件不用做任何事就有档。裸 `showDialog`/`showModalBottomSheet` 开出来
// 的还是传统档——`test/glass_style_guard_test.dart` 用棘轮基线盯着这两个裸入口
// 和裸 Material 按钮的数量，只许降不许升。
//
// # ⚠️ `Opacity` 会把折射打断（已被真机实锤，两个后端都吃这一条）
//
// lens 靠 backdrop 采样吃身后的像素，而 `Opacity`（0 < α < 1 时）会 `saveLayer`
// 把子树隔离出去——层内没有背景，玻璃在淡入淡出的那两百毫秒里基本是空的。
// α == 1 时 `RenderOpacity` 根本不建层，所以**静止态是好的，问题只在过渡中**：
// 读起来就是「**里面的文字先出现，液态玻璃背景才后到**」——玻璃是在动画跑完、
// 透明度层被撤掉的那一刻才「啪」地补上的。玻璃菜单（`showGlassMenu`）此前
// 用 `FadeTransition` 做出入场，正是栽在这条上，已改成不含任何透明度层的
// 「卷开」式出入场。
//
// 所以：**玻璃自己的淡入淡出一律走 `GlassSurface.materialize`**（压材质自身的
// 色调 / 描边 / 投影透明度，图层结构全程不变），不要拿 `Opacity` /
// `AnimatedOpacity` / `FadeTransition` 去包一块玻璃。
//
// 目前还踩在这条线上、尚未改的有两处：回顶浮钮的 `AnimatedOpacity`、
// `GlassSelectionDock` 的 `Opacity`。它们的显隐都带位移，闪的那一下不如菜单
// 明显，改法是一样的（换 `materialize`）。
//
// # 融合：并排的几块玻璃收进同一层
//
// [GlassBackend.liquidWidgets] 档下，一行 chrome 可以用 [GlassBlendGroup] 收进
// **同一层玻璃**，靠得够近时边缘互相吞并——头像圆钮被按住往右拖，会和中间那只
// 胶囊融成一坨。这是「液态」的第九个原语，规矩见 [GlassBlendGroup] 的类注释与
// `glass_morph.dart` 的词汇表。

/// 一块玻璃该由哪套 shader 画出来。由 [LiquidGlassScope] 按子树指定。
enum GlassBackend {
  /// 传统档：半透明底色 + 细描边 + 柔和投影，不采样背景，零 shader 成本。
  /// 全 App 的默认值。
  plain,

  /// `liquid_glass_easy` 的折射透镜（[LiquidGlassBox]）。
  ///
  /// 玻璃菜单（`showGlassMenu`）钉死在这一档：那套「卷开」出入场和面板质感
  /// 是照它调的，chrome 换档不该把菜单一起带走（见 `glass_menu.dart`）。
  easyLens,

  /// `liquid_glass_widgets` 的 `AdaptiveGlass`（[LiquidWidgetsGlassBox]）。
  ///
  /// 与 [easyLens] 的取值刻意对齐同一套观感（见 [GlassTokens.widgetsGlass]），
  /// 差别在**手感**：按压高光、交互折射，以及分段控件那条果冻指示器
  /// （[GlassSegmentedControl] 在这一档下换用 `AnimatedGlassIndicator`）。
  /// 还有一条实在差别——它自带 Skia/Web 回退链（`AdaptiveGlass` 会退到
  /// lightweight shader 再退到磨砂），Windows/Linux 上不会开天窗。
  liquidWidgets,
}

/// 页面级 chrome（header 胶囊、浮动底栏、浮钮、动作坞）默认用哪一档液态玻璃。
///
/// 2026-08-23 从 [GlassBackend.easyLens] 换到 [GlassBackend.liquidWidgets]：
/// 两边并排比过，**按钮组胶囊与分段控件的手感在 widgets 这一档明显更好**；
/// 菜单面板则相反，钉死在 easy（见 `glass_menu.dart` 的 `_menuBackend`）。
/// 要整体回退就改这一个常量，不用去翻各页。
const GlassBackend kChromeGlassBackend = GlassBackend.liquidWidgets;

/// **浮出面板**（菜单、下拉板）该用的档位：恒为 [GlassBackend.easyLens]。
///
/// 为什么钉死在 easy：面板的出入场与质感（尤其 `showGlassMenu` 那套「卷开」）
/// 是照 easy 的 lens 逐帧标定出来的，换 shader 等于全部重来；而用户是分别
/// 评价的——chrome 换 `liquid_glass_widgets` 更好，面板现状就很好。
///
/// # ⛔ 为什么不再跟触发件的档位走（2026-08-24）
///
/// 本函数原先是「传统触发件吐传统面板」：`LiquidGlassScope.of(anchorContext)`
/// 是 plain 就返回 plain。那条规矩写在只有 header 玻璃胶囊会弹菜单的年代，
/// 读起来也合理——一条链上不该出现两种材质。
///
/// 但下拉收口到玻璃菜单之后，触发件绝大多数**不在**任何 chrome scope 里：
/// 列表行里的 `⋮`、播放器工具栏的清晰度/倍速、设置页的
/// [GlassDropdownField]、关注按钮……它们身处滚动容器或视频浮层，本来就上不了
/// lens。于是「跟着触发件走」的结果是：**这些新换的菜单全部静默落回传统档**
/// ——没有折射、没有长按蠕动，除了圆角以外跟旧的 `PopupMenuButton` 看不出
/// 区别。改造做了，用户看到的还是老样子（2026-08-24 的反馈原话：
/// 「我看都没有长按蠕动效果啊」）。
///
/// 面板挂在**根 Overlay** 上，不在任何滚动容器里，那条「lens 不能进滚动容器」
/// 的硬约束对它根本不适用——触发件上不了 lens 不构成面板也上不了的理由。
/// 所以现在无条件给液态档：全站的下拉是同一种面板，与触发件长什么样无关。
GlassBackend panelGlassBackend(BuildContext anchorContext) =>
    debugPanelGlassBackendOverride ?? GlassBackend.easyLens;

/// 测试专用：把 [panelGlassBackend] 的返回值钉在某一档，用完记得置回 null。
///
/// 存在的理由只有一个——**液态面板在测试里 `pumpAndSettle` 不会停**：跟手形变
/// 在手指按住期间会一直跑（这正是它该有的样子），而 Skia 路径下
/// `LiquidGlassView` 还挂着一条按帧抓背景的长跑 ticker。测「按住不放上下划」
/// 那一族交互的用例因此必须先把面板钉回 [GlassBackend.plain]——它们测的是
/// 焦点逻辑，不是材质。
@visibleForTesting
GlassBackend? debugPanelGlassBackendOverride;

/// 给子树指定玻璃后端（见文件头）。
///
/// 它只影响**本子树里的 `GlassSurface`**。挂在根 Overlay 上的浮层（菜单、
/// 弹窗、toast）读不到页面这边的 scope，得由调用方在打开那一刻就地取样、
/// 再在浮层外面重新供上——`showGlassMenu` / `CompactSubscriptionDropdown`
/// 都是这么做的。
class LiquidGlassScope extends InheritedWidget {
  const LiquidGlassScope({
    super.key,
    required this.backend,
    required super.child,
  });

  /// 本子树的玻璃走哪套后端。传 [GlassBackend.plain] 可以在液态子树里
  /// **局部关掉**（例如某处确实要塞进滚动容器）。
  final GlassBackend backend;

  /// 当前位置的玻璃该用哪套后端。没有祖先 scope 时是传统档。
  static GlassBackend of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<LiquidGlassScope>();
    return scope?.backend ?? GlassBackend.plain;
  }

  @override
  bool updateShouldNotify(LiquidGlassScope oldWidget) =>
      backend != oldWidget.backend;
}

/// 把子树里**并排的几块玻璃收进同一层**，靠得够近时边缘互相吞并（metaball）。
///
/// # 这是「液态」的第九个原语：融合
///
/// 前八个原语（见 `glass_morph.dart` 的词汇表）讲的都是**一块**玻璃自己怎么
/// 变；这一个讲的是**两块**玻璃之间的关系。iOS 26 的液态玻璃里，相邻的两块
/// 玻璃不是各画各的：一块被按住拖向另一块时，两者之间会先长出一段液面颈部，
/// 再合成一坨，松手又分开——就像两滴水珠。
///
/// 全 App 第一处有这个效果的是**浮动底栏**（`GlassFloatingTabBar`）：长按右侧
/// 搜索圆钮往左拖，圆钮会被拽长并与左边的栏目胶囊融在一起。那是包里
/// `GlassTabBar.bottom` 自带的，不是我们做的。2026-08-23 用户指出 header 上
/// 「头像圆钮往右拖到分段胶囊上却没有融合」——同一套材质语言，两处却不一致。
/// 本类就是把底栏那份能力提出来，供任何一行 chrome 使用。
///
/// # 怎么用
///
/// 把**这一行**（不是整页）包起来即可，里头的 [GlassSurface] 会自动加入：
///
/// ```dart
/// GlassBlendGroup(
///   child: Row(children: [
///     IdentityAvatarButton(),        // ← 会融合
///     SizedBox(width: 8),
///     GlassCapsuleMorph(child: ...), // ← 会融合
///     SizedBox(width: 8),
///     GlassButtonGroup(children: [...]), // ← 会融合
///   ]),
/// )
/// ```
///
/// 页面一般**不需要自己写**：`GlassHeaderOverlay` 已经替所有 `liquid: true`
/// 的 header 行包好了（见 `GlassHeaderOverlay.blendHeader`）。
///
/// # 只吃最外一层：嵌套玻璃不参与
///
/// 加入融合的那块玻璃会给自己的 child **关掉**这个标记（[exclude]），所以
/// 胶囊**里头**的玻璃（分段控件那条果冻指示器、下拉板）照旧各自成层，不会
/// 和自己的外壳融成一坨——那读起来会是「滑块把胶囊吃了」。
///
/// ## ⚠️ 但「挡在组外」≠「不受影响」：嵌套的镜头会突然有东西可折射
///
/// 被 [exclude] 挡住的子树仍然长在融合层的 `LiquidGlassLayer` / `BackdropGroup`
/// 里，**身下的像素变了**——从「一块平坦的玻璃色」变成「折射过的输出」。对普通
/// 玻璃无所谓；对**嵌套的折射镜头**是可见的行为变化：原来在这片近乎纯白的
/// header 背景上什么都显不出来、被当成良性无效的透镜，会忽然显形。
///
/// 2026-08-23 用户报的「切 tab 时 focus 药丸下面多出一层透明玻璃」正是这一条
/// （分段控件的果冻透镜）。所以嵌套镜头要自己判断——用 [isInside] 而不是
/// [isJoinable]，见 `glass_segmented_control.dart` 里 `_buildJellyStack` 上的
/// 那段。目前全仓库只有那一处嵌套镜头。
///
/// # ⚠️ 融合的代价：同一层玻璃只有一份材质
///
/// 融合的实现是「一个 `LiquidGlassLayer` + 一次 SDF 平滑并集」，所以层里所有
/// 形状**共用同一份 `LiquidGlassSettings`**（色调 / 厚度 / 投影）。落到调用点
/// 上有两条实在的后果：
///
///   1. **按下时的底色加深没有了**。[GlassSurface] 那条 `pressed` 底色过渡在
///      融合态下无效——按下反馈只剩跟手形变（拉伸 + 1.05 呼吸 + 指尖高光），
///      而那几项本来就是这一档的主要反馈，不算丢东西。
///   2. **[GlassSurface.materialize]（材质淡入）无效**。要做材质淡入的那块
///      玻璃必须留在自己的层里——把它挪出融合组，或给外层传
///      `GlassBlendGroup(enabled: false)`。debug 下有 assert 盯着。
///
/// 换来的是：整行只采样一次背景（原来三块玻璃是三次），投影也从三条各自的
/// 变成融合后轮廓的一条。
///
/// # 只在 [GlassBackend.liquidWidgets] 档生效
///
/// 融合是这套 shader 的能力（`LiquidGlassBlendGroup` + 平滑并集），传统档没有
/// 背景采样、easy 档的 lens 各自为政。另外两档下本类是**纯透传**，一个 widget
/// 都不多建。非 Impeller 环境（Skia / Web）由包自己降级成各画各的。
class GlassBlendGroup extends StatelessWidget {
  const GlassBlendGroup({
    super.key,
    required this.child,
    this.blend = GlassTokens.chromeBlend,
    this.clipExpansion = GlassTokens.chromeBlendClipExpansion,
    this.enabled = true,
  });

  final Widget child;

  /// 两块形状开始互相吞并的距离，见 [GlassTokens.chromeBlend]。
  final double blend;

  /// 裁剪外扩，见 [GlassTokens.chromeBlendClipExpansion]。
  final EdgeInsets clipExpansion;

  /// 置 false 时整只透传（连标记都不供），子树里的玻璃各自成层。
  /// 子树里有玻璃要做 [GlassSurface.materialize] 淡入时用得上。
  final bool enabled;

  /// 当前位置是否处在一个**可加入**的融合组里。由 [LiquidWidgetsGlassBox] 调用。
  static bool isJoinable(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_GlassBlendScope>()
          ?.joinable ??
      false;

  /// 当前位置是否**在某个融合层底下**——包括已被 [exclude] 挡在组外的子树。
  ///
  /// 与 [isJoinable] 的差别正是「挡在组外」那一层：那些玻璃不参与吞并，但它们
  /// 仍然长在融合层的 `LiquidGlassLayer` / `BackdropGroup` 里，**身下的像素变了**。
  /// 对普通玻璃无所谓，对**嵌套的折射镜头**要命——见
  /// `glass_segmented_control.dart` 里果冻指示器那段。
  static bool isInside(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GlassBlendScope>() != null;

  /// 把 [child] 挡在融合组之外（已加入的那块玻璃给自己的内容用）。
  static Widget exclude({required Widget child}) =>
      _GlassBlendScope(joinable: false, child: child);

  @override
  Widget build(BuildContext context) {
    if (!enabled ||
        LiquidGlassScope.of(context) != GlassBackend.liquidWidgets) {
      return child;
    }
    final cs = Theme.of(context).colorScheme;
    return lgw.AdaptiveLiquidGlassLayer(
      quality: lgw.GlassQuality.premium,
      blendAmount: blend,
      clipExpansion: clipExpansion,
      // 层里所有形状共用这一份（见类注释里那条代价）。取值与单块玻璃
      // 完全一致，融合前后材质不该有肉眼差别。
      settings: GlassTokens.widgetsGlass(cs, tint: GlassTokens.widgetsTint(cs)),
      child: _GlassBlendScope(joinable: true, child: child),
    );
  }
}

/// 「此处的玻璃该不该加入上面那层融合组」。[GlassBlendGroup] 供 true，
/// 已加入的玻璃给自己的内容供 false。
class _GlassBlendScope extends InheritedWidget {
  const _GlassBlendScope({required this.joinable, required super.child});

  final bool joinable;

  @override
  bool updateShouldNotify(_GlassBlendScope oldWidget) =>
      joinable != oldWidget.joinable;
}

/// 折射透镜版的玻璃体：[GlassSurface] 在液态档下画的就是这个。
///
/// 尺寸语义与传统档的 `AnimatedContainer` 完全一致（[height] 紧约束、[width]
/// 为 null 时按内容收缩、[circle] 取正方），所以两档之间切换不会动布局。
///
/// 有三件事是 lens 自己做掉的、这里不再重复：
///   - **裁切**：lens 会按自身形状裁 child，传统档的 `clipContent` 在这里恒成立。
///   - **描边**：shader 画的边缘光带，不再有 `Border.all` 那 0.6px 的内缩。
///   - **投影**：走 `appearance.shadow`，它长在形变盒内，按下会跟着一起动。
class LiquidGlassBox extends StatelessWidget {
  const LiquidGlassBox({
    super.key,
    required this.child,
    this.height = GlassTokens.pillHeight,
    this.width,
    this.circle = false,
    this.cornerRadius,
    this.pressed = false,
    this.elevated = true,
    this.touchFlex = false,
    this.materialize = 1.0,
  });

  final Widget child;

  /// 为 null 表示按内容自适应高度（见 [GlassSurface.height]）。
  final double? height;

  final double? width;
  final bool circle;

  /// 圆角半径；为 null 时取 [height] / 2（即胶囊）。[circle] 为真时忽略。
  final double? cornerRadius;

  final bool pressed;
  final bool elevated;

  /// 是否接入 [GlassTokens.liquidFlex]——按住并拖动时玻璃跟手拉伸/回弹
  /// （liquid_glass_easy 的 `LiquidGlassTouch`），而不只是 [GlassPressable]
  /// 那层 0.96 缩放。默认 false：`touch` 传 null 时 lens 完全零成本
  /// （不建 `Listener`、不建 ticker），不该让每块玻璃都白白挂上手势监听。
  ///
  /// ⚠️ 只能用在**尺寸已经钉死**的调用点（[height] / [width] 都非 null，
  /// 或 [circle] 给了 [height]）。一旦 `touch` 非 null，lens 会拿收到的
  /// `constraints.biggest` 当形变的 rest size 并自己 `SizedBox.fromSize`——
  /// "抱内容"的玻璃（[height] 或 [width] 为 null，靠父级松/无界约束撑开）
  /// 直接开这个要么被撑满可用空间、要么在无界约束里静默不生效
  /// （见 docs/liquid_glass_easy.md 第 8 节）。
  final bool touchFlex;

  /// 材质的「在场程度」，见 [GlassSurface.materialize]。
  ///
  /// 压的是**色调与投影的透明度**，blur / 描边 / 折射一概不动：那几项一旦被
  /// 压到 0，lens 内部会切换图层结构（blur 层的建与拆），过渡中反而会闪一下。
  /// 所以 0 这一端不是「什么都没有」，而是「一块没有色调、只剩折射与边缘光的
  /// 清玻璃」——用来做几十到一两百毫秒的材质淡入足够，不要拿它当显隐开关。
  final double materialize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double m = materialize.clamp(0.0, 1.0);
    final double radius = circle
        ? height! / 2
        : (cornerRadius ?? (height ?? GlassTokens.pillHeight) / 2);

    // 正圆用 roundedRectangle（圆弧角，半径=半高时就是正圆，也最省）；
    // 胶囊 / 圆角矩形用 continuousRoundedRectangle——半径拉满时它退化成
    // Apple 那种「肩部平滑过渡」的胶囊，比纯圆弧角更贴 iOS 观感。
    final LiquidGlassCornerStyle cornerStyle = circle
        ? LiquidGlassCornerStyle.roundedRectangle
        : LiquidGlassCornerStyle.continuousRoundedRectangle;

    // 按下的底色变化要和传统档同一段过渡（pressDuration / easeOut）。
    // lens 没有 AnimatedContainer 那样的隐式插值，这里自己插。
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        end: pressed
            ? GlassTokens.liquidPressedTint(cs)
            : GlassTokens.liquidTint(cs),
      ),
      duration: GlassTokens.pressDuration,
      curve: Curves.easeOut,
      child: child,
      builder: (context, tint, child) {
        // materialize 在 tween **之后**再压一次 alpha：直接把它算进 tween 的
        // end 会让 TweenAnimationBuilder 每帧都被当成「目标变了」而重启，
        // 120ms 的按压过渡反过来把材质淡入拖成一条追不上的尾巴。
        final Color base = tint ?? GlassTokens.liquidTint(cs);
        final Color color = m >= 1 ? base : base.withValues(alpha: base.a * m);
        Widget lens = SizedBox(
          height: height,
          width: circle ? height : width,
          child: LiquidGlassLens(
            style: LiquidGlassStyle(
              shape: LiquidGlassShape(
                cornerStyle: cornerStyle,
                cornerRadius: radius,
                borderWidth: GlassTokens.liquidBorderWidth,
                borderType: GlassTokens.liquidBorderType,
              ),
              appearance: LiquidGlassAppearance(
                color: color,
                blur: GlassTokens.liquidBlur,
                saturation: GlassTokens.liquidSaturation,
                shadow: elevated
                    ? GlassTokens.liquidShadow(cs, alphaScale: m)
                    : null,
              ),
              refraction: GlassTokens.liquidRefraction,
            ),
            touch: touchFlex ? GlassTokens.liquidFlex : null,
            child: child,
          ),
        );
        // ⛔ 不再叠外层 DecoratedBox 投影：`LiquidGlassAppearance.shadow`
        // 上面已经喂了 [GlassTokens.liquidShadow]，那是包自带的接触阴影环
        // （随形变一起胀缩），[elevated] 已经在那一路生效。这里再套一层
        // `boxShadow: GlassTokens.shadow(...)` 曾经是货真价实的双重投影——
        // 两条阴影同时画在同一圈轮廓上，读起来自然「特别大」。
        return lens;
      },
    );
  }
}

/// `liquid_glass_widgets` 版的玻璃体：[GlassSurface] 在
/// [GlassBackend.liquidWidgets] 档下画的就是这个。
///
/// 与 [LiquidGlassBox] **构造参数一一对应**，尺寸语义也完全一致（[height]
/// 紧约束、[width] 为 null 时按内容收缩、[circle] 取正方），所以三档之间切换
/// 不会动布局——这是「换材质不换尺寸」这条规矩的落点。
///
/// 与 easy 档的实在差别只有三处，其余取值都刻意对齐（见
/// [GlassTokens.widgetsGlass]）：
///   1. **有 Skia/Web 回退链**：`AdaptiveGlass` 会依次退到 lightweight shader
///      和磨砂，Windows/Linux 上不会开天窗（easy 档也有 `_skia` 变体，
///      但这一档的回退是包自己按渲染后端选的，不用我们操心）。
///   2. **投影只在浅色下画**（他们照 iOS 26 的口径，深色背景本来就吃掉投影）。
///      我们照给 [GlassTokens.shadow]，深色下由他们自己跳过。
///   3. **淡入走 `visibility` 而不是压 alpha**：那是这套 shader 自带的通道，
///      同时缩放厚度与色调，比我们在外面调色更接近「玻璃在长出来」。
///
/// 另外这一档独有**融合**：处在 [GlassBlendGroup] 里时本类改走 grouped
/// （`useOwnLayer: false`），与同层的邻居互相吞并；代价是层内共用一份材质，
/// [pressed] 与 [materialize] 在那一支下无效，见 [GlassBlendGroup]。
class LiquidWidgetsGlassBox extends StatelessWidget {
  const LiquidWidgetsGlassBox({
    super.key,
    required this.child,
    this.height = GlassTokens.pillHeight,
    this.width,
    this.circle = false,
    this.cornerRadius,
    this.pressed = false,
    this.elevated = true,
    this.interactive = false,
    this.materialize = 1.0,
  });

  final Widget child;

  /// 为 null 表示按内容自适应高度（见 [GlassSurface.height]）。
  final double? height;

  final double? width;
  final bool circle;

  /// 圆角半径；为 null 时取 [height] / 2（即胶囊）。[circle] 为真时忽略。
  final double? cornerRadius;

  final bool pressed;
  final bool elevated;

  /// 跟手形变：**按住并拖动时整只玻璃跟着手指走、松手弹回**，另带一下按压
  /// 膨胀与指尖处的方向性高光。与 [LiquidGlassBox.touchFlex] 是同一个效果，
  /// 只是换了一套实现。
  ///
  /// 实现上借的是 `GlassButton.custom(style: transparent)`：包里真正干活的
  /// `LiquidStretch` **没有导出**，而 `transparent` 这一档的 `GlassButton`
  /// 恰好「不画任何玻璃、只留 `LiquidStretch` + `GlassGlow`」（见包内
  /// `glass_button.dart` 里 `style == transparent` 那条分支），正好当成一层
  /// 纯形变包装用——玻璃仍由下面那块 `AdaptiveGlass` 自己画，**不会多出
  /// 第二次 backdrop 采样**。
  ///
  /// ⚠️ 别把它当成 `AdaptiveGlass.isInteractive`：那个参数只影响
  /// minimal 档要不要省掉 blur，跟手感没有关系（一开始接错过一次）。
  ///
  /// 与 easy 档不同，这里**没有钉死尺寸的要求**，抱内容的胶囊也能开
  /// （见 [GlassButtonGroup] 里那条分档说明）。
  final bool interactive;

  /// 材质的「在场程度」，见 [GlassSurface.materialize]。这一档喂给他们的
  /// `visibility`——0 端是**真的什么都不剩**（不像 easy 档还留着一层清玻璃）。
  final double materialize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double m = materialize.clamp(0.0, 1.0);
    final double radius = circle
        ? height! / 2
        : (cornerRadius ?? (height ?? GlassTokens.pillHeight) / 2);

    // 形变层会吃掉父级的尺寸约束，这只信使负责把它递到玻璃身上
    // （见 `wrapInteractive` 上那段）。每次 build 新建一只，渲染对象在换新
    // 信使时会把上一份约束接过去，所以重建那一帧不会丢尺寸。
    final _GlassOuterConstraints outerConstraints = _GlassOuterConstraints();

    // 圆用 LiquidOval；胶囊 / 圆角矩形用 superellipse——半径拉满时它就是
    // Apple 那种「肩部平滑过渡」的胶囊，与 easy 档的 continuousRoundedRectangle
    // 是同一个形状语言，换档时轮廓不跳。
    final lgw.LiquidShape shape = circle
        ? const lgw.LiquidOval()
        : lgw.LiquidRoundedSuperellipse(borderRadius: radius);

    /// 只借形变，不借玻璃：transparent 档的 GlassButton 整只跳过
    /// AdaptiveGlass，留下的正好是 LiquidStretch + GlassGlow（见 [interactive]）。
    ///
    /// ⛔ 借来的这层会**把父级给的 min / tight 约束吃掉**：`GlassButton` 内部
    /// 用 `SizedBox(width: null) → Align(widthFactor: 1)` 抱内容，而
    /// `RenderPositionedBox` 是拿 `constraints.loosen()` 去量孩子的——外面
    /// `ConstrainedBox(minWidth: 68)` / `Expanded` / `SizedBox(width: x)` 定下
    /// 的尺寸只落在 Align 自己身上，玻璃缩到「贴着文字」的自然宽度，于是
    /// **占位是长条、画出来的玻璃却短一截**。传统档（`AnimatedContainer`）没有
    /// 这一层，一直是老老实实吃 min 的——换档就变形，正好违背
    /// [GlassSurface] 「三档尺寸语义完全一致」那条约定。
    ///
    /// 2026-08-24 真机报的「宽屏分页栏中间的页码长条变成了圆的、加载光环还留
    /// 在原来那条长条上」就是这一条：光环画在 `GlassSurface` 的外框（68 宽）
    /// 上，玻璃自己却只有文字那么宽。
    ///
    /// 修法是把外层约束**原样递进玻璃那一层**（[_GlassOuterConstraints]），
    /// 而不是一处处给调用点补 `width:`——凡是「抱内容 + 有形变 + 父级给了
    /// 尺寸」的玻璃都吃这一条，逐个补漏必然再漏。
    Widget wrapInteractive(Widget glass) {
      if (!interactive) return glass;
      return _GlassOuterConstraintsSource(
        relay: outerConstraints,
        child: lgw.GlassButton.custom(
          style: lgw.GlassButtonStyle.transparent,
          shape: shape,
          // 这层**只吃形变，不接点击**，给个空实现即可——他们自己的
          // GlassButtonGroup 也是这么用的。所有点击（含「整只玻璃可按」的调用点，
          // 如身份圆钮）都由 `GlassSurface` 塞进 [child] 那一层的 `GlassTapArea`
          // 接住：内容层在这只识别器**里头**，竞技场清算时先赢，顺带把「手指移出
          // 多远才算放弃」那条规矩收在一处（见 `glass_touch.dart`）。
          onTap: () {},
          canRequestFocus: false,
          // 语义节点由外层统一发（[GlassPressable] 的 Semantics），这里不重复
          // 挂一个按钮。
          excludeFromSemantics: true,
          // 别再给我们的玻璃叠一层提亮：色调只有 GlassTokens 一个出处。
          ambientBaseLight: 0,
          // 下面那块玻璃恒是 premium，这里必须报同一档：GlassButton 只在
          // 「premium + 有形变」时才**跳过** RepaintBoundary。不报的话它按主题
          // 默认档（standard）走，会在形变层与玻璃之间垫一层缓存纹理——按住
          // 拉伸时缩放的是那张位图（他们自己注释里写的 bilinear 伪影），融合态
          // 下更麻烦：夹在 layer 与 grouped 形状之间多一层合成。
          quality: lgw.GlassQuality.premium,
          stretch: GlassTokens.widgetsStretch,
          interactionScale: GlassTokens.widgetsInteractionScale,
          resistance: GlassTokens.widgetsStretchResistance,
          child: _GlassOuterConstraintsTarget(
            relay: outerConstraints,
            child: glass,
          ),
        ),
      );
    }

    // ---- 融合态：加入祖先 [GlassBlendGroup] 那一层，与邻居互相吞并 ----
    //
    // 这一支下**材质由 layer 统一供给**，`settings` 只是个占位常量（包里
    // `AdaptiveGlass.grouped` 也是这么传的），所以 [pressed] 的底色过渡和
    // [materialize] 在这里都无效——代价与理由见 [GlassBlendGroup] 的类注释。
    if (GlassBlendGroup.isJoinable(context)) {
      assert(
        m >= 1,
        'GlassSurface.materialize 在融合组里无效（同一层玻璃只有一份材质）。'
        '要做材质淡入请把这块玻璃移出融合组，或给外层传 '
        'GlassBlendGroup(enabled: false)。',
      );
      return wrapInteractive(
        _GlassRim(
          shape: shape,
          materialize: 1,
          child: SizedBox(
            height: height,
            width: circle ? height : width,
            child: lgw.AdaptiveGlass(
              shape: shape,
              quality: lgw.GlassQuality.premium,
              // 占位：grouped 下真正生效的是祖先 layer 的那一份。
              settings: const lgw.LiquidGlassSettings(),
              useOwnLayer: false,
              allowElevation: elevated,
              // 只吃最外一层：胶囊**里头**的玻璃（果冻指示器等）不该和自己的
              // 外壳融成一坨。
              child: GlassBlendGroup.exclude(child: child),
            ),
          ),
        ),
      );
    }

    // 按下的底色变化要和另外两档同一段过渡（pressDuration / easeOut）。
    // 他们的 glass 没有 AnimatedContainer 那样的隐式插值，这里自己插。
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        end: pressed
            ? GlassTokens.widgetsPressedTint(cs)
            : GlassTokens.widgetsTint(cs),
      ),
      duration: GlassTokens.pressDuration,
      curve: Curves.easeOut,
      child: child,
      builder: (context, tint, child) {
        final Widget glass = _GlassRim(
          shape: shape,
          materialize: m,
          child: SizedBox(
            height: height,
            width: circle ? height : width,
            child: lgw.AdaptiveGlass(
              shape: shape,
              // premium 才有完整的 SDF 折射与高光——正是这一档的存在理由。
              // 非 Impeller 环境由 AdaptiveGlass 自己降级，不用我们判断。
              quality: lgw.GlassQuality.premium,
              settings: GlassTokens.widgetsGlass(
                cs,
                tint: tint ?? GlassTokens.widgetsTint(cs),
                materialize: m,
                elevated: elevated,
              ),
              allowElevation: elevated,
              child: child!,
            ),
          ),
        );
        Widget result = wrapInteractive(glass);
        // `widgetsGlass()` 已经把 `shadowElevation` 喂给 AdaptiveGlass 自己的
        // 投影通道，但那条通道**只在浅色模式画**（深色背景吃掉投影是 iOS 26
        // 的口径，包自己在深色下会跳过）。这里补的就是那条缺口——只在深色
        // 模式叠一层手动投影，浅色模式不再叠：两边都画曾经是双重投影，
        // 也是「阴影特别大」的另一个根因（跟 [LiquidGlassBox] 那条是同一个
        // 模式，见其注释）。
        if (elevated && cs.brightness == Brightness.dark) {
          result = DecoratedBox(
            decoration: BoxDecoration(
              shape: circle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: circle ? null : BorderRadius.circular(radius),
              boxShadow: GlassTokens.shadow(cs, alphaScale: m),
            ),
            child: result,
          );
        }
        return result;
      },
    );
  }
}

/// 给「抱内容、宽度会随外部状态过渡」的液态玻璃接入跟手形变，同时避开
/// [LiquidGlassBox.touchFlex] 的钉死尺寸要求。
///
/// touch 需要一个已经量出来的精确尺寸；但像 [GlassButtonGroup] 这样的胶囊，
/// 宽度会在按钮增删时经历一轮自己的过渡动画（[GlassGroupSlot] 的收放 +
/// 外壳的 `AnimatedSize`，两套时序还刻意错开半拍，见 `glass_morph.dart`），
/// 没法用一个公式实时算出"此刻正确的宽度"去跟手。
///
/// 这里换一个策略：**只在静止态开 touch**。[signature] 变化的瞬间立刻退回
/// [builder] 的自然布局（`lockedSize: null`，与不套这层包装时完全一致，
/// 过渡过程不会有任何尺寸错位）；等尺寸真的**不再变**了，才量一次、钉死
/// 喂给 [builder]。
///
/// ## ⛔ 「静止」必须按帧判，不能拿墙上时钟等
///
/// 本类最初是 `Future.delayed(420ms)` 之后量一次就锁死。那是错的，而且不是
/// 偶发——2026-08-23 在 OnePlus Pad 上稳定复现：
///
/// > 进编辑模式时按钮组多冒出一枚键，胶囊被**永久**钉在过渡途中的宽度上，
/// > 里头的 `Row` 从此溢出，末尾那枚「更多」整只被裁掉，debug 下还常驻一条
/// > 黄黑 OVERFLOWED 条；退出编辑模式则反过来钉得太宽，
/// > `AnimatedSize(alignment: centerRight)` 把富余留在左边——**最左侧凭空多出
/// > 一个按钮大小的空位**。两个症状同一个根因。
///
/// 420ms 压根不够：槽位（`GlassGroupSlot`）自己要 300ms 展开，外壳的
/// `AnimatedSize` 还刻意「慢半拍」再追 340ms，合起来 600ms 打底，掉帧或
/// `timeDilation` 下更长。而一旦锁在半路，`GlassSurface` 就给 `Row` 发了一个
/// 比它自然宽度还小的紧约束——那是**不可恢复**的：约束紧了之后再也量不回
/// 真实宽度，只能一直溢出。
///
/// 所以现在改成**逐帧探尺寸**：连续 [_settleStableFrames] 帧宽高都不再变
/// （容差 [_settleEpsilon]）才认定静止并锁死；探到 [_settleMaxFrames] 帧还没
/// 稳下来就**放弃上锁**（停在自然布局、不开 touch），宁可少一点跟手质感，
/// 也不要一个钉错了就再也回不来的尺寸。
///
/// 注意 `addPostFrameCallback` 自己**不会催帧**：动画停下来之后没人再画，
/// 回调就再也不来了，所以每轮探测都要显式 `scheduleFrame()`。
class LiquidGlassSettledTouch extends StatefulWidget {
  const LiquidGlassSettledTouch({
    super.key,
    required this.signature,
    required this.builder,
  });

  /// 影响内容宽高的外部状态摘要（例如 `'$isWide|$isMultiSelect'`）；
  /// 与上一次不 `==` 就视为「要重新经历一轮过渡」。
  final Object signature;

  /// `lockedSize` 为 null 表示还没到静止态（或刚开始一轮新过渡）；
  /// 非 null 时是量出来的精确尺寸，这时 [builder] 才应该开 touch。
  final Widget Function(BuildContext context, Size? lockedSize) builder;

  @override
  State<LiquidGlassSettledTouch> createState() =>
      _LiquidGlassSettledTouchState();
}

/// 连续这么多帧尺寸不变才算静止。3 帧足以滤掉 `AnimatedSize` 收尾那几个
/// 亚像素抖动，又不至于让上锁拖得太久。
const int _settleStableFrames = 3;

/// 探到这么多帧还没稳下来就放弃上锁（约 4 秒 @60fps）。兜底用，正常路径
/// 一次过渡几十帧就到了。
const int _settleMaxFrames = 240;

/// 尺寸「没变」的容差：亚像素级的抖动不该重置计数。
const double _settleEpsilon = 0.1;

class _LiquidGlassSettledTouchState extends State<LiquidGlassSettledTouch> {
  final GlobalKey _contentKey = GlobalKey();
  Size? _lockedSize;
  int _settleToken = 0;

  /// 上一帧探到的尺寸与已经连续稳定的帧数。
  Size? _probed;
  int _stableFrames = 0;
  int _probedFrames = 0;

  @override
  void initState() {
    super.initState();
    _scheduleSettle();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassSettledTouch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.signature != widget.signature) {
      setState(() => _lockedSize = null);
      _scheduleSettle();
    }
  }

  void _scheduleSettle() {
    _probed = null;
    _stableFrames = 0;
    _probedFrames = 0;
    _probeNextFrame(++_settleToken);
  }

  void _probeNextFrame(int token) {
    final WidgetsBinding binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) => _probe(token));
    // 关键：addPostFrameCallback 不催帧。过渡跑完之后就没有下一帧了，
    // 不显式要一帧的话探测会静默停在最后一次动画帧上。
    binding.scheduleFrame();
  }

  void _probe(int token) {
    if (!mounted || token != _settleToken) return;
    if (++_probedFrames > _settleMaxFrames) return; // 放弃上锁，停在自然布局
    final RenderObject? box = _contentKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      _probeNextFrame(token);
      return;
    }
    final Size size = box.size;
    final Size? previous = _probed;
    _probed = size;
    final bool same =
        previous != null &&
        (size.width - previous.width).abs() < _settleEpsilon &&
        (size.height - previous.height).abs() < _settleEpsilon;
    _stableFrames = same ? _stableFrames + 1 : 0;
    if (_stableFrames >= _settleStableFrames) {
      setState(() => _lockedSize = size);
      return;
    }
    _probeNextFrame(token);
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _contentKey,
      child: widget.builder(context, _lockedSize),
    );
  }
}

/// 预热 shader。
///
/// lens 的 shader 是**异步加载**的：没加载完之前，全 App 第一块玻璃会先渲染成
/// 磨砂（`BackdropFilter` + 色调），加载完再 `setState` 切成折射。不预热的话
/// 用户在冷启动首屏就能看见这一下材质跳变。放在启动流程里 fire-and-forget 即可，
/// 失败了也只是退回磨砂，不该阻塞启动。
Future<void> warmUpLiquidGlassShaders() async {
  try {
    await LiquidGlassShaders.ensureLoaded();
  } catch (_) {
    // shader 不可用（构建损坏 / 不支持的环境）：玻璃停在磨砂档，功能不受影响。
  }
  try {
    await lgw.LiquidGlassWidgets.initialize(
      // 他们的性能监视器在 debug/profile 下盯着光栅耗时，超预算就抛一条
      // FlutterError。本 App 同屏常有视频解码，光栅耗时长是常态，这条几乎
      // 必然是误报——关掉，别把真正的报错淹了。release 下它本来就不启用。
      enablePerformanceMonitor: false,
    );
  } catch (_) {
    // 同上：预热失败只是第一块玻璃会晚一点成形，不该影响启动。
  }
}

/// 玻璃的**边缘细线**：上沿一条亮高光、左右与下沿一条暗实线。
///
/// 为什么要自己画，而不是把 shader 的边缘光调亮：见
/// [GlassTokens.widgetsRimGradient] 的注释——shader 那圈光从背景取色，白底
/// 页面上取到的是白，压在同样发白的玻璃上等于没画。这条线是唯一在**任何**
/// 背景下都读得出「这里有一块玻璃、它有边」的东西。
///
/// 形状直接取自同一个 [lgw.LiquidShape]（它本身是 `OutlinedBorder`），所以
/// 线与 shader 画的轮廓严丝合缝，不会出现「描边比玻璃大一圈」。
///
/// ⚠️ 融合态（[GlassBlendGroup]）下每块玻璃仍画自己那条线：静止态两块本来就
/// 分开，读起来没问题；只有被按住往邻居拖、两块真的长出液面颈部的那一瞬间，
/// 两条线会在颈部交叉。要跟着 metaball 一起融，线就得由 shader 自己画——
/// 而 shader 那圈光正是白底上读不出来的那一条（见上）。这里选了「静止态正确」。
/// 把「形变层外面的约束」递给「形变层里面的玻璃」的一只信使。
///
/// # 为什么需要它
///
/// [LiquidWidgetsGlassBox] 的跟手形变是借 `GlassButton.custom(transparent)`
/// 实现的（见 `wrapInteractive`），而那只 widget 内部是
/// `SizedBox(width: null) → Align(widthFactor: 1)`：`RenderPositionedBox` 拿
/// `constraints.loosen()` 去量孩子，**父级定下的 min / tight 尺寸只落在 Align
/// 自己身上，传不到玻璃**。于是「抱内容 + 有形变」的玻璃在
/// `ConstrainedBox(minWidth: …)` / `Expanded` / `SizedBox(width: …)` 底下会缩成
/// 贴着内容的自然宽度——占位是长条，画出来的玻璃却短一截。
///
/// 传统档（`AnimatedContainer`）从来都是老实吃 min 的，所以这是**换档才有的
/// 形变**，违背 [GlassSurface] 「三档尺寸语义完全一致」那条约定。
///
/// # 怎么做的
///
/// [_GlassOuterConstraintsSource] 挂在形变层**外面**，布局时把自己收到的约束
/// 记下来；[_GlassOuterConstraintsTarget] 挂在形变层**里面**（紧贴玻璃），
/// 布局时把记下来的 min 补回自己的约束里。两者靠同一只信使对象通信——布局是
/// 深度优先，外层必然先于内层量到，所以内层读到的永远是本帧的值。
///
/// 用渲染对象而不是 `LayoutBuilder`：`LayoutBuilder` 不支持内在尺寸计算，
/// 而玻璃件确实会长在 `IntrinsicHeight` 底下（侧边导航栏的 trailing 就是），
/// 那会直接抛。
class _GlassOuterConstraints {
  BoxConstraints? value;
  _RenderGlassOuterConstraintsTarget? target;

  void record(BoxConstraints constraints) {
    if (value == constraints) return;
    value = constraints;
    // 中间隔着 Align 的 `loosen()`：外层约束变了，内层收到的约束可能一模一样，
    // 不主动叫醒它就会沿用上一帧的尺寸。这一下在 `invokeLayoutCallback` 里发，
    // 是布局期间允许改动子树的唯一合法姿势。
    target?.markNeedsLayout();
  }

  /// 换新信使时把上一份约束接过来：widget 每帧重建，但渲染对象是持久的，
  /// 内层不一定会跟着重新布局。
  void adoptFrom(_GlassOuterConstraints old) {
    value ??= old.value;
  }
}

class _GlassOuterConstraintsSource extends SingleChildRenderObjectWidget {
  const _GlassOuterConstraintsSource({
    required this.relay,
    required super.child,
  });

  final _GlassOuterConstraints relay;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderGlassOuterConstraintsSource(relay);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderGlassOuterConstraintsSource renderObject,
  ) {
    renderObject.relay = relay;
  }
}

class _RenderGlassOuterConstraintsSource extends RenderProxyBox {
  _RenderGlassOuterConstraintsSource(this._relay);

  _GlassOuterConstraints _relay;

  set relay(_GlassOuterConstraints value) {
    if (identical(_relay, value)) return;
    value.adoptFrom(_relay);
    _relay = value;
  }

  @override
  void performLayout() {
    // 记录这一下可能要叫醒内层（见 [_GlassOuterConstraints.record]），所以得
    // 走 invokeLayoutCallback——布局期间改动子树只有这一个合法入口。
    invokeLayoutCallback<BoxConstraints>(_relay.record);
    super.performLayout();
  }
}

class _GlassOuterConstraintsTarget extends SingleChildRenderObjectWidget {
  const _GlassOuterConstraintsTarget({
    required this.relay,
    required super.child,
  });

  final _GlassOuterConstraints relay;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderGlassOuterConstraintsTarget(relay);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderGlassOuterConstraintsTarget renderObject,
  ) {
    renderObject.relay = relay;
  }
}

class _RenderGlassOuterConstraintsTarget extends RenderProxyBox {
  _RenderGlassOuterConstraintsTarget(this._relay) {
    _relay.target = this;
  }

  _GlassOuterConstraints _relay;

  set relay(_GlassOuterConstraints value) {
    if (identical(_relay, value)) {
      _relay.target = this;
      return;
    }
    value.adoptFrom(_relay);
    if (identical(_relay.target, this)) _relay.target = null;
    _relay = value;
    _relay.target = this;
    markNeedsLayout();
  }

  @override
  void detach() {
    if (identical(_relay.target, this)) _relay.target = null;
    super.detach();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _relay.target = this;
  }

  /// 把外层的 min 补回来。只补 min：max 一路是原样传下来的（`loosen()` 只动
  /// 下界），补过头会把玻璃撑出父级。
  BoxConstraints _withOuterMinimums(BoxConstraints constraints) {
    final BoxConstraints? outer = _relay.value;
    if (outer == null) return constraints;
    final double outerMinWidth = outer.minWidth.isFinite ? outer.minWidth : 0;
    final double outerMinHeight = outer.minHeight.isFinite
        ? outer.minHeight
        : 0;
    final double minWidth = clampDouble(
      outerMinWidth,
      constraints.minWidth,
      constraints.maxWidth,
    );
    final double minHeight = clampDouble(
      outerMinHeight,
      constraints.minHeight,
      constraints.maxHeight,
    );
    if (minWidth == constraints.minWidth &&
        minHeight == constraints.minHeight) {
      return constraints;
    }
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: constraints.maxWidth,
      minHeight: minHeight,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) {
      size = _withOuterMinimums(constraints).smallest;
      return;
    }
    child.layout(_withOuterMinimums(constraints), parentUsesSize: true);
    size = constraints.constrain(child.size);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final RenderBox? child = this.child;
    final BoxConstraints inner = _withOuterMinimums(constraints);
    if (child == null) return inner.smallest;
    return constraints.constrain(child.getDryLayout(inner));
  }
}

class _GlassRim extends StatelessWidget {
  const _GlassRim({
    required this.shape,
    required this.materialize,
    required this.child,
  });

  final lgw.LiquidShape shape;
  final double materialize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (materialize <= 0) return child;
    return CustomPaint(
      foregroundPainter: _GlassRimPainter(
        shape: shape,
        gradient: GlassTokens.widgetsRimGradient(cs, alphaScale: materialize),
        width: GlassTokens.widgetsRimWidth,
      ),
      child: child,
    );
  }
}

class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter({
    required this.shape,
    required this.gradient,
    required this.width,
  });

  final lgw.LiquidShape shape;
  final LinearGradient gradient;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final Rect rect = Offset.zero & size;
    final Path path = shape.getOuterPath(rect);
    // 画 2 倍宽再按形状裁掉外半边：线就正好贴在轮廓**内侧**，外缘由裁剪
    // 抗锯齿收口，不会像居中描边那样溢出玻璃半个像素。
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 2
      ..isAntiAlias = true
      ..shader = gradient.createShader(rect);
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassRimPainter old) =>
      old.shape != shape || old.gradient != gradient || old.width != width;
}
