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

  testWidgets('PIN 输入框拿得到 Overlay 祖先（否则选择浮层会抛断言）', (tester) async {
    await pumpLocked(tester);

    final editable = tester.element(find.byType(EditableText));
    Element? overlay;
    editable.visitAncestorElements((ancestor) {
      if (ancestor.widget.runtimeType == Overlay) {
        overlay = ancestor;
        return false;
      }
      return true;
    });

    expect(overlay, isNotNull, reason: '锁屏必须自带 Overlay，不能指望路由树或 toast 宿主');
  });

  testWidgets('输错后清空再输入，输入框里就只有刚敲的那一个字符', (tester) async {
    await pumpLocked(tester);

    final field = find.byType(TextField);
    await tester.enterText(field, '12345678');
    await tester.pumpAndSettle();
    // 输错 → 解锁失败 → 代码会 clear()
    await tester.tap(find.text(slang.t.settings.appLockUnlock));
    await tester.pumpAndSettle();

    await tester.enterText(field, '');
    await tester.pumpAndSettle();
    await tester.enterText(field, '1');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.widget<TextField>(field).controller!.text,
      '1',
      reason: '断言中途抛出会让 widget 与输入法错位，重输时冒出上一串的全部圆点',
    );
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
