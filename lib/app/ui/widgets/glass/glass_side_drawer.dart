import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_measured_box.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// header 行的**预估**占位（不含状态栏）：上边距 16 + 玻璃圆钮 44 + 下留白 4。
///
/// 只用于首帧，真实高度由 [GlassMeasuredBox] 量出来——原来这里还按副标题
/// 额外加 18，而实测带副标题的标题行仍是 44（标题 28 + 副标题 16 正好填满
/// 圆钮那 44），于是有副标题的抽屉白多出 18px 的空档。
const double _kHeaderExtentEstimate = 16 + GlassTokens.pillHeight + 4;

/// 抽屉里 header 与内容共用的横向留白。header 原来是「左 20 右 12」、内容是
/// 16，三条线各走各的；对齐到同一个数。
const double _kDrawerHPadding = 16;

/// header 底缘与内容之间的呼吸位。
const double _kDrawerHeaderTailSpacing = 8;

/// 宽屏（PC / 平板）下侧边抽屉的固定宽度。
///
/// 380 是量出来的：筛选抽屉里三档评级的 Select、并排的年/月两只 Select、
/// 已保存列表的「名称 + 摘要 + 两枚动作钮」在这个宽度下都不换行也不挤；
/// 再宽只是白白多遮一块——抽屉是浮在页面上的，越窄越能看见身后的列表。
const double kGlassSideDrawerWideWidth = 380;

/// 抽屉左边缘的圆角。右侧抽屉只有靠内的那条边露在外面，圆角也只给那一边。
const double kGlassSideDrawerCornerRadius = 24;

/// 侧边抽屉的宽度：
/// - 宽屏固定 [kGlassSideDrawerWideWidth]，鼠标操作不需要更大靶子；
/// - 窄屏取屏宽 88%（封顶 460），左边留一条能瞥见列表 + 点击关闭的余量。
double glassSideDrawerWidth(BuildContext context) {
  final double width = MediaQuery.sizeOf(context).width;
  if (width >= GlassTokens.dialogWideBreakpoint) {
    return kGlassSideDrawerWideWidth;
  }
  return math.min(width * 0.88, 460);
}

/// 全站**唯一**的右侧抽屉入口：筛选设置、已保存筛选、已保存搜索都走这里。
///
/// # ⛔ 为什么不用 `Scaffold.endDrawer`（2026-08-26）
///
/// 一个 `Scaffold` 只能挂**一只** `endDrawer`，而这些页面右边有两只抽屉
/// （筛选 / 已保存）。历史上「已保存」占了 endDrawer、「筛选」是弹窗，改造
/// 时筛选只能另起一条路由——于是两只抽屉从圆角、遮罩范围到手势全都不一样
/// （2026-08-26 用户逐条点出来的）。现在两边都走这一条，行为按定义一致。
///
/// 顺带修掉 endDrawer 那条路上修不掉的一个 bug：**浮动底栏会盖住抽屉**。
/// 底栏是 Shell 里 `Stack` 的覆盖层，画在页面 `Scaffold` 之上（它不能进
/// `bottomNavigationBar`，见 `home_shell_scaffold.dart` 里那段说明），所以
/// 任何页面级的 endDrawer 都在它底下。这条路由挂在 **root Navigator** 上，
/// 是整个 Shell 的兄弟，自然盖在底栏之上；也因此它读到的 `MediaQuery` 是
/// 未被 Shell 抬高过的原始安全区，抽屉内不需要再 `RemoveFloatingBarInset`。
///
/// # 自己补上的那几件 endDrawer 自带的事
///
///   - 左边缘圆角 + 投影（[kGlassSideDrawerCornerRadius]）；
///   - **按住横向拖动即可甩出关闭**，松手按位移与甩速判定，不到阈值弹回；
///     移动端和 PC 都给（PC 上按住拖也是同一条肌肉记忆，且不影响点按）；
///   - Esc 关闭（宽屏键盘用户的第一反应）、点遮罩关闭。
///
/// ⛔ **没有做「边缘滑动打开」**：热门视频 / 图库 / 订阅三页的主体是
/// `TabBarView`，右边缘横向拖动本来就是「切上一个 tab」，边缘开抽屉会跟它抢
/// 手势；而且这些页面右边有两只抽屉，边缘一划该开哪只本身就没有答案。打开
/// 一律走 header 上那两枚钮。
///
/// 内部的横向滚动区不会被甩出手势吃掉：手势竞技场里更深的识别器先进场，
/// 滚动容器稳赢。
Future<T?> showGlassSideDrawer<T>({
  BuildContext? context,
  required WidgetBuilder builder,
}) {
  final targetContext = context ?? rootNavigatorKey.currentContext;
  if (targetContext == null) return Future<T?>.value();

  final themes = InheritedTheme.capture(
    from: targetContext,
    to: Navigator.of(targetContext, rootNavigator: true).context,
  );

  return showGeneralDialog<T>(
    context: targetContext,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(
      targetContext,
    ).modalBarrierDismissLabel,
    // 宽屏抽屉只占 380px，身后的列表大半还看得见——筛选是即时生效的，价值就在
    // 「边看结果边调」，遮罩再压一层黑等于把这件事挡掉，所以宽屏用浅遮罩。
    barrierColor:
        MediaQuery.sizeOf(targetContext).width >=
            GlassTokens.dialogWideBreakpoint
        ? Colors.black26
        : Colors.black54,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return themes.wrap(_GlassSideDrawerHost(builder: builder));
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: CurvedAnimation(
          parent: animation,
          curve: GlassTokens.motionCurve,
          reverseCurve: Curves.easeInCubic,
        ).drive(Tween(begin: const Offset(1, 0), end: Offset.zero)),
        child: child,
      );
    },
  );
}

/// 抽屉的定位与手势层：贴右对齐 + Esc 关闭 + 按住横拖甩出。
class _GlassSideDrawerHost extends StatefulWidget {
  const _GlassSideDrawerHost({required this.builder});

  final WidgetBuilder builder;

  @override
  State<_GlassSideDrawerHost> createState() => _GlassSideDrawerHostState();
}

class _GlassSideDrawerHostState extends State<_GlassSideDrawerHost>
    with SingleTickerProviderStateMixin {
  /// 松手后弹回原位的那一下。
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  /// 手指把抽屉往右推开的距离（0 = 完全展开）。
  double _dragOffset = 0;
  double _settleFrom = 0;

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double width) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, width);
    });
  }

  void _onDragEnd(DragEndDetails details, double width) {
    final double velocity = details.velocity.pixelsPerSecond.dx;
    // 甩得够快，或者已经推过三分之一，就当是要关
    if (velocity > 700 || _dragOffset > width * 0.35) {
      Navigator.of(context).maybePop();
      return;
    }
    _settleFrom = _dragOffset;
    _settle
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final double width = glassSideDrawerWidth(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Focus(
        autofocus: true,
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onHorizontalDragUpdate: (d) => _onDragUpdate(d, width),
            onHorizontalDragEnd: (d) => _onDragEnd(d, width),
            child: AnimatedBuilder(
              animation: _settle,
              builder: (context, child) {
                final double dx = _settle.isAnimating
                    ? _settleFrom *
                          (1 - Curves.easeOutCubic.transform(_settle.value))
                    : (_settle.isCompleted ? 0 : _dragOffset);
                return Transform.translate(offset: Offset(dx, 0), child: child);
              },
              child: SizedBox(width: width, child: widget.builder(context)),
            ),
          ),
        ),
      ),
    );
  }
}

/// 侧边抽屉的内容骨架：悬浮玻璃 header（标题 · 动作 · 关闭）+ 内容 + 可选底栏。
///
/// 内容铺满整只抽屉，靠 [bodyBuilder] 拿到的 padding 让出 header 高度，滚动时
/// 从玻璃 header 背后经过；上下各一条渐变蒙层收边——与页面上的
/// `GlassHeaderOverlay` 是同一套观感。
class GlassSideDrawerShell extends StatefulWidget {
  const GlassSideDrawerShell({
    super.key,
    required this.title,
    required this.bodyBuilder,
    this.titleWidget,
    this.subtitle,
    this.headerActions = const <Widget>[],
    this.headerBottom,
    this.plainCloseButton = false,
    this.opaqueHeader = false,
    this.footer,
  });

  /// 标题文字。[titleWidget] 非空时不上屏（那时顶替它的控件自己会说明这是
  /// 什么抽屉），但仍要传：它是这只抽屉的名字，也是标题行的兜底。
  final String title;

  /// 用一枚控件**顶替**标题文字站在标题行左侧（例如「接着看」那只切池下拉）。
  ///
  /// 用处只有一个：控制行本身就说明了这是什么抽屉时，标题那行字纯属重复，
  /// 两行 chrome 白占一行的高度。这时把控件提到标题行来，header 收成一行，
  /// 上下留白也跟着换成「围着一枚胶囊」的那套（文字要更多的视觉呼吸，胶囊
  /// 自带内边距，所以不能沿用文字标题的 16/4）。
  ///
  /// 它按内容收缩、左对齐，右边仍是 [headerActions] 与关闭钮。
  final Widget? titleWidget;

  /// header 标题下的一行小字（例如「改动即时生效」）。
  final String? subtitle;

  /// header 右侧的动作键，排在关闭钮左边。关闭钮由外壳自己加。
  final List<Widget> headerActions;

  /// 标题行**下面**那条常驻控制行（切池 / 筛选 / 分段）。
  ///
  /// ⛔ 这种行要放这里，别当成 [bodyBuilder] 的第一个孩子：只有进了 header 这
  /// 一块，它才会 ① 一起被量进 header 高度，于是 `contentPadding.top` 自动把
  /// 它让开——内容的**起始**位置落在它下缘；② 一起被顶部蒙层收边，内容从它
  /// 背后滚过去时是"溶"进去的。放进 body 的话两件事都得自己重做一遍，而且
  /// 漏了第一件就是「列表一开局就压在控制行底下」（2026-08-29 用户报障）。
  final Widget? headerBottom;

  /// 内容。回调里的 padding 已经算好了 header 让位与左右留白，直接交给
  /// 内部可滚动组件的 `padding` 即可（这样内容才会从 header 背后滚过去）。
  final Widget Function(BuildContext context, EdgeInsets contentPadding)
  bodyBuilder;

  /// 关闭钮钉死传统档（半透明底 + 细描边），不跟着 chrome 走液态。
  ///
  /// ⛔ 默认 **false**，而且**目前一处都没有打开它**：一行 chrome 里两种材质
  /// 一眼就能看出来（2026-08-29 用户原话：「重置/保存和关闭这两个按钮的样式
  /// 居然不一样」）。留着这个口子只是为了"整只 header 都不指望折射"那种场合，
  /// 打开它之前先确认同一行里没有别的液态件。
  final bool plainCloseButton;

  /// header 整条铺不透明底，而不是只靠顶部渐变蒙层收边。
  ///
  /// 默认 **false**：内容从半透明 header 背后滚过去正是这套抽屉的观感。
  ///
  /// 但**内容很密**的抽屉（播放器设置：一屏七八行文字）滚起来就是字压字——
  /// 蒙层到 header 下缘时已经淡到 0.1 上下，而那里恰恰是 [headerBottom] 那条
  /// 常驻控制行所在的位置，标题与胶囊底下会一直有字在跑。这类抽屉传 true：
  /// 底色取蒙层的同一个色（[GlassTokens.scrimBase]）拉满不透明度，所以 header
  /// 与蒙层仍是同一块颜色，只是下缘从"淡出"变成一条干净的实边。
  final bool opaqueHeader;

  /// 贴底常驻的一条（生成的查询预览 / 排序提示）。
  final Widget? footer;

  @override
  State<GlassSideDrawerShell> createState() => _GlassSideDrawerShellState();
}

class _GlassSideDrawerShellState extends State<GlassSideDrawerShell> {
  /// header 行的实测高度（含状态栏与上下留白）。首帧用预估值。
  double? _headerHeight;

  void _onHeaderMeasured(Size size) {
    if (_headerHeight != null && (size.height - _headerHeight!).abs() < 0.5) {
      return;
    }
    setState(() => _headerHeight = size.height);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String title = widget.title;
    final String? subtitle = widget.subtitle;
    final List<Widget> headerActions = widget.headerActions;
    final Widget? footer = widget.footer;

    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    final double headerExtent =
        _headerHeight ?? (statusBarHeight + _kHeaderExtentEstimate);

    return Drawer(
      // 宽度由外面的 [_GlassSideDrawerHost] 定，这里撑满即可
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      // 只有靠内的那条边露在外面，圆角与投影都只给左边
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.horizontal(
          start: Radius.circular(kGlassSideDrawerCornerRadius),
        ),
      ),
      elevation: 8,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: widget.bodyBuilder(
                    context,
                    EdgeInsets.fromLTRB(
                      _kDrawerHPadding,
                      headerExtent + _kDrawerHeaderTailSpacing,
                      _kDrawerHPadding,
                      footer == null ? safeBottom + 24 : 8,
                    ),
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      _kDrawerHPadding,
                      0,
                      _kDrawerHPadding,
                      safeBottom + 12,
                    ),
                    child: footer,
                  ),
              ],
            ),
          ),

          // 顶部渐变蒙层：内容从 header 背后滚过时收边
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: EdgeFadeScrim.headerOverlay(
                headerExtent: headerExtent,
                plateauExtent: statusBarHeight,
              ),
            ),
          ),

          // header 行：标题（+ 副标题）· 动作 · 关闭
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassMeasuredBox(
              onSize: _onHeaderMeasured,
              child: _HeaderBackdrop(
                opaque: widget.opaqueHeader,
                child: GlassChromeLayer(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      _kDrawerHPadding,
                      statusBarHeight + (widget.titleWidget == null ? 16 : 8),
                      _kDrawerHPadding,
                      widget.titleWidget == null ? 4 : 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: widget.titleWidget != null
                                  ? Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: widget.titleWidget!,
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (subtitle != null)
                                          Text(
                                            subtitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                      ],
                                    ),
                            ),
                            for (final action in headerActions) ...[
                              const SizedBox(width: 8),
                              action,
                            ],
                            const SizedBox(width: 8),
                            if (widget.plainCloseButton)
                              const LiquidGlassScope(
                                backend: GlassBackend.plain,
                                child: _DrawerCloseButton(),
                              )
                            else
                              const _DrawerCloseButton(),
                          ],
                        ),
                        if (widget.headerBottom != null) ...[
                          const SizedBox(height: 8),
                          widget.headerBottom!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// header 的底：默认透明（蒙层收边），[opaque] 时铺一层蒙层同色的实底。
/// 见 [GlassSideDrawerShell.opaqueHeader]。
class _HeaderBackdrop extends StatelessWidget {
  const _HeaderBackdrop({required this.opaque, required this.child});

  final bool opaque;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!opaque) return child;
    return ColoredBox(
      color: GlassTokens.scrimBase(Theme.of(context).colorScheme),
      child: child,
    );
  }
}

/// [GlassSideDrawerShell] 的「一列分区」变体：内容是自上而下的若干
/// [GlassFilterSection]，整列可滚动。筛选抽屉用的就是它。
class GlassFilterDrawerShell extends StatelessWidget {
  const GlassFilterDrawerShell({
    super.key,
    required this.title,
    required this.children,
    this.onReset,
    this.subtitle,
    this.footer,
  });

  final String title;
  final String? subtitle;

  /// 内容分区，自上而下排布。
  final List<Widget> children;

  /// 重置为「无筛选」。为 null 时重置钮置灰。
  final VoidCallback? onReset;

  /// 贴底常驻的一条（例如生成的查询预览）。
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassSideDrawerShell(
      title: title,
      subtitle: subtitle,
      footer: footer,
      headerActions: [
        GlassIconButton(
          standalone: true,
          icon: const Icon(Icons.restart_alt),
          tooltip: t.searchFilter.clearAll,
          onPressed: onReset,
        ),
      ],
      bodyBuilder: (context, contentPadding) => SingleChildScrollView(
        padding: contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// 抽屉内的一个分区：小标题（可带右侧动作）+ 内容。
class GlassFilterSection extends StatelessWidget {
  const GlassFilterSection({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;

  /// 小标题右侧的动作键（帮助 / 增删标签一类）。
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            // 有动作键时行高按 32 撑开，没有时贴紧标题
            height: actions == null ? null : 32,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ...?actions,
              ],
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// 抽屉右上角那枚关闭钮。单独成一个组件，是为了让它在
/// [LiquidGlassScope] 底下**重新取一次 context**——档位是沿树下发的，写在
/// scope 外面的 `GlassIconButton` 读到的还是外层那一档。
class _DrawerCloseButton extends StatelessWidget {
  const _DrawerCloseButton();

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassIconButton(
      standalone: true,
      icon: const Icon(Icons.close),
      tooltip: t.common.close,
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}
