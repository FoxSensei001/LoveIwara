import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/player_keybinding/key_chord.dart';
import 'package:i_iwara/app/services/player_keybinding/keybinding_service.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_action.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';

/// 键位规则的单测。
///
/// 这些规则以前一条都测不到：[KeybindingService] 在字段初始化时就去
/// `Get.find<ConfigService>()`，而 ConfigService 需要真实 sqlite 库。现在服务
/// 接受注入一个内存 store，规则本身就能直接验。
KeybindingService newService([Object? overrides]) =>
    KeybindingService.forTest(store: InMemoryKeybindingStore(overrides));

KeyChord key(LogicalKeyboardKey k) => KeyChord.fromKey(k);

void main() {
  // 键位匹配会读 HardwareKeyboard.instance 的修饰键状态。
  TestWidgetsFlutterBinding.ensureInitialized();

  group('保留键跟随「全局返回」的真实绑定', () {
    test('默认下叶子作用域保留 Esc，全局自己不保留', () {
      final s = newService();
      final esc = key(LogicalKeyboardKey.escape);
      expect(s.isReserved(esc, ShortcutScope.video), isTrue);
      expect(s.isReserved(esc, ShortcutScope.gallery), isTrue);
      // 全局返回自己的键当然可以改。
      expect(s.isReserved(esc, ShortcutScope.global), isFalse);
    });

    test('把返回改绑到 Backspace 后，保留的是 Backspace，Esc 反而放开', () async {
      final s = newService();
      final backspace = key(LogicalKeyboardKey.backspace);
      await s.setBindings(ShortcutAction.globalBack, [backspace]);

      expect(
        s.isReserved(backspace, ShortcutScope.video),
        isTrue,
        reason: '新的返回键必须在叶子作用域被保护，否则绑走了就退不出全屏',
      );
      expect(
        s.isReserved(key(LogicalKeyboardKey.escape), ShortcutScope.video),
        isFalse,
        reason: 'Esc 已经不是返回键了，不该继续锁着',
      );
    });

    test('返回键被清空后，叶子作用域不再保留任何键', () async {
      final s = newService();
      await s.setBindings(ShortcutAction.globalBack, const []);
      expect(
        s.isReserved(key(LogicalKeyboardKey.escape), ShortcutScope.video),
        isFalse,
      );
    });

    test('改绑返回键会当场把叶子作用域里占用它的键位让出来', () async {
      final s = newService();
      final f = key(LogicalKeyboardKey.keyF); // 默认绑定：全屏切换
      expect(s.chordsOf(ShortcutAction.toggleFullscreen), contains(f));

      await s.setBindings(ShortcutAction.globalBack, [f]);

      expect(
        s.chordsOf(ShortcutAction.toggleFullscreen),
        isNot(contains(f)),
        reason: '不能留到下次启动才清，用户会莫名其妙发现快捷键没了且无从关联',
      );
    });

    test('加载时：叶子作用域里占着返回键的历史绑定会被清掉', () {
      // 用户曾把 Esc 绑给「播放/暂停」（老版本或改过配置文件）。
      final s = newService({
        'play_pause': [key(LogicalKeyboardKey.escape).serialize()],
      });
      expect(s.chordsOf(ShortcutAction.playPause), isEmpty);
    });

    test('加载时的基准是配置里的返回键，而不是默认的 Esc', () {
      final s = newService({
        'global_back': [key(LogicalKeyboardKey.backspace).serialize()],
        // 返回键已经不是 Esc，所以这条应当**留下**。
        'play_pause': [key(LogicalKeyboardKey.escape).serialize()],
        // 而占着 Backspace 的这条要被清掉。
        'toggle_mute': [key(LogicalKeyboardKey.backspace).serialize()],
      });
      expect(
        s.chordsOf(ShortcutAction.playPause),
        contains(key(LogicalKeyboardKey.escape)),
      );
      expect(s.chordsOf(ShortcutAction.toggleMute), isEmpty);
    });
  });

  group('isDefault 与顺序无关', () {
    test('删掉一个默认键再加回来，仍然算默认', () async {
      final s = newService();
      // gallery_next 默认有两个键：→ 与 PageDown。
      final chords = s.chordsOf(ShortcutAction.galleryNext);
      expect(chords.length, 2);
      expect(s.isDefault(ShortcutAction.galleryNext), isTrue);

      await s.removeBinding(ShortcutAction.galleryNext, chords.first);
      expect(s.isDefault(ShortcutAction.galleryNext), isFalse);

      // addBinding 一律追加到末尾，于是顺序与默认表相反。
      await s.addBinding(ShortcutAction.galleryNext, chords.first);
      expect(s.chordsOf(ShortcutAction.galleryNext).first, chords.last);
      expect(
        s.isDefault(ShortcutAction.galleryNext),
        isTrue,
        reason: '顺序只影响设置页里 chip 的排布，不该让它变成「用户覆盖」',
      );
    });

    test('回到默认之后不再写进配置差量（否则吃不到未来默认键位演进）', () async {
      final store = InMemoryKeybindingStore();
      final s = KeybindingService.forTest(store: store);
      final chords = s.chordsOf(ShortcutAction.galleryNext);

      await s.removeBinding(ShortcutAction.galleryNext, chords.first);
      expect((store.raw as Map).containsKey('gallery_next'), isTrue);

      await s.addBinding(ShortcutAction.galleryNext, chords.first);
      expect((store.raw as Map).containsKey('gallery_next'), isFalse);
    });

    test('键位不同则不算默认（别把顺序无关做成集合相等的漏判）', () async {
      final s = newService();
      await s.setBindings(ShortcutAction.playPause, [
        key(LogicalKeyboardKey.keyK),
      ]);
      expect(s.isDefault(ShortcutAction.playPause), isFalse);
    });
  });

  group('按住不放的重复事件', () {
    KeyEvent down(LogicalKeyboardKey k) => KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.keyA,
      logicalKey: k,
      timeStamp: Duration.zero,
    );
    KeyEvent repeat(LogicalKeyboardKey k) => KeyRepeatEvent(
      physicalKey: PhysicalKeyboardKey.keyA,
      logicalKey: k,
      timeStamp: Duration.zero,
    );

    test('可重复的动作（音量）在重复事件上继续触发', () {
      final s = newService();
      expect(
        s.resolve(repeat(LogicalKeyboardKey.arrowUp), ShortcutScope.video),
        ShortcutAction.volumeUp,
      );
    });

    test('开关类动作不会因为按住而反复翻转', () {
      final s = newService();
      expect(
        s.resolve(down(LogicalKeyboardKey.space), ShortcutScope.video),
        ShortcutAction.playPause,
      );
      expect(
        s.resolve(repeat(LogicalKeyboardKey.space), ShortcutScope.video),
        isNull,
        reason: '按住空格不能变成每秒几十次播放/暂停',
      );
    });

    test('进度键的重复事件不触发动作——长按倍速由它自己的定时器负责', () {
      final s = newService();
      expect(
        s.resolve(repeat(LogicalKeyboardKey.arrowRight), ShortcutScope.video),
        isNull,
      );
    });

    test('但调度层仍能看出「这个键确实绑在本作用域」，从而吃掉事件', () {
      final s = newService();
      // 不吃掉的话，方向键的重复事件会冒泡成 DirectionalFocusIntent 把焦点挪走。
      expect(
        s.matchIgnoringRepeatPolicy(
          repeat(LogicalKeyboardKey.arrowRight),
          ShortcutScope.video,
        ),
        ShortcutAction.seekForward,
      );
      expect(
        s.matchIgnoringRepeatPolicy(
          repeat(LogicalKeyboardKey.keyZ),
          ShortcutScope.video,
        ),
        isNull,
      );
    });

    test('可重复的动作只有音量与图库缩放——新增前请确认重复施加是累积而非翻转', () {
      final repeatable = ShortcutAction.values
          .where((a) => a.repeatable)
          .toSet();
      expect(repeatable, {
        ShortcutAction.volumeUp,
        ShortcutAction.volumeDown,
        ShortcutAction.galleryZoomIn,
        ShortcutAction.galleryZoomOut,
      });
    });
  });
}
