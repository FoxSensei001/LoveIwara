import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/player_keybinding/key_chord.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';

/// 「作用域 × 输入通道」能力表的闸门。
///
/// 这张表存在的理由是：在此之前「某作用域受理哪些输入通道」没有权威来源，
/// 设置页与运行时各说各话，于是长出了一族「设置页答应了、运行时做不到」的
/// 缺陷（全局/图库能绑鼠标键却永不触发；图库设置里写着「旋转画面」而图库
/// 根本不会旋转）。下面的用例就是防止它再长出来。
void main() {
  group('能力表本身', () {
    test('每个作用域都必须声明它受理的通道（新增作用域别忘了登记）', () {
      for (final scope in ShortcutScope.values) {
        expect(
          kScopeInputChannels.containsKey(scope),
          isTrue,
          reason: '$scope 没有在 kScopeInputChannels 里登记输入通道',
        );
      }
    });

    test('每个作用域至少受理键盘——否则它的动作全都没法触发', () {
      for (final scope in ShortcutScope.values) {
        expect(
          inputChannelsOf(scope).contains(ShortcutInputChannel.keyboard),
          isTrue,
          reason: '$scope 一个可用通道都没有',
        );
      }
    });
  });

  group('声明必须与运行时接线一致', () {
    /// 扫源码找出「真的调用了 resolvePointer 并指明作用域」的那些作用域。
    Set<ShortcutScope> scopesWithPointerWiring() {
      final found = <ShortcutScope>{};
      final files = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final file in files) {
        // 服务自身的定义/文档不算接线，只看调用方。
        if (file.path.contains('player_keybinding/')) continue;
        final src = file.readAsStringSync();
        var idx = src.indexOf('resolvePointer');
        while (idx != -1) {
          // 调用点与它的 scope 实参之间隔着换行与缩进，取一小段窗口来找。
          final window = src.substring(
            idx,
            (idx + 200).clamp(0, src.length),
          );
          for (final scope in ShortcutScope.values) {
            if (window.contains('ShortcutScope.${scope.name}')) {
              found.add(scope);
            }
          }
          idx = src.indexOf('resolvePointer', idx + 1);
        }
      }
      return found;
    }

    test('声明受理鼠标的作用域，必须真的存在 resolvePointer 接线', () {
      final wired = scopesWithPointerWiring();
      for (final scope in ShortcutScope.values) {
        if (!scopeAcceptsMouseButtons(scope)) continue;
        expect(
          wired.contains(scope),
          isTrue,
          reason:
              '$scope 在能力表里声明了 mouseButton，但 lib/ 下找不到对应的 '
              'resolvePointer 调用点——这正是「能绑却永不触发」的成因',
        );
      }
    });

    test('没声明受理鼠标的作用域，不得偷偷接上 resolvePointer', () {
      final wired = scopesWithPointerWiring();
      for (final scope in ShortcutScope.values) {
        if (scopeAcceptsMouseButtons(scope)) continue;
        expect(
          wired.contains(scope),
          isFalse,
          reason: '$scope 接了 resolvePointer 却没在能力表里声明 mouseButton',
        );
      }
    });

    test('图库确实没有旋转能力，能力表不得声明旋转（曾被设置页凭空承诺）', () {
      expect(scopeSupportsFixedRotate(ShortcutScope.gallery), isFalse);
      // 反向锚定：视频是真有旋转的，别把这条用例写成永真。
      expect(scopeSupportsFixedRotate(ShortcutScope.video), isTrue);
    });
  });

  group('固定手势卡片的展示条件由能力表推导', () {
    test('全局没有任何固定手势，不该渲染那张卡片', () {
      expect(scopeHasFixedGestures(ShortcutScope.global), isFalse);
    });

    test('图库只展示缩放、不展示旋转', () {
      expect(scopeSupportsFixedZoom(ShortcutScope.gallery), isTrue);
      expect(scopeSupportsFixedRotate(ShortcutScope.gallery), isFalse);
    });

    test('视频缩放旋转都展示', () {
      expect(scopeSupportsFixedZoom(ShortcutScope.video), isTrue);
      expect(scopeSupportsFixedRotate(ShortcutScope.video), isTrue);
    });
  });

  group('可绑定性（isReserved 的鼠标分支）', () {
    // KeybindingService 要 Get.find<ConfigService>()，这里只验纯判定所依赖的
    // 那条规则本身，不去起服务。
    test('不受理鼠标的作用域，鼠标组合不可绑定', () {
      for (final scope in ShortcutScope.values) {
        final blocked = !scopeAcceptsMouseButtons(scope);
        expect(
          blocked,
          scope != ShortcutScope.video,
          reason: '当前只有视频作用域受理鼠标按键；改了这条要同步改设置页文案',
        );
      }
    });

    test('鼠标组合只认中键 / 后退 / 前进，其余按钮不可捕获', () {
      const capturable = [
        kMiddleMouseButton,
        kBackMouseButton,
        kForwardMouseButton,
      ];
      for (final button in capturable) {
        expect(
          KeyChord.pointer(button).isPointer,
          isTrue,
          reason: '$button 应当是合法的鼠标组合',
        );
      }
    });

    test('键盘组合不受鼠标通道影响（回归锚点）', () {
      final chord = KeyChord.fromKey(LogicalKeyboardKey.keyF);
      expect(chord.isPointer, isFalse);
    });
  });
}
