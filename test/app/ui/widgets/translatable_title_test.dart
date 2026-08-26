import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/translatable_title.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 标题长按必须永远有去处。
///
/// 用户报障：视频 / 图库详情页的标题在**折叠态**长按什么也不会发生——尤其
/// 是短标题，短到根本不出现展开箭头，于是既展不开也复制不了。折叠态渲染的
/// 是一段纯 `Text`（要靠它才有省略号），自身没有任何选中能力，所以必须显式
/// 补一层长按 → 完整标题弹窗（全文可选取 + 复制 / 翻译）。
void main() {
  /// 弹窗里的复制圆钮，只在完整标题弹窗中出现，用它判定弹窗开没开。
  final dialogCopyButton = find.byIcon(Icons.copy_outlined);

  Future<void> pump(
    WidgetTester tester, {
    required String title,
    required double width,
    bool selectable = false,
  }) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: TranslatableTitle(
                  text: title,
                  selectable: selectable,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('短标题（没有展开箭头）长按也能开全文弹窗', (tester) async {
    await pump(tester, title: '短标题', width: 400);

    // 短到不溢出：连折叠箭头都不该出现
    expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    expect(dialogCopyButton, findsNothing);

    await tester.longPress(find.byType(TranslatableTitle));
    await tester.pumpAndSettle();

    expect(dialogCopyButton, findsOneWidget);
    expect(find.byType(SelectableText), findsWidgets);
  });

  testWidgets('长标题折叠态长按开全文弹窗（可选中的视频标题同样）', (tester) async {
    const longTitle = '这是一个很长很长的视频标题，长到一行放不下必须被省略号截断才行';
    await pump(tester, title: longTitle, width: 200, selectable: true);

    // 溢出了才会有折叠箭头（AnimatedCrossFade 两态同时在树上，各有一枚）。
    // 折叠态显示的是纯 Text：可选中的那一份是 crossfade 的底层 child，被
    // IgnorePointer 挡着，长按够不到它。
    expect(find.byIcon(Icons.keyboard_arrow_down), findsWidgets);

    await tester.longPress(find.byType(TranslatableTitle));
    await tester.pumpAndSettle();

    expect(dialogCopyButton, findsOneWidget);
  });

  testWidgets('不可选中的展开态（图库标题）长按同样开全文弹窗', (tester) async {
    const longTitle = '这是一个很长很长的图库标题，长到一行放不下必须被省略号截断才行';
    await pump(tester, title: longTitle, width: 200);

    // 点箭头展开：图库标题不可选中，展开后仍是纯 Text
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down).last);
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);

    await tester.longPress(find.byType(TranslatableTitle));
    await tester.pumpAndSettle();

    expect(dialogCopyButton, findsOneWidget);
  });

  testWidgets('可选中的展开态长按仍归 SelectableText（不被弹窗抢走）', (tester) async {
    const longTitle = '这是一个很长很长的视频标题，长到一行放不下必须被省略号截断才行';
    await pump(tester, title: longTitle, width: 200, selectable: true);

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down).last);
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsOneWidget);

    // 长按落在文字上：SelectableText 自己的长按识别器更深，先赢下竞技场
    final Offset textSpot =
        tester.getTopLeft(find.byType(SelectableText)) + const Offset(40, 10);
    await tester.longPressAt(textSpot);
    await tester.pumpAndSettle();

    expect(
      dialogCopyButton,
      findsNothing,
      reason: '展开态的可选中标题本来就能长按选中 + 复制，不该被全文弹窗顶掉',
    );
  });
}
