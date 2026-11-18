import 'dart:async';

import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/widgets/loading_content_transition.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:loading_more_list/loading_more_list.dart';
import 'package:material_ui/material_ui.dart';

class _Source extends LoadingMoreBase<int> {
  _Source() {
    addAll(List<int>.generate(60, (i) => i));
    indicatorStatus = IndicatorStatus.none;
  }

  @override
  bool get hasMore => false;

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async => true;
}

class _PendingSource extends LoadingMoreBase<int> {
  final ready = Completer<bool>();

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) => ready.future;
}

class _FailedAppendSource extends _Source {
  int attempts = 0;

  @override
  bool get hasMore => true;

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    attempts++;
    return false;
  }
}

void main() {
  Future<void> mount(
    WidgetTester tester,
    LoadingMoreBase<int> source,
    ScrollController controller, {
    void Function(double offset, double delta, ScrollDirection direction)?
    onScroll,
  }) async {
    await tester.pumpWidget(
      slang.TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: MediaListView<int>(
              sourceList: source,
              scrollController: controller,
              enablePullToRefresh: false,
              onScrollMetricsChanged: onScroll,
              itemBuilder: (context, item, index) =>
                  SizedBox(height: 96, child: Text('row $item')),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'a data event updates the sliver without rebuilding the viewport',
    (tester) async {
      final source = _Source();
      final controller = ScrollController();
      addTearDown(source.dispose);
      addTearDown(controller.dispose);
      await mount(tester, source, controller);
      final scrollView = find.byType(LoadingMoreCustomScrollView);
      final viewport = tester.widget(scrollView);
      expect(find.text('row 0'), findsOneWidget);

      source[0] = 1000;
      source.setState();
      await tester.pump();

      expect(find.text('row 1000'), findsOneWidget);
      expect(tester.widget(scrollView), same(viewport));
      expect(
        tester
            .widget<LoadingContentTransition>(
              find.byType(LoadingContentTransition),
            )
            .isLoading,
        isFalse,
      );
    },
  );

  testWidgets('initial loading still transitions to a populated list', (
    tester,
  ) async {
    final source = _PendingSource();
    final controller = ScrollController();
    addTearDown(source.dispose);
    addTearDown(controller.dispose);
    await mount(tester, source, controller);

    LoadingContentTransition transition() =>
        tester.widget(find.byType(LoadingContentTransition));
    expect(transition().isLoading, isTrue);

    source.add(7);
    source.ready.complete(true);
    await tester.pump();
    await tester.pump(LoadingContentTransition.duration);

    expect(transition().isLoading, isFalse);
    expect(find.text('row 7'), findsOneWidget);
    expect(controller.positions, hasLength(1));
  });

  testWidgets('near-end prefetch does not retry a failed append on scroll', (
    tester,
  ) async {
    final source = _FailedAppendSource();
    final controller = ScrollController();
    addTearDown(source.dispose);
    addTearDown(controller.dispose);
    await mount(tester, source, controller);

    controller.jumpTo(controller.position.maxScrollExtent - 100);
    await tester.pump();
    expect(source.attempts, 1);
    expect(source.indicatorStatus, IndicatorStatus.error);

    // Stay within the prefetch zone; further motion is not a retry action.
    controller.jumpTo(controller.position.maxScrollExtent - 50);
    await tester.pump();
    expect(source.attempts, 1);
  });

  testWidgets('rapid scroll updates preserve distance and the final offset', (
    tester,
  ) async {
    final source = _Source();
    final controller = ScrollController();
    addTearDown(source.dispose);
    addTearDown(controller.dispose);
    final offsets = <double>[];
    final deltas = <double>[];
    await mount(
      tester,
      source,
      controller,
      onScroll: (offset, delta, _) {
        offsets.add(offset);
        deltas.add(delta);
      },
    );

    controller.jumpTo(20);
    controller.jumpTo(40);
    controller.jumpTo(60);
    await tester.pump();

    expect(offsets, [20, 40, 60]);
    expect(deltas, [20, 20, 20]);
  });
}
