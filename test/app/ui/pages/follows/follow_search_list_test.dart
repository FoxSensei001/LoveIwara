import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_dto.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follow_search_controller.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follows_controller.dart';
import 'package:i_iwara/app/ui/pages/follows/widgets/follow_search_list.dart';
import 'package:i_iwara/app/ui/pages/follows/widgets/special_follows_list.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/i18n/strings.g.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  testWidgets('paginated refresh invalidates snapshots before fetching', (
    tester,
  ) async {
    final repository = _Pages();
    final signal = ListRefreshSignal();
    addTearDown(repository.dispose);
    addTearDown(signal.dispose);
    var invalidations = 0;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: MediaListView<int>(
              sourceList: repository,
              isPaginated: true,
              refreshSignal: signal,
              onPaginatedRefresh: () {
                invalidations++;
                repository.resetPagingState();
              },
              itemBuilder: (context, item, index) => Text('row $item'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final before = repository.fetches;
    final refreshed = signal.request();
    expect(invalidations, 1);
    await tester.pumpAndSettle();
    await refreshed;
    expect(repository.fetches, before + 1);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 600), const Size(1100, 700)]) {
    for (final brightness in Brightness.values) {
      testWidgets('wait warning fits $size in $brightness', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final search = FollowSearchController(
          fetchPage: (p, l, t) async => PageData(
            count: 5000,
            page: p,
            limit: 50,
            results: List.generate(50, (i) => User(id: '$i')),
          ),
        );
        final scroll = ScrollController();
        addTearDown(search.dispose);
        addTearDown(scroll.dispose);
        await search.startAll();
        expect(search.awaitingConfirmation, isTrue);
        await tester.pumpWidget(
          TranslationProvider(
            child: MaterialApp(
              theme: ThemeData(brightness: brightness),
              home: Scaffold(body: FollowSearchDetailsDialog(search: search)),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Continue loading'), findsOneWidget);
        expect(find.textContaining('A large list'), findsOneWidget);
        expect(find.text('Browsing page'), findsNothing);
        // The wait panel can scroll on a short screen without overflowing.
        await tester.ensureVisible(find.text('Continue loading'));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'clearing search restores the mounted browsing list and controller',
    (tester) async {
      final search = FollowSearchController(
        fetchPage: (p, l, t) async =>
            PageData(count: 0, page: p, limit: l, results: []),
      );
      final scroll = ScrollController();
      addTearDown(search.dispose);
      addTearDown(scroll.dispose);
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: FollowSearchList(
                search: search,
                scrollController: scroll,
                paddingTop: 0,
                browseBuilder: (controller) => ListView(
                  key: const ValueKey('browse'),
                  controller: controller,
                  children: const [Text('Browsing page')],
                ),
              ),
            ),
          ),
        ),
      );
      final element = tester.element(find.byKey(const ValueKey('browse')));
      search.setQuery('missing');
      await tester.pump();
      expect(find.text('Browsing page'), findsNothing);
      expect(scroll.positions.length, 1);
      search.setQuery('');
      await tester.pump();
      expect(find.text('Browsing page'), findsOneWidget);
      expect(
        tester.element(find.byKey(const ValueKey('browse'))),
        same(element),
      );
      expect(scroll.positions.length, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('special follows filter and reorder retain hidden users', (
    tester,
  ) async {
    final preferences = _Preferences();
    Get.put<UserPreferenceService>(preferences);
    addTearDown(Get.reset);
    final controller = FollowsController(userId: 'test', initIsFollowing: true);
    addTearDown(controller.specialFollowsScrollController.dispose);
    preferences.likedUsers.assignAll([
      UserDTO(id: 'a', name: 'Match A', username: 'alpha', avatarUrl: ''),
      UserDTO(id: 'hidden', name: 'Hidden', username: 'other', avatarUrl: ''),
      UserDTO(id: 'b', name: 'Match B', username: 'beta', avatarUrl: ''),
    ]);
    controller.specialSearchQuery.value = 'match';
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(body: SpecialFollowsList(controller: controller)),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Match A'), findsOneWidget);
    expect(find.text('Match B'), findsOneWidget);
    expect(find.text('Hidden'), findsNothing);
    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    list.onReorderItem!(0, 1);
    await tester.pump();
    expect(preferences.likedUsers.map((u) => u.id), ['b', 'hidden', 'a']);
    expect(preferences.saves, 1);
    controller.specialSearchQuery.value = '@ALPHA';
    await tester.pump();
    expect(find.text('Match A'), findsOneWidget);
    expect(find.text('Match B'), findsNothing);
    controller.specialSearchQuery.value = 'unknown';
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.text('No matching special follows.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Preferences extends UserPreferenceService {
  int saves = 0;
  @override
  Future<void> saveLikedUsers() async {
    saves++;
  }
}

class _Pages extends ExtendedLoadingMoreBase<int> {
  int fetches = 0;
  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    fetches++;
    return {
      'items': [fetches],
    };
  }

  @override
  List<int> extractDataList(Map<String, dynamic> response) =>
      response['items'] as List<int>;

  @override
  int extractTotalCount(Map<String, dynamic> response) => 1;
}
