import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 「老样式控件」棘轮守护。
///
/// # 为什么需要它
///
/// 液态玻璃铺开是分批做的，每一批都靠人肉记住「这批要换、那批先留着」。
/// 结果是同一件事被反复发现、反复报障：某张弹窗点开一看，关闭钮还是裸
/// `IconButton`、动作行还是裸 `TextButton`，既没有新材质也没有长按蠕动。
/// 而这类回退**编译得过、analyze 干净、单测全绿**——没有任何自动信号，
/// 只能等用户亲自点开那张弹窗。
///
/// 这个测试把「还欠多少」变成一个会失败的数字：
///
///   - [_rawMaterialButtonBaseline] / [_rawDialogRouteBaseline] 是**当前欠账**
///     的快照。数字只许降、不许升；文件只许删、不许加。
///   - 新写的代码用了老控件 → 出现在基线外的新文件 → 测试红。
///   - 改造完一个文件 → 数字降了 → 测试提醒你把基线一起改小（锁死战果，
///     不会被下一个人悄悄加回去）。
///
/// # 该用什么替代
///
///   - `TextButton`/`FilledButton`/`ElevatedButton`/`OutlinedButton`
///     → 弹窗动作行用 `GlassAlertDialog(actions: [GlassDialogAction(...)])`；
///       独立位置用 `GlassButtonGroup` + `GlassTextActionButton`。
///   - `IconButton` → `GlassIconButton`（弹窗标题行的关闭键一律
///     `standalone: true`）。
///   - `showDialog`/`showGeneralDialog` → `showAppDialog`
///     （出入场走 `GlassDialogRoute`，并在路由层供上液态档；裸 `showDialog`
///     开出来的弹窗里所有玻璃件都会静默落回传统档）。
///   - `AlertDialog` → `GlassAlertDialog`（这一条已经清零，见下方零容忍规则）。
///
/// 基线里的条目**不是豁免**，是待办清单。
void main() {
  test('没有新的裸 AlertDialog（已清零，零容忍）', () {
    final offenders = <String>[];
    for (final file in _dartFiles()) {
      if (_isExempt(file)) continue;
      final source = file.readAsStringSync();
      for (final match in _rawAlertDialog.allMatches(source)) {
        // GlassAlertDialog( 也会命中 AlertDialog(，靠前一个字符排掉
        final start = match.start;
        if (start > 0 && RegExp(r'[A-Za-z0-9_]').hasMatch(source[start - 1])) {
          continue;
        }
        offenders.add(_rel(file));
        break;
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          '裸 AlertDialog 已在 2026-08-24 清零，请改用 GlassAlertDialog：\n'
          '${offenders.join('\n')}',
    );
  });

  test('玻璃件外面不许再包 Opacity / AnimatedOpacity / FadeTransition（已清零，零容忍）', () {
    final offenders = <String>[];
    for (final file in _dartFiles()) {
      if (_isExempt(file)) continue;
      final source = file.readAsStringSync();
      for (final match in _opacityWrapper.allMatches(source)) {
        // 只看这层 Opacity 往下若干行里有没有玻璃件——嵌套再深的追不到，
        // 但复制粘贴出来的那一坨（浮钮 / 选择坞）都是紧挨着的。
        final tail = source.substring(
          match.end,
          (match.end + 400).clamp(0, source.length),
        );
        if (_glassWidget.hasMatch(tail)) {
          final line =
              '\n'.allMatches(source.substring(0, match.start)).length + 1;
          offenders.add('${_rel(file)}:$line');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'α∈(0,1) 时 RenderOpacity 会 saveLayer 把子树隔离，液态玻璃的 backdrop '
          '采样吃不到背景——整段淡入淡出里折射是断的，读起来就是「按钮先出现、'
          '玻璃质感后补」。玻璃的显隐一律走 GlassReveal / GlassSurface.materialize：'
          '\n${offenders.join('\n')}',
    );
  });

  test('没有 Material 的下拉 / 弹出菜单（已清零，零容忍）', () {
    final offenders = <String>[];
    for (final file in _dartFiles()) {
      if (_isExempt(file)) continue;
      // 注释里提到这些名字的（词汇表、"原来是 PopupMenuButton" 这类说明）
      // 不算调用点。
      final source = file.readAsStringSync().replaceAll(_lineComment, '');
      for (final match in _materialPopup.allMatches(source)) {
        final line =
            '\n'.allMatches(source.substring(0, match.start)).length + 1;
        offenders.add('${_rel(file)}:$line ${match.group(1)}');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          '全站的下拉 / 弹出菜单已在 2026-08-24 统一到 showGlassMenu：\n'
          '  · 触发钮：GlassIconButton / GlassPressable（都要 opensOverlay: true）\n'
          '  · 条目：GlassMenuOption（分组标题 GlassMenuSectionHeader、\n'
          '    分隔线 GlassMenuSeparator、副标题 GlassMenuOption.description）\n'
          '  · 表单里的下拉：GlassDropdownField\n'
          '  · 右键菜单：showGlassMenu(globalAnchor: 指针位置 & Size.zero)\n'
          'Material 的那套吐出来是块不透明卡片，既没有折射也没有长按蠕动，\n'
          '和玻璃触发件接不上（见 glass_menu.dart 文件头）：\n'
          '${offenders.join('\n')}',
    );
  });

  test('开菜单的钮都声明了 opensOverlay（零容忍）', () {
    final offenders = <String>[];
    for (final file in _dartFiles()) {
      final rel = _rel(file);
      if (_opensOverlayExemptFiles.contains(rel)) continue;
      // 注释里提到 showGlassMenu 的（词汇表、类文档）不算调用点。
      final source = file.readAsStringSync().replaceAll(_lineComment, '');
      if (!_showsGlassMenu.hasMatch(source)) continue;
      if (source.contains('opensOverlay: true')) continue;
      offenders.add(rel);
    }
    expect(
      offenders,
      isEmpty,
      reason:
          '这些文件会弹出玻璃菜单，但触发钮没声明 opensOverlay: true——于是长按打不开菜单，\n'
          '「按住 → 划到某一条 → 松手选中」那条也整只没有。组件没法预知 onTap 会干什么，\n'
          '只能由调用点声明一次，见 GlassTapArea.opensOverlay：\n'
          '${offenders.join('\n')}',
    );
  });

  test('没有硬编码的液态档（全局开关能一把关掉，零容忍）', () {
    final offenders = <String>[];
    for (final file in _dartFiles()) {
      if (_rel(file) == _glassBackendSourceOfTruth) continue;
      // 注释里提到档位名字的（词汇表、类文档）不算供档点。
      final source = file.readAsStringSync().replaceAll(_lineComment, '');
      for (final match in _hardcodedLiquidBackend.allMatches(source)) {
        final line =
            '\n'.allMatches(source.substring(0, match.start)).length + 1;
        offenders.add('${_rel(file)}:$line ${match.group(0)}');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          '玻璃质感现在是用户在主题设置里选的（真玻璃 / 假玻璃，见 '
          'GlassMaterialMode）。谁把液态档写成字面量，谁就绕过了那个开关——'
          '用户关掉模糊之后这块玻璃还在采样背景，而且改了不会重建。\n'
          '  · 页面 chrome（header 胶囊 / 浮动底栏 / 浮钮 / 动作坞）：\n'
          '    LiquidGlassScope(backend: chromeGlassBackend(context))\n'
          '  · 浮出面板（菜单 / 下拉板）：panelGlassBackend(anchorContext)\n'
          '  · 确实要在液态子树里局部关掉：GlassBackend.plain（这个不受限）\n'
          '${offenders.join('\n')}',
    );
  });

  test('裸 Material 按钮数量只降不升', () {
    _expectRatchet(
      pattern: _rawMaterialButton,
      baseline: _rawMaterialButtonBaseline,
      what: '裸 Material 按钮',
      fix:
          '弹窗动作行改 GlassDialogAction / 其余改 GlassButtonGroup + '
          'GlassTextActionButton',
    );
  });

  test('裸 showDialog / showGeneralDialog 数量只降不升', () {
    _expectRatchet(
      pattern: _rawDialogRoute,
      baseline: _rawDialogRouteBaseline,
      what: '裸弹窗路由',
      fix: '改用 showAppDialog（液态档与出入场都供在那条路由上）',
    );
  });
}

final _rawAlertDialog = RegExp(r'AlertDialog\(');
final _opacityWrapper = RegExp(
  r'(?<![A-Za-z0-9_])(AnimatedOpacity|FadeTransition|Opacity)\(',
);
final _glassWidget = RegExp(
  r'(?<![A-Za-z0-9_])(GlassIconButton|GlassButtonGroup|GlassSurface|'
  r'GlassTextActionButton|GlassSelectionDock)\(',
);
final _rawMaterialButton = RegExp(
  r'(?<![A-Za-z0-9_])(TextButton|ElevatedButton|FilledButton|OutlinedButton)'
  r'(\.[A-Za-z]+)?\(',
);
final _lineComment = RegExp(r'^[ \t]*//.*$', multiLine: true);

/// Material 那套下拉 / 弹出菜单。`showMenuTooltip` 一类的标识符不会命中：
/// 名字后面必须紧跟 `(` 或 `<`。
final _materialPopup = RegExp(
  r'(?<![A-Za-z0-9_])(PopupMenuButton|PopupMenuItem|CheckedPopupMenuItem|'
  r'PopupMenuDivider|PopupMenuEntry|DropdownButton|DropdownButtonFormField|'
  r'DropdownMenuItem|DropdownMenu|showMenu)\s*[(<]',
);
final _showsGlassMenu = RegExp(r'(?<![A-Za-z0-9_])showGlassMenu(<[^>\n]*>)?\(');

/// 玻璃菜单自己的实现文件，以及**不由玻璃按钮触发**的调用点。
const _opensOverlayExemptFiles = <String>{
  'lib/app/ui/widgets/glass/glass_menu.dart',
  // 触发钮是 Material 的 ElevatedButton / ActionIconButtonScaffold（关注按钮
  // 本身没有玻璃化，只有它吐出来的面板换了）。没有 GlassTapArea 就接不了
  // 「长按不抬手直接划进面板」那条手指接力，普通点按照常。
  'lib/app/ui/widgets/follow_button_widget.dart',
  // 同上：右键上下文菜单由 GestureDetector.onSecondaryTapUp 触发，
  // 桌面端右键本来就没有「长按」这一说。
  'lib/app/ui/pages/download/widgets/default_download_task_item_widget.dart',
  'lib/app/ui/pages/download/widgets/video_download_task_item_widget.dart',
  'lib/app/ui/pages/download/widgets/gallery_download_task_item_widget.dart',
};

/// 硬编码的液态档供档点：`backend: GlassBackend.liquidWidgets` 之类。
/// 比较（`== GlassBackend.easyLens`）不算——那是组件内部按当前档分支，不是供档。
final _hardcodedLiquidBackend = RegExp(
  r'backend:\s*GlassBackend\.(liquidWidgets|easyLens)',
);

/// 全局材质开关与两个供档函数的定义处——液态档字面量只该出现在这里。
const _glassBackendSourceOfTruth =
    'lib/app/ui/widgets/glass/liquid_glass_material.dart';

final _rawDialogRoute = RegExp(
  r'(?<![A-Za-z0-9_])(showDialog|showGeneralDialog)(<[^>\n]*>)?\(',
);

/// 玻璃组件自己的实现文件——它们**就是**替代品的定义处，不算欠账。
const _exemptFiles = <String>{
  'lib/app/ui/widgets/glass/glass_alert_dialog.dart',
  'lib/app/ui/widgets/glass/glass_dialog_motion.dart',
};

/// 当前欠账快照（2026-08-24）。**只许降，不许升。**
const _rawMaterialButtonBaseline = <String, int>{
  'lib/app/ui/pages/author_profile/author_profile_page.dart': 1,
  'lib/app/ui/pages/comment/widgets/comment_remove_dialog.dart': 2,
  'lib/app/ui/pages/comment/widgets/comment_replies_bottom_sheet.dart': 2,
  'lib/app/ui/pages/comment/widgets/comment_section_widget.dart': 2,
  'lib/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart': 2,
  'lib/app/ui/pages/download/download_category_manage_page.dart': 1,
  'lib/app/ui/pages/download/widgets/download_picker_sheet.dart': 2,
  'lib/app/ui/pages/download/widgets/move_to_category_sheet.dart': 1,
  'lib/app/ui/pages/emoji_library/emoji_group_detail_page.dart': 5,
  'lib/app/ui/pages/favorite/favorite_folder_detail_page.dart': 2,
  'lib/app/ui/pages/favorite/favorite_list_page.dart': 1,
  'lib/app/ui/pages/favorite_tags/favorite_tags_page.dart': 1,
  'lib/app/ui/pages/first_time_setup/widgets/welcome_step_widget.dart': 1,
  'lib/app/ui/pages/forum/forum_page.dart': 2,
  'lib/app/ui/pages/gallery_detail/gallery_detail_page.dart': 3,
  'lib/app/ui/pages/gallery_detail/widgets/image_widget.dart': 6,
  'lib/app/ui/pages/gallery_detail/widgets/video_player_widget.dart': 4,
  'lib/app/ui/pages/history/history_list_page.dart': 3,
  'lib/app/ui/pages/local_video_detail/widgets/local_video_info_widget.dart': 2,
  'lib/app/ui/pages/login/login_page_v2.dart': 4,
  'lib/app/ui/pages/news/news_detail_page.dart': 3,
  'lib/app/ui/pages/news/news_page.dart': 1,
  'lib/app/ui/pages/notifications/notification_list_page.dart': 1,
  'lib/app/ui/pages/notifications/widgets/notification_list_item_widget.dart':
      4,
  'lib/app/ui/pages/popular_media_list/controllers/popular_gallery_controller.dart':
      2,
  'lib/app/ui/pages/popular_media_list/widgets/blocked_media_card_placeholder.dart':
      2,
  'lib/app/ui/pages/popular_media_list/widgets/media_description_widget.dart':
      2,
  'lib/app/ui/pages/popular_media_list/widgets/popular_media_search_config_widget.dart':
      2,
  'lib/app/ui/pages/popular_media_list/widgets/remove_search_tag_dialog.dart':
      1,
  'lib/app/ui/pages/post_detail/post_detail_page.dart': 2,
  'lib/app/ui/pages/post_detail/widgets/share_post_bottom_sheet.dart': 2,
  'lib/app/ui/pages/search/search_result.dart': 2,
  'lib/app/ui/pages/search/widgets/filter_builder_widget.dart': 4,
  'lib/app/ui/pages/settings/about_page.dart': 4,
  'lib/app/ui/pages/settings/block_settings_page.dart': 5,
  'lib/app/ui/pages/settings/diagnostics_page.dart': 1,
  'lib/app/ui/pages/settings/download_settings_page.dart': 10,
  'lib/app/ui/pages/settings/google_translation_settings_page.dart': 2,
  'lib/app/ui/pages/settings/history_update_logs_page.dart': 1,
  'lib/app/ui/pages/settings/keybinding_settings_page.dart': 2,
  'lib/app/ui/pages/settings/widgets/ai_translation_setting_widget.dart': 3,
  'lib/app/ui/pages/settings/widgets/base_proxy_widget.dart': 2,
  'lib/app/ui/pages/settings/widgets/deeplx_translation_setting_widget.dart': 2,
  'lib/app/ui/pages/settings/widgets/download_test_widget.dart': 1,
  'lib/app/ui/pages/settings/widgets/proxy_config_widget.dart': 1,
  'lib/app/ui/pages/settings/widgets/recommended_paths_widget.dart': 1,
  'lib/app/ui/pages/sign_in/sing_in_page.dart': 6,
  'lib/app/ui/pages/subscriptions/subscriptions_page.dart': 2,
  'lib/app/ui/pages/subscriptions/widgets/subscription_select_list_widget.dart':
      2,
  'lib/app/ui/pages/tag_blacklist/tag_blacklist_page.dart': 2,
  'lib/app/ui/pages/video_detail/controllers/my_video_state_controller.dart': 7,
  'lib/app/ui/pages/video_detail/video_detail_page_v2.dart': 6,
  'lib/app/ui/pages/video_detail/widgets/detail/add_video_to_playlist_dialog.dart':
      1,
  'lib/app/ui/pages/video_detail/widgets/detail/like_avatars_widget.dart': 1,
  'lib/app/ui/pages/video_detail/widgets/dlna_cast_sheet.dart': 5,
  'lib/app/ui/pages/video_detail/widgets/player/bottom_toolbar_widget.dart': 2,
  'lib/app/ui/pages/video_detail/widgets/player/video_gesture_guide_page.dart':
      2,
  'lib/app/ui/pages/video_detail/widgets/player/widgets/error_state_widget.dart':
      6,
  'lib/app/ui/pages/video_detail/widgets/player/widgets/playback_issue_sheet.dart':
      3,
  'lib/app/ui/pages/video_detail/widgets/private_or_deleted_video_widget.dart':
      6,
  'lib/app/ui/widgets/add_to_favorite_dialog.dart': 1,
  'lib/app/ui/widgets/ai_translation_toggle_button.dart': 3,
  'lib/app/ui/widgets/block_user_button_widget.dart': 2,
  'lib/app/ui/widgets/empty_widget.dart': 1,
  'lib/app/ui/widgets/follow_button_widget.dart': 3,
  'lib/app/ui/widgets/friend_button_widget.dart': 5,
  'lib/app/ui/widgets/iwara_site_switcher.dart': 2,
  'lib/app/ui/widgets/like_button_widget.dart': 1,
  'lib/app/ui/widgets/loading_button_widget.dart': 2,
  'lib/app/ui/widgets/oreno3d_video_card.dart': 2,
};

/// 当前欠账快照（2026-08-24）。**只许降，不许升。**
const _rawDialogRouteBaseline = <String, int>{
  'lib/app/ui/pages/download/download_task_list_page.dart': 2,
  'lib/app/ui/pages/download/widgets/download_category_picker.dart': 1,
  'lib/app/ui/pages/favorite/favorite_folder_detail_page.dart': 1,
  'lib/app/ui/pages/favorite/favorite_list_page.dart': 2,
  'lib/app/ui/pages/follows/widgets/special_follows_list.dart': 1,
  'lib/app/ui/pages/forum/forum_page.dart': 1,
  'lib/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart':
      1,
  'lib/app/ui/pages/popular_media_list/widgets/video_tile_list_item_widget.dart':
      1,
  'lib/app/ui/pages/search/widgets/saved_search_drawer.dart': 1,
  'lib/app/ui/pages/settings/app_settings_page.dart': 4,
  'lib/app/ui/pages/settings/keybinding_settings_page.dart': 4,
  'lib/app/ui/pages/settings/widgets/download_test_widget.dart': 1,
  'lib/app/ui/pages/settings/widgets/player_settings_widget.dart': 1,
  'lib/app/ui/pages/video_detail/widgets/player/video_gesture_guide.dart': 1,
  'lib/app/ui/pages/video_detail/widgets/tabs/video_info_tab_widget.dart': 1,
  'lib/app/ui/widgets/oreno3d_video_card.dart': 1,
  'lib/app/ui/widgets/translation_dialog_widget.dart': 1,
};

void _expectRatchet({
  required RegExp pattern,
  required Map<String, int> baseline,
  required String what,
  required String fix,
}) {
  final regressions = <String>[];
  final improvements = <String>[];
  final seen = <String>{};

  for (final file in _dartFiles()) {
    final rel = _rel(file);
    if (_isExempt(file)) continue;
    final count = pattern.allMatches(file.readAsStringSync()).length;
    if (count == 0) continue;
    seen.add(rel);
    final allowed = baseline[rel];
    if (allowed == null) {
      regressions.add('  + $rel：新增 $count 处（基线里没有这个文件）');
    } else if (count > allowed) {
      regressions.add('  ↑ $rel：$allowed → $count');
    } else if (count < allowed) {
      improvements.add('  ↓ $rel：$allowed → $count');
    }
  }
  for (final entry in baseline.entries) {
    if (!seen.contains(entry.key)) {
      improvements.add('  ✓ ${entry.key}：已清空，请从基线里删掉');
    }
  }

  final problems = <String>[
    if (regressions.isNotEmpty) ...['$what 变多了（请改用玻璃组件：$fix）：', ...regressions],
    if (improvements.isNotEmpty) ...[
      '$what 变少了 —— 好事，把基线一起改小锁死战果：',
      ...improvements,
    ],
  ];
  expect(problems, isEmpty, reason: problems.join('\n'));
}

Iterable<File> _dartFiles() sync* {
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) yield entity;
  }
}

String _rel(File file) => file.path.replaceAll(r'\', '/');

bool _isExempt(File file) {
  final rel = _rel(file);
  // 生成物（i18n）里出现这些名字与样式无关
  return _exemptFiles.contains(rel) || rel.startsWith('lib/i18n/');
}
