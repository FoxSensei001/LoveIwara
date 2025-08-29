import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';

/// 桌面/移动端自适应布局容器
class StepResponsiveScaffold extends StatelessWidget {
  final Widget Function(BuildContext, ThemeData) desktopBuilder;
  final Widget Function(BuildContext, ThemeData, bool) mobileBuilder;

  const StepResponsiveScaffold({
    super.key,
    required this.desktopBuilder,
    required this.mobileBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final isNarrow = screenWidth < 400;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final content = isDesktop
        ? desktopBuilder(context, theme)
        : mobileBuilder(context, theme, isNarrow);

    final horizontalPadding = isNarrow ? 16.0 : (isDesktop ? 48.0 : 24.0);
    final bottomPadding = horizontalPadding;
    // 让内容从 AppBar 背后滑出，同时避免视觉被遮挡
    final topPadding = mediaQuery.padding.top + AppService.titleBarHeight;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        bottomPadding,
      ),
      child: Column(
        children: [
          content,
          const SafeArea(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

/// 标准的左右布局（左侧文案/提示，右侧设置卡片）
class StepTwoColumnLayout extends StatelessWidget {
  final Widget left;
  final Widget right;

  const StepTwoColumnLayout({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: left),
        const SizedBox(width: 80),
        Expanded(flex: 1, child: right),
      ],
    );
  }
}


