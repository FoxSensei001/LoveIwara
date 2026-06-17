import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/player_keybinding/key_chord.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_action.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';

void main() {
  group('KeyChord 序列化', () {
    test('无修饰键往返', () {
      final chord = KeyChord.fromKey(LogicalKeyboardKey.arrowRight);
      final restored = KeyChord.tryDeserialize(chord.serialize());
      expect(restored, equals(chord));
      expect(restored!.hasModifier, isFalse);
    });

    test('带多个修饰键往返', () {
      final chord = KeyChord.fromKey(
        LogicalKeyboardKey.keyF,
        control: true,
        shift: true,
      );
      final raw = chord.serialize();
      expect(raw, contains('ctrl'));
      expect(raw, contains('shift'));
      final restored = KeyChord.tryDeserialize(raw);
      expect(restored, equals(chord));
      expect(restored!.control, isTrue);
      expect(restored.shift, isTrue);
      expect(restored.alt, isFalse);
      expect(restored.meta, isFalse);
    });

    test('非法字符串返回 null', () {
      expect(KeyChord.tryDeserialize('ctrl+shift'), isNull);
      expect(KeyChord.tryDeserialize('not-a-key'), isNull);
    });
  });

  group('KeyChord 相等性', () {
    test('相同 keyId 与修饰键相等且 hashCode 一致', () {
      final a = KeyChord.fromKey(LogicalKeyboardKey.space);
      final b = KeyChord.fromKey(LogicalKeyboardKey.space);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('修饰键不同则不相等', () {
      final plain = KeyChord.fromKey(LogicalKeyboardKey.keyM);
      final withCtrl = KeyChord.fromKey(LogicalKeyboardKey.keyM, control: true);
      expect(plain, isNot(equals(withCtrl)));
    });
  });

  group('KeyChord 展示标签', () {
    test('方向键渲染为箭头符号', () {
      expect(KeyChord.fromKey(LogicalKeyboardKey.arrowLeft).displayLabel, '←');
    });

    test('修饰键 + 普通键拼接', () {
      final label = KeyChord.fromKey(
        LogicalKeyboardKey.keyF,
        control: true,
      ).displayLabel;
      expect(label, startsWith('Ctrl + '));
      expect(label, endsWith('F'));
    });
  });

  group('KeyChord 鼠标按键', () {
    test('鼠标侧键序列化往返', () {
      final chord = const KeyChord.pointer(kBackMouseButton);
      final raw = chord.serialize();
      expect(raw, 'mouse$kBackMouseButton');
      final restored = KeyChord.tryDeserialize(raw);
      expect(restored, equals(chord));
      expect(restored!.isPointer, isTrue);
      expect(restored.pointerButton, kBackMouseButton);
    });

    test('带修饰键的鼠标组合往返', () {
      final chord = const KeyChord.pointer(kForwardMouseButton, control: true);
      final raw = chord.serialize();
      expect(raw, 'ctrl+mouse$kForwardMouseButton');
      expect(KeyChord.tryDeserialize(raw), equals(chord));
    });

    test('鼠标组合与同位 keyId 的键盘组合不相等', () {
      // kBackMouseButton == 8，键盘组合也可能恰好是某个 keyId，需互不混淆。
      final mouse = const KeyChord.pointer(kBackMouseButton);
      final keyboard = const KeyChord(keyId: kBackMouseButton);
      expect(mouse, isNot(equals(keyboard)));
      expect(mouse.isPointer, isTrue);
      expect(keyboard.isPointer, isFalse);
    });

    test('鼠标按键展示为友好标签', () {
      expect(const KeyChord.pointer(kBackMouseButton).displayLabel, 'Mouse ◀');
      expect(
        const KeyChord.pointer(kForwardMouseButton).displayLabel,
        'Mouse ▶',
      );
      expect(
        const KeyChord.pointer(kMiddleMouseButton).displayLabel,
        'Mouse ⬤',
      );
    });
  });

  group('ShortcutAction 元信息', () {
    test('每个动作 id 唯一且可反查', () {
      final ids = <String>{};
      for (final action in ShortcutAction.values) {
        expect(ids.add(action.id), isTrue, reason: '重复 id: ${action.id}');
        expect(ShortcutActionMetaExt.fromId(action.id), equals(action));
      }
    });

    test('默认键位可序列化往返', () {
      for (final action in ShortcutAction.values) {
        for (final chord in action.defaultChords) {
          expect(
            KeyChord.tryDeserialize(chord.serialize()),
            equals(chord),
            reason: '动作 ${action.id} 的默认键位往返失败',
          );
        }
      }
    });

    test('视频动作保持原有 id 向后兼容', () {
      final videoIds = ShortcutAction.values
          .where((a) => a.scope == ShortcutScope.video)
          .map((a) => a.id)
          .toList();
      // 视频 id 应该是无前缀的旧格式：play_pause, speed_up 等
      expect(videoIds, contains('play_pause'));
      expect(videoIds, contains('speed_up'));
      expect(videoIds, contains('seek_forward'));
    });
  });
}
