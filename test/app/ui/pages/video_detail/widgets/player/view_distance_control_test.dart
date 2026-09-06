import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/view_distance_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart';

void main() {
  final factors = <double>[];
  final interactions = <bool>[];
  var resets = 0;

  setUp(() {
    LocaleSettings.setLocale(AppLocale.en);
    factors.clear();
    interactions.clear();
    resets = 0;
  });

  Future<void> pumpControl(
    WidgetTester tester, {
    bool visible = true,
    bool compact = false,
    Listenable? cancelSignal,
  }) {
    return tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: LiquidGlassScope(
                backend: GlassBackend.plain,
                child: ViewDistanceControl(
                  visible: visible,
                  materialize: visible ? 1 : 0,
                  compact: compact,
                  maxWidth: 280,
                  onScale: factors.add,
                  onReset: () => resets++,
                  onInteraction: interactions.add,
                  cancelSignal: cancelSignal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<TestGesture> pressCloser(WidgetTester tester) async {
    await pumpControl(tester);
    await tester.tap(find.text('Distance'));
    await tester.pump();
    return tester.startGesture(tester.getCenter(find.text('Closer')));
  }

  testWidgets(
    'holding moves continuously; release stops and releases the pointer guard',
    (tester) async {
      final gesture = await pressCloser(tester);
      final first = factors.length;
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(factors.length, greaterThan(first));
      expect(factors.every((factor) => factor > 1), isTrue);
      expect(interactions.last, isTrue);
      await gesture.up();
      final released = factors.length;
      await tester.pump(const Duration(milliseconds: 500));
      expect(factors.length, released);
      expect(interactions.last, isFalse);
    },
  );

  testWidgets('cancel and moving outside the button stop movement', (
    tester,
  ) async {
    final gesture = await pressCloser(tester);
    await tester.pump(const Duration(milliseconds: 32));
    await gesture.moveBy(const Offset(400, 0));
    final movedOut = factors.length;
    await tester.pump(const Duration(milliseconds: 250));
    expect(factors.length, movedOut);
    await gesture.cancel();
    expect(interactions.last, isFalse);
  });

  testWidgets(
    'hiding or removing controls while held cannot leave movement running',
    (tester) async {
      final gesture = await pressCloser(tester);
      await tester.pump(const Duration(milliseconds: 32));
      await pumpControl(tester, visible: false);
      final hidden = factors.length;
      await tester.pump(const Duration(milliseconds: 300));
      expect(factors.length, hidden);
      expect(interactions.last, isFalse);
      await gesture.up();

      final second = await pressCloser(tester);
      await tester.pump(const Duration(milliseconds: 32));
      await tester.pumpWidget(const SizedBox.shrink());
      final removed = factors.length;
      await tester.pump(const Duration(milliseconds: 300));
      expect(factors.length, removed);
      expect(interactions.last, isFalse);
      await second.cancel();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('backgrounding the app stops a held control', (tester) async {
    final gesture = await pressCloser(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    final paused = factors.length;
    await tester.pump(const Duration(milliseconds: 300));
    expect(factors.length, paused);
    expect(interactions.last, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await gesture.up();
  });

  testWidgets(
    'a fullscreen or media transition cancels before the widget is replaced',
    (tester) async {
      final cancel = ChangeNotifier();
      await pumpControl(tester, cancelSignal: cancel);
      await tester.tap(find.text('Distance'));
      await tester.pump();
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Closer')),
      );
      await tester.pump(const Duration(milliseconds: 32));
      cancel.notifyListeners();
      final stopped = factors.length;
      expect(interactions.last, isFalse);
      await tester.pump(const Duration(milliseconds: 500));
      expect(factors.length, stopped);
      await gesture.up();
      await tester.pumpWidget(const SizedBox.shrink());
      cancel.dispose();
    },
  );

  testWidgets(
    'compact controls fit a narrow player and reset without changing direction',
    (tester) async {
      await pumpControl(tester, compact: true);
      await tester.tap(find.text('Distance'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(ViewDistanceControl)).width,
        lessThanOrEqualTo(280),
      );
      await tester.tap(find.text('Farther'));
      expect(factors.last, lessThan(1));
      await tester.tap(find.text('Reset'));
      expect(resets, 1);
      expect(interactions.last, isFalse);
    },
  );
}
