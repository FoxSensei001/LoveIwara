// 多语言版式复测的**截图取证**工具（不是断言型测试）。
//
// 只有在设了环境变量 `I18N_SHOT_DIR` 时才干活，否则整组直接跳过——这样它进
// 常规 CI 套件时不会因为字体/渲染差异变红，需要出证据时手动跑：
//
//   I18N_SHOT_DIR=/tmp/i18n-shots flutter test test/tool/i18n_screenshots_test.dart
//
// 出图内容：底栏（5 格 + 搜索圆钮）与弹窗动作行（3 个动作 = 最挤的一档），
// 按语言 × 屏宽渲染。字体与 `test/i18n_multilingual_layout_test.dart` 同一套：
// Flutter SDK 的 Roboto 打底，再挂 Arial Unicode 兜住中日韩 / 韩文 / 泰文字形。
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_floating_tab_bar.dart';
import 'package:i_iwara/i18n/strings.g.dart';

const String _probeFontFamily = 'I18nProbeFont';

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
  final wide = File('/System/Library/Fonts/Supplemental/Arial Unicode.ttf');
  if (wide.existsSync()) {
    loader.addFont(Future.value(ByteData.sublistView(await wide.readAsBytes())));
    loaded++;
  }
  if (loaded > 0) await loader.load();
}

/// 出图必须在 `tester.runAsync` 里做：widget test 的时钟是假的，`toImage` 这类
/// 真异步调用不套 runAsync 会一直等下去（本文件第一版就是这么挂死的）。
Future<void> _shoot(WidgetTester tester, GlobalKey key, String path) async {
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path).writeAsBytesSync(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  final shotDir = Platform.environment['I18N_SHOT_DIR'];
  if (shotDir == null) {
    test('i18n 截图取证（未设 I18N_SHOT_DIR，跳过）', () {}, skip: '按需运行');
    return;
  }
  Directory(shotDir).createSync(recursive: true);

  setUpAll(() async {
    await _loadProbeFonts();
    await LocaleSettings.instance.loadAllLocales();
  });

  testWidgets('按语言出图：底栏与弹窗动作行', (tester) async {
    const size = Size(360, 690);
    for (final locale in AppLocale.values) {
      final tag = locale.languageTag;
      await LocaleSettings.setLocale(locale);
      final t = LocaleSettings.currentLocale.translations;
      await tester.binding.setSurfaceSize(size);

      final barKey = GlobalKey();
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            theme: ThemeData(fontFamily: _probeFontFamily, useMaterial3: true),
            home: Scaffold(
              backgroundColor: const Color(0xFF1B1B1F),
              body: Align(
                alignment: Alignment.bottomCenter,
                child: RepaintBoundary(
                  key: barKey,
                  child: SizedBox(
                    width: size.width,
                    child: GlassFloatingTabBar(
                      items: [
                        GlassTabItem(
                          icon: Icons.video_library,
                          label: t.bottomNav.video,
                        ),
                        GlassTabItem(icon: Icons.photo, label: t.bottomNav.gallery),
                        GlassTabItem(
                          icon: Icons.subscriptions,
                          label: t.bottomNav.subscription,
                        ),
                        GlassTabItem(icon: Icons.forum, label: t.bottomNav.community),
                        GlassTabItem(
                          icon: Icons.folder_open,
                          label: t.bottomNav.localMedia,
                        ),
                      ],
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
        ),
      );
      await tester.pumpAndSettle();
      await _shoot(tester, barKey, '$shotDir/tabbar_$tag.png');

      final dialogKey = GlobalKey();
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            theme: ThemeData(fontFamily: _probeFontFamily, useMaterial3: true),
            home: Scaffold(
              backgroundColor: const Color(0xFF1B1B1F),
              // 就地渲染弹窗本体（不走路由），只为出图；布局与路由里一致。
              body: Center(
                child: RepaintBoundary(
                  key: dialogKey,
                  child: GlassAlertDialog(
                    title: t.settings.autoDeleteHistory,
                    content: Text(t.settings.autoRecordHistoryDesc),
                    actions: [
                      GlassDialogAction(
                        label: t.common.cancel,
                        emphasized: false,
                        onPressed: () {},
                      ),
                      GlassDialogAction(
                        label: t.common.delete,
                        destructive: true,
                        onPressed: () {},
                      ),
                      GlassDialogAction(label: t.common.confirm, onPressed: () {}),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _shoot(tester, dialogKey, '$shotDir/dialog_$tag.png');
    }
    await tester.binding.setSurfaceSize(null);
  });
}
