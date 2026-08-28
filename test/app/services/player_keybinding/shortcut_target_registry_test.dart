import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';
import 'package:i_iwara/app/services/player_keybinding/text_input_focus.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_target_registry.dart';

/// 真机复现的缺陷：播放器快捷键原本挂在自己那只 Focus 上，只有当 Flutter 焦点
/// 恰好落在播放器子树里才生效。实测新开视频页 20 秒内注入 5 次按键一条都收不到，
/// 注入 Tab 把焦点移进去才收得到——「自定义键不生效、方向键有效」的真因。
///
/// 注册表把「谁接管按键」从焦点改成显式的合格判定，这些用例守的就是那套判定。
void main() {
  final registry = ShortcutTargetRegistry.instance;

  setUp(registry.clearForTest);
  tearDown(registry.clearForTest);

  KeyEvent downEvent() => const KeyDownEvent(
    physicalKey: PhysicalKeyboardKey.keyF,
    logicalKey: LogicalKeyboardKey.keyF,
    timeStamp: Duration.zero,
  );

  void addTarget(
    Object owner, {
    required bool eligible,
    required List<Object> log,
    bool handles = true,
    ShortcutScope scope = ShortcutScope.video,
  }) {
    registry.register(
      owner: owner,
      scope: scope,
      isEligible: () => eligible,
      handle: (event) {
        log.add(owner);
        return handles ? KeyEventResult.handled : KeyEventResult.ignored;
      },
    );
  }

  test('没有任何目标时不接管', () {
    expect(registry.dispatch(downEvent()), KeyEventResult.ignored);
    expect(registry.activeScope, isNull);
  });

  test('单个合格目标接管', () {
    final log = <Object>[];
    addTarget('video', eligible: true, log: log);
    expect(registry.dispatch(downEvent()), KeyEventResult.handled);
    expect(log, ['video']);
  });

  test('不合格的目标一律跳过，连 handle 都不会被调用', () {
    final log = <Object>[];
    addTarget('covered', eligible: false, log: log);
    expect(registry.dispatch(downEvent()), KeyEventResult.ignored);
    expect(log, isEmpty, reason: '不合格就不该拿到事件');
    expect(registry.activeScope, isNull);
  });

  test('视频页层层叠加：被盖住的那个不许抢栈顶的按键', () {
    // A 在播 → push B，A 暂停但仍然挂载。A 的 isCurrent 为 false。
    final log = <Object>[];
    addTarget('pageA', eligible: false, log: log);
    addTarget('pageB', eligible: true, log: log);
    registry.dispatch(downEvent());
    expect(log, ['pageB'], reason: '只能是栈顶那个还合格的页面接管');
  });

  test('栈顶不合格时往下找（内嵌层与全屏层同时挂载的情形）', () {
    final log = <Object>[];
    addTarget('inline', eligible: true, log: log);
    addTarget('fullscreenLayerNotActive', eligible: false, log: log);
    registry.dispatch(downEvent());
    expect(log, ['inline']);
  });

  test('目标表示「不归我管」时继续往下问', () {
    final log = <Object>[];
    addTarget('lower', eligible: true, log: log);
    addTarget('upper', eligible: true, log: log, handles: false);
    expect(registry.dispatch(downEvent()), KeyEventResult.handled);
    expect(log, ['upper', 'lower'], reason: '先问栈顶，未接管再往下');
  });

  test('反注册后不再接管（页面销毁）', () {
    final log = <Object>[];
    addTarget('video', eligible: true, log: log);
    registry.unregister('video');
    expect(registry.dispatch(downEvent()), KeyEventResult.ignored);
    expect(registry.length, 0);
  });

  test('同一个 owner 重复注册只保留最新的一份', () {
    final log = <Object>[];
    addTarget('video', eligible: true, log: log);
    addTarget('video', eligible: true, log: log);
    expect(registry.length, 1);
    registry.dispatch(downEvent());
    expect(log, ['video'], reason: '重复注册不能导致一次按键派发两遍');
  });

  test('合格判定是每次派发实时求值，不是注册时快照', () {
    // 这条守的是「事件标记会永久冻结」那个坑：RouteObserver 不把
    // removeRoute / pushReplacement 转成 didPopNext。
    var eligible = false;
    final log = <Object>[];
    registry.register(
      owner: 'video',
      scope: ShortcutScope.video,
      isEligible: () => eligible,
      handle: (event) {
        log.add('video');
        return KeyEventResult.handled;
      },
    );
    expect(registry.dispatch(downEvent()), KeyEventResult.ignored);
    eligible = true;
    expect(registry.dispatch(downEvent()), KeyEventResult.handled);
    expect(log, ['video']);
  });

  test('activeScope 反映的是栈顶第一个合格目标', () {
    final log = <Object>[];
    addTarget('gallery', eligible: true, log: log, scope: ShortcutScope.gallery);
    addTarget('videoCovered', eligible: false, log: log);
    expect(registry.activeScope, ShortcutScope.gallery);
  });

  test('松开事件同样会被转发（长按倍速要靠 KeyUp 收尾）', () {
    final seen = <KeyEvent>[];
    registry.register(
      owner: 'video',
      scope: ShortcutScope.video,
      isEligible: () => true,
      handle: (event) {
        seen.add(event);
        return KeyEventResult.handled;
      },
    );
    const up = KeyUpEvent(
      physicalKey: PhysicalKeyboardKey.arrowRight,
      logicalKey: LogicalKeyboardKey.arrowRight,
      timeStamp: Duration.zero,
    );
    registry.dispatch(up);
    expect(
      seen.single,
      isA<KeyUpEvent>(),
      reason: '只转发 KeyDownEvent 会让进度键卡在长按倍速态',
    );
  });

  group('根部处理器的顺序：打字时叶子作用域也必须让位', () {
    testWidgets('输入框聚焦时，注册表根本不会被问', (tester) async {
      final log = <Object>[];
      registry.register(
        owner: 'player',
        scope: ShortcutScope.video,
        isEligible: () => true,
        handle: (event) {
          log.add('player');
          return KeyEventResult.handled;
        },
      );

      // 复刻 my_app.dart `_shortCutsWrapper` 的顺序：typing 闸门在最前面，
      // 且盖住叶子派发。用户很可能把「.」这种可打印字符绑成播放器快捷键
      // （真机上绑的就是 Period → 增大音量），在评论框里敲它必须是输入字符。
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onKeyEvent: (node, event) {
              final typing = isTextInputFocused();
              if (!typing) {
                final leaf = registry.dispatch(event);
                if (leaf == KeyEventResult.handled) return leaf;
              }
              return KeyEventResult.ignored;
            },
            child: child!,
          ),
          home: const Scaffold(body: TextField(autofocus: true)),
        ),
      );
      await tester.pumpAndSettle();
      expect(isTextInputFocused(), isTrue, reason: '前提：输入框已聚焦');

      await tester.sendKeyEvent(LogicalKeyboardKey.period);
      await tester.pumpAndSettle();

      expect(
        log,
        isEmpty,
        reason: '打字时按「.」不该被播放器当成音量键吃掉',
      );
    });

    testWidgets('没有输入框聚焦时，注册表照常接管（按下与松开都转发）', (tester) async {
      final log = <KeyEvent>[];
      registry.register(
        owner: 'player',
        scope: ShortcutScope.video,
        isEligible: () => true,
        handle: (event) {
          log.add(event);
          return KeyEventResult.handled;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onKeyEvent: (node, event) {
              if (!isTextInputFocused()) {
                return registry.dispatch(event);
              }
              return KeyEventResult.ignored;
            },
            child: child!,
          ),
          // 放一个可聚焦但**不是输入框**的控件：焦点必须落在树内，否则事件从
          // FocusManager 的根 scope 起步，压根不会经过我们这只祖先 Focus——
          // 这正是本次真机缺陷的同一个机制，第一版反向锚点就栽在这里。
          home: Scaffold(
            body: ElevatedButton(
              autofocus: true,
              onPressed: () {},
              child: const Text('焦点在非输入控件上'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(isTextInputFocused(), isFalse, reason: '前提：焦点不在输入框');

      await tester.sendKeyEvent(LogicalKeyboardKey.period);
      await tester.pumpAndSettle();

      // 一次按键会派发按下 + 松开两个事件，两个都要送到：进度键的长按倍速
      // 正是靠 KeyUpEvent 收尾，只转发按下会让它卡在倍速态。
      expect(log.whereType<KeyDownEvent>(), hasLength(1),
          reason: '不在打字就该正常接管（反向锚点）');
      expect(log.whereType<KeyUpEvent>(), hasLength(1),
          reason: '松开事件必须一并转发');
    });
  });
}
