import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isWideScreen = true;

  const SettingsAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // 根据当前主题动态设置状态栏样式
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDarkMode
          ? Brightness.light
          : Brightness.dark,
    );

    return AppBar(
      title: Text(title),
      elevation: 2,
      automaticallyImplyLeading: !isWideScreen, // 在宽屏模式下不显示返回按钮
      systemOverlayStyle: systemOverlayStyle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// 带模糊效果的SliverAppBar
class BlurredSliverAppBar extends StatelessWidget {
  final String title;
  final bool isWideScreen;
  final double expandedHeight;
  final bool pinned;
  final bool floating;

  const BlurredSliverAppBar({
    super.key,
    required this.title,
    this.isWideScreen = false,
    this.expandedHeight = kToolbarHeight,
    this.pinned = true,
    this.floating = false,
  });

  @override
  Widget build(BuildContext context) {
    // 根据当前主题动态设置状态栏样式
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDarkMode
          ? Brightness.light
          : Brightness.dark,
    );

    return SliverAppBar(
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      automaticallyImplyLeading: !isWideScreen,
      pinned: pinned,
      floating: floating,
      expandedHeight: expandedHeight,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: systemOverlayStyle,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.8),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
