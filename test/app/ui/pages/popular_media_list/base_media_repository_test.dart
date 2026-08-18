import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_repository.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';

void main() {
  test('stale paginated response cannot overwrite the current total', () async {
    final repository = _FakeBaseMediaRepository();

    final staleLoad = repository.loadPageData(0, 20);
    await _waitUntil(() => repository.requests.length == 1);

    repository.resetState();
    final currentLoad = repository.loadPageData(0, 20);
    await _waitUntil(() => repository.requests.length == 2);

    repository.requests[1].complete(_success(count: 40, items: <int>[2]));
    expect(await currentLoad, <int>[2]);
    expect(repository.requestTotalCount, 40);

    repository.requests[0].complete(_success(count: 10, items: <int>[1]));
    await expectLater(staleLoad, throwsA(isA<StalePageLoadException>()));
    expect(repository.requestTotalCount, 40);

    repository.dispose();
  });

  test('stale paginated failure cannot overwrite the current error', () async {
    final repository = _FakeBaseMediaRepository();

    final staleLoad = repository.loadPageData(0, 20);
    await _waitUntil(() => repository.requests.length == 1);

    repository.resetState();
    final currentLoad = repository.loadPageData(0, 20);
    await _waitUntil(() => repository.requests.length == 2);

    repository.requests[1].complete(_success(count: 20, items: <int>[2]));
    await currentLoad;

    repository.requests[0].complete(ApiResult<PageData<int>>.fail('stale'));
    await expectLater(staleLoad, throwsA(isA<StalePageLoadException>()));
    expect(repository.lastErrorMessage, isNull);

    repository.dispose();
  });
}

class _FakeBaseMediaRepository extends BaseMediaRepository<int> {
  _FakeBaseMediaRepository() : super(sortId: 'test');

  final List<Completer<ApiResult<PageData<int>>>> requests =
      <Completer<ApiResult<PageData<int>>>>[];

  @override
  Future<ApiResult<PageData<int>>> fetchData(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) {
    final request = Completer<ApiResult<PageData<int>>>();
    requests.add(request);
    return request.future;
  }
}

ApiResult<PageData<int>> _success({
  required int count,
  required List<int> items,
}) {
  return ApiResult<PageData<int>>.success(
    data: PageData<int>(count: count, page: 0, limit: 20, results: items),
  );
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
