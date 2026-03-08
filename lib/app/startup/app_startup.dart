import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/batch_download_service.dart';
import 'package:i_iwara/app/services/comment_service.dart';
import 'package:i_iwara/app/services/config_backup_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/services/deep_link_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/http_client_factory.dart';
import 'package:i_iwara/app/services/iwara_network_service.dart';
import 'package:i_iwara/app/services/light_service.dart';
import 'package:i_iwara/app/services/logging/log_service.dart';
import 'package:i_iwara/app/services/message_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/playback_history_service.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/services/search_service.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/app/services/tag_service.dart';
import 'package:i_iwara/app/services/theme_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/services/upload_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/version_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/auth_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/dlna_cast_service.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/glsl_shader_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/proxy/proxy_util.dart';
import 'package:media_kit/media_kit.dart';

final appStartupCoordinator = AppStartupCoordinator();

typedef StartupProgressCallback = void Function(AppStartupProgress progress);

abstract class AppStartupRunner {
  bool get isReady;

  Future<void> initializeDeferred({
    required StartupProgressCallback onProgress,
  });
}

enum AppStartupStage { preparing, initializing, ready }

class AppStartupProgress {
  const AppStartupProgress({
    required this.stage,
    required this.value,
    required this.detail,
  });

  final AppStartupStage stage;
  final double value;
  final String detail;

  String label(slang.Translations t) {
    switch (stage) {
      case AppStartupStage.preparing:
        return t.splash.preparing;
      case AppStartupStage.initializing:
        return t.splash.initializing;
      case AppStartupStage.ready:
        return t.splash.ready;
    }
  }
}

class AppStartupCoordinator implements AppStartupRunner {
  bool _coreInitialized = false;
  bool _deferredInitialized = false;
  Future<void>? _runningDeferredInitialization;
  final List<Future<void> Function()> _cleanupActions = [];

  @override
  bool get isReady => _deferredInitialized;

  Future<void> initializeCore({
    required LogService logService,
    required bool isProduction,
  }) async {
    if (_coreInitialized) {
      return;
    }

    await _initializeBaseServices();
    await _initializeCoreAppServices();

    if (Get.isRegistered<ConfigService>()) {
      final configService = Get.find<ConfigService>();
      await logService.applyPolicy(
        LogService.policyFromConfig(configService, isProduction: isProduction),
      );
    }

    _coreInitialized = true;
  }

  @override
  Future<void> initializeDeferred({
    required StartupProgressCallback onProgress,
  }) async {
    if (_deferredInitialized) {
      onProgress(
        const AppStartupProgress(
          stage: AppStartupStage.ready,
          value: 1,
          detail: 'MyApp',
        ),
      );
      return;
    }

    final running = _runningDeferredInitialization;
    if (running != null) {
      return running;
    }

    final future = _runDeferredInitialization(onProgress: onProgress);
    _runningDeferredInitialization = future;

    try {
      await future;
      _deferredInitialized = true;
      onProgress(
        const AppStartupProgress(
          stage: AppStartupStage.ready,
          value: 1,
          detail: 'MyApp',
        ),
      );
    } catch (_) {
      await _cleanupDeferredServices();
      rethrow;
    } finally {
      _runningDeferredInitialization = null;
    }
  }

  Future<void> _initializeBaseServices() async {
    final deepLinkService = DeepLinkService();
    await deepLinkService.init();
    _putIfAbsent<DeepLinkService>(deepLinkService);

    await GetStorage.init();
    await StorageService().init();

    final dbService = DatabaseService();
    await dbService.init();
    _putIfAbsent<DatabaseService>(dbService);

    await dbService.cleanupLogDatabase();

    _putIfAbsent<MessageService>(MessageService());
  }

  Future<void> _initializeCoreAppServices() async {
    _putIfAbsent<AppService>(AppService());

    final configService = await ConfigService().init();
    _putIfAbsent<ConfigService>(configService);
    Get.find<AppService>().syncSiteModeFromConfig(configService);

    await _applyLocale(configService);
  }

  Future<void> _runDeferredInitialization({
    required StartupProgressCallback onProgress,
  }) async {
    _cleanupActions.clear();

    onProgress(
      const AppStartupProgress(
        stage: AppStartupStage.preparing,
        value: 0.08,
        detail: 'ConfigBackupService',
      ),
    );
    _registerDeferredSingleton<ConfigBackupService>(ConfigBackupService());

    onProgress(
      const AppStartupProgress(
        stage: AppStartupStage.initializing,
        value: 0.24,
        detail: 'Proxy / Preferences',
      ),
    );
    _configureProxy();
    _cleanupActions.add(() async {
      HttpOverrides.global = MyHttpOverrides(null);
      HttpClientFactory.instance.setProxy(null);
    });
    final userPreferenceService = await UserPreferenceService().init();
    _registerDeferredSingleton<UserPreferenceService>(userPreferenceService);

    onProgress(
      const AppStartupProgress(
        stage: AppStartupStage.initializing,
        value: 0.42,
        detail: 'Network / Session',
      ),
    );
    _registerDeferredSingleton<IwaraNetworkService>(IwaraNetworkService());
    await _initializeAuthServices();

    onProgress(
      const AppStartupProgress(
        stage: AppStartupStage.initializing,
        value: 0.58,
        detail: 'Version / Theme',
      ),
    );
    final versionService = await VersionService().init();
    _registerDeferredSingleton<VersionService>(versionService);

    final themeService = await ThemeService().init();
    _registerDeferredSingleton<ThemeService>(themeService);

    onProgress(
      const AppStartupProgress(
        stage: AppStartupStage.initializing,
        value: 0.76,
        detail: 'Upload / Media',
      ),
    );
    final uploadService = await UploadService.getInstance();
    _registerDeferredSingleton<UploadService>(uploadService);

    MediaKit.ensureInitialized();

    final glslShaderService = await GlslShaderService().init();
    _registerDeferredSingleton<GlslShaderService>(glslShaderService);

    onProgress(
      const AppStartupProgress(
        stage: AppStartupStage.initializing,
        value: 0.92,
        detail: 'Feature Services',
      ),
    );
    _registerFeatureServices();
  }

  Future<void> _initializeAuthServices() async {
    try {
      LogUtils.d('开始初始化认证服务', '启动初始化');
      final authService = await AuthService().init();
      _registerDeferredSingleton<AuthService>(authService);

      LogUtils.d('开始初始化API服务', '启动初始化');
      final apiService = await ApiService.getInstance();
      _registerDeferredSingleton<ApiService>(apiService);

      try {
        LogUtils.d('开始初始化用户服务', '启动初始化');
        final userService = UserService();
        _registerDeferredSingleton<UserService>(userService);
        LogUtils.d('用户服务初始化完成', '启动初始化');
      } catch (error, stackTrace) {
        LogUtils.e(
          '用户服务初始化失败',
          tag: '启动初始化',
          error: error,
          stackTrace: stackTrace,
        );
        _registerDeferredSingleton<UserService>(UserService());
      }
    } catch (error, stackTrace) {
      LogUtils.e(
        '认证相关服务初始化失败',
        tag: '启动初始化',
        error: error,
        stackTrace: stackTrace,
      );
      _registerDeferredSingleton<UserService>(UserService());
    }
  }

  void _registerFeatureServices() {
    _registerDeferredLazy<VideoService>(() => VideoService());
    _registerDeferredLazy<CommentService>(() => CommentService());
    _registerDeferredLazy<SearchService>(() => SearchService());
    _registerDeferredLazy<GalleryService>(() => GalleryService());
    _registerDeferredLazy<PostService>(() => PostService());
    _registerDeferredLazy<TagService>(() => TagService());
    _registerDeferredLazy<LightService>(() => LightService());
    _registerDeferredLazy<PlayListService>(() => PlayListService());
    _registerDeferredLazy<ForumService>(() => ForumService());
    _registerDeferredLazy<ConversationService>(() => ConversationService());

    _registerDeferredSingleton<PermissionService>(PermissionService());
    _registerDeferredSingleton<DownloadService>(DownloadService());
    _registerDeferredSingleton<DownloadPathService>(DownloadPathService());
    _registerDeferredSingleton<FilenameTemplateService>(
      FilenameTemplateService(),
    );
    _registerDeferredSingleton<BatchDownloadService>(BatchDownloadService());
    _registerDeferredSingleton<TranslationService>(TranslationService());
    _registerDeferredSingleton<FavoriteService>(FavoriteService());
    _registerDeferredSingleton<PlaybackHistoryService>(
      PlaybackHistoryService(),
    );
    _registerDeferredSingleton<EmojiLibraryService>(EmojiLibraryService());
    _registerDeferredSingleton<DlnaCastService>(DlnaCastService());
    _registerDeferredSingleton<HistoryRepository>(HistoryRepository());
  }

  void _configureProxy() {
    final configService = Get.find<ConfigService>();

    if (ProxyUtil.isSupportedPlatform()) {
      final bool useProxy =
          configService.settings[ConfigKey.USE_PROXY]?.value ?? false;
      String? proxyUrl;
      if (useProxy) {
        proxyUrl = configService.settings[ConfigKey.PROXY_URL]?.value;
      }

      if (useProxy && proxyUrl != null && proxyUrl.isNotEmpty) {
        HttpOverrides.global = MyHttpOverrides(proxyUrl);
        HttpClientFactory.instance.setProxy(proxyUrl);
        LogUtils.i('代理设置完成: $proxyUrl', '启动初始化');
        return;
      }

      HttpOverrides.global = MyHttpOverrides(null);
      HttpClientFactory.instance.setProxy(null);
      LogUtils.i('未启用代理', '启动初始化');
      return;
    }

    HttpOverrides.global = MyHttpOverrides(null);
    HttpClientFactory.instance.setProxy(null);
    LogUtils.i('当前平台不支持代理', '启动初始化');
  }

  Future<void> _applyLocale(ConfigService configService) async {
    final String applicationLocale =
        configService[ConfigKey.APPLICATION_LOCALE];
    if (applicationLocale == 'system') {
      await slang.LocaleSettings.useDeviceLocale();
      return;
    }

    slang.AppLocale? targetLocale;
    for (final locale in slang.AppLocale.values) {
      if (locale.languageTag.toLowerCase() == applicationLocale.toLowerCase()) {
        targetLocale = locale;
        break;
      }
    }

    if (targetLocale != null) {
      await slang.LocaleSettings.setLocale(targetLocale);
    } else {
      await slang.LocaleSettings.useDeviceLocale();
    }
  }

  void _putIfAbsent<T>(T service, {bool permanent = false}) {
    if (Get.isRegistered<T>()) {
      return;
    }
    Get.put<T>(service, permanent: permanent);
  }

  void _registerDeferredSingleton<T>(T service, {bool permanent = false}) {
    if (Get.isRegistered<T>()) {
      return;
    }

    Get.put<T>(service, permanent: permanent);
    _cleanupActions.add(() async {
      if (Get.isRegistered<T>()) {
        Get.delete<T>(force: true);
      }
    });
  }

  void _registerDeferredLazy<T>(InstanceBuilderCallback<T> builder) {
    if (Get.isRegistered<T>()) {
      return;
    }
    Get.lazyPut<T>(builder);
    _cleanupActions.add(() async {
      if (Get.isRegistered<T>()) {
        Get.delete<T>(force: true);
      }
    });
  }

  Future<void> _cleanupDeferredServices() async {
    for (final cleanup in _cleanupActions.reversed) {
      try {
        await cleanup();
      } catch (error, stackTrace) {
        LogUtils.w('清理启动服务失败: $error\n$stackTrace', '启动初始化');
      }
    }
    _cleanupActions.clear();
  }
}

class MyHttpOverrides extends HttpOverrides {
  MyHttpOverrides(this.proxy);

  final String? proxy;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.idleTimeout = const Duration(seconds: 90);

    if (proxy != null && proxy!.isNotEmpty) {
      client.findProxy = (uri) => 'PROXY $proxy; DIRECT';
    }

    return client;
  }
}
