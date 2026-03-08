import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/startup/app_startup.dart';
import 'package:i_iwara/app/startup/app_startup_shell.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await LogUtils.init(isProduction: true);
  });

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('shows splash before startup completes and then hands off', (
    tester,
  ) async {
    final completer = Completer<void>();
    final runner = _FakeStartupRunner(
      onRun: ({required onProgress}) {
        onProgress(
          const AppStartupProgress(
            stage: AppStartupStage.initializing,
            value: 0.4,
            detail: 'Session Restore',
          ),
        );
        return completer.future;
      },
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: AppStartupShell(
          runner: runner,
          readyBuilder: (_) =>
              const ColoredBox(key: Key('ready-child'), color: Colors.green),
        ),
      ),
    );

    await tester.pump();

    expect(find.byKey(const ValueKey('startup-splash')), findsOneWidget);
    expect(find.byKey(const Key('startup-icon')), findsOneWidget);
    expect(find.byKey(const Key('ready-child')), findsNothing);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ready-child')), findsOneWidget);
    expect(find.byKey(const ValueKey('startup-splash')), findsNothing);
  });

  testWidgets('supports retry after initialization failure', (tester) async {
    var attempt = 0;
    final runner = _FakeStartupRunner(
      onRun: ({required onProgress}) async {
        attempt += 1;
        if (attempt == 1) {
          throw StateError('boot failed');
        }

        onProgress(
          const AppStartupProgress(
            stage: AppStartupStage.ready,
            value: 1,
            detail: 'MyApp',
          ),
        );
      },
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: AppStartupShell(
          runner: runner,
          readyBuilder: (_) => const SizedBox(key: Key('ready-child')),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('startup-icon')), findsOneWidget);
    expect(find.byKey(const Key('startup-retry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('startup-retry')));
    await tester.pumpAndSettle();

    expect(attempt, 2);
    expect(find.byKey(const Key('ready-child')), findsOneWidget);
  });

  testWidgets('does not throw when disposed before deferred init finishes', (
    tester,
  ) async {
    final completer = Completer<void>();
    final runner = _FakeStartupRunner(
      onRun: ({required onProgress}) => completer.future,
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: AppStartupShell(
          runner: runner,
          readyBuilder: (_) => const SizedBox(key: Key('ready-child')),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    completer.complete();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

class _FakeStartupRunner implements AppStartupRunner {
  _FakeStartupRunner({required this.onRun});

  final Future<void> Function({required StartupProgressCallback onProgress})
  onRun;
  @override
  bool get isReady => false;

  @override
  Future<void> initializeDeferred({
    required StartupProgressCallback onProgress,
  }) {
    return onRun(onProgress: onProgress);
  }
}
