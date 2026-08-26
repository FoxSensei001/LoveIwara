import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_picker_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 选择器弹窗骨架的两条硬约束。
///
/// 2026-08-26 报障：本地收藏 / 播放列表弹窗里「列表和顶部那两行控件的底部
/// 毫无空隙，且横向 padding 不一致」。
///
/// 根因不是某一张弹窗写错了数，是四张弹窗各自在文件顶部**手写常数去猜自己
/// 有多高**：`_kSearchRowHeight = 8 + 44`。而玻璃输入框实测是 48
/// （`prefixIcon` 的默认约束 `kMinInteractiveDimension` 顶着），
/// `IconButton.filled(constraints: tightFor(44, 44))` 实测也是 48
/// （`MaterialTapTargetSize.padded` 又套了一层 48 点击区）。
/// 每多一行输入框就少算 4，两行正好把 8px 的尾部留白吃干净。
///
/// 所以这里锁的是**机制**而不是某几个数字：
///   · 留白由实测算出来，字号放大 / 加减一行都不会再被吃掉；
///   · header 每一行与列表内容左对齐在同一条线上。
void main() {
  Widget host(Widget child) => TranslationProvider(
    child: MaterialApp(home: Scaffold(body: child)),
  );

  /// 搭一张 [fieldRows] 行输入框的选择器弹窗，返回它下发给列表的 headerExtent。
  Future<double> pumpPicker(
    WidgetTester tester, {
    int fieldRows = 2,
    double textScale = 1.0,
  }) async {
    final controllers = List.generate(
      fieldRows,
      (_) => TextEditingController(),
    );
    addTearDown(() {
      for (final c in controllers) {
        c.dispose();
      }
    });

    late double reported;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: GlassPickerDialog(
              title: '选择器',
              rows: [
                for (var i = 0; i < fieldRows; i++)
                  GlassPickerRow.field(
                    child: GlassPickerField(
                      key: ValueKey('row$i'),
                      controller: controllers[i],
                      hintText: 'hint$i',
                      icon: Icons.search,
                    ),
                  ),
              ],
              bodyBuilder: (context, headerExtent) {
                reported = headerExtent;
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    GlassPickerDialog.hPadding,
                    headerExtent,
                    GlassPickerDialog.hPadding,
                    12,
                  ),
                  children: [
                    Container(key: const ValueKey('firstItem'), height: 60),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return reported;
  }

  group('header 底缘与列表之间的留白', () {
    testWidgets('两行输入框：留白是 tailSpacing，不是 0（报障的那张）', (tester) async {
      await pumpPicker(tester, fieldRows: 2);
      final double gap =
          tester.getRect(find.byKey(const ValueKey('firstItem'))).top -
          tester.getRect(find.byKey(const ValueKey('row1'))).bottom;
      expect(
        gap,
        moreOrLessEquals(GlassPickerDialog.tailSpacing, epsilon: 0.5),
      );
    });

    testWidgets('一行输入框：同样是 tailSpacing', (tester) async {
      await pumpPicker(tester, fieldRows: 1);
      final double gap =
          tester.getRect(find.byKey(const ValueKey('firstItem'))).top -
          tester.getRect(find.byKey(const ValueKey('row0'))).bottom;
      expect(
        gap,
        moreOrLessEquals(GlassPickerDialog.tailSpacing, epsilon: 0.5),
      );
    });

    testWidgets('放大字号后留白仍在——高度是实测的，不是常数', (tester) async {
      final double normal = await pumpPicker(tester, fieldRows: 2);
      final double scaled = await pumpPicker(
        tester,
        fieldRows: 2,
        textScale: 1.8,
      );
      expect(
        scaled,
        greaterThan(normal),
        reason: '字号放大后 header 真的变高了，headerExtent 必须跟着变',
      );
      final double gap =
          tester.getRect(find.byKey(const ValueKey('firstItem'))).top -
          tester.getRect(find.byKey(const ValueKey('row1'))).bottom;
      expect(
        gap,
        moreOrLessEquals(GlassPickerDialog.tailSpacing, epsilon: 0.5),
      );
    });
  });

  testWidgets('标题 / 控件行 / 列表内容左对齐在同一条线上', (tester) async {
    await pumpPicker(tester, fieldRows: 2);
    final double titleLeft = tester.getRect(find.text('选择器')).left;
    final double row0Left = tester
        .getRect(find.byKey(const ValueKey('row0')))
        .left;
    final double row1Left = tester
        .getRect(find.byKey(const ValueKey('row1')))
        .left;
    final double itemLeft = tester
        .getRect(find.byKey(const ValueKey('firstItem')))
        .left;
    expect(row0Left, moreOrLessEquals(titleLeft, epsilon: 0.5));
    expect(row1Left, moreOrLessEquals(titleLeft, epsilon: 0.5));
    expect(
      itemLeft,
      moreOrLessEquals(titleLeft, epsilon: 0.5),
      reason: '列表内容原本是 12、标题是 20、控件行是 16，三条线各走各的',
    );
  });
}
