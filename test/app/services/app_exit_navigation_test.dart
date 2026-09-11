import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/utils/exit_confirm_util.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/pop_coordinator.dart';
import 'package:i_iwara/utils/logger_utils.dart';

void main() {
  const immersive = MethodChannel('i_iwara/immersive');
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final immersiveCalls = <String>[];
  final platformCalls = <String>[];

  setUpAll(() async {
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  setUp(() {
    immersiveCalls.clear();
    platformCalls.clear();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(immersive, (
      call,
    ) async {
      immersiveCalls.add(call.method);
      return true;
    });
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        platformCalls.add(call.method);
        return null;
      },
    );
  });

  setUp(ExitConfirmUtil.resetForTest);

  /// 把「再按一次退出」那条 toast 的自动关闭定时器跑完。
  ///
  /// ⛔ 不放干净的话，测试收尾时会撞上 `A Timer is still pending even after the
  /// widget tree was disposed`——断言其实已经过了，红的是收尾。
  Future<void> drainToasts(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  tearDown(() {
    ExitConfirmUtil.resetForTest();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(immersive, null);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  Future<BuildContext> pumpHome(WidgetTester tester) async {
    late BuildContext home;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: rootNavigatorKey,
        // ⛔ 必须挂 [AppToastHost]。根上按返回走的是「再按一次退出」那条
        // （`PopCoordinator.handleBack` → `ExitConfirmUtil.handleExit`），它会
        // 弹一条 toast；没有宿主时 toastification 直接断言失败，测的那件事还
        // 没验到就先炸了。位置与 `my_app.dart:315` 一致：`MaterialApp.builder`
        // 里，也就是所有路由之上。
        builder: (context, child) =>
            AppToastHost(child: child ?? const SizedBox.shrink()),
        home: Builder(
          builder: (context) {
            home = context;
            return const Scaffold(body: Text('home'));
          },
        ),
      ),
    );
    return home;
  }

  testWidgets('sidebar return at root requests exit of the whole XR app', (
    tester,
  ) async {
    final context = await pumpHome(tester);
    // ⛔ 退出是**双击确认**的（[ExitConfirmUtil]）：第一下只弹「再按一次退出」，
    // 5 秒内的第二下才真退。所以这里要按两下。
    AppService.tryPop(context: context);
    await tester.pump();
    expect(immersiveCalls, isEmpty, reason: '第一下只该弹提示，不该退出');
    AppService.tryPop(context: context);
    await tester.pump();

    expect(immersiveCalls, contains('exitApp'));
    expect(platformCalls, isNot(contains('SystemNavigator.pop')));
    await drainToasts(tester);
  });

  testWidgets('non-XR exit retains the platform navigator fallback', (
    tester,
  ) async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(immersive, (
      call,
    ) async {
      immersiveCalls.add(call.method);
      return false;
    });
    final context = await pumpHome(tester);
    // 同上：双击确认，第一下只弹提示。
    AppService.tryPop(context: context);
    await tester.pump();
    AppService.tryPop(context: context);
    await tester.pump();

    expect(
      platformCalls.where((call) => call == 'SystemNavigator.pop'),
      hasLength(1),
    );
    await drainToasts(tester);
  });

  testWidgets('a fresh back press immediately after a page pop reaches home', (
    tester,
  ) async {
    final context = await pumpHome(tester);
    var homeBacks = 0;
    Future<bool> homeBack() async {
      homeBacks++;
      return true;
    }

    final dispatcher = appRouter.backButtonDispatcher;
    dispatcher.addCallback(homeBack);
    addTearDown(() => dispatcher.removeCallback(homeBack));
    PopCoordinator.init();
    await tester.pump();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('detail')),
      ),
    );
    await tester.pumpAndSettle();

    await dispatcher.invokeCallback(Future<bool>.value(false));
    await tester.pump();
    expect(rootNavigatorKey.currentState!.canPop(), isFalse);
    expect(homeBacks, 0);

    // A new physical press is valid even inside the old 250 ms suppression window.
    await dispatcher.invokeCallback(Future<bool>.value(false));
    await tester.pump();
    expect(homeBacks, 1);
  });
}
