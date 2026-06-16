import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 一个可序列化的「按键组合」（trigger 键 + 修饰键）。
///
/// - [keyId] 取自 [LogicalKeyboardKey.keyId]，跨 Flutter 版本稳定，适合持久化；
/// - 修饰键用四个布尔位表示，匹配时要求与当前实际修饰键状态「完全一致」
///   （即纯方向键不会被 Ctrl+方向键误触发）；
/// - 序列化格式形如 `ctrl+shift+4294967304`，便于直接存入 ConfigService 的 JSON。
@immutable
class KeyChord {
  final int keyId;
  final bool control;
  final bool shift;
  final bool alt;
  final bool meta;

  const KeyChord({
    required this.keyId,
    this.control = false,
    this.shift = false,
    this.alt = false,
    this.meta = false,
  });

  /// 由 [LogicalKeyboardKey] 直接构造（用于代码内置默认键位）。
  KeyChord.fromKey(
    LogicalKeyboardKey key, {
    bool control = false,
    bool shift = false,
    bool alt = false,
    bool meta = false,
  }) : this(
         keyId: key.keyId,
         control: control,
         shift: shift,
         alt: alt,
         meta: meta,
       );

  LogicalKeyboardKey get logicalKey => LogicalKeyboardKey(keyId);

  bool get hasModifier => control || shift || alt || meta;

  /// 捕获一次按下事件，结合当前硬件修饰键状态生成键位组合。
  ///
  /// 当按下的本身就是修饰键（Ctrl/Shift/Alt/Meta）时返回 null，表示尚未构成有效组合。
  static KeyChord? fromEvent(KeyEvent event) {
    final key = event.logicalKey;
    if (_isModifierKey(key)) return null;
    final keyboard = HardwareKeyboard.instance;
    return KeyChord(
      keyId: key.keyId,
      control: keyboard.isControlPressed,
      shift: keyboard.isShiftPressed,
      alt: keyboard.isAltPressed,
      meta: keyboard.isMetaPressed,
    );
  }

  /// 该组合是否匹配某次按下事件（修饰键状态需完全一致）。
  bool matches(KeyEvent event) {
    if (event.logicalKey.keyId != keyId) return false;
    final keyboard = HardwareKeyboard.instance;
    return keyboard.isControlPressed == control &&
        keyboard.isShiftPressed == shift &&
        keyboard.isAltPressed == alt &&
        keyboard.isMetaPressed == meta;
  }

  String serialize() {
    final parts = <String>[];
    if (control) parts.add('ctrl');
    if (shift) parts.add('shift');
    if (alt) parts.add('alt');
    if (meta) parts.add('meta');
    parts.add(keyId.toString());
    return parts.join('+');
  }

  static KeyChord? tryDeserialize(String raw) {
    final parts = raw.split('+');
    bool control = false, shift = false, alt = false, meta = false;
    int? keyId;
    for (final part in parts) {
      switch (part) {
        case 'ctrl':
          control = true;
          break;
        case 'shift':
          shift = true;
          break;
        case 'alt':
          alt = true;
          break;
        case 'meta':
          meta = true;
          break;
        default:
          keyId = int.tryParse(part);
      }
    }
    if (keyId == null) return null;
    return KeyChord(
      keyId: keyId,
      control: control,
      shift: shift,
      alt: alt,
      meta: meta,
    );
  }

  /// 人类可读的展示文本，如 `Ctrl + ←`、`⌘ + F`。
  String get displayLabel {
    final segments = <String>[];
    if (control) segments.add('Ctrl');
    if (alt) segments.add(GetPlatform.isMacOS ? 'Option' : 'Alt');
    if (shift) segments.add('Shift');
    if (meta) segments.add(GetPlatform.isMacOS ? '⌘' : 'Meta');
    segments.add(_keyLabel());
    return segments.join(' + ');
  }

  String _keyLabel() {
    final friendly = _friendlyKeyLabels[keyId];
    if (friendly != null) return friendly;
    final label = logicalKey.keyLabel;
    if (label.isNotEmpty) return label.toUpperCase();
    // 退化为去掉前缀的调试名（极少触发）。
    final debug = logicalKey.debugName ?? 'Key($keyId)';
    return debug;
  }

  static bool _isModifierKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.shift ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.alt ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight ||
        key == LogicalKeyboardKey.meta;
  }

  static final Map<int, String> _friendlyKeyLabels = {
    LogicalKeyboardKey.arrowLeft.keyId: '←',
    LogicalKeyboardKey.arrowRight.keyId: '→',
    LogicalKeyboardKey.arrowUp.keyId: '↑',
    LogicalKeyboardKey.arrowDown.keyId: '↓',
    LogicalKeyboardKey.space.keyId: 'Space',
    LogicalKeyboardKey.enter.keyId: 'Enter',
    LogicalKeyboardKey.escape.keyId: 'Esc',
    LogicalKeyboardKey.tab.keyId: 'Tab',
    LogicalKeyboardKey.backspace.keyId: 'Backspace',
    LogicalKeyboardKey.delete.keyId: 'Delete',
    LogicalKeyboardKey.home.keyId: 'Home',
    LogicalKeyboardKey.end.keyId: 'End',
    LogicalKeyboardKey.pageUp.keyId: 'PageUp',
    LogicalKeyboardKey.pageDown.keyId: 'PageDown',
    LogicalKeyboardKey.bracketLeft.keyId: '[',
    LogicalKeyboardKey.bracketRight.keyId: ']',
    LogicalKeyboardKey.comma.keyId: ',',
    LogicalKeyboardKey.period.keyId: '.',
    LogicalKeyboardKey.minus.keyId: '-',
    LogicalKeyboardKey.equal.keyId: '=',
    LogicalKeyboardKey.slash.keyId: '/',
    LogicalKeyboardKey.semicolon.keyId: ';',
  };

  @override
  bool operator ==(Object other) =>
      other is KeyChord &&
      other.keyId == keyId &&
      other.control == control &&
      other.shift == shift &&
      other.alt == alt &&
      other.meta == meta;

  @override
  int get hashCode => Object.hash(keyId, control, shift, alt, meta);

  @override
  String toString() => 'KeyChord(${serialize()})';
}
