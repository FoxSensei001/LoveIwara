import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/player_keybinding/key_chord.dart';

/// 真机回归：罗技 G502 侧下键在安卓上**不绑也会返回**（系统把它翻成返回键），
/// 一旦再绑到「返回」，一次按下会连退两页——我们这条和系统那条各跑一次。
///
/// 平台返回通道（PopCoordinator 的 ChildBackButtonDispatcher）与键盘/指针通道
/// 互不知情，`KeyEventResult.handled` 拦不住它。唯一可靠的做法是：在平台自己
/// 就会返回的平台上，不让这个键/键位被绑定。
void main() {
  // fromPointerEvent 会读 HardwareKeyboard.instance，需要先初始化绑定。
  TestWidgetsFlutterBinding.ensureInitialized();

  group('平台返回键的可绑定性', () {
    test('桌面端（测试环境即桌面）后退键可以正常捕获', () {
      // 测试跑在桌面上，GetPlatform.isAndroid/isIOS 为 false，
      // 因此后退键仍应是可绑定的——桌面没有系统级返回，绑它是合法能力。
      expect(KeyChord.isPlatformHandledBackButton, isFalse);
      final chord = KeyChord.pointer(kBackMouseButton);
      expect(chord.isPointer, isTrue);
      expect(chord.pointerButton, kBackMouseButton);
    });

    test('中键与前进键任何平台都不受这条规则影响', () {
      for (final button in [kMiddleMouseButton, kForwardMouseButton]) {
        expect(KeyChord.pointer(button).pointerButton, button);
      }
    });

    test('平台返回键位表非空且包含 goBack / browserBack', () {
      expect(
        KeyChord.platformBackKeyIds,
        containsAll(<int>[
          LogicalKeyboardKey.goBack.keyId,
          LogicalKeyboardKey.browserBack.keyId,
        ]),
        reason: '两条通道都要堵：安卓的返回键既可能作为逻辑键到达，也可能只走系统返回',
      );
    });

    test('平台返回键位表里不含 Esc（Esc 没有系统返回通道，是正常可用的默认键）', () {
      expect(
        KeyChord.platformBackKeyIds.contains(LogicalKeyboardKey.escape.keyId),
        isFalse,
        reason: 'Esc 是「返回」的默认键位，把它也保留掉会让默认键位自相矛盾',
      );
    });
  });

  group('历史遗留绑定也要挡（不能只挡捕获入口）', () {
    test('可绑定判定对三个按钮的结论（桌面测试环境）', () {
      expect(KeyChord.isBindableMouseButton(kMiddleMouseButton), isTrue);
      expect(KeyChord.isBindableMouseButton(kForwardMouseButton), isTrue);
      // 测试跑在桌面：桌面没有系统级返回，后退键是正当可绑的。
      expect(KeyChord.isBindableMouseButton(kBackMouseButton), isTrue);
    });

    test('左键 / 右键任何平台都不可绑（别让损坏配置绑上左键）', () {
      expect(KeyChord.isBindableMouseButton(kPrimaryMouseButton), isFalse);
      expect(KeyChord.isBindableMouseButton(kSecondaryMouseButton), isFalse);
    });

    test('捕获入口与可绑定判定是同一份规则', () {
      // 捕获走 fromPointerEvent → _capturableButton → isBindableMouseButton。
      // 两处若各写一套，就会重演「只挡新绑、老绑活过升级」这个洞。
      for (final button in [
        kMiddleMouseButton,
        kForwardMouseButton,
        kBackMouseButton,
        kPrimaryMouseButton,
        kSecondaryMouseButton,
      ]) {
        final captured = KeyChord.fromPointerEvent(
          PointerDownEvent(buttons: button, kind: PointerDeviceKind.mouse),
        );
        expect(
          captured != null,
          KeyChord.isBindableMouseButton(button),
          reason: '按钮 $button 的「能否捕获」与「能否绑定」必须一致',
        );
      }
    });
  });
}
