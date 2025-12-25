import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'translation_settings_page.dart';

import '../../../../utils/proxy/proxy_util.dart';
import 'app_settings_page.dart';
import 'player_settings_page.dart';
import 'forum_settings_page.dart';
import 'proxy_settings_page.dart';
import 'theme_settings_page.dart';
import 'download_settings_page.dart';
import 'display_settings_page.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({this.initialPage = -1, super.key});

  final int initialPage;

  // 静态引用，用于子页面导航
  static _SettingsPageState? _currentInstance;

  @override
  State<SettingsPage> createState() => _SettingsPageState();

  // 静态方法：在宽屏模式下导航到深层页面
  static void navigateToNestedPage(Widget page) {
    final instance = _currentInstance;
    if (instance != null) {
      if (instance.enableTwoViews) {
        // 宽屏模式：使用内部导航
        instance._nestedNavigatorKey.currentState?.push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
          ),
        );
      } else {
        // 窄屏模式：使用页面栈
        instance._addToPageStack(page);
      }
    }
  }

  // 新增静态方法，用于外部检查是否可以内部pop
  static bool canPopInternally() {
    final instance = _currentInstance;
    if (instance == null) {
      return false;
    }
    return (instance.enableTwoViews &&
            (instance._nestedNavigatorKey.currentState?.canPop() ?? false)) ||
        (!instance.enableTwoViews && instance._pageStack.isNotEmpty) ||
        instance.currentPage != -1;
  }

  // 新增静态方法，用于外部触发内部pop
  static void popInternally() {
    _currentInstance?._handlePop();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  Worker? _selectedIndexWorker;
  int currentPage = -1; // 当前选中的设置页面索引
  double offset = 0; // 用于手势拖拽
  HorizontalDragGestureRecognizer? gestureRecognizer;

  // 深层页面导航
  final GlobalKey<NavigatorState> _nestedNavigatorKey =
      GlobalKey<NavigatorState>();
  final List<Widget> _pageStack = []; // 页面栈

  // 响应式布局判断
  bool get enableTwoViews => MediaQuery.of(context).size.width > 720;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;

    // 设置静态引用
    SettingsPage._currentInstance = this;

    // 如果初始页面不是主设置列表，确保页面栈是干净的
    if (widget.initialPage != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _clearAllNestedPages();
      });
    }

    // 初始化手势识别器
    gestureRecognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onUpdate = ((details) {
        if (currentPage != -1 && !enableTwoViews) {
          setState(() {
            offset = (offset + details.delta.dx).clamp(
              0.0,
              MediaQuery.of(context).size.width,
            );
          });
        }
      })
      ..onEnd = (details) async {
        if (currentPage != -1 && !enableTwoViews) {
          final screenWidth = MediaQuery.of(context).size.width;
          final velocity = details.velocity.pixelsPerSecond.dx;

          // 判断是否应该返回
          bool shouldPop = false;
          if (velocity > 300) {
            // 快速向右滑动
            shouldPop = true;
          } else if (offset > screenWidth * 0.4) {
            // 滑动距离超过40%
            shouldPop = true;
          }

          if (shouldPop) {
            _handlePop();
          } else {
            // 回弹到原位置
            setState(() {
              offset = 0;
            });
          }
        }
      };
  }

  @override
  void dispose() {
    _selectedIndexWorker?.dispose();
    gestureRecognizer?.dispose();

    // 清理静态引用
    if (SettingsPage._currentInstance == this) {
      SettingsPage._currentInstance = null;
    }

    super.dispose();
  }

  // 添加页面到栈中
  void _addToPageStack(Widget page) {
    setState(() {
      _pageStack.add(page);
    });
  }

  // 清理所有子页面和导航状态
  void _clearAllNestedPages() {
    setState(() {
      // 清空页面栈
      _pageStack.clear();
      // 重置偏移量
      offset = 0;
    });

    // 如果是宽屏模式，清除嵌套导航器的所有路由
    if (enableTwoViews) {
      _nestedNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  void _handlePop() {
    // 宽屏模式下，先检查嵌套的Navigator是否可以pop
    if (enableTwoViews &&
        (_nestedNavigatorKey.currentState?.canPop() ?? false)) {
      _nestedNavigatorKey.currentState!.pop();
      return;
    }
    // 窄屏模式下，检查页面栈
    if (!enableTwoViews && _pageStack.isNotEmpty) {
      setState(() {
        _pageStack.removeLast();
      });
      return;
    }
    // 如果没有嵌套路由或者页面栈，则返回主设置列表
    if (currentPage != -1) {
      setState(() {
        currentPage = -1;
      });
      _clearAllNestedPages();
      return;
    }
    // 如果已经在主设置列表，则pop整个SettingsPage
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      AppService.tryPop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop =
        !((enableTwoViews &&
                (_nestedNavigatorKey.currentState?.canPop() ?? false)) ||
            (!enableTwoViews && _pageStack.isNotEmpty) ||
            currentPage != -1);

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        _handlePop();
      },
      child: Material(color: Colors.transparent, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (enableTwoViews) {
      // 桌面端：双栏布局
      return Row(
        children: [
          SizedBox(
            width: 280,
            height: double.infinity,
            child: _buildLeft(), // 左侧导航
          ),
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.6,
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) {
                        var width = constraints.maxWidth;
                        var value = animation.isForwardOrCompleted
                            ? 1 - animation.value
                            : 1;
                        var left = width * value;
                        return Stack(
                          children: [
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: left,
                              width: width,
                              child: child,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              child: _buildRight(), // 右侧内容
            ),
          ),
        ],
      );
    } else {
      // 移动端：单页布局
      return Listener(
        onPointerDown: handlePointerDown,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // 底层：导航列表
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: currentPage == -1 && _pageStack.isEmpty
                      ? 0
                      : -constraints.maxWidth,
                  width: constraints.maxWidth,
                  top: 0,
                  bottom: 0,
                  child: _buildLeft(),
                ),
                // 顶层：设置子页面
                if (currentPage != -1 && _pageStack.isEmpty)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: offset,
                    width: constraints.maxWidth,
                    top: 0,
                    bottom: 0,
                    child: Material(
                      elevation: 8,
                      color: Colors.transparent,
                      child: _buildRight(),
                    ),
                  ),
                // 页面栈中的页面
                ..._pageStack.asMap().entries.map((entry) {
                  final index = entry.key;
                  final page = entry.value;
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: index == _pageStack.length - 1 ? offset : 0,
                    width: constraints.maxWidth,
                    top: 0,
                    bottom: 0,
                    child: Material(
                      elevation: 8 + index.toDouble(),
                      color: Colors.transparent,
                      child: page,
                    ),
                  );
                }),
              ],
            );
          },
        ),
      );
    }
  }

  Widget _buildLeft() {
    final t = slang.Translations.of(context);

    return Material(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: t.settings.settings,
            isWideScreen: false, // 显示返回按钮
            expandedHeight: 56,
          ),
          _buildCategoriesSliver(),
        ],
      ),
    );
  }

  Widget _buildCategoriesSliver() {
    final t = slang.Translations.of(context);

    // 定义分组设置项
    final settingGroups = [
      _SettingGroup(
        title: t.settings.basicSettings,
        items: [
          if (ProxyUtil.isSupportedPlatform())
            _SettingItem(
              title: t.settings.networkSettings,
              icon: Icons.wifi,
              index: 0,
            ),
          _SettingItem(
            title: t.translation.translation,
            icon: Icons.translate,
            index: ProxyUtil.isSupportedPlatform() ? 1 : 0,
          ),
          _SettingItem(
            title: t.settings.appSettings,
            icon: Icons.settings,
            index: ProxyUtil.isSupportedPlatform() ? 2 : 1,
          ),
          _SettingItem(
            title: t.settings.downloadSettings.downloadSettingsTitle,
            icon: Icons.download,
            index: ProxyUtil.isSupportedPlatform() ? 4 : 3,
          ),
        ],
      ),
      _SettingGroup(
        title: t.settings.personalizedSettings,
        items: [
          _SettingItem(
            title: t.settings.chatSettings.name,
            icon: Icons.forum,
            index: ProxyUtil.isSupportedPlatform() ? 3 : 2,
          ),
          _SettingItem(
            title: t.settings.playerSettings,
            icon: Icons.play_circle_outline,
            index: ProxyUtil.isSupportedPlatform() ? 5 : 4,
          ),
          _SettingItem(
            title: t.settings.themeSettings,
            icon: Icons.color_lens,
            index: ProxyUtil.isSupportedPlatform() ? 6 : 5,
          ),
          _SettingItem(
            title: t.displaySettings.layoutSettings,
            icon: Icons.display_settings,
            index: ProxyUtil.isSupportedPlatform() ? 7 : 6,
          ),
        ],
      ),
      _SettingGroup(
        title: t.settings.otherSettings,
        items: [
          _SettingItem(
            title: t.settings.about,
            icon: Icons.info_outline,
            index: ProxyUtil.isSupportedPlatform() ? 8 : 7,
          ),
        ],
      ),
    ];

    return SliverPadding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, groupIndex) {
          final group = settingGroups[groupIndex];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      group.title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ...List.generate(group.items.length, (itemIndex) {
                    final item = group.items[itemIndex];
                    final isSelected = currentPage == item.index;

                    return Column(
                      children: [
                        Material(
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondaryContainer
                                    .withValues(alpha: 0.3)
                              : Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // 切换设置页时，清除所有子页面
                              setState(() {
                                currentPage = item.index;
                              });
                              _clearAllNestedPages();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 20,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : null,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (itemIndex != group.items.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: Divider(
                              height: 1,
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.1),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        }, childCount: settingGroups.length),
      ),
    );
  }

  Widget _buildRight() {
    if (currentPage == -1 && _pageStack.isEmpty) {
      return const SizedBox(); // 空页面
    }

    // 如果是宽屏模式，使用Navigator来管理深层页面
    if (enableTwoViews) {
      return Navigator(
        key: _nestedNavigatorKey,
        onGenerateRoute: (settings) {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return _getSettingsPage();
            },
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
          );
        },
      );
    } else {
      // 窄屏模式
      if (_pageStack.isNotEmpty) {
        return _pageStack.last;
      }
      return _getSettingsPage();
    }
  }

  Widget _getSettingsPage() {
    // 根据索引返回对应的设置页面
    int adjustedIndex = currentPage;
    if (!ProxyUtil.isSupportedPlatform()) {
      // 如果不支持代理，需要调整索引
      if (adjustedIndex >= 0) {
        adjustedIndex += 1;
      }
    }

    switch (adjustedIndex) {
      case 0: // 网络设置
        return ProxySettingsPage(isWideScreen: enableTwoViews);
      case 1: // 翻译设置
        return TranslationSettingsPage(isWideScreen: enableTwoViews);
      case 2: // 应用设置
        return AppSettingsPage(isWideScreen: enableTwoViews);
      case 3: // 聊天设置
        return ForumSettingsPage(useSettingsNavi: true);
      case 4: // 下载设置
        return DownloadSettingsPage(isWideScreen: enableTwoViews);
      case 5: // 播放器设置
        return PlayerSettingsPage(isWideScreen: enableTwoViews);
      case 6: // 主题设置
        return ThemeSettingsPage(isWideScreen: enableTwoViews);
      case 7: // 显示设置
        return DisplaySettingsPage(useSettingsNavi: true);
      case 8: // 关于
        return AboutPage(isWideScreen: enableTwoViews);
      default:
        return const SizedBox();
    }
  }

  // 手势处理方法
  void handlePointerDown(PointerDownEvent event) {
    if (!enableTwoViews && (currentPage != -1 || _pageStack.isNotEmpty)) {
      // 只在窄屏且有子页面时才处理手势
      if (event.position.dx < 20) {
        gestureRecognizer?.addPointer(event);
      }
    }
  }
}

// 设置项数据模型
class SettingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
  final String route;

  SettingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
    required this.route,
  });
}

// 分组设置项数据模型
class _SettingGroup {
  final String title;
  final List<_SettingItem> items;

  _SettingGroup({required this.title, required this.items});
}

// 简化的设置项模型（用于左侧导航）
class _SettingItem {
  final String title;
  final IconData icon;
  final int index;

  _SettingItem({required this.title, required this.icon, required this.index});
}
