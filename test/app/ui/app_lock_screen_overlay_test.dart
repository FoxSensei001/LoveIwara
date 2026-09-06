import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/app_lock_screen.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import '../../support/app_lock_fakes.dart';

/// 锁屏挂在 `MaterialApp.router` builder 的 Stack 上、和整棵 Navigator 做兄弟。
/// 这棵子树里没有 Navigator/Overlay 祖先——2026-08-26 真机报障的两个症状
/// （PIN 输入框抛 "No Overlay widget found" + 清空后重输冒出一整串圆点、
/// 「重置应用锁」弹窗被画在锁屏底下点不到）都出在这里。
///
/// ⚠️ 这里**故意不**在外面套 Overlay，而且这正是真机的情形：锁屏是 builder 里
/// Stack 的兄弟层，整棵路由树（含根 Navigator 的 Overlay）都在它**旁边**而不是
/// 上面。当年的 OKToast 还额外埋了一层 vendored 的同名 `Overlay` 迷惑视线
/// （见 `detached_navigator_host.dart` 的留档），现在宿主已换成 toastification，
/// 但结论没变：锁屏子树一个真 Overlay 都没有，必须自带。
void main() {
  late FakeSecureStorage storage;
  late AppLockService service;

  setUp(() async {
    final config = MemoryConfigService();
    config.settings[ConfigKey.APP_LOCK_ENABLED]!.value = true;
    storage = FakeSecureStorage();
    await seedAppLockCredential(storage, '4321');
    service = AppLockService(
      configService: config,
      storageService: storage,
      localAuthentication: FakeLocalAuth(supported: false),
    );
    service.isLocked.value = true;
    Get.put<AppLockService>(service);
  });

  tearDown(Get.reset);

  Future<void> pumpLocked(WidgetTester tester, {Size? size}) async {
    if (size != null) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      slang.TranslationProvider(
        child: MaterialApp(
          home: const Scaffold(body: Text('底层页面')),
          builder: (context, child) => Stack(
            children: [child!, const Positioned.fill(child: AppLockScreen())],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// 已输入的圆点个数。
  int dotCount(WidgetTester tester) => tester
      .widgetList(
        find.byWidgetPredicate((w) {
          final key = w.key;
          return key is ValueKey<String> &&
              key.value.startsWith('app-lock-pin-dot-');
        }),
      )
      .length;

  Future<void> tapKey(WidgetTester tester, String digit) async {
    await tester.tap(find.text(digit));
    await tester.pumpAndSettle();
  }

  testWidgets('锁屏里没有任何文本输入框（否则 iOS 的系统键盘收不起来）', (tester) async {
    await pumpLocked(tester);

    // 2026-09-06 真机报障：iPhone 上点进输入框弹出系统数字键盘，而 iOS 没有
    // 主动收起它的办法——键盘盖住了解锁 / 生物验证两枚钮，页面又滚不动，人被
    // 卡死在这一屏。PIN 一律走自带的九宫格，一个字符都不经过系统输入法。
    expect(find.byType(EditableText), findsNothing);
    expect(find.byType(TextField), findsNothing);
    for (final digit in const ['0', '1', '5', '9']) {
      expect(find.text(digit), findsOneWidget, reason: '自带键盘上该有这枚键');
    }
  });

  testWidgets('输错后圆点清空，再敲就只剩刚按的那一个', (tester) async {
    await pumpLocked(tester);

    for (final digit in const ['1', '2', '3', '4']) {
      await tapKey(tester, digit);
    }
    expect(dotCount(tester), 4);

    // 凭据是 4321，输错 → 解锁失败 → 圆点整串清掉
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();
    expect(dotCount(tester), 0);
    expect(find.text(slang.t.settings.appLockInvalidPin), findsOneWidget);

    await tapKey(tester, '1');
    expect(dotCount(tester), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('位数不够时解锁键按不动，够了才亮', (tester) async {
    await pumpLocked(tester);

    for (final digit in const ['4', '3', '2']) {
      await tapKey(tester, digit);
    }
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();
    expect(service.isLocked.value, isTrue, reason: '3 位就该按不动，连试都不该试');

    await tapKey(tester, '1');
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();
    expect(service.isLocked.value, isFalse);
  });

  testWidgets('凭据读不出来的那屏在 360dp 窄屏上不溢出', (tester) async {
    service.credentialUnavailable.value = true;
    await pumpLocked(tester, size: const Size(360, 780));

    expect(tester.takeException(), isNull, reason: '两枚动作钮挤一行会 OVERFLOWED');
    expect(find.text(slang.t.settings.appLockRetry), findsOneWidget);
    expect(find.text(slang.t.settings.appLockReset), findsOneWidget);
  });

  testWidgets('凭据读不出来时，「重置应用锁」的确认弹窗画在锁屏之上、点得到', (tester) async {
    service.credentialUnavailable.value = true;
    await pumpLocked(tester);

    await tester.tap(find.text(slang.t.settings.appLockReset));
    await tester.pumpAndSettle();

    final confirm = find.text(slang.t.settings.appLockResetConfirmTitle);
    expect(confirm, findsOneWidget);

    // 决定性判据：命中测试打到的最上层必须是弹窗自己，而不是锁屏那块不透明 Material
    final hit = tester.hitTestOnBinding(tester.getCenter(confirm));
    final targets = hit.path.map((e) => e.target).toList();
    final paragraph = targets.indexWhere(
      (t) => t.runtimeType.toString().contains('RenderParagraph'),
    );
    expect(
      paragraph,
      lessThan(4),
      reason: '弹窗被锁屏盖住时，命中测试最上层会是锁屏的 Material 而不是弹窗文字',
    );
  });
}
