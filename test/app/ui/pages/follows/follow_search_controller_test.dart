import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follow_search_controller.dart';

PageData<User> page(int index, int limit, int total, {List<User>? users}) =>
    PageData(
      count: total,
      page: index,
      limit: limit,
      results:
          users ??
          List.generate(
            (total - index * limit).clamp(0, limit),
            (i) => User(
              id: '${index * limit + i}',
              name: 'Creator ${index * limit + i}',
              username: 'handle${index * limit + i}',
            ),
          ),
    );

DioException rejected(int status, Object body) {
  final options = RequestOptions(path: '/following');
  return DioException.badResponse(
    statusCode: status,
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status, data: body),
  );
}

void main() {
  test(
    'full search keeps existing loaded matches visible while probing',
    () async {
      final pending = Completer<PageData<User>>();
      final search = FollowSearchController(
        fetchPage: (p, l, t) => pending.future,
      );
      addTearDown(search.dispose);
      search.recordLoaded(page(0, 20, 100));
      search.setQuery('@handle19');
      final scan = search.startAll();
      expect(search.results.single.id, '19');
      search.cancel();
      pending.complete(page(0, 50, 100));
      await scan;
    },
  );

  test(
    'a fully loaded first page needs no additional full-search request',
    () async {
      var requests = 0;
      final search = FollowSearchController(
        fetchPage: (p, l, t) async {
          requests++;
          return page(p, l, 3);
        },
      );
      addTearDown(search.dispose);
      search.recordLoaded(page(0, 20, 3));
      await search.startAll();
      expect(search.complete, isTrue);
      expect(search.results.length, 3);
      expect(requests, 0);
    },
  );

  test(
    'a browsing response cannot overwrite an in-flight scan count',
    () async {
      final pending = Completer<PageData<User>>();
      final search = FollowSearchController(
        fetchPage: (p, l, t) async {
          if (p == 0) return page(0, 20, 45);
          return pending.future;
        },
      );
      addTearDown(search.dispose);
      final scan = search.startAll();
      while (search.pageSize == null) {
        await Future<void>.delayed(Duration.zero);
      }
      search.recordLoaded(page(0, 20, 999));
      expect(search.totalCount, 45);
      search.cancel();
      pending.complete(page(1, 20, 45));
      await scan;
    },
  );

  test('loaded search matches names and handles without network requests', () {
    var requests = 0;
    final search = FollowSearchController(
      fetchPage: (p, l, t) async {
        requests++;
        return page(p, l, 0);
      },
    );
    addTearDown(search.dispose);
    search.recordLoaded(
      page(
        0,
        20,
        2,
        users: [
          User(id: '1', name: '初音未来', username: 'Miku'),
          User(id: '2', name: 'Other', username: 'another'),
        ],
      ),
    );
    search.setQuery('  @MIKU ');
    expect(search.results.map((u) => u.id), ['1']);
    search.setQuery('初音');
    expect(search.results.map((u) => u.id), ['1']);
    search.setQuery('  ');
    expect(search.results.length, 2);
    expect(requests, 0);
  });

  test(
    'server clamp determines page offsets and cached queries reuse full data',
    () async {
      final requests = <(int, int)>[];
      final search = FollowSearchController(
        fetchPage: (p, l, t) async {
          requests.add((p, l));
          return page(p, l.clamp(1, 50), 123);
        },
      );
      addTearDown(search.dispose);
      await search.startAll();
      expect(search.complete, isTrue);
      expect(search.pageSize, 50);
      expect(search.scannedCount, 123);
      expect(requests, [(0, 10000), (1, 50), (2, 50)]);
      search.setQuery('@handle122');
      expect(search.results.single.id, '122');
      search.useLoaded();
      await search.startAll();
      expect(requests.length, 3);
    },
  );

  test('silently capped responses are normalized before paging', () async {
    final requests = <(int, int)>[];
    final search = FollowSearchController(
      fetchPage: (p, l, t) async {
        requests.add((p, l));
        final actual = page(p, l.clamp(1, 40), 95);
        return page(p, l, 95, users: actual.results);
      },
    );
    addTearDown(search.dispose);
    await search.startAll();
    expect(search.complete, isTrue);
    expect(requests, [(0, 10000), (0, 40), (1, 40), (2, 40)]);
  });

  test(
    'explicit limit rejection finds the actual maximum by binary search',
    () async {
      final limits = <int>[];
      final search = FollowSearchController(
        fetchPage: (p, l, t) async {
          limits.add(l);
          if (l > 73) throw rejected(400, {'message': 'invalid limit'});
          return page(p, l, 170);
        },
      );
      addTearDown(search.dispose);
      await search.startAll();
      expect(search.pageSize, 73);
      expect(search.complete, isTrue);
      expect(limits, contains(74));
    },
  );

  for (final status in [401, 403, 429, 500]) {
    test(
      'HTTP $status is an error, not evidence of a page-size limit',
      () async {
        var calls = 0;
        final search = FollowSearchController(
          fetchPage: (p, l, t) async {
            calls++;
            throw rejected(status, {'message': 'limit access'});
          },
        );
        addTearDown(search.dispose);
        await search.startAll();
        expect(calls, 1);
        expect(search.error, isA<DioException>());
        expect(search.complete, isFalse);
      },
    );
  }

  test(
    'unrelated validation failure does not trigger pagination probing',
    () async {
      var calls = 0;
      final search = FollowSearchController(
        fetchPage: (p, l, t) async {
          calls++;
          throw rejected(400, {'message': 'invalid user'});
        },
      );
      addTearDown(search.dispose);
      await search.startAll();
      expect(calls, 1);
      expect(search.error, isNotNull);
    },
  );

  test(
    'large scans wait for confirmation, then resume without re-probing',
    () async {
      final requests = <int>[];
      final search = FollowSearchController(
        fetchPage: (p, l, t) async {
          requests.add(p);
          return page(p, 20, 500);
        },
      );
      addTearDown(search.dispose);
      await search.startAll();
      expect(search.awaitingConfirmation, isTrue);
      expect(search.loading, isFalse);
      expect(search.remainingRequests, 24);
      expect(requests, [0]);
      await search.startAll();
      expect(requests, [0]);
      await search.startAll(confirmed: true);
      expect(search.complete, isTrue);
      expect(requests.length, 25);
      expect(requests.where((p) => p == 0).length, 1);
    },
  );

  test(
    'cancellation ignores late responses and preserves completed pages',
    () async {
      final pending = Completer<PageData<User>>();
      CancelToken? activeToken;
      final requests = <int>[];
      final search = FollowSearchController(
        fetchPage: (p, l, t) async {
          requests.add(p);
          if (p == 1 && requests.length == 2) {
            activeToken = t;
            return pending.future;
          }
          return page(p, 20, 45);
        },
      );
      addTearDown(search.dispose);
      final scanning = search.startAll();
      while (activeToken == null) {
        await Future<void>.delayed(Duration.zero);
      }
      search.cancel();
      expect(activeToken!.isCancelled, isTrue);
      expect(search.scannedCount, 20);
      expect(search.cancelled, isTrue);
      await search.startAll(confirmed: true);
      expect(search.complete, isTrue);
      pending.complete(page(1, 20, 999));
      await scanning;
      expect(search.totalCount, 45);
      expect(search.scannedCount, 45);
      expect(requests, [0, 1, 1, 2]);
    },
  );

  test('refresh drops the stale snapshot but rescans the whole list', () async {
    final calls = <Completer<PageData<User>>>[];
    final search = FollowSearchController(
      fetchPage: (p, l, t) {
        calls.add(Completer<PageData<User>>());
        return calls.last.future;
      },
    );
    addTearDown(search.dispose);
    search.setQuery('name');
    final stale = search.startAll();
    search.reset();
    // The rescan has started its own probe; the stale one must not leak in.
    expect(calls, hasLength(2));
    expect(search.query, 'name');
    expect(search.searchAll, isTrue);
    expect(search.loading, isTrue);
    calls.first.complete(page(0, 20, 99));
    await stale;
    expect(search.totalCount, isNull);
    expect(search.error, isNull);
    calls.last.complete(page(0, 20, 20));
    await pumpEventQueue();
    expect(search.complete, isTrue);
    expect(search.scannedCount, 20);
    expect(search.totalCount, 20);
  });

  test('refresh keeps a cancelled whole-list search cancelled', () async {
    var requests = 0;
    final search = FollowSearchController(
      fetchPage: (p, l, t) async {
        requests++;
        return page(0, 20, 20);
      },
    );
    addTearDown(search.dispose);
    final scan = search.startAll();
    search.cancel();
    await scan;
    final before = requests;
    search.reset();
    await pumpEventQueue();
    expect(search.searchAll, isTrue);
    expect(search.cancelled, isTrue);
    expect(requests, before);

    search.useLoaded();
    search.reset();
    expect(search.searchAll, isFalse);
  });

  test(
    'duplicate or empty pages cannot masquerade as a complete search',
    () async {
      final search = FollowSearchController(
        fetchPage: (p, l, t) async =>
            page(p, 20, 45, users: page(0, 20, 45).results),
      );
      addTearDown(search.dispose);
      await search.startAll();
      expect(search.complete, isFalse);
      expect(search.error, isNotNull);
      expect(search.scannedCount, 20);
      expect(search.pageSize, isNull);
    },
  );

  test('empty full list completes in one request', () async {
    var requests = 0;
    final search = FollowSearchController(
      fetchPage: (p, l, t) async {
        requests++;
        return page(0, 100, 0);
      },
    );
    addTearDown(search.dispose);
    await search.startAll();
    expect(search.complete, isTrue);
    expect(search.results, isEmpty);
    expect(requests, 1);
  });

  test('a changing total cannot mark a mixed snapshot complete', () async {
    final search = FollowSearchController(
      fetchPage: (p, l, t) async => page(p, 20, p == 0 ? 45 : 0),
    );
    addTearDown(search.dispose);
    await search.startAll();
    expect(search.complete, isFalse);
    expect(search.error, isNotNull);
    expect(search.pageSize, isNull);
    expect(search.scannedCount, 20);
  });

  test(
    'limits below the normal browsing size are still discoverable',
    () async {
      final search = FollowSearchController(
        fetchPage: (p, l, t) async {
          if (l > 7) throw rejected(422, {'message': 'invalid limit'});
          return page(p, l, 15);
        },
      );
      addTearDown(search.dispose);
      await search.startAll();
      expect(search.pageSize, 7);
      expect(search.complete, isTrue);
    },
  );

  test(
    'cancelling a binary probe keeps already fetched users searchable',
    () async {
      final pending = Completer<PageData<User>>();
      var probing = false;
      final search = FollowSearchController(
        fetchPage: (p, l, t) async {
          if (l >= 100) throw rejected(400, {'message': 'invalid limit'});
          if (l == 20) return page(0, 20, 200);
          probing = true;
          return pending.future;
        },
      );
      addTearDown(search.dispose);
      final scan = search.startAll();
      while (!probing) {
        await Future<void>.delayed(Duration.zero);
      }
      search.cancel();
      expect(search.loadedCount, 20);
      expect(search.scannedCount, 20);
      search.setQuery('@handle19');
      expect(search.results.single.id, '19');
      pending.complete(page(0, 60, 200));
      await scan;
      expect(search.scannedCount, 20);
    },
  );

  test(
    'a slow in-flight request extends the conservative time estimate',
    () async {
      final pending = Completer<PageData<User>>();
      var requestedSecond = false;
      final search = FollowSearchController(
        fetchPage: (p, l, t) async {
          if (p == 0) return page(0, 20, 100);
          requestedSecond = true;
          return pending.future;
        },
      );
      addTearDown(search.dispose);
      final scan = search.startAll(confirmed: true);
      while (!requestedSecond) {
        await Future<void>.delayed(Duration.zero);
      }
      final original = search.estimatedRemaining;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(search.estimatedRemaining, greaterThan(original));
      search.cancel();
      pending.complete(page(1, 20, 100));
      await scan;
    },
  );
}
