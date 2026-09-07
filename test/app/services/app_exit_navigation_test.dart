import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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

  tearDown(() {
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
    AppService.tryPop(context: context);
    await tester.pump();

    expect(immersiveCalls, contains('exitApp'));
    expect(platformCalls, isNot(contains('SystemNavigator.pop')));
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
    AppService.tryPop(context: context);
    await tester.pump();

    expect(
      platformCalls.where((call) => call == 'SystemNavigator.pop'),
      hasLength(1),
    );
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
