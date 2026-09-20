import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_measured_box.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_picker_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// `showModalBottomSheet` 正文的收口壳。
///
/// 收口前：24 个文件各写一份 `Container(color: Colors.white,
/// borderRadius: BorderRadius.vertical(top: Radius.circular(16)))`
/// 当外壳——`Colors.white` 是硬编码，暗色主题下这些弹窗全是一块刺眼的白板；
/// 圆角、内边距、标题行、底部安全区（[computeSheetBottomInset]）也是各写各的。
///
/// 2026-08-24 给内容接上液态：**面板背景本身不接**（用户明确要求——弹窗/
/// 弹层的壳保持原样，不要变透明玻璃），只给壳里的内容（标题行按钮、动作行）
/// 套一层 [LiquidGlassScope]（钉死 [chromeGlassBackend]，与页面 chrome
/// 同一档）。做法是把 scope 包在 `child`/`builder(...)` 外面、壳自己的
/// `GlassSurface` 调用之外——壳的背景读的是它自己 build 时的祖先 scope
/// （面板挂在根 Navigator 上，天然没有祖先，落回 plain，与收口前一致），
/// 内容里的 `GlassIconButton`/`GlassButtonGroup`/[GlassComposerActions] 等
/// 才会跟着换档、长出液态档的长按蠕动。壳内如果套了
/// `ListView`/`SingleChildScrollView`，**列表 item 本身不能含 `GlassSurface`**
/// （约束见 `liquid_glass_material.dart` 文件头）——本仓库现状是干净的，新增
/// 调用点也要守这条。
class GlassBottomSheet extends StatelessWidget {
  const GlassBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showCloseButton = true,
    this.showDragHandle = true,
    this.maxHeightFactor,
    this.scrollable = false,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 16),
  });

  /// 标题（可选）；不传就没有标题行，只留拖拽把手 + 正文。
  final String? title;

  final Widget child;

  /// 有标题时是否带右侧玻璃关闭圆钮（约定同 [GlassAlertDialog]）。
  final bool showCloseButton;

  /// 顶部拖拽把手（一条短横线，纯装饰，不接手势——`showModalBottomSheet`
  /// 本身已经支持整块下滑关闭，把手只是视觉提示）。
  final bool showDragHandle;

  /// 正文最高不超过屏幕高度的这个比例（超出部分交给 [scrollable] 内部滚动）。
  /// 不传则不限高，由调用方自己控制内容高度。
  final double? maxHeightFactor;

  /// 正文过长时是否允许内部滚动。
  final bool scrollable;

  final EdgeInsetsGeometry padding;

  /// 标题行左右不许贴边的下限——正文常见「不要横向内边距，让 [ListTile]
  /// 自己那圈 16 撑距离」的写法（下载任务「更多」菜单等），但标题行没有那圈
  /// 自带内边距，跟着 [padding] 的横向值一起归零就会贴到弹层边框上。标题行
  /// 因此**不直接吃 [padding] 的横向值**，改吃这个下限与它的较大者——
  /// 正文自己的横向内边距、成因不变。
  static const double _minTitleHorizontalInset = 16;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    Widget body = child;
    if (scrollable) {
      body = SingleChildScrollView(child: body);
    }

    final EdgeInsets resolvedPadding = padding.resolve(
      Directionality.of(context),
    );
    final double titleLeft = resolvedPadding.left < _minTitleHorizontalInset
        ? _minTitleHorizontalInset
        : resolvedPadding.left;
    final double titleRight = resolvedPadding.right < _minTitleHorizontalInset
        ? _minTitleHorizontalInset
        : resolvedPadding.right;

    // 正文的内边距：有标题时顶部已经由标题行自己的间距占掉，这里不再重复。
    final EdgeInsets bodyPadding = EdgeInsets.fromLTRB(
      resolvedPadding.left,
      title != null ? 0 : resolvedPadding.top,
      resolvedPadding.right,
      resolvedPadding.bottom,
    );
    // Flexible 只能直接挂在 Column 底下——Padding 包一层会触发
    // "Incorrect use of ParentDataWidget"，所以内边距得包在 Flexible **里面**。
    final Widget paddedBody = Padding(padding: bodyPadding, child: body);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              titleLeft,
              resolvedPadding.top,
              titleRight,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(title!, style: theme.textTheme.titleLarge),
                ),
                if (showCloseButton) ...[
                  const SizedBox(width: 8),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close),
                    tooltip: t.common.close,
                    onPressed: () => AppService.tryPop(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (maxHeightFactor != null)
          Flexible(child: paddedBody)
        else
          paddedBody,
      ],
    );

    // 底部安全区（导航条/手势条）由壳在**背景里面**让位——不能在壳外面套
    // `Padding`/`SheetBottomSafeArea`：那样壳的不透明 `Material` 只铺到导航条
    // 上沿为止，导航条那条带就只剩下弹层遮罩，看起来像「弹层先隔了一条安全区
    // 才出现」。约定见 [computeSheetBottomInset] 的注释。
    final double bottomInset = computeSheetBottomInset(context);

    return ConstrainedBox(
      // 限高同步加上这条安全区：壳现在把它含在自己身子里，不加的话内容可用
      // 高度会比收口前凭空少一条导航条。
      constraints: maxHeightFactor == null
          ? const BoxConstraints()
          : BoxConstraints(
              maxHeight: math.min(
                screenHeight,
                screenHeight * maxHeightFactor! + bottomInset,
              ),
            ),
      child: _GlassBottomSheetShell(
        showDragHandle: showDragHandle,
        bottomInset: bottomInset,
        child: content,
      ),
    );
  }
}

/// 外壳：圆角顶 + 玻璃材质，替掉各页手写的 `Colors.white` 容器。
///
/// 复用 [GlassSurface]（全 App 唯一的玻璃材质定义处）而不是自己再画一套
/// fill/stroke——顶部单独圆角是 [GlassSurface.borderRadius] 已支持的口子，
/// 液态档要跟进也只用改这一处。
class _GlassBottomSheetShell extends StatelessWidget {
  const _GlassBottomSheetShell({
    required this.child,
    required this.showDragHandle,
    required this.bottomInset,
  });

  final Widget child;
  final bool showDragHandle;

  /// 底部系统安全区（导航条/手势条）高度。加在 [Material] **内部**，
  /// 这样背景一直铺到屏幕底边，只有内容避开导航条。
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 面板背景用不透明的 [GlassTokens.sheetFill]：半透明会把下层被遮的内容
    // 透出来；也不能用 surface——M3 下页面 Scaffold 的背景就是它，弹层会跟
    // 页面完全同色，只剩遮罩能看出层次；也不能直接用 [GlassTokens.fill]——
    // 传统档下弹层里的玻璃卡片（[GlassSettingSection] 一类）吃的正是这个
    // token，外壳跟着同色会把卡片自己那圈半透明「膜」衬没，见该 token 注释。
    // 内部按钮通过 LiquidGlassScope 接入液态档。
    return Material(
      color: GlassTokens.sheetFill(cs),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) ...[
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
          ],
          // 液态档由 [showGlassBottomSheet] 在路由层统一供（见那里的注释），
          // 壳自己不再包——包在壳里的话，自建壳的弹层（表情选择器一类）
          // 就漏掉了。
          // 安全区包在 Flexible **里面**：Flexible 只能直接挂在 Column 底下，
          // 外面再套 Padding 会触发 "Incorrect use of ParentDataWidget"。
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// 打开一块 [GlassBottomSheet]。`backgroundColor: transparent` +
/// `isScrollControlled: true` 是固定搭配（壳自己画背景、自己算高度），
/// 不用在调用点重复传。
///
/// ⭐ 液态档在**这一层**供，不在 [GlassBottomSheet] 壳里：弹层内容不一定用
/// 我们的壳（表情选择器就是自建 `DraggableScrollableSheet` + 自己的
/// `Container`），供在壳里那些就全漏了，里头的新组件会静默落回传统档。
/// 供在路由上，「走了这个入口就一定有档」。壳自己的背景不受影响——它画的是
/// 不透明 `Material`，不是 `GlassSurface`。
Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    builder: (context) => RepaintBoundary(
      child: LiquidGlassScope(
        backend: flatGlassBackend(context),
        child: builder(context),
      ),
    ),
  );
}

/// [GlassBottomSheet] 的可拖拽缩放变体。
///
/// [GlassBottomSheet] 是钉死高度（+ 可选内部滚动）的壳，适合表单/选项这类
/// 长度大致可预期的内容。评论列表一类**可能很长、用户会想拖大看更多**的内容
/// 用它并不合适——2026-08-24 之前，这类弹层（评论回复列表、播放器设置面板）
/// 各自手写了一份 `DraggableScrollableSheet` + `Container(color: colorScheme.surface)`
/// 当外壳，和 [GlassBottomSheet] 收编前的裸 `showModalBottomSheet` 是同一个问题：
/// 硬编码底色、圆角、拖拽条、安全区各写一份。
///
/// 这里只收口「壳」（玻璃材质 + 顶部圆角 + 拖拽条 + 安全区），**不**收口标题行——
/// 各处标题行结构差异较大（有的带图标+计数+两枚动作钮，有的只是简单标题+关闭钮），
/// 强行统一反而会丢信息。[builder] 拿到的 `scrollController` 必须接到内容的
/// 可滚动组件上（`ListView(controller: scrollController)` 一类）——它由
/// `DraggableScrollableSheet` 提供，滚动到底部与拖拽变高共用同一条手势链路，
/// 这也是不能直接套 [GlassBottomSheet]（自己接 [SingleChildScrollView]）的原因。
///
/// 用 [showGlassDraggableBottomSheet] 打开。
class GlassDraggableBottomSheet extends StatelessWidget {
  const GlassDraggableBottomSheet({
    super.key,
    required this.builder,
    this.initialChildSize = 0.6,
    this.minChildSize = 0.3,
    this.maxChildSize = 0.92,
    this.snap = false,
    this.handleOverContent = false,
    this.backgroundColor,
  });

  /// 拖拽条那一条占的总高：上留白 8 + 条 4 + 下留白 4。
  ///
  /// [handleOverContent] 为真时，它就是内容顶上要让出的第一段，也是顶部蒙层
  /// 的平台段（恒定不透明那一截，角色等同页面档的状态栏）。
  static const double dragHandleExtent = 16;

  /// 内容构建器，`scrollController` 必须接到正文的可滚动组件上。
  final Widget Function(BuildContext context, ScrollController scrollController)
  builder;

  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  /// 拖拽松手后是否吸附到 [DraggableScrollableSheet] 的 snap 位置。
  final bool snap;

  /// 拖拽条改成**浮在内容之上**的一层，内容铺到它背后。
  ///
  /// 默认 false：拖拽条独占一行，内容从它下面开始（普通弹层的样子）。
  ///
  /// [GlassFloatingHeaderSheet] 这类「内容从 header 背后滚过去」的弹层必须传
  /// true——否则拖拽条那一条既没有蒙层也没有内容经过，看上去是块从弹层里独立
  /// 出来的空带子（2026-09-20 用户报障）。
  final bool handleOverContent;

  /// 外壳面色。不传走 [GlassTokens.sheetFill]（绝大多数弹层）；只有壳底色会
  /// 与自己内容里的控件撞色的那几张弹层才需要指定（见
  /// [GlassTokens.commentSheetFill]）。
  final Color? backgroundColor;

  Widget _buildHandle(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: false,
      snap: snap,
      // 同 [_GlassBottomSheetShell]：只给内容接液态，壳自己的 GlassSurface
      // 留在 LiquidGlassScope 之外，面板背景保持原样；底部安全区也同样让在
      // Material **里面**（壳外面套 Padding 的话，导航条那条带只剩弹层遮罩）。
      builder: (context, scrollController) {
        // 同上：液态档由 [showGlassDraggableBottomSheet] 在路由层供。
        final Widget content = Padding(
          padding: EdgeInsets.only(bottom: computeSheetBottomInset(context)),
          child: builder(context, scrollController),
        );
        return Material(
          // 同 [_GlassBottomSheetShell]：默认走 [GlassTokens.sheetFill]，
          // 既要与页面背景（surface）拉开，也要与弹层里的玻璃卡片
          // （[GlassTokens.fill]）拉开，理由见该 token 注释；
          // [backgroundColor] 是给「壳与自己内容撞色」的弹层留的口子。
          color:
              backgroundColor ??
              GlassTokens.sheetFill(Theme.of(context).colorScheme),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: handleOverContent
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: content),
                    // 拖拽条画在最上层：它身下是内容与蒙层，滚动时内容从它背后
                    // 经过。IgnorePointer 让这一截照常能滑动列表 / 拖拽弹层。
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(child: _buildHandle(context)),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHandle(context),
                    Expanded(child: content),
                  ],
                ),
        );
      },
    );
  }
}

/// 标题行**浮在内容之上**的可拖拽弹层（[GlassDraggableBottomSheet] 的收口变体）。
///
/// # 为什么要有这个收口点
///
/// [GlassDraggableBottomSheet] 只收口了「壳」，标题行留给各调用点自己写，于是
/// 评论弹窗那一族（作者页 / 投稿详情 / 图库详情 / 子回复）各抄了一份
/// `Column[标题 Row, Expanded(列表)]`：标题行与列表**上下分家**，投稿页还自己
/// 补了一条 `Divider` 当分界，另外三处连分界都没有——同一个弹窗四种长相，而
/// 且全都不是液态玻璃改造要的那个样子（内容从玻璃标题行**背后**滚过去）。
///
/// 这里把页面档的 [GlassHeaderOverlay] / 弹窗档的 [GlassPickerDialog] 那一套
/// 搬进可拖拽弹层：
///
/// - 内容铺满整块（含拖拽条背后那一截，见
///   [GlassDraggableBottomSheet.handleOverContent]），用 [bodyBuilder] 收到的
///   `headerExtent` 当 `padding.top` 让出首屏位置（**不要**在外面套 `Padding`，
///   否则内容滚不到标题行背后）；
/// - 标题行与内容之间只有一层 [EdgeFadeScrim]，配方与「接着看」抽屉
///   （[GlassSideDrawerShell]）**逐字相同**：平台段只盖顶上那一小截
///   （抽屉是状态栏，弹层是拖拽条），整条标题行都在 smoothstep 的淡出段里。
///   ⛔ 别把平台段设成整行标题的高度——那样 header 每一行的不透明度完全一样，
///   渐变只发生在 header 之外那十几像素里，观感就是硬切了一刀（见 EdgeFadeScrim
///   文档里 2026-08-26 的那次报障）；
/// - 标题行高度**实测**（[GlassMeasuredBox]），字号放大 / 换语言 / 加减动作钮
///   都不用回来改常数（成因见 [GlassPickerDialog] 类文档）。
class GlassFloatingHeaderSheet extends StatefulWidget {
  const GlassFloatingHeaderSheet({
    super.key,
    required this.title,
    required this.bodyBuilder,
    this.leading,
    this.actions = const <Widget>[],
    this.showCloseButton = true,
    this.onClose,
    this.initialChildSize = 0.75,
    this.minChildSize = 0.2,
    this.maxChildSize = 0.92,
    this.snap = true,
    this.backgroundColor,
  });

  /// 标题行横向留白——内容区也用这个数，别一处 8 一处 16。
  static const double hPadding = 16;

  /// 标题行上方 / 下方留白。上方那一段从拖拽条底缘算起，所以比
  /// [GlassPickerDialog.titleTopPadding] 收一档。
  static const double titleTopPadding = 8;
  static const double titleBottomGap = 4;

  /// 标题行底缘与内容首屏之间的呼吸位——这一段必须真的空出来。
  static const double tailSpacing = 8;

  final String title;

  /// 标题文字左边的小图标（子回复弹层用）。
  final Widget? leading;

  /// 标题行右侧、关闭钮左边的动作件（玻璃圆钮 / 玻璃胶囊组），按 8 的间距排开
  /// ——8 是 [GlassTokens.chromeBlend] 标定的「刚好不粘连、拖近才融合」的距离。
  final List<Widget> actions;

  final bool showCloseButton;

  /// 关闭钮动作，默认 pop 掉本弹层。
  final VoidCallback? onClose;

  /// 内容构建器。`scrollController` 必须接到内容的可滚动组件上（同
  /// [GlassDraggableBottomSheet]）；`headerExtent` 是**实测**的顶部总高
  /// （拖拽条 + 标题行 + [tailSpacing]），直接当滚动视图的 `padding.top` 用。
  final Widget Function(
    BuildContext context,
    ScrollController scrollController,
    double headerExtent,
  )
  bodyBuilder;

  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool snap;

  /// 外壳面色，透传给 [GlassDraggableBottomSheet]（不传 = 默认弹层底色）。
  final Color? backgroundColor;

  @override
  State<GlassFloatingHeaderSheet> createState() =>
      _GlassFloatingHeaderSheetState();
}

class _GlassFloatingHeaderSheetState extends State<GlassFloatingHeaderSheet> {
  /// 首帧用预估值，布局跑完立刻换成实测值（默认字号下两者相等，看不到跳变）。
  late double _titleRowHeight = _estimatedTitleRowHeight;

  double get _estimatedTitleRowHeight =>
      GlassFloatingHeaderSheet.titleTopPadding +
      GlassTokens.pillHeight +
      GlassFloatingHeaderSheet.titleBottomGap;

  void _onTitleRowMeasured(Size size) {
    if ((size.height - _titleRowHeight).abs() < 0.5) return;
    setState(() => _titleRowHeight = size.height);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    // 顶部三段：拖拽条 / 标题行 / 呼吸位。内容从最上面就开始铺，整段都是它
    // 要让出的 padding.top。
    const double handleExtent = GlassDraggableBottomSheet.dragHandleExtent;
    final double headerExtent =
        handleExtent + _titleRowHeight + GlassFloatingHeaderSheet.tailSpacing;

    return GlassDraggableBottomSheet(
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      snap: widget.snap,
      backgroundColor: widget.backgroundColor,
      // 拖拽条浮在内容之上：内容与蒙层都要铺到它背后，否则那一条是块独立空带。
      handleOverContent: true,
      builder: (context, scrollController) => Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: widget.bodyBuilder(context, scrollController, headerExtent),
          ),
          // 平台段只盖拖拽条那一小截（角色同「接着看」抽屉里的状态栏），整条
          // 标题行连同伸进内容区的尾巴都在 smoothstep 的淡出段里。
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: EdgeFadeScrim.headerOverlay(
              headerExtent: headerExtent,
              plateauExtent: handleExtent,
            ),
          ),
          Positioned(
            top: handleExtent,
            left: 0,
            right: 0,
            child: GlassMeasuredBox(
              onSize: _onTitleRowMeasured,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  GlassFloatingHeaderSheet.hPadding,
                  GlassFloatingHeaderSheet.titleTopPadding,
                  GlassFloatingHeaderSheet.hPadding,
                  GlassFloatingHeaderSheet.titleBottomGap,
                ),
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (final action in widget.actions) ...[
                      const SizedBox(width: 8),
                      action,
                    ],
                    if (widget.showCloseButton) ...[
                      const SizedBox(width: 8),
                      GlassIconButton(
                        standalone: true,
                        icon: const Icon(Icons.close),
                        tooltip: t.common.close,
                        onPressed:
                            widget.onClose ?? () => Navigator.pop(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 打开一块 [GlassDraggableBottomSheet]。同 [showGlassBottomSheet]，
/// `backgroundColor: transparent` + `isScrollControlled: true` 固定搭配，
/// 液态档同样供在这一层。
Future<T?> showGlassDraggableBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    builder: (context) => RepaintBoundary(
      child: LiquidGlassScope(
        backend: flatGlassBackend(context),
        child: builder(context),
      ),
    ),
  );
}
