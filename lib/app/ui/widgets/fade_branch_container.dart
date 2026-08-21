import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 首页分支（视频/图库/订阅/论坛/新闻）切换的淡入容器，
/// 用于替代 [StatefulShellRoute.indexedStack] 的硬切。
///
/// 行为上与 IndexedStack 等价：不可见分支 Offstage + 停 Ticker，状态全保留。
/// 差别只在切换瞬间——新分支在旧分支上方做一次轻淡入（Telegram 式），
/// 旧分支动画期间保持完全不透明垫底，中途不会透出 Scaffold 背景闪一下；
/// 动画结束后旧分支回到 Offstage。系统开了「减弱动态效果」时退回硬切。
class FadeBranchContainer extends StatefulWidget {
  const FadeBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  /// 当前活跃分支下标（对应 [children] 的下标）。
  final int currentIndex;

  /// 各分支的 Navigator（由 go_router 的 navigatorContainerBuilder 传入）。
  final List<Widget> children;

  @override
  State<FadeBranchContainer> createState() => _FadeBranchContainerState();
}

class _FadeBranchContainerState extends State<FadeBranchContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: GlassTokens.motionDuration,
    // 初始就停在终点：首帧不做入场动画。
    value: 1,
  );
  late final Animation<double> _fadeIn = CurvedAnimation(
    parent: _controller,
    curve: GlassTokens.motionCurve,
  );

  /// 正在被盖掉的上一个分支；淡入结束后回到 null（重新 Offstage）。
  int? _previousIndex;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          _previousIndex != null &&
          mounted) {
        setState(() => _previousIndex = null);
      }
    });
  }

  @override
  void didUpdateWidget(FadeBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex == oldWidget.currentIndex) return;

    final mediaQuery = MediaQuery.of(context);
    final reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
    if (reduceMotion) {
      _previousIndex = null;
      _controller.value = 1;
      return;
    }
    _previousIndex = oldWidget.currentIndex;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> below = <Widget>[];
    Widget? active;

    for (int i = 0; i < widget.children.length; i++) {
      final bool isActive = i == widget.currentIndex;
      final bool isFadingOut = i == _previousIndex;

      // 各状态共用同一套包裹结构（只改参数不换类型），避免切换时子树被
      // 重建；分支 Navigator 自带 GlobalKey，Stack 重排序也不丢状态。
      final Widget wrapped = KeyedSubtree(
        key: ValueKey<int>(i),
        child: FadeTransition(
          opacity: isActive ? _fadeIn : kAlwaysCompleteAnimation,
          child: ExcludeFocus(
            excluding: !isActive,
            child: IgnorePointer(
              ignoring: !isActive,
              child: Offstage(
                offstage: !isActive && !isFadingOut,
                child: TickerMode(enabled: isActive, child: widget.children[i]),
              ),
            ),
          ),
        ),
      );

      if (isActive) {
        active = wrapped;
      } else {
        below.add(wrapped);
      }
    }

    // 活跃分支永远画在最上层，淡入时盖住旧分支。
    return Stack(fit: StackFit.expand, children: [...below, ?active]);
  }
}
