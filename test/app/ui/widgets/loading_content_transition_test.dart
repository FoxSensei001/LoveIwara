import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/loading_content_transition.dart';

Widget subject({
  required bool loading,
  required Widget child,
  bool retain = true,
  bool reduceMotion = false,
  bool accessibleNavigation = false,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      disableAnimations: reduceMotion,
      accessibleNavigation: accessibleNavigation,
    ),
    child: Scaffold(
      body: LoadingContentTransition(
        isLoading: loading,
        retainLoading: retain,
        child: child,
      ),
    ),
  ),
);

Finder get transitionFades => find.descendant(
  of: find.byType(LoadingContentTransition),
  matching: find.byType(FadeTransition),
);

void main() {
  testWidgets('dissolves the loader while content is already interactive', (
    tester,
  ) async {
    var loadingTaps = 0;
    var contentTaps = 0;
    await tester.pumpWidget(
      subject(
        loading: true,
        child: SizedBox(
          height: 200,
          child: TextButton(
            onPressed: () => loadingTaps++,
            child: const Text('Loading'),
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      subject(
        loading: false,
        child: SizedBox(
          height: 100,
          child: TextButton(
            onPressed: () => contentTaps++,
            child: const Text('Content'),
          ),
        ),
      ),
    );
    // Outgoing height does not affect the content's layout.
    expect(tester.getSize(find.byType(LoadingContentTransition)).height, 100);
    expect(find.text('Loading'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 90));
    final fades = tester.widgetList<FadeTransition>(
      find.byType(FadeTransition),
    );
    expect(fades.last.opacity.value, inExclusiveRange(0, 1));
    await tester.tap(find.text('Content'));
    expect(contentTaps, 1);
    expect(loadingTaps, 0);
    await tester.pumpAndSettle();
    expect(find.text('Loading'), findsNothing);
  });

  testWidgets(
    'removing the overlay preserves content state and scroll offset',
    (tester) async {
      final key = GlobalKey();
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      Widget content() => ListView.builder(
        key: key,
        controller: scroll,
        itemCount: 100,
        itemExtent: 50,
        itemBuilder: (_, index) => Text('Row $index'),
      );
      await tester.pumpWidget(
        subject(
          loading: true,
          child: const SizedBox.expand(child: Text('Loading')),
        ),
      );
      await tester.pumpWidget(subject(loading: false, child: content()));
      final element = key.currentContext;
      scroll.jumpTo(200);
      await tester.pumpAndSettle();
      await tester.pumpWidget(subject(loading: false, child: content()));
      expect(key.currentContext, same(element));
      expect(scroll.offset, 200);
    },
  );

  testWidgets('shared scroll controller only attaches to the active child', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    Widget list(String label) =>
        ListView(controller: scroll, children: [Text(label)]);
    await tester.pumpWidget(
      subject(loading: true, retain: false, child: list('Loading')),
    );
    await tester.pumpWidget(
      subject(loading: false, retain: false, child: list('Content')),
    );
    expect(scroll.positions.length, 1);
    expect(find.text('Loading'), findsNothing);
    await tester.pump(const Duration(milliseconds: 90));
    final fade = tester.widget<FadeTransition>(transitionFades.first);
    expect(fade.opacity.value, inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(fade.opacity.value, 1);
  });

  testWidgets('outgoing Hero is disabled and content Hero can fly', (
    tester,
  ) async {
    Widget hero(String label) => Hero(tag: 'shared', child: Text(label));
    await tester.pumpWidget(subject(loading: true, child: hero('Loading')));
    await tester.pumpWidget(subject(loading: false, child: hero('Content')));
    final disabled = tester.widget<HeroMode>(find.byType(HeroMode));
    expect(disabled.enabled, isFalse);
    final context = tester.element(find.text('Content'));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(body: hero('Destination')),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Destination'), findsOneWidget);
  });

  testWidgets('cached content is opaque immediately and updates do not fade', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(loading: false, retain: false, child: const Text('Cached')),
    );
    await tester.pumpWidget(
      subject(loading: false, retain: false, child: const Text('Updated')),
    );
    final fade = tester.widget<FadeTransition>(transitionFades.first);
    expect(fade.opacity.value, 1);
  });

  testWidgets('reload during a dissolve discards the stale placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(loading: true, child: const Text('Old loader')),
    );
    await tester.pumpWidget(
      subject(loading: false, child: const Text('Old data')),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(
      subject(loading: true, child: const Text('New loader')),
    );
    expect(find.text('Old loader'), findsNothing);
    expect(find.text('Old data'), findsNothing);
    await tester.pumpWidget(
      subject(loading: false, child: const Text('New data')),
    );
    await tester.pumpAndSettle();
    expect(find.text('New loader'), findsNothing);
    expect(find.text('New data'), findsOneWidget);
  });

  for (final accessible in [false, true]) {
    testWidgets('system motion preference skips transition ($accessible)', (
      tester,
    ) async {
      await tester.pumpWidget(
        subject(
          loading: true,
          reduceMotion: !accessible,
          accessibleNavigation: accessible,
          child: const Text('Loading'),
        ),
      );
      await tester.pumpWidget(
        subject(
          loading: false,
          reduceMotion: !accessible,
          accessibleNavigation: accessible,
          child: const Text('Content'),
        ),
      );
      expect(find.text('Loading'), findsNothing);
      expect(find.text('Content'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });
  }

  testWidgets('enabling reduced motion ends an in-flight dissolve', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(loading: true, child: const Text('Loading')),
    );
    await tester.pumpWidget(
      subject(loading: false, child: const Text('Content')),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(
      subject(loading: false, reduceMotion: true, child: const Text('Content')),
    );
    expect(find.text('Loading'), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
