import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// composer 底栏是一行「动作组 ··· 状态/字数 · 提交键」。
///
/// ⛔ 提交键必须**一直贴着右边缘**。这条是 analyze 与全套单测都查不出来的
/// 那一类：`Spacer() + Flexible(状态)` 两者都是 flex 1，会把空当对半分，
/// Flexible 那半里用不掉的部分顶在状态标签与提交键之间，把提交键从右边缘
/// 推开一大截（2026-09-21 用户截图报障）。
void main() {
  setUpAll(() {
    slang.LocaleSettings.setLocaleRaw('zh-CN');
  });

  /// 底栏右边缘到提交键右边缘的距离。0 就是贴死了。
  Future<double> gapAfterSubmit(
    WidgetTester tester, {
    String? statusText,
    int? length,
    int? limit,
  }) async {
    await tester.pumpWidget(
      // GlassComposerBar 内部读 `slang.Translations.of(context)`（工具键的
      // tooltip），没有 TranslationProvider 会直接抛。
      slang.TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: GlassComposerBar(
                  onSubmit: () {},
                  statusText: statusText,
                  length: length,
                  limit: limit,
                  onEmoji: () {},
                  onPreview: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    final bar = tester.getRect(find.byType(GlassComposerBar));
    final submit = tester.getRect(find.byType(GlassSubmitButton));
    return bar.right - submit.right;
  }

  testWidgets('没有状态时提交键贴着右边缘', (tester) async {
    expect(await gapAfterSubmit(tester), closeTo(0, 0.5));
  });

  testWidgets('⛔ 挂上状态文案后提交键仍旧贴着右边缘（不许被挤开）', (tester) async {
    expect(
      await gapAfterSubmit(tester, statusText: '正在生成 AI 一言… 1/2'),
      closeTo(0, 0.5),
    );
  });

  testWidgets('⛔ 状态文案再长也只是省略，不推动提交键、不撑破一行', (tester) async {
    expect(
      await gapAfterSubmit(tester, statusText: '正在生成 ' * 40),
      closeTo(0, 0.5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('字数标签在场时同样不推动提交键', (tester) async {
    expect(
      await gapAfterSubmit(tester, length: 990, limit: 1000),
      closeTo(0, 0.5),
    );
  });
}
