// 多语言版式探针：12 门语言 × 多种屏宽，渲染**真实组件**，检查
//
//   (a) 有没有 RenderFlex overflow / 渲染异常；
//   (b) 底栏标签有没有被省略号截断（`didExceedMaxLines`）。
//
// 为什么需要它：德/俄/法/西比中英文长 20~45%，泰语没有词间空格，长词条会把
// 底栏、弹窗这种「宽度预算固定」的地方撑到省略号或溢出。`tool/i18n_check.dart`
// 只管 key 与占位符，管不了版式，这条测试补上另一半。
//
// 判据：**以基准语言 en 为参照**——en 排得下而某门语言排不下，就是这门语言
// 的新词条太长，必须改词条（改 yaml），而不是放宽断言。en 自己也排不下的组合
// （例如 320dp 屏上三个动作键的弹窗）属于既有约束，单独记录，不记到新语言头上。
//
// 字体：优先用 Flutter SDK 里的 Roboto（与安卓端真实字体一致），再挂一份
// Arial Unicode 兜住中日韩 / 韩文 / 泰文这些 Roboto 没有的字形。测试默认字体
// 没有这些字形，量出来的宽度不可信。
//
// 截图证据（可选）：设了环境变量 `I18N_GOLDEN_DIR` 时，每个组合额外写一张 PNG
// 到该目录（配合 `flutter test --update-goldens`）。默认不写，因此这条测试进
// 常规套件时不会因为字体/渲染差异而红。
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_floating_tab_bar.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';

const String _probeFontFamily = 'I18nProbeFont';

final String? _goldenDir = Platform.environment['I18N_GOLDEN_DIR'];

const List<Size> _screens = [
  Size(320, 568), // 最窄的常见手机
  Size(360, 690), // 安卓主流
  Size(640, 360), // 横屏
];

Future<void> _loadProbeFonts() async {
  final loader = FontLoader(_probeFontFamily);
  var loaded = 0;
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    for (final name in const [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
    ]) {
      final file = File('$flutterRoot/bin/cache/artifacts/material_fonts/$name');
      if (file.existsSync()) {
        loader.addFont(
          Future.value(ByteData.sublistView(await file.readAsBytes())),
        );
        loaded++;
      }
    }
  }
  for (final path in const [
    '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
    '/Library/Fonts/Arial Unicode.ttf',
  ]) {
    final file = File(path);
    if (file.existsSync()) {
      loader.addFont(
        Future.value(ByteData.sublistView(await file.readAsBytes())),
      );
      loaded++;
      break;
    }
  }
  if (loaded > 0) await loader.load();
}

List<GlassTabItem> _tabItems(Translations t) => [
  GlassTabItem(icon: Icons.video_library, label: t.bottomNav.video),
  GlassTabItem(icon: Icons.photo, label: t.bottomNav.gallery),
  GlassTabItem(icon: Icons.subscriptions, label: t.bottomNav.subscription),
  GlassTabItem(icon: Icons.forum, label: t.bottomNav.community),
  GlassTabItem(icon: Icons.folder_open, label: t.bottomNav.localMedia),
];

Future<void> _pumpTabBar(WidgetTester tester, AppLocale locale, Size size) async {
  await tester.binding.setSurfaceSize(size);
  await LocaleSettings.setLocale(locale);
  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(fontFamily: _probeFontFamily, useMaterial3: true),
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            // 生产里这条栏吃 Scaffold 的整宽；这里必须显式给宽，否则 Align 传
            // 下去的是松约束，`_labelMaxWidth` 拿不到有限宽度，标签不会被钉住
            // （探针会假阴性）。
            child: SizedBox(
              width: size.width,
              child: GlassFloatingTabBar(
                items: _tabItems(LocaleSettings.currentLocale.translations),
                currentIndex: 2,
                onTap: (_) {},
                action: GlassFloatingBarAction(
                  icon: Icons.search,
                  label: 'search',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 收集某个子树里被省略号截断的文本。
List<String> _truncatedTexts(WidgetTester tester, Type widgetType) {
  final truncated = <String>[];
  for (final element in find
      .descendant(of: find.byType(widgetType), matching: find.byType(RichText))
      .evaluate()) {
    final paragraph = element.renderObject;
    if (paragraph is RenderParagraph && paragraph.didExceedMaxLines) {
      truncated.add(paragraph.text.toPlainText());
    }
  }
  return truncated;
}

void main() {
  setUpAll(() async {
    await _loadProbeFonts();
    await LocaleSettings.instance.loadAllLocales();
  });

  testWidgets('底栏 5 格 + 搜索圆钮：12 门语言 × 3 种屏宽', (tester) async {
    final report = <String>[];
    final truncatedByLocale = <String, Set<String>>{};
    final overflowByLocale = <String, Set<String>>{};

    for (final locale in AppLocale.values) {
      final tag = locale.languageTag;
      truncatedByLocale[tag] = <String>{};
      overflowByLocale[tag] = <String>{};
      for (final size in _screens) {
        await _pumpTabBar(tester, locale, size);
        final exception = tester.takeException();
        if (exception != null) {
          overflowByLocale[tag]!.add('${size.width.toInt()}x${size.height.toInt()}');
        }
        final truncated = _truncatedTexts(tester, GlassFloatingTabBar);
        truncatedByLocale[tag]!.addAll(
          truncated.map((label) => '${size.width.toInt()}:$label'),
        );
        report.add(
          'I18N-LAYOUT tabbar locale=$tag size=${size.width.toInt()}x${size.height.toInt()} '
          'truncated=${truncated.length}${truncated.isEmpty ? '' : ' ${truncated.toSet().join(' | ')}'}'
          '${exception == null ? '' : ' EXCEPTION'}',
        );
        final dir = _goldenDir;
        if (dir != null) {
          await expectLater(
            find.byType(GlassFloatingTabBar),
            matchesGoldenFile(
              Uri.file('$dir/tabbar_${tag}_${size.width.toInt()}x${size.height.toInt()}.png'),
            ),
          );
        }
      }
    }

    // ignore: avoid_print
    print(report.join('\n'));
    // ignore: avoid_print
    print('I18N-LAYOUT tabbar-summary '
        '${overflowByLocale.entries.map((e) => '${e.key}:overflow=${e.value.length}').join(' ')}');

    for (final locale in AppLocale.values) {
      final tag = locale.languageTag;
      expect(
        overflowByLocale[tag],
        isEmpty,
        reason: '底栏在 $tag 溢出（RenderFlex overflow）',
      );
    }
    // en 排得下的标签，别的语言也必须排得下（不允许靠省略号糊过去）。
    final baseline = truncatedByLocale['en']!;
    for (final locale in AppLocale.values) {
      final tag = locale.languageTag;
      expect(
        truncatedByLocale[tag]!.difference(baseline),
        isEmpty,
        reason: '底栏标签在 $tag 被省略号截断，但 en 排得下——属词条过长，'
            '应改 lib/i18n/$tag.i18n.yaml 的 bottomNav.* 短标签',
      );
    }
  });

  for (final actionCount in const [2, 3]) {
    testWidgets('弹窗动作行（$actionCount 个动作）：12 门语言 × 竖屏窄屏', (tester) async {
      final report = <String>[];
      final overflowByLocale = <String, Set<String>>{};
      for (final locale in AppLocale.values) {
        final tag = locale.languageTag;
        overflowByLocale[tag] = <String>{};
        for (final size in const [Size(320, 568), Size(360, 690)]) {
          await tester.binding.setSurfaceSize(size);
          await LocaleSettings.setLocale(locale);
          final t = LocaleSettings.currentLocale.translations;
          late BuildContext hostContext;
          await tester.pumpWidget(
            TranslationProvider(
              child: MaterialApp(
                theme: ThemeData(fontFamily: _probeFontFamily, useMaterial3: true),
                home: Builder(
                  builder: (context) {
                    hostContext = context;
                    return const Scaffold(body: SizedBox.expand());
                  },
                ),
              ),
            ),
          );
          // 走生产的弹窗路由：SafeArea + 主题捕获 + 出厂动画都在那一层，
          // 直接塞进 Center 量出来的宽度不代表真机。
          showAppDialog(
            GlassAlertDialog(
              title: t.settings.autoDeleteHistory,
              content: Text(t.settings.autoRecordHistoryDesc),
              actions: [
                GlassDialogAction(
                  label: t.common.cancel,
                  emphasized: false,
                  onPressed: () {},
                ),
                if (actionCount >= 3)
                  GlassDialogAction(
                    label: t.common.delete,
                    destructive: true,
                    onPressed: () {},
                  ),
                GlassDialogAction(label: t.common.confirm, onPressed: () {}),
              ],
            ),
            dialogContext: hostContext,
            useRootNavigator: false,
          );
          await tester.pumpAndSettle();
          final exception = tester.takeException();
          if (exception != null) {
            overflowByLocale[tag]!.add('${size.width.toInt()}x${size.height.toInt()}');
          }
          report.add(
            'I18N-LAYOUT dialog actions=$actionCount locale=$tag '
            'size=${size.width.toInt()}x${size.height.toInt()} '
            '${exception == null ? 'ok' : 'OVERFLOW'}',
          );
          final dir = _goldenDir;
          if (dir != null) {
            await expectLater(
              find.byType(GlassAlertDialog),
              matchesGoldenFile(
                Uri.file('$dir/dialog${actionCount}_${tag}_${size.width.toInt()}x${size.height.toInt()}.png'),
              ),
            );
          }
        }
      }
      // ignore: avoid_print
      print(report.join('\n'));
      // ignore: avoid_print
      print('I18N-LAYOUT dialog-summary actions=$actionCount '
          '${overflowByLocale.entries.map((e) => '${e.key}:${e.value.isEmpty ? '-' : e.value.join(',')}').join(' ')}');

      final baseline = overflowByLocale['en']!;
      for (final locale in AppLocale.values) {
        final tag = locale.languageTag;
        expect(
          overflowByLocale[tag]!.difference(baseline),
          isEmpty,
          reason: '弹窗（$actionCount 个动作）在 $tag 溢出，但 en 同样的组合不溢出'
              '——属词条过长，应改该语言的按钮文案',
        );
      }
    });
  }
}
