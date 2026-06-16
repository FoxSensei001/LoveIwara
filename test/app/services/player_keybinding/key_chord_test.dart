import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/player_keybinding/key_chord.dart';
import 'package:i_iwara/app/services/player_keybinding/player_action.dart';

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
      expect(
        KeyChord.fromKey(LogicalKeyboardKey.arrowLeft).displayLabel,
        '←',
      );
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

  group('PlayerAction 元信息', () {
    test('每个动作 id 唯一且可反查', () {
      final ids = <String>{};
      for (final action in PlayerAction.values) {
        expect(ids.add(action.id), isTrue, reason: '重复 id: ${action.id}');
        expect(PlayerActionMetaExt.fromId(action.id), equals(action));
      }
    });

    test('默认键位可序列化往返', () {
      for (final action in PlayerAction.values) {
        for (final chord in action.defaultChords) {
          expect(
            KeyChord.tryDeserialize(chord.serialize()),
            equals(chord),
            reason: '动作 ${action.id} 的默认键位往返失败',
          );
        }
      }
    });

    test('已移除倍速增减动作', () {
      final ids = PlayerAction.values.map((a) => a.id).toList();
      expect(ids, isNot(contains('speed_up')));
      expect(ids, isNot(contains('speed_down')));
    });
  });
}
