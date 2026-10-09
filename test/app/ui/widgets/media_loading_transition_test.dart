import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/widgets/infinite_scroll_waterfall_tab.dart';
import 'package:i_iwara/app/ui/widgets/loading_content_transition.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:loading_more_list/loading_more_list.dart';

class _Source extends LoadingMoreBase<int> {
  Completer<void> response = Completer<void>();

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    await response.future;
    final start = length;
    addAll(List.generate(40, (index) => start + index));
    return true;
  }
}

void main() {
  testWidgets('media source completion fades once without losing scroll', (
    tester,
  ) async {
    final source = _Source();
    final scroll = ScrollController();
    addTearDown(source.dispose);
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaListView<int>(
            sourceList: source,
            scrollController: scroll,
            itemBuilder: (_, item, index) =>
                SizedBox(height: 150, child: Text('Item $item')),
          ),
        ),
      ),
    );
    await tester.pump();
    source.response.complete();
    await tester.pump();
    await tester.pump();
    Finder fades() => find.descendant(
      of: find.byType(LoadingContentTransition),
      matching: find.byType(FadeTransition),
    );
    await tester.pump(const Duration(milliseconds: 90));
    expect(
      tester.widget<FadeTransition>(fades().first).opacity.value,
      inExclusiveRange(0, 1),
    );
    await tester.pumpAndSettle();
    scroll.jumpTo(200);
    await tester.pump();
    expect(scroll.positions.length, 1);

    source.response = Completer<void>();
    final more = source.loadMore();
    await tester.pump();
    expect(tester.widget<FadeTransition>(fades().first).opacity.value, 1);
    source.response.complete();
    await more;
    await tester.pump();
    expect(tester.widget<FadeTransition>(fades().first).opacity.value, 1);
    expect(scroll.offset, 200);
  });

  testWidgets('waterfall refresh keeps available cards instead of skeletons', (
    tester,
  ) async {
    Widget build({required bool loading, required List<int> items}) =>
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: InfiniteScrollWaterfallTab<int>(
                items: items,
                isLoading: loading,
                isLoadingMore: false,
                hasMore: false,
                onLoadMore: () {},
                emptyMessage: 'Empty',
                itemBuilder: (_, item, width) => Text('Card $item'),
                skeletonBuilder: (_, width) => const Text('Skeleton'),
              ),
            ),
          ),
        );
    await tester.pumpWidget(build(loading: true, items: []));
    expect(find.text('Skeleton'), findsWidgets);
    await tester.pumpWidget(build(loading: false, items: [1]));
    await tester.pumpAndSettle();
    final element = tester.element(find.text('Card 1'));
    await tester.pumpWidget(build(loading: true, items: [1]));
    expect(find.text('Skeleton'), findsNothing);
    expect(tester.element(find.text('Card 1')), same(element));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('scrolling during refresh cannot request another page', (
    tester,
  ) async {
    var requests = 0;
    Widget build(bool loading) => TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: InfiniteScrollWaterfallTab<int>(
            items: List.generate(40, (index) => index),
            isLoading: loading,
            isLoadingMore: false,
            hasMore: true,
            onLoadMore: () => requests++,
            emptyMessage: 'Empty',
            itemBuilder: (_, item, width) =>
                SizedBox(height: 150, child: Text('Card $item')),
          ),
        ),
      ),
    );
    await tester.pumpWidget(build(true));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -5000));
    await tester.pumpAndSettle();
    expect(requests, 0);
    await tester.pumpWidget(build(false));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(requests, greaterThan(0));
  });
}
