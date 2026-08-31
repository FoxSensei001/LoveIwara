import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_search_input_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';

/// 搜索胶囊的两条约定，2026-08-31 报障后立的闸：
///
///   1. **命中区是整只胶囊**，不是文字那一行——点左内边距、点放大镜、点文字上下
///      的空白，都要给输入框取焦（[GlassSearchPillTapArea]）。
///   2. **文字落在胶囊的光学中心**，输入文字与提示文字都是——第一版靠「把 TextField
///      拉满高度 + textAlignVertical」，那只把外框撑大了，里头的行盒仍旧贴着顶
///      （见 [GlassSearchInputField] 类注释里的实测）。摆正之后再往上抬
///      `fontSize × 0.22`：几何正中读着偏沉，那一档是对着 5 倍渲染图挑出来的。
void main() {
  Widget pill({
    required FocusNode focusNode,
    required TextEditingController controller,
    required double height,
    required double fontSize,
    Widget? trailing,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            child: GlassSearchPillTapArea(
              focusNode: focusNode,
              child: GlassSurface(
                height: height,
                liquidTouch: false,
                borderRadius: BorderRadius.circular(height / 2),
                padding: const EdgeInsets.only(left: 16, right: 6),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassSearchInputField(
                        controller: controller,
                        focusNode: focusNode,
                        fontSize: fontSize,
                        hintText: '搜索建议: 132',
                        onSubmitted: (_) {},
                      ),
                    ),
                    ?trailing,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<FocusNode> pump(
    WidgetTester tester, {
    double height = 52,
    double fontSize = 15.5,
    String text = '',
  }) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final controller = TextEditingController(text: text);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      pill(
        focusNode: focusNode,
        controller: controller,
        height: height,
        fontSize: fontSize,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return focusNode;
  }

  // ── 垂直居中 ────────────────────────────────────────────────────────────
  for (final form in const [('桌面 52', 52.0, 15.5), ('移动 44', 44.0, 14.5)]) {
    for (final filled in const [false, true]) {
      testWidgets('${form.$1}${filled ? '（有字）' : '（空）'}：文字落在胶囊的光学中心', (
        tester,
      ) async {
        await pump(
          tester,
          height: form.$2,
          fontSize: form.$3,
          text: filled ? '已经打了几个字' : '',
        );
        final pillRect = tester.getRect(find.byType(GlassSurface));
        // 几何正中再往上 fontSize×0.22 —— 光学抬升，见 GlassSearchInputField
        // 里 _opticalRise 的说明（几何居中读着偏沉，是取向不是 bug）。
        final target = pillRect.center.dy - form.$3 * 0.22;
        final line = tester.getRect(find.byType(EditableText));
        expect(
          line.center.dy,
          moreOrLessEquals(target, epsilon: 0.1),
          reason: '输入行盒没落在光学中心：行盒 ${line.top}..${line.bottom}，胶囊 $pillRect',
        );

        // 提示文字是 InputDecorator 自己摆的一只 Text，行盒规则得跟输入文字一致。
        final hint = find.text('搜索建议: 132');
        if (hint.evaluate().isNotEmpty) {
          expect(
            tester.getRect(hint).center.dy,
            moreOrLessEquals(target, epsilon: 0.1),
            reason: '提示文字与输入文字没落在同一高度',
          );
        }
      });
    }
  }

  testWidgets('行盒高度不看字体脸色：恒等于字号 × 1.25', (tester) async {
    await pump(tester, fontSize: 16);
    final line = tester.getRect(find.byType(EditableText));
    // forceStrutHeight 把 ascent/descent 那套字体 metrics 挡在外面：换字体、
    // 中英混排都不会让这条行盒忽高忽低（也就不会忽上忽下）。
    expect(line.height, moreOrLessEquals(16 * 1.25, epsilon: 0.1));
  });

  // ── 命中区 ──────────────────────────────────────────────────────────────
  testWidgets('点胶囊里任何一处都能取焦', (tester) async {
    final focusNode = await pump(tester);
    final pillRect = tester.getRect(find.byType(GlassSurface));
    final iconRect = tester.getRect(find.byType(Icon));

    final probes = <String, Offset>{
      '左内边距': Offset(pillRect.left + 4, pillRect.center.dy),
      '放大镜图标': iconRect.center,
      '图标与文字之间': Offset(iconRect.right + 4, pillRect.center.dy),
      '文字上方的空白': Offset(pillRect.center.dx, pillRect.top + 4),
      '文字下方的空白': Offset(pillRect.center.dx, pillRect.bottom - 4),
      '右内边距': Offset(pillRect.right - 3, pillRect.center.dy),
    };

    for (final probe in probes.entries) {
      focusNode.unfocus();
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);
      await tester.tapAt(probe.value);
      await tester.pump();
      expect(focusNode.hasFocus, isTrue, reason: '点「${probe.key}」没取上焦');
    }
  });

  testWidgets('胶囊里的按钮照旧是自己的 onPressed，不被取焦层吃掉', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var pressed = 0;

    await tester.pumpWidget(
      pill(
        focusNode: focusNode,
        controller: controller,
        height: 52,
        fontSize: 15.5,
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => pressed++,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(pressed, 1);
  });

  // ── 单行 ────────────────────────────────────────────────────────────────
  testWidgets('仍是单行：回车走 onSubmitted 而不是换行', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? submitted;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 44,
            child: GlassSearchInputField(
              controller: controller,
              focusNode: focusNode,
              hintText: '搜点什么',
              onSubmitted: (v) => submitted = v,
            ),
          ),
        ),
      ),
    );

    expect(tester.widget<TextField>(find.byType(TextField)).maxLines, 1);

    await tester.enterText(find.byType(TextField), 'iwara');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(submitted, 'iwara');
  });
}
