import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/animated_navigation_rail_slot.dart';

void main() {
  test('wide rail preserves the existing 600px breakpoint semantics', () {
    expect(shouldShowWideNavigationRail(599, enabled: true), isFalse);
    expect(shouldShowWideNavigationRail(600, enabled: true), isFalse);
    expect(shouldShowWideNavigationRail(601, enabled: true), isTrue);
    expect(shouldShowWideNavigationRail(601, enabled: false), isFalse);
  });

  Widget buildSubject({
    required bool visible,
    bool reduceMotion = false,
    VoidCallback? onFocusExitRequested,
    Widget? child,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            AnimatedNavigationRailSlot(
              visible: visible,
              reduceMotion: reduceMotion,
              width: 120,
              onFocusExitRequested: onFocusExitRequested,
              child: child ?? const SizedBox.expand(),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  double slotWidth(WidgetTester tester) {
    return tester.getSize(find.byType(SizeTransition)).width;
  }

  testWidgets('animates the slot without replacing its child', (tester) async {
    final childKey = GlobalKey();
    await tester.pumpWidget(
      buildSubject(visible: true, child: SizedBox(key: childKey)),
    );
    final initialElement = childKey.currentContext;

    await tester.pumpWidget(
      buildSubject(visible: false, child: SizedBox(key: childKey)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(slotWidth(tester), greaterThan(0));
    expect(slotWidth(tester), lessThan(120));
    expect(childKey.currentContext, same(initialElement));

    await tester.pumpAndSettle();
    expect(slotWidth(tester), 0);
    expect(find.byKey(childKey), findsOneWidget);
  });

  testWidgets('retargets a running transition to the latest visibility', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(visible: true));
    await tester.pumpWidget(buildSubject(visible: false));
    await tester.pump(const Duration(milliseconds: 80));
    final interruptedWidth = slotWidth(tester);

    await tester.pumpWidget(buildSubject(visible: true));
    await tester.pump(const Duration(milliseconds: 40));
    expect(slotWidth(tester), greaterThan(interruptedWidth));

    await tester.pumpAndSettle();
    expect(slotWidth(tester), 120);
  });

  testWidgets('reduced motion keeps the slot while fading out', (tester) async {
    await tester.pumpWidget(buildSubject(visible: true, reduceMotion: true));
    await tester.pumpWidget(buildSubject(visible: false, reduceMotion: true));
    await tester.pump(const Duration(milliseconds: 60));

    expect(slotWidth(tester), 120);
    final slot = find.byType(AnimatedNavigationRailSlot);
    final slide = find.descendant(
      of: slot,
      matching: find.byType(SlideTransition),
    );
    final fade = find.descendant(
      of: slot,
      matching: find.byType(FadeTransition),
    );
    expect(tester.widget<SlideTransition>(slide).position.value, Offset.zero);
    expect(
      tester.widget<FadeTransition>(fade).opacity.value,
      inExclusiveRange(0, 1),
    );

    await tester.pumpAndSettle();
    expect(slotWidth(tester), 0);
  });

  testWidgets('requests focus exit when a focused rail is hidden', (
    tester,
  ) async {
    var focusExitRequests = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      buildSubject(
        visible: true,
        onFocusExitRequested: () => focusExitRequests++,
        child: TextButton(
          focusNode: focusNode,
          onPressed: () {},
          child: const Text('Destination'),
        ),
      ),
    );
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.pumpWidget(
      buildSubject(
        visible: false,
        onFocusExitRequested: () => focusExitRequests++,
        child: TextButton(
          focusNode: focusNode,
          onPressed: () {},
          child: const Text('Destination'),
        ),
      ),
    );
    await tester.pump();

    expect(focusExitRequests, 1);
  });

  testWidgets('hidden rail cannot regain focus', (tester) async {
    final railFocusNode = FocusNode();
    addTearDown(railFocusNode.dispose);

    await tester.pumpWidget(
      buildSubject(
        visible: true,
        child: TextButton(
          focusNode: railFocusNode,
          onPressed: () {},
          child: const Text('Destination'),
        ),
      ),
    );
    railFocusNode.requestFocus();
    await tester.pump();
    expect(railFocusNode.hasFocus, isTrue);

    await tester.pumpWidget(
      buildSubject(
        visible: false,
        child: TextButton(
          focusNode: railFocusNode,
          onPressed: () {},
          child: const Text('Destination'),
        ),
      ),
    );
    await tester.pump();
    expect(railFocusNode.hasFocus, isFalse);

    railFocusNode.requestFocus();
    await tester.pump();

    expect(railFocusNode.hasFocus, isFalse);
  });
}
