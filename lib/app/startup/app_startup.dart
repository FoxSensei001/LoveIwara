import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/services/batch_download_service.dart';
import 'package:i_iwara/app/services/comment_service.dart';
import 'package:i_iwara/app/services/config_backup_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/startup/restored_install_guard.dart';
import 'package:i_iwara/app/services/content_block_service.dart';
import 'package:i_iwara/app/services/player_keybinding/keybinding_service.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/services/deep_link_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/download_notification_service.dart';
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/http_client_factory.dart';
import 'package:i_iwara/app/services/iwara_news_service.dart';
import 'package:i_iwara/app/services/iwara_network_service.dart';
import 'package:i_iwara/app/services/light_service.dart';
import 'package:i_iwara/app/services/logging/log_service.dart';
import 'package:i_iwara/app/services/message_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/playback_history_service.dart';
import 'package:i_iwara/app/services/vr_format_override_service.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/services/search_service.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/app/services/tag_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/services/oreno3d_localization_service.dart';
import 'package:i_iwara/app/services/theme_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/services/upload_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/version_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/auth_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/dlna_cast_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
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
    await _initializeCoreAppServices(
      logService: logService,
      isProduction: isProduction,
    );

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

  Future<void> _initializeCoreAppServices({
    required LogService logService,
    required bool isProduction,
  }) async {
    _putIfAbsent<AppService>(AppService());

    final configService = await ConfigService().init();
    _putIfAbsent<ConfigService>(configService);

    // 配置有可能是从备份 / 换机搬过来的（Android 自动备份会把整个配置库带走）。
    // 那种情况下首次引导和玻璃质感提醒的"已问过"标记也一起回来了，要在任何人
    // 读到它们之前先复位——路由守卫和 GlassMaterialIntro 都晚于这里。
    await RestoredInstallGuard.reconcile(configService);

    // 玻璃材质开关要在**任何一块玻璃 build 之前**灌好：shader 预热和第一帧
    // chrome 都读它，晚一步就会先渲染成真玻璃再跳回假玻璃。
    applyGlassMaterialFromConfig(
      configService[ConfigKey.ENABLE_LIQUID_GLASS_KEY] == true,
    );

    // 日志策略要在 ConfigService 一就绪就应用，而不是等整个 core 初始化跑完。
    // 日志总开关出厂默认关闭，用户既然关了，剩下的启动流程就不该再按全价
    // 打日志（控制台 PrettyPrinter 是这条链路上最贵的一段）。
    // 更早是做不到的：开关存在配置表里，得先有 DB 和 ConfigService。
    await logService.applyPolicy(
      LogService.policyFromConfig(configService, isProduction: isProduction),
    );

    // 应用锁要在路由/UI 起来之前就位：init() 里读安全存储凭据，
    // 决定这次冷启动是否直接进锁屏。
    final appLockService = await AppLockService().init();
    _putIfAbsent<AppLockService>(appLockService);

    await Get.find<AppService>().syncSiteModeFromConfig(configService);

    // 冷启动恒为主站。如果这次是被一条 AI 站链接拉起来的，趁应用树还没 build
    // 直接以那个站点起步，省掉"开了页面才发现站点不对 → 切站 → 重启整棵树"。
    if (Get.isRegistered<DeepLinkService>()) {
      await Get.find<AppService>().adoptStartupSiteMode(
        Get.find<DeepLinkService>().pendingInitialLinkSite,
        configService,
      );
    }

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
        _tryRegisterFallbackUserService();
      }
    } catch (error, stackTrace) {
      LogUtils.e(
        '认证相关服务初始化失败',
        tag: '启动初始化',
        error: error,
        stackTrace: stackTrace,
      );
      _tryRegisterFallbackUserService();
    }
  }

  /// 兜底注册 UserService —— 仅当其构造依赖(AuthService/ApiService)确实就绪时才尝试，
  /// 否则 UserService 构造会立即 Get.find 这些服务而二次抛错、冲垮启动(MEDIUM#5)。
  void _tryRegisterFallbackUserService() {
    if (Get.isRegistered<UserService>()) return;
    if (!Get.isRegistered<AuthService>() || !Get.isRegistered<ApiService>()) {
      LogUtils.e(
        'AuthService/ApiService 未就绪，跳过 UserService 兜底注册以避免二次崩溃',
        tag: '启动初始化',
      );
      return;
    }
    try {
      _registerDeferredSingleton<UserService>(UserService());
    } catch (error, stackTrace) {
      LogUtils.e(
        'UserService 兜底注册仍失败',
        tag: '启动初始化',
        error: error,
        stackTrace: stackTrace,
      );
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
    _registerDeferredLazy<IwaraNewsService>(() => IwaraNewsService());
    _registerDeferredLazy<ConversationService>(() => ConversationService());

    _registerDeferredSingleton<PermissionService>(PermissionService());
    // 系统通知服务需在 DownloadService 之前注册，确保派发钩子能解析到它。
    // 下载这一簇全部 permanent：它们持有活跃连接、文件句柄与内存队列，
    // 被启动回滚 delete 掉会导致下载中断 + UI 监听挂在死实例上（见
    // _registerDeferredSingleton 的注释）。
    _registerDeferredSingleton<DownloadNotificationService>(
      DownloadNotificationService(),
      permanent: true,
    );
    _registerDeferredSingleton<DownloadService>(
      DownloadService(),
      permanent: true,
    );
    _registerDeferredSingleton<DownloadPathService>(
      DownloadPathService(),
      permanent: true,
    );
    _registerDeferredSingleton<FilenameTemplateService>(
      FilenameTemplateService(),
    );
    _registerDeferredSingleton<BatchDownloadService>(
      BatchDownloadService(),
      permanent: true,
    );
    _registerDeferredSingleton<TranslationService>(TranslationService());
    _registerDeferredSingleton<FavoriteService>(FavoriteService());
    _registerDeferredSingleton<WatchLaterService>(WatchLaterService());
    // 视频池的登记处：池必须活在页面之外（连播是原地换片、抽屉是 root 路由、
    // 详情页可层层叠加），所以挂成长寿命单例。
    _registerDeferredSingleton<PlaybackQueueService>(PlaybackQueueService());
    _registerDeferredSingleton<PlaybackHistoryService>(
      PlaybackHistoryService(),
    );
    // VR 片源格式的按视频手动覆盖：一张永不清理的小表，读写都在详情页里发生。
    _registerDeferredSingleton<VrFormatOverrideService>(
      VrFormatOverrideService(),
    );
    _registerDeferredSingleton<EmojiLibraryService>(EmojiLibraryService());
    _registerDeferredSingleton<DlnaCastService>(DlnaCastService());
    _registerDeferredSingleton<HistoryRepository>(HistoryRepository());
    _registerDeferredSingleton<ContentBlockService>(ContentBlockService());
    // 标签本地化词库：注册后后台加载（缓存 -> 打包资源 -> CDN 刷新），不阻塞启动
    _registerDeferredSingleton<TagLocalizationService>(
      TagLocalizationService(),
    );
    unawaited(Get.find<TagLocalizationService>().init());
    // Oreno3d 元数据（原作/角色/标签）本地化词库：同样后台加载，不阻塞启动
    _registerDeferredSingleton<Oreno3dLocalizationService>(
      Oreno3dLocalizationService(),
    );
    unawaited(Get.find<Oreno3dLocalizationService>().init());
    // 全应用自定义快捷键服务（依赖 ConfigService，onInit 时加载键位表）
    _registerDeferredSingleton<KeybindingService>(KeybindingService());

    // 启动时按配置自动清理超期历史记录（默认关闭，不阻塞启动）
    _maybeAutoCleanupHistory();
  }

  /// 若用户开启了「自动清理历史记录」，删除超过设定天数的浏览历史。
  /// 失败不影响启动流程。
  void _maybeAutoCleanupHistory() {
    try {
      final configService = Get.find<ConfigService>();
      final bool enabled =
          configService
              .settings[ConfigKey.AUTO_DELETE_HISTORY_ENABLED]
              ?.value ??
          false;
      if (!enabled) return;
      final int days =
          configService.settings[ConfigKey.AUTO_DELETE_HISTORY_DAYS]?.value ??
          30;
      if (days <= 0) return;
      // 异步执行，避免阻塞启动；记录清理结果
      Get.find<HistoryRepository>()
          .deleteRecordsOlderThanDays(days)
          .then((removed) {
            if (removed > 0) {
              LogUtils.i('已自动清理 $removed 条超过 $days 天的历史记录', '启动初始化');
            }
          })
          .catchError((error) {
            LogUtils.w('自动清理历史记录失败: $error', '启动初始化');
          });
    } catch (error) {
      LogUtils.w('自动清理历史记录初始化失败: $error', '启动初始化');
    }
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

  /// 注册一个延迟阶段的单例。
  ///
  /// [permanent] = true 时**不登记回滚清理**：该服务在启动失败重试时不会被
  /// `Get.delete` 换掉。这对持有长生命周期状态的服务是硬性要求——下载服务持有
  /// 活跃 dio 连接、文件句柄与内存队列，一旦被 force delete，正在跑的下载会被
  /// 连根拔掉；更隐蔽的是：页面上已经挂在旧实例 Rx 上的监听会静默失聪，表现为
  /// 「暂停/继续/删除都不刷新，必须重进页面」。
  void _registerDeferredSingleton<T>(T service, {bool permanent = false}) {
    if (Get.isRegistered<T>()) {
      return;
    }

    Get.put<T>(service, permanent: permanent);
    if (permanent) {
      return;
    }
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
