import 'package:flutter/material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/proxy/proxy_util.dart';

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

/// 设置树的根路径。旧的 `/settings_page` 由路由层 redirect 到这里。
const String kSettingsRootPath = '/settings';

/// 双栏（master-detail）断点。宽于此值时左栏常驻、右栏跟着路由变。
const double kSettingsTwoPaneBreakpoint = 720;

/// 设置的一级分区。
///
/// 这个枚举是分区的**唯一真相源**：路径、标题、图标、页面构造全在这里，
/// 不再有「平台相关的 int 索引 + 反向 ±1 修正」那套魔数
/// （历史实现见 git fd84edf5 之前的 `settings_page.dart`）。
///
/// 平台差异用「这条路由存不存在」表达，见 [isAvailable]——不支持代理的平台上
/// [SettingsSection.network] 既不注册路由也不出现在列表里，被深链命中时由
/// 路由层回落到 [kSettingsRootPath]。
enum SettingsSection {
  network,
  translation,
  keybinding,
  app,
  download,
  chat,
  player,
  theme,
  display,
  gallery,
  block,
  about,
  diagnostics;

  /// 路由 path，同时也是 go_router 的完整 location。
  String get path => '$kSettingsRootPath/$_segment';

  /// go_router 的路由名。
  String get routeName => 'settings_$_segment';

  String get _segment => switch (this) {
    SettingsSection.network => 'network',
    SettingsSection.translation => 'translation',
    SettingsSection.keybinding => 'keybinding',
    SettingsSection.app => 'app',
    SettingsSection.download => 'download',
    SettingsSection.chat => 'chat',
    SettingsSection.player => 'player',
    SettingsSection.theme => 'theme',
    SettingsSection.display => 'display',
    SettingsSection.gallery => 'gallery',
    SettingsSection.block => 'block',
    SettingsSection.about => 'about',
    SettingsSection.diagnostics => 'diagnostics',
  };

  /// iOS 上是否允许**整页**跟手侧滑返回。
  ///
  /// 页内有横向手势控件的分区必须关掉，退回「仅边缘可滑」，否则向右滑会和内部
  /// 手势抢竞技场（同 `buildAdaptiveSwipeablePage` 的 fullSwipe 分级）。
  bool get allowsFullSwipeBack => switch (this) {
    // 屏蔽规则页是三个 Tab 的 TabBarView
    SettingsSection.block => false,
    _ => true,
  };

  /// 当前平台是否提供该分区。
  bool get isAvailable => switch (this) {
    SettingsSection.network => ProxyUtil.isSupportedPlatform(),
    _ => true,
  };

  String title(slang.Translations t) => switch (this) {
    SettingsSection.network => t.settings.networkSettings,
    SettingsSection.translation => t.translation.translation,
    SettingsSection.keybinding => t.settings.keybinding.title,
    SettingsSection.app => t.settings.appSettings,
    SettingsSection.download => t.settings.downloadSettings.downloadSettingsTitle,
    SettingsSection.chat => t.settings.chatSettings.name,
    SettingsSection.player => t.settings.playerSettings,
    SettingsSection.theme => t.settings.themeSettings,
    SettingsSection.display => t.displaySettings.layoutSettings,
    SettingsSection.gallery => t.settings.gallerySettings.gallerySettingsTitle,
    SettingsSection.block => t.settings.blockSettings.title,
    SettingsSection.about => t.settings.about,
    SettingsSection.diagnostics => t.settings.diagnosticsAndFeedback,
  };

  IconData get icon => switch (this) {
    SettingsSection.network => Icons.wifi,
    SettingsSection.translation => Icons.translate,
    SettingsSection.keybinding => Icons.keyboard,
    SettingsSection.app => Icons.settings,
    SettingsSection.download => Icons.download,
    SettingsSection.chat => Icons.forum,
    SettingsSection.player => Icons.play_circle_outline,
    SettingsSection.theme => Icons.color_lens,
    SettingsSection.display => Icons.display_settings,
    SettingsSection.gallery => Icons.photo_library_outlined,
    SettingsSection.block => Icons.block,
    SettingsSection.about => Icons.info_outline,
    SettingsSection.diagnostics => Icons.bug_report_outlined,
  };

  /// 构造分区页。
  ///
  /// [isWideScreen] 只作为各页自身的排版提示透传（列数 / 内边距等），
  /// **不再**用来决定返回钮的显隐——那件事已经收口到
  /// `GlassSettingsScaffold`，由「设置内部导航栈还能不能退」推导。
  Widget buildPage({required bool isWideScreen}) => switch (this) {
    SettingsSection.network => ProxySettingsPage(isWideScreen: isWideScreen),
    SettingsSection.translation => TranslationSettingsPage(
      isWideScreen: isWideScreen,
    ),
    SettingsSection.keybinding => KeybindingSettingsPage(
      isWideScreen: isWideScreen,
    ),
    SettingsSection.app => AppSettingsPage(isWideScreen: isWideScreen),
    SettingsSection.download => DownloadSettingsPage(
      isWideScreen: isWideScreen,
    ),
    SettingsSection.chat => const ForumSettingsPage(),
    SettingsSection.player => PlayerSettingsPage(isWideScreen: isWideScreen),
    SettingsSection.theme => ThemeSettingsPage(isWideScreen: isWideScreen),
    SettingsSection.display => const DisplaySettingsPage(),
    SettingsSection.gallery => GallerySettingsPage(isWideScreen: isWideScreen),
    SettingsSection.block => BlockSettingsPage(isWideScreen: isWideScreen),
    SettingsSection.about => AboutPage(isWideScreen: isWideScreen),
    SettingsSection.diagnostics => DiagnosticsPage(
      isWideScreen: isWideScreen,
    ),
  };

  /// 宽屏进入设置时自动选中的分区（第一个在本平台可用的）。
  static SettingsSection get firstAvailable =>
      settingsSectionGroups.expand((g) => g.sections).firstWhere(
        (s) => s.isAvailable,
        orElse: () => SettingsSection.translation,
      );

  /// 从 go_router location 反推当前所在分区（三级页也能推到其所属分区）。
  /// 不在设置树内或落在 `/settings` 根上时返回 null。
  static SettingsSection? fromLocation(String location) {
    final normalized = location.split('?').first;
    if (!normalized.startsWith('$kSettingsRootPath/')) return null;
    final segment = normalized
        .substring(kSettingsRootPath.length + 1)
        .split('/')
        .first;
    for (final section in SettingsSection.values) {
      if (section._segment == segment) return section;
    }
    return null;
  }
}

/// 设置树里的三级（及更深）页面路径。
///
/// 这些页面不出现在一级列表里，只能从所属分区页点进去，路径即层级。
/// 注意 [navigationOrder] 有两个入口（显示设置直接进、以及布局设置里再进），
/// 两个入口 push 的是同一个路径——`push` 只压一页，所以两条路径下的返回都正确。
abstract final class SettingsSubRoutes {
  static String get translationGoogle =>
      '${SettingsSection.translation.path}/google';
  static String get translationAi => '${SettingsSection.translation.path}/ai';
  static String get translationDeeplx =>
      '${SettingsSection.translation.path}/deeplx';
  static String get displayLayout => '${SettingsSection.display.path}/layout';
  static String get displayNavigationOrder =>
      '${SettingsSection.display.path}/navigation_order';
  static String get aboutChangelog => '${SettingsSection.about.path}/changelog';
  static String get diagnosticsLogs =>
      '${SettingsSection.diagnostics.path}/logs';
}

/// 一级列表里的分组。
class SettingsSectionGroup {
  final String Function(slang.Translations t) title;
  final List<SettingsSection> sections;

  const SettingsSectionGroup({required this.title, required this.sections});
}

/// 一级列表的分组与顺序（左栏与窄屏整页列表共用）。
const List<SettingsSectionGroup> settingsSectionGroups = [
  SettingsSectionGroup(
    title: _basicTitle,
    sections: [
      SettingsSection.network,
      SettingsSection.translation,
      SettingsSection.keybinding,
      SettingsSection.app,
      SettingsSection.download,
    ],
  ),
  SettingsSectionGroup(
    title: _personalizedTitle,
    sections: [
      SettingsSection.chat,
      SettingsSection.player,
      SettingsSection.theme,
      SettingsSection.display,
      SettingsSection.gallery,
      SettingsSection.block,
    ],
  ),
  SettingsSectionGroup(
    title: _otherTitle,
    sections: [SettingsSection.about, SettingsSection.diagnostics],
  ),
];

String _basicTitle(slang.Translations t) => t.settings.basicSettings;
String _personalizedTitle(slang.Translations t) =>
    t.settings.personalizedSettings;
String _otherTitle(slang.Translations t) => t.settings.otherSettings;
