import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_controller.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_detail_controller.dart';
import 'package:i_iwara/app/ui/pages/play_list/play_list.dart';
import 'package:i_iwara/app/ui/pages/play_list/play_list_detail.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await LogUtils.init(isProduction: true);
  });

  setUp(() {
    Get.testMode = true;
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  tearDown(() {
    Get.reset();
  });

  group('PlayListPage delete flow', () {
    testWidgets('shows delete affordance only on owned playlist page', (
      tester,
    ) async {
      final fakeService = _FakePlayListService(
        playlists: [
          PlaylistModel(
            id: 'playlist-1',
            title: 'Owned Playlist',
            numVideos: 3,
            user: User(id: 'user-1'),
          ),
        ],
      );
      Get.put<PlayListService>(fakeService);

      await tester.pumpWidget(
        _buildTestApp(
          child: const PlayListPage(userId: 'user-1', isMine: true),
        ),
      );
      await _pumpPlaylistPage(tester);

      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      await tester.pumpWidget(
        _buildTestApp(
          child: const PlayListPage(userId: 'user-1', isMine: false),
        ),
      );
      await _pumpPlaylistPage(tester);

      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets(
      'deletes owned playlist after confirmation and refreshes list',
      (tester) async {
        final fakeService = _FakePlayListService(
          playlists: [
            PlaylistModel(
              id: 'playlist-1',
              title: 'Owned Playlist',
              numVideos: 3,
              user: User(id: 'user-1'),
            ),
          ],
        );
        Get.put<PlayListService>(fakeService);

        await tester.pumpWidget(
          _buildTestApp(
            child: const PlayListPage(userId: 'user-1', isMine: true),
          ),
        );
        await _pumpPlaylistPage(tester);

        expect(find.text('Owned Playlist'), findsOneWidget);
        expect(find.byIcon(Icons.more_vert), findsOneWidget);

        await _openDeleteDialog(tester);

        expect(find.text(t.common.confirmDelete), findsOneWidget);

        await tester.tap(find.widgetWithText(TextButton, t.common.delete).last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(seconds: 3));

        expect(fakeService.deletedPlaylistIds, ['playlist-1']);
        expect(find.text('Owned Playlist'), findsNothing);
      },
    );

    testWidgets(
      'prevents dismissing the delete dialog while request is in flight',
      (tester) async {
        final completer = Completer<ApiResult<void>>();
        final fakeService = _FakePlayListService(
          playlists: [
            PlaylistModel(
              id: 'playlist-1',
              title: 'Owned Playlist',
              numVideos: 3,
              user: User(id: 'user-1'),
            ),
          ],
          deleteHandler: (_) => completer.future,
        );
        Get.put<PlayListService>(fakeService);

        await tester.pumpWidget(
          _buildTestApp(
            child: const PlayListPage(userId: 'user-1', isMine: true),
          ),
        );
        await _pumpPlaylistPage(tester);

        await _openDeleteDialog(tester);

        await tester.tap(find.widgetWithText(TextButton, t.common.delete).last);
        await tester.pump();

        final cancelButton = tester.widget<TextButton>(
          find.widgetWithText(TextButton, t.common.cancel),
        );
        expect(cancelButton.onPressed, isNull);
        expect(find.byType(CircularProgressIndicator), findsWidgets);

        await tester.binding.handlePopRoute();
        await tester.pump();

        expect(find.text(t.common.confirmDelete), findsOneWidget);
        expect(find.text('Owned Playlist'), findsOneWidget);

        completer.complete(ApiResult.success());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(seconds: 3));

        expect(find.text(t.common.confirmDelete), findsNothing);
        expect(find.text('Owned Playlist'), findsNothing);
      },
    );
  });

  group('PlayListDetailPage delete flow', () {
    testWidgets('shows delete menu item only for owned playlist detail', (
      tester,
    ) async {
      final fakeService = _FakePlayListService(
        playlists: [
          PlaylistModel(
            id: 'playlist-1',
            title: 'Owned Playlist',
            numVideos: 3,
            user: User(id: 'user-1'),
          ),
        ],
      );
      Get.put<PlayListService>(fakeService);

      await tester.pumpWidget(
        _buildTestApp(
          child: const PlayListDetailPage(
            playlistId: 'playlist-1',
            isMine: true,
          ),
        ),
      );
      await _pumpPlaylistPage(tester);

      await _openDetailMenu(tester);
      expect(find.text(t.common.delete), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      await tester.pumpWidget(
        _buildTestApp(
          child: const PlayListDetailPage(
            playlistId: 'playlist-1',
            isMine: false,
          ),
        ),
      );
      await _pumpPlaylistPage(tester);

      await _openDetailMenu(tester);
      expect(find.text(t.common.delete), findsNothing);
    });

    testWidgets(
      'prevents dismissing owned playlist delete dialog while request is in flight',
      (tester) async {
        final completer = Completer<ApiResult<void>>();
        final fakeService = _FakePlayListService(
          playlists: [
            PlaylistModel(
              id: 'playlist-1',
              title: 'Owned Playlist',
              numVideos: 3,
              user: User(id: 'user-1'),
            ),
          ],
          deleteHandler: (_) => completer.future,
        );
        Get.put<PlayListService>(fakeService);

        await tester.pumpWidget(
          _buildTestApp(
            child: const PlayListDetailPage(
              playlistId: 'playlist-1',
              isMine: true,
            ),
          ),
        );
        await _pumpPlaylistPage(tester);

        await _openOwnedDetailDeleteDialog(tester);

        await tester.tap(find.widgetWithText(TextButton, t.common.delete).last);
        await tester.pump();

        final cancelButton = tester.widget<TextButton>(
          find.widgetWithText(TextButton, t.common.cancel),
        );
        expect(cancelButton.onPressed, isNull);
        expect(find.byType(CircularProgressIndicator), findsWidgets);

        await tester.binding.handlePopRoute();
        await tester.pump();

        expect(find.text(t.common.confirmDelete), findsOneWidget);

        completer.complete(ApiResult.success());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(seconds: 3));
      },
    );

    testWidgets('keeps detail delete dialog open after a failed delete', (
      tester,
    ) async {
      final fakeService = _FakePlayListService(
        playlists: [
          PlaylistModel(
            id: 'playlist-1',
            title: 'Owned Playlist',
            numVideos: 3,
            user: User(id: 'user-1'),
          ),
        ],
        deleteHandler: (_) async => ApiResult.fail('Delete failed'),
      );
      Get.put<PlayListService>(fakeService);

      await tester.pumpWidget(
        _buildTestApp(
          child: const PlayListDetailPage(
            playlistId: 'playlist-1',
            isMine: true,
          ),
        ),
      );
      await _pumpPlaylistPage(tester);

      await _openOwnedDetailDeleteDialog(tester);

      await tester.tap(find.widgetWithText(TextButton, t.common.delete).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 3));

      expect(fakeService.deletedPlaylistIds, ['playlist-1']);
      expect(find.byType(PlayListDetailPage), findsOneWidget);
      expect(find.text(t.common.confirmDelete), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      final cancelButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, t.common.cancel),
      );
      final deleteButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, t.common.delete).last,
      );
      expect(cancelButton.onPressed, isNotNull);
      expect(deleteButton.onPressed, isNotNull);
    });

    testWidgets('pops success result and refreshes owned list after delete', (
      tester,
    ) async {
      final fakeService = _FakePlayListService(
        playlists: [
          PlaylistModel(
            id: 'playlist-1',
            title: 'Owned Playlist',
            numVideos: 3,
            user: User(id: 'user-1'),
          ),
        ],
      );
      Get.put<PlayListService>(fakeService);

      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: PlayListPage(userId: 'user-1', isMine: true),
            ),
          ),
          GoRoute(
            path: '/playlist_detail/:id',
            builder: (context, state) {
              final extra = state.extra! as PlayListDetailExtra;
              return PlayListDetailPage(
                playlistId: state.pathParameters['id']!,
                isMine: extra.isMine,
              );
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildRouterTestApp(router));
      await _pumpPlaylistPage(tester);

      expect(find.text('Owned Playlist'), findsOneWidget);

      await tester.tap(find.text('Owned Playlist'));
      await tester.pumpAndSettle();

      await _openOwnedDetailDeleteDialog(tester);
      await tester.tap(find.widgetWithText(TextButton, t.common.delete).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(fakeService.deletedPlaylistIds, ['playlist-1']);
      expect(find.byType(PlayListPage), findsOneWidget);
      expect(find.text('Owned Playlist'), findsNothing);
    });
  });

  group('PlayListsController delete guard', () {
    testWidgets('ignores duplicate delete requests for the same playlist', (
      tester,
    ) async {
      final completer = Completer<ApiResult<void>>();
      final fakeService = _FakePlayListService(
        playlists: const [],
        deleteHandler: (_) => completer.future,
      );
      Get.put<PlayListService>(fakeService);

      await tester.pumpWidget(_buildTestApp(child: const SizedBox.shrink()));

      final controller = PlayListsController();
      final firstDelete = controller.deletePlaylist('playlist-1');
      final secondDelete = controller.deletePlaylist('playlist-1');

      await tester.pump();

      expect(controller.isDeletingPlaylist('playlist-1'), isTrue);
      expect(fakeService.deletedPlaylistIds, ['playlist-1']);
      expect(await secondDelete, isFalse);

      completer.complete(ApiResult.success());

      expect(await firstDelete, isTrue);
      expect(controller.isDeletingPlaylist('playlist-1'), isFalse);
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('PlayListDetailController delete guard', () {
    testWidgets('ignores duplicate delete requests for detail page', (
      tester,
    ) async {
      final completer = Completer<ApiResult<void>>();
      final fakeService = _FakePlayListService(
        playlists: const [],
        deleteHandler: (_) => completer.future,
      );
      Get.put<PlayListService>(fakeService);

      await tester.pumpWidget(_buildTestApp(child: const SizedBox.shrink()));

      final controller = PlayListDetailController(playlistId: 'playlist-1');
      final firstDelete = controller.deletePlaylist();
      final secondDelete = controller.deletePlaylist();

      await tester.pump();

      expect(controller.isDeleting.value, isTrue);
      expect(fakeService.deletedPlaylistIds, ['playlist-1']);
      expect(await secondDelete, isFalse);

      completer.complete(ApiResult.success());

      expect(await firstDelete, isTrue);
      expect(controller.isDeleting.value, isFalse);
      await tester.pump(const Duration(seconds: 3));
    });
  });
}

Widget _buildTestApp({required Widget child}) {
  return TranslationProvider(
    child: OKToast(
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        home: Scaffold(body: child),
      ),
    ),
  );
}

Widget _buildRouterTestApp(GoRouter router) {
  return TranslationProvider(
    child: OKToast(child: MaterialApp.router(routerConfig: router)),
  );
}

Future<void> _pumpPlaylistPage(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _openDeleteDialog(WidgetTester tester) async {
  final popupFinder = find.byWidgetPredicate(
    (widget) => widget is PopupMenuButton,
  );
  final dynamic popupState = tester.state(popupFinder);
  popupState.showButtonMenu();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));

  expect(find.text(t.common.delete), findsOneWidget);

  await tester.tap(find.text(t.common.delete));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _openDetailMenu(WidgetTester tester) async {
  final popupFinder = find.byWidgetPredicate(
    (widget) => widget is PopupMenuButton<String>,
  );
  final dynamic popupState = tester.state(popupFinder);
  popupState.showButtonMenu();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _openOwnedDetailDeleteDialog(WidgetTester tester) async {
  await _openDetailMenu(tester);

  expect(find.text(t.common.delete), findsOneWidget);

  await tester.tap(find.text(t.common.delete));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
}

class _FakePlayListService extends GetxService implements PlayListService {
  _FakePlayListService({
    required List<PlaylistModel> playlists,
    this.deleteHandler,
  }) : _playlists = List.of(playlists);

  final List<PlaylistModel> _playlists;
  final Future<ApiResult<void>> Function(String playlistId)? deleteHandler;
  final List<String> deletedPlaylistIds = <String>[];

  @override
  Future<ApiResult<void>> createPlaylist({required String title}) async {
    return ApiResult.success();
  }

  @override
  Future<ApiResult<PageData<PlaylistModel>>> getPlaylists({
    required String userId,
    required int page,
    int limit = 20,
  }) async {
    final results = page == 0
        ? List<PlaylistModel>.from(_playlists)
        : <PlaylistModel>[];
    return ApiResult.success(
      data: PageData<PlaylistModel>(
        count: _playlists.length,
        page: page,
        limit: limit,
        results: results,
      ),
    );
  }

  @override
  Future<ApiResult<void>> deletePlaylist({required String playlistId}) async {
    deletedPlaylistIds.add(playlistId);
    final result =
        await (deleteHandler?.call(playlistId) ??
            Future.value(ApiResult.success()));
    if (result.isSuccess) {
      _playlists.removeWhere((playlist) => playlist.id == playlistId);
    }
    return result;
  }

  @override
  Future<ApiResult<String>> getPlaylistName({
    required String playlistId,
  }) async {
    final playlist = _playlists.firstWhereOrNull(
      (item) => item.id == playlistId,
    );
    return ApiResult.success(data: playlist?.title ?? 'Unknown Playlist');
  }

  @override
  Future<ApiResult<PageData<Video>>> getPlaylistVideos({
    required String playlistId,
    int page = 0,
    int limit = 32,
  }) async {
    return ApiResult.success(
      data: PageData<Video>(
        count: 0,
        page: page,
        limit: limit,
        results: const <Video>[],
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
