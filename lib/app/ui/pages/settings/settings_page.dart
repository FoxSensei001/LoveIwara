import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

import '../../../../utils/proxy/proxy_util.dart';
import 'about_page.dart';
import 'app_settings_page.dart';
import 'block_settings_page.dart';
import 'diagnostics_page.dart';
import 'display_settings_page.dart';
import 'download_settings_page.dart';
import 'forum_settings_page.dart';
import 'gallery_settings_page.dart';
import 'keybinding_settings_page.dart';
import 'player_settings_page.dart';
import 'proxy_settings_page.dart';
import 'theme_settings_page.dart';
import 'translation_settings_page.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 设置子页的统一标识。
///
/// 取代旧实现里「硬编码 int 索引 + `ProxyUtil.isSupportedPlatform()` 偏移」：
/// 那套写法里左栏、`_getSettingsPage` 的 switch、AppService 深链入口三处
/// 各自维护同一份索引算术，平台裁剪（网络设置）一动就全乱。现在入口是否
/// 支持由 [isSupported] 收口，深链（[SettingsPageExtra.initialSection]）
/// 直接传枚举，不存在偏移。
enum SettingsSection {
  network,
  translation,
  keybinding,
  app,
  forum,
  download,
  player,
  theme,
  layout,
  gallery,
  block,
  about,
  diagnostics;

  /// 当前平台是否开放该入口（网络设置仅代理可用平台）。
  bool get isSupported =>
      this != SettingsSection.network || ProxyUtil.isSupportedPlatform();

  String title(slang.Translations t) => switch (this) {
    SettingsSection.network => t.settings.networkSettings,
    SettingsSection.translation => t.translation.translation,
    SettingsSection.keybinding => t.settings.keybinding.title,
    SettingsSection.app => t.settings.appSettings,
    SettingsSection.forum => t.settings.chatSettings.name,
    SettingsSection.download =>
      t.settings.downloadSettings.downloadSettingsTitle,
    SettingsSection.player => t.settings.playerSettings,
    SettingsSection.theme => t.settings.themeSettings,
    SettingsSection.layout => t.displaySettings.layoutSettings,
    SettingsSection.gallery =>
      t.settings.gallerySettings.gallerySettingsTitle,
    SettingsSection.block => t.settings.blockSettings.title,
    SettingsSection.about => t.settings.about,
    SettingsSection.diagnostics => t.settings.diagnosticsAndFeedback,
  };

  IconData get icon => switch (this) {
    SettingsSection.network => Icons.wifi,
    SettingsSection.translation => Icons.translate,
    SettingsSection.keybinding => Icons.keyboard,
    SettingsSection.app => Icons.settings,
    SettingsSection.forum => Icons.forum,
    SettingsSection.download => Icons.download,
    SettingsSection.player => Icons.play_circle_outline,
    SettingsSection.theme => Icons.color_lens,
    SettingsSection.layout => Icons.display_settings,
    SettingsSection.gallery => Icons.photo_library_outlined,
    SettingsSection.block => Icons.block,
    SettingsSection.about => Icons.info_outline,
    SettingsSection.diagnostics => Icons.bug_report_outlined,
  };

  Widget buildPage({required bool isWideScreen}) => switch (this) {
    SettingsSection.network => ProxySettingsPage(isWideScreen: isWideScreen),
    SettingsSection.translation =>
      TranslationSettingsPage(isWideScreen: isWideScreen),
    SettingsSection.keybinding =>
      KeybindingSettingsPage(isWideScreen: isWideScreen),
    SettingsSection.app => AppSettingsPage(isWideScreen: isWideScreen),
    SettingsSection.forum => ForumSettingsPage(useSettingsNavi: true),
    SettingsSection.download =>
      DownloadSettingsPage(isWideScreen: isWideScreen),
    SettingsSection.player => PlayerSettingsPage(isWideScreen: isWideScreen),
    SettingsSection.theme => ThemeSettingsPage(isWideScreen: isWideScreen),
    SettingsSection.layout => DisplaySettingsPage(useSettingsNavi: true),
    SettingsSection.gallery => GallerySettingsPage(isWideScreen: isWideScreen),
    SettingsSection.block => BlockSettingsPage(isWideScreen: isWideScreen),
    SettingsSection.about => AboutPage(isWideScreen: isWideScreen),
    SettingsSection.diagnostics =>
      DiagnosticsPage(isWideScreen: isWideScreen),
  };
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({this.initialSection, super.key});

  /// 深链直接打开的子页（抽屉里的「内容屏蔽」、报障引导的「诊断」等入口）。
  /// 为 null 时打开设置主列表。
  final SettingsSection? initialSection;

  // 静态引用，用于子页面导航
  static _SettingsPageState? _currentInstance;

  @override
  State<SettingsPage> createState() => _SettingsPageState();

  /// 打开某个设置分区（左栏 / 主列表点击）。
  static void openSection(SettingsSection section) =>
      _currentInstance?._openSection(section);

  /// 从子页继续下钻（翻译设置 -> Google/DeepLX/AI 子页等）。
  static void navigateToNestedPage(Widget page) =>
      _currentInstance?._navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => page),
      );

  /// 是否还能在设置内部返回（内部 Navigator 是否有可弹的路由）。
  static bool canPopInternally() =>
      _currentInstance?._navigatorKey.currentState?.canPop() ?? false;

  /// 内部返回一层；退无可退时不在这里退出整个路由（交给调用方的
  /// [AppService.tryPop] 兜底），保持与 PopCoordinator 的返回链路一致。
  static void popInternally() => _currentInstance?._handlePop();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _homeRouteName = 'settings_home';

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final _SettingsNavObserver _observer = _SettingsNavObserver(
    _syncFromNavigator,
  );

  /// 左栏 / 主列表的选中高亮。observer 只能触发本页 setState，而窄屏主列表
  /// 在内部 Navigator 的路由里、不会跟着重建，所以再挂一个 notifier 让
  /// 列表自己监听。
  final ValueNotifier<SettingsSection?> _sectionNotifier =
      ValueNotifier<SettingsSection?>(null);

  HorizontalDragGestureRecognizer? _gestureRecognizer;
  double _dragDistance = 0;

  bool get _isWide => MediaQuery.sizeOf(context).width > 720;

  bool get _canPopInternal =>
      _navigatorKey.currentState?.canPop() ?? false;

  @override
  void initState() {
    super.initState();
    SettingsPage._currentInstance = this;

    // 窄屏左缘拖拽返回（Android 没有系统级的边缘横滑）。
    // 只保留「松手提交」：拖拽过程中的跟手位移由路由自己的过渡动画接管。
    _gestureRecognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onUpdate = (details) {
        if (!_isWide && _canPopInternal) {
          _dragDistance += details.delta.dx;
        }
      }
      ..onEnd = (details) {
        if (!_isWide && _canPopInternal) {
          final screenWidth = MediaQuery.sizeOf(context).width;
          final velocity = details.velocity.pixelsPerSecond.dx;
          final shouldPop =
              velocity > 300 || _dragDistance > screenWidth * 0.4;
          if (shouldPop) {
            _navigatorKey.currentState?.pop();
          }
        }
        _dragDistance = 0;
      };
  }

  @override
  void dispose() {
    _gestureRecognizer?.dispose();
    _sectionNotifier.dispose();

    if (SettingsPage._currentInstance == this) {
      SettingsPage._currentInstance = null;
    }
    super.dispose();
  }

  /// 内部 Navigator 的栈一变（push/pop/replace），PopScope.canPop 与选中
  /// 高亮都要跟着刷新；PopScope.canPop 只在 build 时取值，漏掉刷新会让
  /// 系统返回键带着过期的判定直接弹掉整个设置路由。
  void _syncFromNavigator() {
    if (!mounted) return;
    _sectionNotifier.value = _observer.currentSection;
    setState(() {});
  }

  void _openSection(SettingsSection section) {
    final nav = _navigatorKey.currentState;
    if (nav == null) return;
    final alreadyInStack = _observer.stack.any(
      (r) => r.settings.name == section.name,
    );
    if (alreadyInStack) {
      // 目标分区已在栈里：弹到它为止（顺带清掉盖在上面的下钻页/旧高亮）。
      nav.popUntil((route) => route.settings.name == section.name);
      return;
    }
    nav.popUntil((route) => route.isFirst);
    if (_observer.stack.isNotEmpty &&
        _observer.stack.first.settings.name != _homeRouteName) {
      // 深链进来的首路由本身就是某个分区页：换成目标分区，
      // 返回语义仍然是「离开设置」而不是「回到上一个分区」。
      nav.pushReplacement(_sectionRoute(section));
    } else {
      nav.push(_sectionRoute(section));
    }
  }

  MaterialPageRoute<void> _sectionRoute(SettingsSection section) =>
      MaterialPageRoute<void>(
        settings: RouteSettings(name: section.name),
        builder: (_) => _SectionHost(section: section),
      );

  void _handlePop() {
    if (_canPopInternal) {
      _navigatorKey.currentState!.pop();
      return;
    }
    AppService.tryPop(context: context);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_isWide && _canPopInternal && event.position.dx < 20) {
      _gestureRecognizer?.addPointer(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_canPopInternal,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _handlePop();
      },
      child: Material(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isWide) {
      // 桌面端：左栏常驻导航 + 右栏内部 Navigator
      return Row(
        children: [
          SizedBox(width: 280, height: double.infinity, child: _buildLeftNav()),
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
          Expanded(child: _navigatorHost()),
        ],
      );
    }
    // 移动端：同一个内部 Navigator 占满全屏，首路由是设置主列表
    return Listener(
      onPointerDown: _handlePointerDown,
      child: _navigatorHost(),
    );
  }

  /// 宽窄屏共用一个 Navigator 实例（GlobalKey 挂树时保住路由栈）；
  /// 分区页/主列表在 build 时自行读 MediaQuery 适配宽度，
  /// 所以跨断点旋转/缩放不会把错误的布局冻在路由里。
  Widget _navigatorHost() {
    return Navigator(
      key: _navigatorKey,
      observers: [_observer],
      initialRoute: widget.initialSection?.name ?? _homeRouteName,
      onGenerateRoute: (settings) {
        final name = settings.name ?? _homeRouteName;
        if (name == _homeRouteName) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => _SettingsHomePage(sectionNotifier: _sectionNotifier),
          );
        }
        for (final section in SettingsSection.values) {
          if (section.name == name) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => _SectionHost(section: section),
            );
          }
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SizedBox(),
        );
      },
    );
  }

  Widget _buildLeftNav() {
    return Material(
      child: _SettingsNavListPage(sectionNotifier: _sectionNotifier),
    );
  }
}

/// 内部 Navigator 的栈镜像 + 选中分区推导。
///
/// NavigatorObserver 拿不到公开的栈查询 API，就在回调里自己维护一份镜像；
/// 「当前分区」取栈里从顶往下第一个名字能对上分区的路由（下钻页
/// （如 翻译设置 -> Google 翻译）名字对不上，会被跳过，高亮仍指向其下的分区）。
class _SettingsNavObserver extends NavigatorObserver {
  _SettingsNavObserver(this.onChanged);

  final VoidCallback onChanged;
  final List<Route<dynamic>> stack = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    stack.add(route);
    onChanged();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    stack.remove(route);
    onChanged();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    stack.remove(route);
    onChanged();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      final i = stack.indexOf(oldRoute);
      if (i >= 0 && newRoute != null) {
        stack[i] = newRoute;
      } else {
        stack.remove(oldRoute);
      }
    }
    if (oldRoute == null && newRoute != null) {
      stack.add(newRoute);
    }
    onChanged();
  }

  SettingsSection? get currentSection {
    for (final route in stack.reversed) {
      final name = route.settings.name;
      if (name == null) continue;
      for (final section in SettingsSection.values) {
        if (section.name == name) return section;
      }
    }
    return null;
  }
}

/// 分区路由的宿主：在 build 时读当前宽度再构造页面，
/// 让 `isWideScreen` 跟着窗口尺寸走而不是被冻在 push 那一刻。
class _SectionHost extends StatelessWidget {
  const _SectionHost({required this.section});

  final SettingsSection section;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 720;
    return section.buildPage(isWideScreen: isWide);
  }
}

/// 内部 Navigator 的首路由：
/// - 窄屏 = 设置主列表页（带玻璃 header，返回键退出整个设置路由）；
/// - 宽屏 = 右栏空占位（分组导航常驻左栏，右栏没选中分区时留白）。
class _SettingsHomePage extends StatelessWidget {
  const _SettingsHomePage({required this.sectionNotifier});

  final ValueNotifier<SettingsSection?> sectionNotifier;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 720;
    if (isWide) {
      return const SizedBox.expand();
    }
    return _SettingsNavListPage(sectionNotifier: sectionNotifier);
  }
}

/// 设置分组列表（宽屏左栏与窄屏主列表共用同一份渲染）。
class _SettingsNavListPage extends StatelessWidget {
  const _SettingsNavListPage({required this.sectionNotifier});

  final ValueNotifier<SettingsSection?> sectionNotifier;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassSettingsScaffold(
      title: t.settings.settings,
      // 窄屏主列表才需要返回钮（退出整个设置路由）；宽屏左栏不需要。
      isWideScreen: MediaQuery.sizeOf(context).width > 720,
      slivers: [_SettingsGroupsSliver(sectionNotifier: sectionNotifier)],
    );
  }
}

class _SettingsGroupsSliver extends StatelessWidget {
  const _SettingsGroupsSliver({required this.sectionNotifier});

  final ValueNotifier<SettingsSection?> sectionNotifier;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));

    final groups = <(String, List<SettingsSection>)>[
      (
        t.settings.basicSettings,
        [
          if (SettingsSection.network.isSupported) SettingsSection.network,
          SettingsSection.translation,
          SettingsSection.keybinding,
          SettingsSection.app,
          SettingsSection.download,
        ],
      ),
      (
        t.settings.personalizedSettings,
        [
          SettingsSection.forum,
          SettingsSection.player,
          SettingsSection.theme,
          SettingsSection.layout,
          SettingsSection.gallery,
          SettingsSection.block,
        ],
      ),
      (
        t.settings.otherSettings,
        [SettingsSection.about, SettingsSection.diagnostics],
      ),
    ];

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + bottomInset),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, groupIndex) {
            final group = groups[groupIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassSettingSection(
                title: group.$1,
                children: [
                  for (final section in group.$2)
                    ValueListenableBuilder<SettingsSection?>(
                      valueListenable: sectionNotifier,
                      builder: (context, selected, _) => GlassSettingTile(
                        icon: section.icon,
                        title: Text(section.title(t)),
                        selected: selected == section,
                        onTap: () => SettingsPage.openSection(section),
                      ),
                    ),
                ],
              ),
            );
          },
          childCount: groups.length,
        ),
      ),
    );
  }
}
