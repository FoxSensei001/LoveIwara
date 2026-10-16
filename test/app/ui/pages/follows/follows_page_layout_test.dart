import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/routes/app_router.dart' show rootNavigatorKey;
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follows_controller.dart';
import 'package:i_iwara/app/ui/pages/follows/follows_page.dart';
import 'package:i_iwara/app/ui/pages/follows/widgets/follow_search_list.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:i_iwara/i18n/strings.g.dart';

void main() {
  setUpAll(() async {
    await LocaleSettings.setLocale(AppLocale.zhCn);
    if (Platform.environment['FOLLOW_SEARCH_PREVIEW_DIR'] != null) {
      final loader = FontLoader('FollowPreview');
      loader.addFont(
        Future.value(
          ByteData.sublistView(
            await File(
              '/System/Library/Fonts/Hiragino Sans GB.ttc',
            ).readAsBytes(),
          ),
        ),
      );
      await loader.load();
      final icons = FontLoader('MaterialIcons');
      icons.addFont(
        Future.value(
          ByteData.sublistView(
            await File(
              // flutter_tester 在 <flutter>/bin/cache/artifacts/engine/<平台>/ 下，
              // 图标字体在同级的 material_fonts 里；不写死本机路径
              '${File(Platform.resolvedExecutable).parent.parent.parent.path}'
              '/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytes(),
          ),
        ),
      );
      await icons.load();
    }
  });
  tearDown(Get.reset);

  for (final width in [320.0, 375.0, 1100.0]) {
    testWidgets('one-row header with an expanding search at width $width', (
      tester,
    ) async {
      final key = GlobalKey();
      await _mount(tester, width: width, boundaryKey: key);
      final header = tester.getRect(
        find.byKey(const ValueKey('follows-header')),
      );
      expect(header.height, GlassTokens.headerRowHeight);
      // 是谁的列表必须常驻：宽屏独立成名字胶囊（昵称 + @用户名），窄屏只写
      // 昵称、并进类型下拉钮
      final owner = find.text(width < 600 ? 'A' : 'A @shinyoki').hitTestable();
      expect(owner, findsOneWidget);
      expect(tester.getRect(owner).top, greaterThanOrEqualTo(header.top));
      expect(tester.getRect(owner).bottom, lessThanOrEqualTo(header.bottom));
      expect(find.text('关注').hitTestable(), findsOneWidget);
      expect(
        find.byType(FollowSearchStatus),
        findsNothing,
        reason: 'Loading statistics do not occupy a permanent list row',
      );
      // 收起态：只有一枚搜索圆钮，输入框不接手势
      final toggle = find.byKey(const ValueKey('follow-search-toggle'));
      expect(tester.getSize(toggle).width, GlassTokens.pillHeight);
      expect(find.byType(TextField).hitTestable(), findsNothing);
      final viewport = find
          .descendant(
            of: find.byType(FollowSearchList).first,
            matching: find.byType(Scrollable),
          )
          .first;
      expect(
        tester.getTopLeft(viewport).dy,
        tester.getTopLeft(find.byType(GlassHeaderOverlay)).dy,
      );
      expect(tester.takeException(), isNull);
      await _capture(tester, key, 'follows-${width.toInt()}-1-collapsed.png');

      // 点开：圆钮向左长成输入框，窄屏收起动作胶囊让位
      await tester.tap(toggle);
      await _paint(tester);
      final input = find.byType(TextField).hitTestable();
      expect(input, findsOneWidget);
      expect(tester.getSize(input).width, greaterThan(100));
      final more = find.byIcon(Icons.more_horiz).hitTestable();
      final refresh = find.byIcon(Icons.refresh).hitTestable();
      if (width < 600) {
        expect(more, findsNothing);
      } else {
        expect(refresh, findsOneWidget);
        // 宽屏：输入框长到封顶宽度就停，关注类型留在左边
        expect(tester.getSize(toggle).width, 480);
        expect(find.text('粉丝').hitTestable(), findsOneWidget);
      }
      await _capture(tester, key, 'follows-${width.toInt()}-2-open.png');

      await tester.enterText(input, '用户');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      final resultViewport = find
          .descendant(
            of: find.byType(FollowSearchList).first,
            matching: find.byType(Scrollable),
          )
          .first;
      expect(
        tester.getTopLeft(resultViewport).dy,
        tester.getTopLeft(find.byType(GlassHeaderOverlay)).dy,
      );
      await tester.drag(resultViewport, const Offset(0, -220));
      await _paint(tester);
      final firstCard = tester.getRect(find.byType(UserCard).first);
      expect(
        firstCard.top,
        lessThan(header.bottom),
        reason: 'Search results scroll underneath the floating controls',
      );
      expect(tester.takeException(), isNull);
      await _capture(tester, key, 'follows-${width.toInt()}-3-typed.png');

      // 关闭键：先清字，再收起
      final close = find.byKey(const ValueKey('follow-search-close'));
      await tester.tap(close);
      await _paint(tester);
      expect(find.byType(TextField).hitTestable(), findsOneWidget);
      await tester.tap(close);
      await _paint(tester);
      expect(find.byType(TextField).hitTestable(), findsNothing);
      expect(tester.getSize(toggle).width, GlassTokens.pillHeight);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('keyboard and enlarged text keep the open search in one row', (
    tester,
  ) async {
    await _mount(tester, width: 320, keyboard: 270, textScale: 1.5);
    await tester.tap(find.byKey(const ValueKey('follow-search-toggle')));
    await _paint(tester);
    await tester.enterText(find.byType(TextField).hitTestable(), '用户名');
    await _paint(tester);
    final header = tester.getRect(find.byKey(const ValueKey('follows-header')));
    final input = tester.getRect(find.byType(TextField).hitTestable());
    expect(header.height, GlassTokens.headerRowHeight);
    expect(input.width, greaterThan(32));
    expect(input.top, greaterThanOrEqualTo(header.top));
    expect(input.bottom, lessThanOrEqualTo(header.bottom));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('long scans show a dismissible warning and keep search open', (
    tester,
  ) async {
    final key = GlobalKey();
    await _mount(tester, width: 375, total: 5000, boundaryKey: key);
    final controller = Get.find<FollowsController>(tag: 'test-user');
    await controller.followingSearch.startAll();
    await _paint(tester);
    expect(find.byType(FollowSearchStatus), findsOneWidget);
    expect(find.textContaining('列表较大'), findsOneWidget);
    expect(find.text('继续加载'), findsOneWidget);
    await _capture(tester, key, 'follows-375-4-long-wait.png');
    await tester.tap(find.text('取消'));
    await _paint(tester);
    expect(find.byType(FollowSearchStatus), findsNothing);
    expect(controller.followingSearch.cancelled, isTrue);
    // 搜全部期间输入框一直展开着，范围图标报「已取消」
    expect(find.byType(TextField).hitTestable(), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
    await _capture(tester, key, 'follows-375-5-cancelled.png');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('scope icon opens a menu to switch loaded and whole list', (
    tester,
  ) async {
    final key = GlobalKey();
    await LocaleSettings.setLocale(AppLocale.en);
    await _mount(tester, width: 320, textScale: 1.5, boundaryKey: key);
    final controller = Get.find<FollowsController>(tag: 'test-user');
    await tester.tap(find.byKey(const ValueKey('follow-search-toggle')));
    await _paint(tester);
    final scope = find.byKey(const ValueKey('follow-search-scope'));
    expect(find.byIcon(Icons.manage_search).hitTestable(), findsOneWidget);
    expect(
      tester.getSize(find.byType(TextField).hitTestable()).width,
      greaterThan(32),
    );
    await tester.tap(scope);
    await _paint(tester);
    await _capture(tester, key, 'follows-320-6-scope-menu.png');
    expect(find.text('Loaded').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Whole list').hitTestable());
    await _paint(tester);
    expect(controller.followingSearch.searchAll, isTrue);
    expect(find.byIcon(Icons.travel_explore).hitTestable(), findsOneWidget);
    await _capture(tester, key, 'follows-320-7-whole-list.png');
    await tester.tap(scope);
    await _paint(tester);
    await tester.tap(find.text('Loaded').hitTestable());
    await _paint(tester);
    expect(controller.followingSearch.searchAll, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await LocaleSettings.setLocale(AppLocale.zhCn);
  });
}

Future<void> _mount(
  WidgetTester tester, {
  required double width,
  GlobalKey? boundaryKey,
  double keyboard = 0,
  double textScale = 1,
  int total = 100,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 740);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  Get.put<UserService>(_Users(total));
  Get.put(UserPreferenceService());
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: TranslationProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: rootNavigatorKey,
          theme: ThemeData(
            fontFamily:
                Platform.environment['FOLLOW_SEARCH_PREVIEW_DIR'] == null
                ? null
                : 'FollowPreview',
          ),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 740),
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              viewInsets: EdgeInsets.only(bottom: keyboard),
              textScaler: TextScaler.linear(textScale),
            ),
            child: const FollowsPage(
              userId: 'test-user',
              name: 'A',
              username: 'shinyoki',
              initIsFollowing: true,
            ),
          ),
        ),
      ),
    ),
  );
  await _paint(tester);
}

// Liquid glass and loading avatars can keep tickers active; wait for a stable
// layout rather than requiring every animation in the app to stop.
Future<void> _paint(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  final directory = Platform.environment['FOLLOW_SEARCH_PREVIEW_DIR'];
  if (directory == null) return;
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(directory).create(recursive: true);
    await File('$directory/$name').writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

class _Users extends GetxService implements UserService {
  _Users(this.total);
  final int total;
  @override
  Rxn<User> currentUser = Rxn<User>();

  Future<ApiResult<PageData<User>>> _fetch(int page, int limit) async {
    final size = limit.clamp(1, 50);
    return ApiResult.success(
      data: PageData(
        count: total,
        page: page,
        limit: size,
        results: List.generate(
          (total - page * size).clamp(0, size),
          (i) => User(
            id: '${page * size + i}',
            name: '用户 ${page * size + i}',
            username: 'creator${page * size + i}',
          ),
        ),
      ),
    );
  }

  @override
  Future<ApiResult<PageData<User>>> fetchFollowingUsers({
    int page = 0,
    int limit = 20,
    required String userId,
    CancelToken? cancelToken,
    bool rethrowErrors = false,
  }) => _fetch(page, limit);
  @override
  Future<ApiResult<PageData<User>>> fetchFollowers({
    int page = 0,
    int limit = 20,
    required String userId,
    CancelToken? cancelToken,
    bool rethrowErrors = false,
  }) => _fetch(page, limit);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
