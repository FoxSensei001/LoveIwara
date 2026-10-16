import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follow_search_controller.dart';
import 'package:i_iwara/app/ui/pages/follows/repositories/followers_list_repository.dart';
import 'package:i_iwara/app/ui/pages/follows/repositories/following_list_repository.dart';

void main() {
  tearDown(Get.reset);
  for (final followers in [false, true]) {
    test(
      '${followers ? 'followers' : 'following'} captures paginated pages and rejects stale refresh data',
      () async {
        final service = _Users();
        Get.put<UserService>(service);
        final search = FollowSearchController(
          fetchPage: (p, l, t) async =>
              PageData(count: 0, page: p, limit: l, results: []),
        );
        final repository = followers
            ? FollowersListRepository('user', search: search)
            : FollowingListRepository('user', search: search);
        addTearDown(search.dispose);
        addTearDown(repository.dispose);
        final first = repository.loadPageData(0, 20);
        service.requests[0].complete(_result('first', 0));
        await first;
        final second = repository.loadPageData(1, 20);
        service.requests[1].complete(_result('second', 1));
        await second;
        expect(search.loadedCount, 2);
        expect(
          repository,
          isEmpty,
          reason: 'Paged search does not mutate waterfall cursor',
        );
        final old = repository.loadPageData(2, 20);
        repository.resetPagingState();
        final fresh = repository.loadPageData(0, 20);
        service.requests[3].complete(_result('fresh', 0));
        await fresh;
        service.requests[2].complete(_result('stale', 2));
        await expectLater(old, throwsException);
        expect(search.results.map((u) => u.id), ['fresh']);
        expect(
          service.tokens.every((token) => token == repository.cancelToken),
          isTrue,
        );
      },
    );
  }
}

ApiResult<PageData<User>> _result(String id, int page) => ApiResult.success(
  data: PageData(
    count: 100,
    page: page,
    limit: 20,
    results: [User(id: id)],
  ),
);

class _Users extends GetxService implements UserService {
  final requests = <Completer<ApiResult<PageData<User>>>>[];
  final tokens = <CancelToken?>[];

  Future<ApiResult<PageData<User>>> _fetch(CancelToken? token) {
    final request = Completer<ApiResult<PageData<User>>>();
    requests.add(request);
    tokens.add(token);
    return request.future;
  }

  @override
  Future<ApiResult<PageData<User>>> fetchFollowingUsers({
    int page = 0,
    int limit = 20,
    required String userId,
    CancelToken? cancelToken,
    bool rethrowErrors = false,
  }) => _fetch(cancelToken);

  @override
  Future<ApiResult<PageData<User>>> fetchFollowers({
    int page = 0,
    int limit = 20,
    required String userId,
    CancelToken? cancelToken,
    bool rethrowErrors = false,
  }) => _fetch(cancelToken);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
