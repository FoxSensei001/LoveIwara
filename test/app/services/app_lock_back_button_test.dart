import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/pop_coordinator.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 锁屏是 Navigator **旁边**的一层 Stack sibling，它自己的 `PopScope`
/// 管不到底层路由——返回键必须由 [PopCoordinator] 在锁定期间统一吃掉，
/// 否则「详情页锁上 → 按返回 → 底层页面被 pop 掉 → 解锁后落点变了」。
void main() {
  late ConfigService config;
  late AppLockService service;

  setUpAll(() async {
    // PopCoordinator 一路都在 LogUtils.d，late logger 得先就位。
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  setUp(() {
    config = ConfigService();
    for (final key in ConfigKey.values) {
      config.settings[key] = Rx<dynamic>(key.defaultValue);
    }
    config.settings[ConfigKey.APP_LOCK_ENABLED]!.value = true;
    service = AppLockService(
      configService: config,
      storageService: StorageService(),
    );
    Get.put<AppLockService>(service);
  });

  tearDown(Get.reset);

  Future<BuildContext> pumpTwoPages(WidgetTester tester) async {
    late BuildContext pageContext;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: rootNavigatorKey,
        home: Builder(
          builder: (context) {
            pageContext = context;
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('详情页')),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('详情页'), findsOneWidget);
    return pageContext;
  }

  testWidgets('锁定期间 handleBack 不动底层路由栈', (tester) async {
    final context = await pumpTwoPages(tester);

    service.isLocked.value = true;
    PopCoordinator.handleBack(context);
    await tester.pumpAndSettle();

    expect(find.text('详情页'), findsOneWidget, reason: '锁屏期间返回键不该弹掉底层页面');
  });

  testWidgets('解锁后返回键恢复正常', (tester) async {
    final context = await pumpTwoPages(tester);

    service.isLocked.value = true;
    PopCoordinator.handleBack(context);
    await tester.pumpAndSettle();
    expect(find.text('详情页'), findsOneWidget);

    service.isLocked.value = false;
    PopCoordinator.handleBack(context);
    await tester.pumpAndSettle();

    expect(find.text('详情页'), findsNothing);
  });

  testWidgets('锁定期间不弹「再按一次退出」', (tester) async {
    await pumpTwoPages(tester);

    service.isLocked.value = true;
    expect(PopCoordinator.shouldConfirmExitAtHomeRoot(), isFalse);
  });
}
