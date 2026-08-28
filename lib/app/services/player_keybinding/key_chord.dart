import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 一个可序列化的「按键组合」（trigger 键 + 修饰键）。
///
/// 既能表达键盘按键，也能表达鼠标按键（侧键/中键），二者互斥：
/// - 键盘组合：[pointerButton] 为 null，[keyId] 取自 [LogicalKeyboardKey.keyId]，
///   跨 Flutter 版本稳定，适合持久化；
/// - 鼠标组合：[pointerButton] 为按钮位掩码（[kMiddleMouseButton] / [kBackMouseButton]
///   / [kForwardMouseButton]），此时 [keyId] 恒为 0；
/// - 修饰键用四个布尔位表示，匹配时要求与当前实际修饰键状态「完全一致」
///   （即纯方向键不会被 Ctrl+方向键误触发）；
/// - 序列化格式形如 `ctrl+shift+4294967304`（键盘）或 `ctrl+mouse8`（鼠标），
///   便于直接存入 ConfigService 的 JSON。
@immutable
class KeyChord {
  final int keyId;

  /// 鼠标按钮位掩码；为 null 表示这是一个键盘组合。
  final int? pointerButton;
  final bool control;
  final bool shift;
  final bool alt;
  final bool meta;

  const KeyChord({
    required this.keyId,
    this.pointerButton,
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

  /// 由鼠标按钮位掩码构造（用于鼠标侧键/中键绑定）。
  const KeyChord.pointer(
    int button, {
    bool control = false,
    bool shift = false,
    bool alt = false,
    bool meta = false,
  }) : this(
         keyId: 0,
         pointerButton: button,
         control: control,
         shift: shift,
         alt: alt,
         meta: meta,
       );

  /// 是否为鼠标按键组合。
  bool get isPointer => pointerButton != null;

  LogicalKeyboardKey get logicalKey => LogicalKeyboardKey(keyId);

  bool get hasModifier => control || shift || alt || meta;

  /// 捕获一次键盘按下事件，结合当前硬件修饰键状态生成键位组合。
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

  /// 捕获一次鼠标按下事件并生成鼠标组合。
  ///
  /// 只接受「可绑定」的按钮（中键 / 后退键 / 前进键），以免抢占左键点按、
  /// 右键菜单等既有交互；不可绑定时返回 null。
  static KeyChord? fromPointerEvent(PointerDownEvent event) {
    final button = _capturableButton(event.buttons);
    if (button == null) return null;
    final keyboard = HardwareKeyboard.instance;
    return KeyChord.pointer(
      button,
      control: keyboard.isControlPressed,
      shift: keyboard.isShiftPressed,
      alt: keyboard.isAltPressed,
      meta: keyboard.isMetaPressed,
    );
  }

  /// 可被绑定的鼠标按钮（仅中键 / 后退键 / 前进键，需为唯一按下的按钮）。
  ///
  /// 移动端额外排除**后退键**：Android 把鼠标后退键直接翻译成系统返回，
  /// 由 `PopCoordinator` 的 `ChildBackButtonDispatcher` 那条通道处理——
  /// 也就是说不绑它本来就能返回。再把它绑到任何动作上，一次按下会既跑我们的
  /// 动作、又跑系统返回（绑到「返回」就表现为**连退两页**，真机已复现）。
  /// 这不是能靠 `handled` 拦住的：两条通道互不知情。
  static int? _capturableButton(int buttons) =>
      isBindableMouseButton(buttons) ? buttons : null;

  /// 某个鼠标按钮在**当前平台**是否可绑定。
  ///
  /// 捕获入口与加载入口共用这一份判定：只挡捕获的话，用户在旧版本里已经存下的
  /// 「侧键 → 某动作」绑定会活过升级，继续双触发（动作 + 系统返回）。
  static bool isBindableMouseButton(int button) {
    if (button == kMiddleMouseButton) return true;
    if (button == kForwardMouseButton) return true;
    if (button == kBackMouseButton) return !isPlatformHandledBackButton;
    return false;
  }

  /// 当前平台是否自己就会把「后退」输入变成系统返回。
  ///
  /// 移动端为真；桌面端没有系统级返回，绑定后退键是合法且有用的。
  static bool get isPlatformHandledBackButton =>
      GetPlatform.isAndroid || GetPlatform.isIOS;

  /// 平台自带返回语义的按键：绑上去会与系统返回重复触发。
  ///
  /// Android 的物理/鼠标返回键在 Flutter 侧既可能作为这些逻辑键到达，
  /// 也可能只走系统返回通道；两条通道我们都堵，以免留下一半的洞。
  static final Set<int> platformBackKeyIds = {
    LogicalKeyboardKey.goBack.keyId,
    LogicalKeyboardKey.browserBack.keyId,
  };

  /// 该组合是否匹配某次键盘按下事件（修饰键状态需完全一致）。
  bool matches(KeyEvent event) {
    if (isPointer) return false;
    if (event.logicalKey.keyId != keyId) return false;
    return _modifiersMatch();
  }

  /// 该组合是否匹配某次鼠标按下事件（按钮 + 修饰键需完全一致）。
  bool matchesPointer(PointerDownEvent event) {
    if (!isPointer) return false;
    if (event.buttons != pointerButton) return false;
    return _modifiersMatch();
  }

  bool _modifiersMatch() {
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
    parts.add(isPointer ? 'mouse$pointerButton' : keyId.toString());
    return parts.join('+');
  }

  static KeyChord? tryDeserialize(String raw) {
    final parts = raw.split('+');
    bool control = false, shift = false, alt = false, meta = false;
    int? keyId;
    int? pointerButton;
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
          if (part.startsWith('mouse')) {
            pointerButton = int.tryParse(part.substring(5));
          } else {
            keyId = int.tryParse(part);
          }
      }
    }
    if (pointerButton != null) {
      return KeyChord.pointer(
        pointerButton,
        control: control,
        shift: shift,
        alt: alt,
        meta: meta,
      );
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

  /// 人类可读的展示文本，如 `Ctrl + ←`、`⌘ + F`、`Mouse ◀`。
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
    if (isPointer) {
      return _pointerButtonLabels[pointerButton] ?? 'Mouse($pointerButton)';
    }
    final friendly = _friendlyKeyLabels[keyId];
    if (friendly != null) return friendly;
    final label = logicalKey.keyLabel;
    if (label.isNotEmpty) return label.toUpperCase();
    // 退化为去掉前缀的调试名（极少触发）。
    final debug = logicalKey.debugName ?? 'Key($keyId)';
    return debug;
  }

  /// 人类可读地描述一个鼠标按钮位掩码（含不可绑定的左/右键），
  /// 供录入弹窗回显「检测到了什么」。
  static String describeMouseButton(int button) {
    if (button == kPrimaryMouseButton) return 'Mouse L';
    if (button == kSecondaryMouseButton) return 'Mouse R';
    return _pointerButtonLabels[button] ?? 'Mouse($button)';
  }

  static const Map<int, String> _pointerButtonLabels = {
    kMiddleMouseButton: 'Mouse ⬤',
    kBackMouseButton: 'Mouse ◀',
    kForwardMouseButton: 'Mouse ▶',
  };

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
    // 小键盘与浏览器导航键：不补这些就会落到 `logicalKey.debugName` 兜底，
    // 在设置页里显示成 `NUMPAD ADD` / `BROWSER FORWARD` 这种调试名。
    // 那句「极少触发」的注释是错的——图库的默认键位、以及罗技鼠标侧键
    // （安卓上以 browserBack / browserForward 的身份到达）都会走到这里。
    LogicalKeyboardKey.numpad0.keyId: '小键盘 0',
    LogicalKeyboardKey.numpad1.keyId: '小键盘 1',
    LogicalKeyboardKey.numpad2.keyId: '小键盘 2',
    LogicalKeyboardKey.numpad3.keyId: '小键盘 3',
    LogicalKeyboardKey.numpad4.keyId: '小键盘 4',
    LogicalKeyboardKey.numpad5.keyId: '小键盘 5',
    LogicalKeyboardKey.numpad6.keyId: '小键盘 6',
    LogicalKeyboardKey.numpad7.keyId: '小键盘 7',
    LogicalKeyboardKey.numpad8.keyId: '小键盘 8',
    LogicalKeyboardKey.numpad9.keyId: '小键盘 9',
    LogicalKeyboardKey.numpadAdd.keyId: '小键盘 +',
    LogicalKeyboardKey.numpadSubtract.keyId: '小键盘 -',
    LogicalKeyboardKey.numpadMultiply.keyId: '小键盘 *',
    LogicalKeyboardKey.numpadDivide.keyId: '小键盘 /',
    LogicalKeyboardKey.numpadDecimal.keyId: '小键盘 .',
    LogicalKeyboardKey.numpadEnter.keyId: '小键盘 Enter',
    LogicalKeyboardKey.numpadEqual.keyId: '小键盘 =',
    LogicalKeyboardKey.browserBack.keyId: '后退键',
    LogicalKeyboardKey.browserForward.keyId: '前进键',
    LogicalKeyboardKey.goBack.keyId: '返回键',
  };

  @override
  bool operator ==(Object other) =>
      other is KeyChord &&
      other.keyId == keyId &&
      other.pointerButton == pointerButton &&
      other.control == control &&
      other.shift == shift &&
      other.alt == alt &&
      other.meta == meta;

  @override
  int get hashCode =>
      Object.hash(keyId, pointerButton, control, shift, alt, meta);

  @override
  String toString() => 'KeyChord(${serialize()})';
}
