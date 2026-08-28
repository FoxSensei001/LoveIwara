import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/player_keybinding/text_input_focus.dart';

/// 「打字时全局快捷键让位」这道闸门的回归测试。
///
/// 复现的是这个真实缺陷：全局返回默认绑 Esc，而按键会从聚焦节点冒泡到应用根部的
/// 全局处理器，`EditableText` 又不消费 Esc —— 于是在评论框里写到一半按 Esc，
/// 整页被退掉、草稿一起没。
void main() {
  group('isTextInputFocused', () {
    testWidgets('输入框聚焦时为真', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TextField(autofocus: true))),
      );
      await tester.pumpAndSettle();
      expect(isTextInputFocused(), isTrue);
    });

    testWidgets('焦点在按钮上时为假（别把普通可聚焦控件也当成输入框）', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              autofocus: true,
              onPressed: () {},
              child: const Text('按钮'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(isTextInputFocused(), isFalse);
    });

    testWidgets('无焦点时为假', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      await tester.pumpAndSettle();
      expect(isTextInputFocused(), isFalse);
    });

    testWidgets('输入框失焦后回到假', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TextField(autofocus: true))),
      );
      await tester.pumpAndSettle();
      expect(isTextInputFocused(), isTrue);

      expect(unfocusTextInput(), isTrue);
      await tester.pumpAndSettle();
      expect(isTextInputFocused(), isFalse);

      // 已经没有输入焦点时，收起操作应当告诉调用方「没我的事」。
      expect(unfocusTextInput(), isFalse);
    });
  });

  group('根部全局快捷键的让位行为', () {
    /// 复刻 my_app.dart `_shortCutsWrapper` 的结构：一个挂在整棵树根部、
    /// 只参与冒泡的 Focus。这里用它来断言「谁应该吃到这次按键」。
    Widget buildHarness({
      required List<String> globalHandled,
      required TextEditingController controller,
    }) {
      // 必须挂在 Navigator **之上**，与 my_app.dart 里 `_shortCutsWrapper` 包住
      // widget.child 的位置一致。挂在路由内部是测不出来的：输入框失焦后主焦点会
      // 回到路由自己的 FocusScope，而那只 scope 是路由内部节点的祖先，事件只会
      // 往上走、不会再经过它的后代。
      return MaterialApp(
        builder: (context, child) => Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            if (event.logicalKey != LogicalKeyboardKey.escape) {
              return KeyEventResult.ignored;
            }
            // ↓↓↓ 被测的那道闸门 ↓↓↓
            if (isTextInputFocused()) {
              FocusManager.instance.primaryFocus?.unfocus();
              return KeyEventResult.handled;
            }
            globalHandled.add('globalBack');
            return KeyEventResult.handled;
          },
          child: child!,
        ),
        home: Scaffold(
          body: TextField(controller: controller, autofocus: true),
        ),
      );
    }

    testWidgets('打字时按 Esc 只收起输入焦点，不触发全局返回', (tester) async {
      final handled = <String>[];
      final controller = TextEditingController(text: '写了一半的评论');
      await tester.pumpWidget(
        buildHarness(globalHandled: handled, controller: controller),
      );
      await tester.pumpAndSettle();
      expect(isTextInputFocused(), isTrue, reason: '前提：输入框已聚焦');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(
        handled,
        isEmpty,
        reason: '这一下 Esc 不该走到全局返回——那正是「草稿被退没了」的成因',
      );
      expect(isTextInputFocused(), isFalse, reason: '应当已收起输入焦点');
      expect(controller.text, '写了一半的评论', reason: '草稿必须还在');
    });

    testWidgets('失焦之后再按 Esc 才是真的返回', (tester) async {
      final handled = <String>[];
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildHarness(globalHandled: handled, controller: controller),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape); // 第一下：收起焦点
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape); // 第二下：返回
      await tester.pumpAndSettle();

      expect(handled, ['globalBack']);
    });
  });
}
