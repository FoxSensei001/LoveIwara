import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';
import 'package:loading_more_list/loading_more_list.dart';

void main() {
  group('LoadingMoreRefreshGuard', () {
    test(
      'serializes concurrent refreshes without losing the last request',
      () async {
        final source = _GuardedSource();

        final first = source.refresh(true);
        final second = source.refresh(true);

        await _waitUntil(() => source.requests.length == 1);
        source.requests[0].complete(<int>[1]);
        expect(await first, isTrue);

        await _waitUntil(() => source.requests.length == 2);
        source.requests[1].complete(<int>[2]);
        expect(await second, isTrue);

        expect(source.loadCalls, 2);
        expect(source.toList(), <int>[2]);
        source.dispose();
      },
    );

    test('waits for loadMore before resetting and starting refresh', () async {
      final source = _GuardedSource();

      final loadMore = source.loadMore();
      await _waitUntil(() => source.requests.length == 1);

      var refreshCompleted = false;
      final refresh = source.refresh(true).whenComplete(() {
        refreshCompleted = true;
      });

      // Let several polling cycles pass. There is intentionally no network
      // timeout: refresh must remain queued until the actual request settles.
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(refreshCompleted, isFalse);
      expect(source.requests, hasLength(1));

      source.requests[0].complete(<int>[1]);
      expect(await loadMore, isTrue);
      await _waitUntil(() => source.requests.length == 2);

      source.requests[1].complete(<int>[2]);
      expect(await refresh, isTrue);
      expect(source.toList(), <int>[2]);
      source.dispose();
    });

    test('dispose releases a refresh waiting behind loadMore', () async {
      final source = _GuardedSource();

      final loadMore = source.loadMore();
      await _waitUntil(() => source.requests.length == 1);
      final refresh = source.refresh(true);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      source.dispose();
      expect(await refresh.timeout(const Duration(seconds: 1)), isFalse);

      source.requests[0].complete(<int>[1]);
      expect(await loadMore, isTrue);
      expect(source, isEmpty);
    });

    test('a failed guarded operation does not poison the queue', () async {
      final source = _GuardedSource();

      final failed = source.scheduleOperation(() async {
        throw StateError('expected failure');
      });
      final recovered = source.scheduleOperation(() async => true);

      await expectLater(failed, throwsStateError);
      expect(await recovered, isTrue);
      expect(source.resetCount, 2);
      source.dispose();
    });
  });
}

class _GuardedSource extends LoadingMoreBase<int>
    with LoadingMoreRefreshGuard<int> {
  final List<Completer<List<int>>> requests = <Completer<List<int>>>[];
  int loadCalls = 0;
  int resetCount = 0;

  @override
  bool get hasMore => true;

  @override
  void resetPagingState() {
    super.resetPagingState();
    resetCount++;
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) {
    return runGuardedRefresh(() => super.refresh(notifyStateChanged));
  }

  Future<bool> scheduleOperation(Future<bool> Function() operation) {
    return runGuardedRefresh(operation);
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    final generation = currentGeneration;
    final request = Completer<List<int>>();
    requests.add(request);
    loadCalls++;

    final items = await request.future;
    if (isStaleGeneration(generation)) return true;
    addAll(items);
    return true;
  }
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 1));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met before timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}
