import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// [GlassDropdownField] 的两条外观契约，都是 2026-08-26 真机看出来的：
///   1. 展开箭头要**贴右**，不能紧跟在文字屁股后面——文字长短不该让箭头晃；
///   2. `enabled: false` 要**看得出来**。筛选抽屉里「没选年份则月份不可点」，
///      在此之前两只 Select 长得一模一样，点不动只会让人以为是自己没点准。
void main() {
  Widget host(Widget child, {double width = 320}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );
  }

  const items = <GlassDropdownItem<String>>[
    GlassDropdownItem(value: 'a', label: '短'),
    GlassDropdownItem(value: 'b', label: '长一点的选项'),
  ];

  testWidgets('宽度有界时撑满，箭头贴右（与文字长短无关）', (tester) async {
    for (final value in ['a', 'b']) {
      await tester.pumpWidget(
        host(
          GlassDropdownField<String>(
            value: value,
            items: items,
            onChanged: (_) {},
          ),
        ),
      );
      final field = tester.getRect(find.byType(GlassDropdownField<String>));
      final chevron = tester.getRect(find.byIcon(Icons.expand_more));
      expect(
        field.width,
        320,
        reason: '有界宽度下选择器应该撑满，而不是按文字收缩',
      );
      expect(
        chevron.right,
        // 12 是内边距，再减一条 0.6 的描边
        closeTo(field.right - 12 - GlassTokens.strokeWidth, 0.5),
        reason: '箭头右缘该落在右内边距上（选中「$value」时）',
      );
    }
  });

  testWidgets('shrinkWrap: true 时按内容收缩（ListTile.trailing 那类位置）', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.centerLeft,
          child: GlassDropdownField<String>(
            shrinkWrap: true,
            value: 'a',
            items: items,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    final field = tester.getRect(find.byType(GlassDropdownField<String>));
    expect(field.width, lessThan(320));
  });

  testWidgets('禁用态与可用态的文字/箭头颜色不同（不是只有点不动）', (tester) async {
    Color chevronColor() =>
        tester.widget<Icon>(find.byIcon(Icons.expand_more)).color!;
    Color labelColor() => tester.widget<Text>(find.text('短')).style!.color!;

    await tester.pumpWidget(
      host(
        GlassDropdownField<String>(
          value: 'a',
          items: items,
          onChanged: (_) {},
        ),
      ),
    );
    final enabledChevron = chevronColor();
    final enabledLabel = labelColor();

    await tester.pumpWidget(
      host(
        GlassDropdownField<String>(
          enabled: false,
          value: 'a',
          items: items,
          onChanged: (_) {},
        ),
      ),
    );
    expect(chevronColor(), isNot(enabledChevron));
    expect(labelColor(), isNot(enabledLabel));
    expect(
      chevronColor().a,
      lessThan(enabledChevron.a),
      reason: '禁用态该更淡，而不是换个别的颜色',
    );
  });

  testWidgets('禁用时点击不弹菜单', (tester) async {
    await tester.pumpWidget(
      host(
        GlassDropdownField<String>(
          enabled: false,
          value: 'a',
          items: items,
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.byType(GlassDropdownField<String>));
    await tester.pumpAndSettle();
    expect(find.text('长一点的选项'), findsNothing);
  });
}
