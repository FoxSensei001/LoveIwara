import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 头部行占位（不含状态栏）：上边距 16 + 玻璃圆钮 44 + 下留白 4。
const double _kHeaderExtent = 16 + GlassTokens.pillHeight + 4;

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
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: child,
                );
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
class GlassSideDrawerShell extends StatelessWidget {
  const GlassSideDrawerShell({
    super.key,
    required this.title,
    required this.bodyBuilder,
    this.subtitle,
    this.headerActions = const <Widget>[],
    this.footer,
  });

  final String title;

  /// header 标题下的一行小字（例如「改动即时生效」）。
  final String? subtitle;

  /// header 右侧的动作键，排在关闭钮左边。关闭钮由外壳自己加。
  final List<Widget> headerActions;

  /// 内容。回调里的 padding 已经算好了 header 让位与左右留白，直接交给
  /// 内部可滚动组件的 `padding` 即可（这样内容才会从 header 背后滚过去）。
  final Widget Function(BuildContext context, EdgeInsets contentPadding)
  bodyBuilder;

  /// 贴底常驻的一条（生成的查询预览 / 排序提示）。
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    final double headerExtent =
        statusBarHeight + _kHeaderExtent + (subtitle == null ? 0 : 18);

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
                  child: bodyBuilder(
                    context,
                    EdgeInsets.fromLTRB(
                      16,
                      headerExtent + 8,
                      16,
                      footer == null ? safeBottom + 24 : 8,
                    ),
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, safeBottom + 12),
                    child: footer!,
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
            child: GlassChromeLayer(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
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
                    GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.close),
                      tooltip: t.common.close,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
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
