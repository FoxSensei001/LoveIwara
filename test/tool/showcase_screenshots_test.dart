// Render production Flutter pages with offline fixtures. No AI-generated UI.
// SHOWCASE_SHOT_DIR=docs/imgs flutter test test/tool/showcase_screenshots_test.dart
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
// CacheManager's public FileInfo uses package:file; this fixture reuses its
// existing transitive dependency without adding a production dependency.
// ignore: depend_on_referenced_packages
import 'package:file/file.dart' as fs;
// ignore: depend_on_referenced_packages
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Translations, Response;
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/iwara_page.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/my_app.dart' show buildThemeData;
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/search_service.dart';
import 'package:i_iwara/app/services/comment_service.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/theme_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/pages/home/home_shell_scaffold.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/popular_gallery_list_page.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/popular_video_list_page.dart';
import 'package:i_iwara/app/ui/pages/search/search_page.dart';
import 'package:i_iwara/app/ui/pages/search/search_result.dart';
import 'package:i_iwara/app/ui/pages/community/community_page.dart';
import 'package:i_iwara/app/ui/pages/forum/thread_detail_page.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/gallery_detail_page.dart';
import 'package:i_iwara/app/ui/pages/author_profile/author_profile_page.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/subscriptions_page.dart';
import 'package:i_iwara/app/ui/pages/local_media/local_home_page.dart';
import 'package:i_iwara/app/ui/widgets/media_preview_dialog.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/theme_settings_page.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/ui/widgets/window_layout_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';

const _date = '2024-05-16T08:00:00.000Z';
const _font = 'ShowcaseFont';
const _titles = [
  'Harbor lighting study',
  'Cloud motion study',
  'Garden environment',
  'Studio animation',
  'Moonlight scene',
  'Island environment',
  'Courtyard lighting',
  'Orbit camera study',
  'Forest environment',
  'Morning light study',
  'Ocean animation',
  'City environment',
];

Map<String, dynamic> _file(int index, {String type = 'image'}) => {
  'id': 'demo-$index',
  'type': type,
  'path': '/',
  'name': 'demo.png',
  'mime': 'image/png',
  'width': 960,
  'height': 540,
  'duration': 184 + index * 9,
  'animatedPreview': false,
  'createdAt': _date,
  'updatedAt': _date,
};

Map<String, dynamic> _user(int index) => {
  'id': 'demo-user-$index',
  'name': ['Demo Studio', 'Cloud Lab', 'Garden Works'][index % 3],
  'username': 'demo-user-$index',
  'role': 'user',
  'premium': false,
  'createdAt': _date,
  'updatedAt': _date,
  'seenAt': _date,
  'avatar': {..._file(index), 'id': 'avatar-$index'},
  'header': _file(index),
  'body': 'Fictional profile for interface demonstration.',
};

Map<String, dynamic> _media(int index) => {
  'id': 'demo-media-$index',
  'title': _titles[index % _titles.length],
  'body': 'Placeholder media used to demonstrate the interface.',
  'rating': 'general',
  'private': false,
  'liked': false,
  'numViews': 1240 + index * 731,
  'numLikes': 32 + index * 17,
  'numComments': 2 + index,
  'numImages': 4 + index,
  'createdAt': _date,
  'updatedAt': _date,
  'user': _user(index % 3),
  'file': _file(index, type: 'video'),
  'customThumbnail': _file(index),
  'thumbnail': _file(index),
  'files': [_file(index)],
  'tags': <dynamic>[],
};

Map<String, dynamic> _comment(int index) => {
  'id': 'demo-comment-$index',
  'approved': true,
  'body': index == 0
      ? 'This is a fictional technical discussion used to demonstrate the interface.\n\n### Scene notes\n\n- Keep the horizon level.\n- Preview at different qualities.\n- Use ordinary sample media.'
      : 'Thanks for sharing the sample. The lighting and camera movement look clear.',
  'replyNum': index,
  'user': _user(index % 3),
  'createdAt': _date,
  'updatedAt': _date,
  'threadId': 'demo-thread-0',
};

Map<String, dynamic> _thread(int index) => {
  'id': 'demo-thread-$index',
  'approved': true,
  'section': 'general',
  'title': [
    'Lighting a harbor scene',
    'Tips for smooth playback',
    'Organizing a local library',
    'Choosing video quality',
    'Keyboard shortcut ideas',
    'Sharing a garden render',
  ][index % 6],
  'locked': false,
  'sticky': false,
  'numViews': 84 + index * 21,
  'numPosts': 2 + index,
  'createdAt': _date,
  'updatedAt': _date,
  'user': _user(index % 3),
  'lastPost': _comment(1),
};

class _MemoryConfig extends ConfigService {
  _MemoryConfig() {
    for (final key in ConfigKey.values) {
      settings[key] = Rx<dynamic>(key.defaultValue);
    }
    settings[ConfigKey.ENABLE_LIQUID_GLASS_KEY]!.value = false;
    settings[ConfigKey.SHOW_SUBSCRIPTION_TUTORIAL]!.value = false;
  }

  @override
  Future<void> saveSetting(ConfigKey key, dynamic value) async {}
}

class _DemoUser extends GetxService implements UserService {
  final _authenticated = true.obs;
  @override
  RxBool isLogining = false.obs;
  @override
  Rxn<User> currentUser = Rxn(User.fromJson(_user(0)));
  @override
  RxInt notificationCount = 0.obs;
  @override
  RxInt friendRequestsCount = 0.obs;
  @override
  RxInt messagesCount = 0.obs;
  @override
  bool get isAuthenticated => _authenticated.value;
  @override
  bool get hasLoadedProfile => true;
  @override
  String get userAvatar => currentUser.value!.avatar!.avatarUrl;
  @override
  void startNotificationTimer() {}
  @override
  void stopNotificationTimer() {}
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected user operation: ${invocation.memberName}');
}

class _FixtureApi extends GetxService implements ApiService {
  final requests = <String>[];
  final unexpectedPaths = <String>[];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #fetchSitewideAnnouncement) {
      return Future<ApiResult<IwaraPageModel>>.value(
        ApiResult.success(
          data: IwaraPageModel.fromJson({
            'id': 'demo-announcement',
            'title': 'Demo community',
            'body': 'Fictional sample data for interface screenshots.',
            'createdAt': _date,
            'updatedAt': _date,
          }),
        ),
      );
    }
    if (invocation.memberName != #get) {
      throw StateError('Unexpected API operation: ${invocation.memberName}');
    }
    final path = invocation.positionalArguments.first as String;
    requests.add(path);
    final params = invocation.namedArguments[#queryParameters] as Map?;
    final page = params?['page'] as int? ?? 0;
    dynamic data;
    final items = page == 0
        ? List.generate(
            12,
            (i) => {
              ..._media(i),
              'thumbnail':
                  path.endsWith('/images') ||
                      path == '/image/demo-media-0/related'
                  ? _file(i)
                  : 0,
            },
          )
        : <Map<String, dynamic>>[];
    if (path.endsWith('/videos') ||
        path.endsWith('/images') ||
        path == '/image/demo-media-0/related' ||
        path == '/search') {
      data = {'count': 12, 'page': page, 'limit': 20, 'results': items};
    } else if (path == '/forum') {
      data = [
        {
          'id': 'general',
          'group': 'global',
          'label': 'General discussion',
          'description': 'Technical discussion and sample scenes.',
          'locked': false,
          'numPosts': 24,
          'numThreads': 12,
        },
      ];
    } else if (path == '/forum/threads') {
      final threads = params?['sticky'] == true || page != 0
          ? <Map<String, dynamic>>[]
          : List.generate(12, _thread);
      data = {
        'count': threads.length,
        'page': page,
        'limit': 20,
        'results': threads,
      };
    } else if (path.contains('demo-thread-0')) {
      data = {
        'thread': _thread(0),
        'count': 2,
        'page': page,
        'limit': 20,
        'results': page == 0 ? List.generate(2, _comment) : <dynamic>[],
      };
    } else if (path.endsWith('/comments') ||
        path == '/image/demo-media-0/likes' ||
        path == '/posts') {
      data = {'count': 0, 'page': page, 'limit': 20, 'results': <dynamic>[]};
    } else if (path == '/image/demo-media-0') {
      data = _media(0);
    } else if (path.startsWith('/profile/')) {
      data = {
        'user': _user(0),
        'body': 'Fictional profile for interface demonstration.',
        'header': _file(0),
      };
    } else if (path.contains('/followers') || path.contains('/following')) {
      data = {'count': 24, 'results': <dynamic>[]};
    } else if (path.endsWith('/friends/status')) {
      data = {'status': 'none'};
    } else {
      unexpectedPaths.add(path);
      throw StateError('No offline fixture for $path');
    }
    return Future<Response<dynamic>>.value(
      Response<dynamic>(
        data: data,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      ),
    );
  }
}

class _DemoSearch extends GetxController implements SearchService {
  @override
  Future<ApiResult<PageData<Video>>> fetchVideoByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
    CancelToken? cancelToken,
  }) async {
    return ApiResult.success(
      data: PageData(
        count: 2,
        page: page,
        limit: limit,
        results: page == 0
            ? [
                Video.fromJson({..._media(0), 'thumbnail': 0}),
                Video.fromJson({
                  ..._media(1),
                  'thumbnail': 0,
                  'title': 'Harbor morning study',
                }),
              ]
            : <Video>[],
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected search operation: ${invocation.memberName}');
}

class _DemoTranslation extends GetxService implements TranslationService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Translation is disabled in the offline showcase.');
}

// CachedNetworkImage accepts a process-local cache manager. Supplying PNG files
// here leaves production image widgets untouched and never opens a socket.
class _PlaceholderCache extends BaseCacheManager with ImageCacheManager {
  _PlaceholderCache(this.files, this.avatars);
  final List<fs.File> files;
  final List<fs.File> avatars;
  final requestedUrls = <String>[];

  FileInfo _info(String url) {
    requestedUrls.add(url);
    final match = RegExp(r'(?:demo|avatar)-(\d+)').firstMatch(url);
    final index = int.tryParse(match?.group(1) ?? '') ?? 0;
    final choices = url.contains('avatar') ? avatars : files;
    return FileInfo(
      choices[index % choices.length],
      FileSource.Cache,
      DateTime(2099),
      url,
    );
  }

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) => Stream.value(_info(url));

  @override
  Stream<FileResponse> getImageFile(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
    int? maxHeight,
    int? maxWidth,
  }) => getFileStream(url);

  @override
  Future<fs.File> getSingleFile(
    String url, {
    String? key,
    Map<String, String>? headers,
  }) async => _info(url).file;

  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected cache operation: ${invocation.memberName}');
}

Future<fs.File> _placeholder(
  String directory,
  int index, {
  bool avatar = false,
}) async {
  const colors = [
    Color(0xFFB8C9DC),
    Color(0xFFC9D9D1),
    Color(0xFFD9CBBE),
    Color(0xFFD2CAE2),
    Color(0xFFB9D6D8),
    Color(0xFFE0CECB),
  ];
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = avatar ? const Size(96, 96) : const Size(960, 540);
  final color = colors[index % colors.length];
  canvas.drawRect(Offset.zero & size, Paint()..color = color);
  if (avatar) {
    canvas.drawCircle(
      size.center(Offset.zero),
      22,
      Paint()..color = const Color(0xFF536579),
    );
  } else {
    canvas.drawCircle(
      const Offset(760, 120),
      54,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 440)
        ..lineTo(280, 215)
        ..lineTo(500, 410)
        ..lineTo(660, 300)
        ..lineTo(960, 540)
        ..lineTo(0, 540)
        ..close(),
      Paint()..color = color.withValues(alpha: 0.65),
    );
    final label = TextPainter(
      text: TextSpan(
        text: 'SAMPLE ${index + 1}',
        style: const TextStyle(
          fontFamily: _font,
          fontSize: 34,
          letterSpacing: 4,
          color: Color(0xFF536579),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset(40, size.height - 76));
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = const LocalFileSystem().file(
    '$directory/${avatar ? 'avatar' : 'media'}-$index.png',
  );
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  image.dispose();
  picture.dispose();
  return file;
}

Future<void> _loadFonts() async {
  final loader = FontLoader(_font);
  var root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    final config = File('.dart_tool/package_config.json');
    final packages =
        (jsonDecode(await config.readAsString()) as Map)['packages'] as List;
    final flutter = packages.cast<Map>().firstWhere(
      (p) => p['name'] == 'flutter',
    );
    final packageUri = config.absolute.uri.resolve(
      flutter['rootUri'] as String,
    );
    root = Directory.fromUri(packageUri).parent.parent.path;
  }
  for (final name in [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]) {
    final file = File('$root/bin/cache/artifacts/material_fonts/$name');
    if (file.existsSync()) {
      loader.addFont(
        Future.value(ByteData.sublistView(await file.readAsBytes())),
      );
    }
  }
  final cjk = File('/System/Library/Fonts/Supplemental/Arial Unicode.ttf');
  if (cjk.existsSync()) {
    await (FontLoader(
          'ShowcaseCjk',
        )..addFont(Future.value(ByteData.sublistView(await cjk.readAsBytes()))))
        .load();
  }
  await loader.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
}

void main() {
  final output = Platform.environment['SHOWCASE_SHOT_DIR'];
  if (output == null) {
    test('showcase renderer is opt-in', () {}, skip: 'Set SHOWCASE_SHOT_DIR');
    return;
  }
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporary;
  late _PlaceholderCache cache;
  final oldHistory = CommonConstants.enableHistory;

  setUpAll(() async {
    await _loadFonts();
    await LocaleSettings.instance.loadAllLocales();
    await LocaleSettings.setLocale(AppLocale.en);
    temporary = await Directory.systemTemp.createTemp('loveiwara-showcase-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => temporary.path,
        );
    // Production repositories use the singleton. Bootstrap it only inside the
    // disposable fixture directory; never load the user's application database.
    CommonConstants.enableHistory = false;
    await DatabaseService().init();
    final local = LocalMediaRepository();
    for (var i = 0; i < 2; i++) {
      local.upsertSource(
        LocalMediaSource(
          id: 'demo-source-$i',
          kind: LocalMediaSourceKind.directory,
          displayName: i == 0 ? 'Demo Library' : 'Scene Studies',
          path: i == 0 ? '/Demo/Library' : '/Demo/Scenes',
          autoRescan: false,
          createdAt: DateTime.parse(_date).millisecondsSinceEpoch ~/ 1000,
          sortOrder: i,
        ),
      );
    }
    final media = <fs.File>[];
    final avatars = <fs.File>[];
    for (var i = 0; i < 12; i++) {
      media.add(await _placeholder(temporary.path, i));
      avatars.add(await _placeholder(temporary.path, i, avatar: true));
    }
    cache = _PlaceholderCache(media, avatars);
    // Set without reading the lazy production default: constructing it would
    // start path_provider/database plugins outside this offline test harness.
    CachedNetworkImageProvider.defaultCacheManager = cache;
    Directory(output).createSync(recursive: true);
  });

  tearDownAll(() async {
    DatabaseService().close();
    CommonConstants.enableHistory = oldHistory;
    await temporary.delete(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    await LocaleSettings.setLocale(AppLocale.en);
  });

  final scenes = <String, (String, Widget Function())>{
    'home_screen.png': ('/videos', () => const PopularVideoListPage()),
    'gallery.png': ('/gallery', () => const PopularGalleryListPage()),
    'search_page.png': ('/search', () => const SearchPage()),
    'settings_page.png': (
      '/settings/theme',
      () => const SettingsShell(
        location: '/settings/theme',
        child: ThemeSettingsPage(isWideScreen: true),
      ),
    ),
    'forum_page.png': ('/community', () => const CommunityPage()),
    'thread_detail.png': (
      '/forum/general/demo-thread-0',
      () => ThreadDetailPage(
        threadId: 'demo-thread-0',
        categoryId: 'general',
        initialThread: ForumThreadModel.fromJson(_thread(0)),
      ),
    ),
    'search_result_page.png': (
      '/search_result',
      () => const SearchResult(
        initialSearch: 'Harbor',
        initialSegment: SearchSegment.video,
      ),
    ),
    'sub_page.png': (
      '/subscriptions',
      () => const SubscriptionsPage(site: IwaraSite.main),
    ),
    'gallery_detail.png': (
      '/gallery_detail/demo-media-0',
      () => GalleryDetailPage(
        imageModelId: 'demo-media-0',
        preloadedDetail: ImageModel.fromJson(_media(0)),
      ),
    ),
    'user_detail_page.png': (
      '/profile/demo-user-0',
      () => AuthorProfilePage(
        username: 'demo-user-0',
        initialUser: User.fromJson(_user(0)),
      ),
    ),
    'local_page.png': ('/local', () => const LocalHomePage()),
    'video_preview.png': ('/videos', () => const PopularVideoListPage()),
  };

  for (final entry in scenes.entries) {
    testWidgets('render ${entry.key} from production widgets', (tester) async {
      final oldShadows = debugDisableShadows;
      debugDisableShadows = false;
      Get.testMode = true;
      Get.put<ConfigService>(_MemoryConfig());
      final app = Get.put(AppService());
      if (entry.key == 'gallery_detail.png') app.currentIndex = 1;
      if (entry.key == 'thread_detail.png') app.currentIndex = 3;
      Get.put<UserService>(_DemoUser());
      final api = _FixtureApi();
      Get.put<ApiService>(api);
      Get.put(VideoService());
      Get.put(GalleryService());
      Get.put(ForumService());
      Get.put<SearchService>(_DemoSearch());
      Get.put(CommentService());
      Get.put(PostService());
      Get.put<TranslationService>(_DemoTranslation());
      Get.put(PlaybackQueueService());
      Get.put(WatchLaterService());
      Get.put(FavoriteService());
      Get.put(UserPreferenceService());
      Get.put(ThemeService());
      glassMaterialMode.value = GlassMaterialMode.material;
      const size = Size(1400, 860);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      final key = GlobalKey();
      final (path, build) = entry.value;
      final router = GoRouter(
        initialLocation: path,
        routes: [
          GoRoute(
            path: path,
            builder: (_, _) => WindowTitleBarLayout(
              HomeShellScaffold(currentPath: path, child: build()),
            ),
          ),
        ],
      );
      try {
        await tester.pumpWidget(
          TranslationProvider(
            child: GlassMaterialScope(
              child: MaterialApp.router(
                routerConfig: router,
                theme:
                    buildThemeData(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: const Color(0xFF52638A),
                      ),
                    ).copyWith(
                      platform: TargetPlatform.macOS,
                      textTheme: ThemeData().textTheme.apply(
                        fontFamily: _font,
                        fontFamilyFallback: ['ShowcaseCjk'],
                      ),
                      primaryTextTheme: ThemeData().primaryTextTheme.apply(
                        fontFamily: _font,
                        fontFamilyFallback: ['ShowcaseCjk'],
                      ),
                    ),
                builder: (_, child) => RepaintBoundary(key: key, child: child!),
              ),
            ),
          ),
        );
        // File decoding runs on the real clock, unlike widget-test animations.
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        });
        await tester.pump(const Duration(seconds: 1));
        if (entry.key == 'video_preview.png') {
          final video = Video.fromJson({..._media(0), 'thumbnail': 0});
          unawaited(
            showMediaPreviewDialog(
              context: tester.element(find.byType(PopularVideoListPage)),
              video: video,
              loadVideoDetail: () async => video,
              onOpenDetail: () async {},
            ),
          );
          await tester.pump(const Duration(seconds: 1));
        }
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
        });
        await tester.pump(const Duration(seconds: 1));
        // Alternate real IO and fake frame clocks; awaiting an already-mounted
        // ImageStream inside runAsync deadlocks its fake-zone listeners.
        for (var frame = 0; frame < 8; frame++) {
          await tester.runAsync(() async {
            await Future<void>.delayed(const Duration(milliseconds: 80));
          });
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(tester.takeException(), isNull);
        expect(
          api.unexpectedPaths,
          isEmpty,
          reason: 'Every request must have an explicit offline fixture.',
        );
        if ([
          'home_screen.png',
          'search_result_page.png',
          'sub_page.png',
          'user_detail_page.png',
          'video_preview.png',
        ].contains(entry.key)) {
          expect(find.byType(VideoCardListItemWidget), findsWidgets);
        }
        if (entry.key == 'gallery.png') {
          expect(find.byType(ImageModelCardListItemWidget), findsWidgets);
        }
        if (entry.key == 'local_page.png') {
          expect(
            find.textContaining('Demo Library', findRichText: true),
            findsOneWidget,
          );
        }
        if (entry.key == 'thread_detail.png') {
          expect(find.text('Scene notes'), findsOneWidget);
        }
        if (entry.key == 'gallery_detail.png') {
          expect(find.byType(ImageModelCardListItemWidget), findsWidgets);
          final state = tester.state<GalleryDetailPageState>(
            find.byType(GalleryDetailPage),
          );
          expect(state.commentController.errorMessage.value, isEmpty);
          expect(state.detailController.errorMessage.value, isNull);
        }
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1.5);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '$output/${entry.key}',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      } finally {
        debugDisableShadows = oldShadows;
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        Get.reset();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });
  }
}
