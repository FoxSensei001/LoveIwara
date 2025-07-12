import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/comment_service.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/services/deep_link_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/light_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/playback_history_service.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/services/search_service.dart';
import 'package:i_iwara/app/services/tag_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/proxy/proxy_util.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/log_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'dart:ui' show Canvas, PaintingStyle, Picture, PictureRecorder, Rect;

import 'app/my_app.dart';
import 'app/services/api_service.dart';
import 'app/services/auth_service.dart';
import 'app/services/cloudflare_service.dart';
import 'app/services/storage_service.dart';
import 'app/services/user_preference_service.dart';
import 'app/services/user_service.dart';
import 'db/database_service.dart';
import 'app/services/translation_service.dart';
import 'i18n/strings.g.dart';
import 'app/services/theme_service.dart';
import 'app/services/version_service.dart';
import 'app/repositories/history_repository.dart';
import 'app/services/message_service.dart';
import 'app/services/favorite_service.dart';
import 'package:i_iwara/app/services/config_backup_service.dart';
import 'package:i_iwara/utils/refresh_rate_helper.dart';

void main() {
  // 确保Flutter初始化
  runZonedGuarded(() async {

    // 确保Flutter初始化
    WidgetsFlutterBinding.ensureInitialized();

    // 日志初始化 - 仅初始化基本功能，不依赖数据库
    bool isProduction = !kDebugMode;
    await LogUtils.init(isProduction: isProduction);
    
    // 记录应用启动信息
    LogUtils.i('应用启动', '启动初始化');

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent.withAlpha(0x01)/*Android=28,不能用全透明 */
    ));

    // 设置Flutter错误处理
    FlutterError.onError = (FlutterErrorDetails details) {
      LogUtils.e('Flutter框架错误',
        tag: '全局错误处理',
        error: details.exception,
        stackTrace: details.stack
      );
      
      // 确保日志已写入
      try {
        if (Get.isRegistered<LogService>()) {
          // 同步等待日志刷新完成
          Get.find<LogService>().flushBufferToDatabase();
        }
      } catch (_) {
        // Man, wut can i do
      }
      
      FlutterError.presentError(details);
    };

    // 初始化基础服务
    await _initializeBaseServices();

    // 初始化业务服务
    await _initializeBusinessServices();

    // 运行应用
    runApp(TranslationProvider(child: const MyApp()));

    if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
      await _initializeDesktop();
    }

    // 在应用启动时配置图片缓存
    configureImageCache();

    // 启用高刷新率（仅限Android）
    if (GetPlatform.isAndroid) {
      RefreshRateHelper.enableHighRefreshRate().then((success) {
        if (success) {
          LogUtils.i('高刷新率已启用', '启动初始化');
        } else {
          LogUtils.w('启用高刷新率失败，使用默认刷新率', '启动初始化');
        }
      }).catchError((error) {
        LogUtils.e('启用高刷新率时发生错误', tag: '启动初始化', error: error);
      });
    }

  }, (error, stackTrace) {
    // 在这里处理未捕获的异常
    LogUtils.e('未捕获的异常: $error', tag: '全局异常处理', stackTrace: stackTrace);
    
    // 确保日志已写入
    try {
      if (Get.isRegistered<LogService>()) {
        // 同步等待日志刷新完成
        Get.find<LogService>().flushBufferToDatabase();
      }
    } catch (_) {
      // Man, wut can i do
    }
    
    // TODO: 可以在这里添加额外处理，例如显示错误页面或重启应用
  });
}

/// 初始化基础服务
Future<void> _initializeBaseServices() async {

  // 初始化深度链接服务
  final deepLinkService = DeepLinkService();
  await deepLinkService.init();
  Get.put(deepLinkService);

  // 初始化语言设置
  String systemLanguage = CommonUtils.getDeviceLocale();
  if (systemLanguage == 'zh' || systemLanguage == 'zh-CN' || systemLanguage == 'ja' || systemLanguage == 'zh-TW') {
    LocaleSettings.useDeviceLocale();
  } else if (systemLanguage == 'zh-HK') {
    LocaleSettings.setLocaleRaw('zh-TW');
  } else {
    LocaleSettings.setLocaleRaw('en');
  }

  // 初始化存储服务
  await GetStorage.init();
  await StorageService().init();

  // 初始化数据库服务
  final dbService = DatabaseService();
  await dbService.init();

  // 初始化日志服务 - 现在放在数据库服务之后
  var logService = await LogService().init();
  Get.put(logService);

  // 初始化消息服务
  Get.put(MessageService());
}

/// 初始化业务服务
Future<void> _initializeBusinessServices() async {

  // 初始化应用服务
  Get.put(AppService());

  // 初始化配置服务
  var configService = await ConfigService().init();
  Get.put(configService);
  
  
  LogUtils.setPersistenceEnabled(CommonConstants.enableLogPersistence);
  LogUtils.i('日志配置已更新：持久化=${CommonConstants.enableLogPersistence}，大小限制=${CommonConstants.maxLogDatabaseSize / (1024 * 1024)}MB', '启动初始化');

  // 注册 ConfigBackupService 作为 GetxService
  Get.put(ConfigBackupService());

  // 设置代理
  if (ProxyUtil.isSupportedPlatform()) {
    bool useProxy = configService.settings[ConfigKey.USE_PROXY]?.value;
    if (useProxy) {
      String proxyUrl = configService.settings[ConfigKey.PROXY_URL]?.value;
      HttpOverrides.global = MyHttpOverrides(proxyUrl);
      LogUtils.i('代理设置完成: $proxyUrl', '启动初始化');
    } else {
      LogUtils.i('未启用代理', '启动初始化');
    }
  }

  // 初始化用户相关服务
  var userPreferenceService = await UserPreferenceService().init();
  Get.put(userPreferenceService);

  // 初始化认证服务和API服务
  try {
    LogUtils.d('开始初始化认证服务', '启动初始化');
    Get.put(CloudflareService());
    AuthService authService = await AuthService().init();
    Get.put(authService);

    LogUtils.d('开始初始化API服务', '启动初始化');
    ApiService apiService = await ApiService.getInstance();
    Get.put(apiService);

    // 只有在认证服务初始化成功后才初始化用户服务
    if (authService.isAuthenticated) {
      try {
        LogUtils.d('开始初始化用户服务', '启动初始化');
        UserService userService = UserService();
        Get.put(userService);
        LogUtils.d('用户服务初始化完成', '启动初始化');
      } catch (e) {
        LogUtils.e('用户服务初始化失败', tag: '启动初始化', error: e);
        // 用户服务初始化失败，清理认证状态
        await authService.handleTokenExpired();
        Get.put(UserService());
      }
    } else {
      LogUtils.d('用户未认证，跳过用户服务初始化', '启动初始化');
      // 如果未认证，仍然注册服务但不初始化
      Get.put(UserService());
    }
  } catch (e) {
    LogUtils.e('认证相关服务初始化失败', tag: '启动初始化', error: e);
    // 即使认证失败，也要注册基本服务
    Get.put(UserService());
    // 确保清理任何可能的部分认证状态
    try {
      final authService = Get.find<AuthService>();
      await authService.handleTokenExpired();
    } catch (_) {}
  }

  // 初始化其他服务
  var versionService = await VersionService().init();
  Get.put(versionService);

  var themeService = await ThemeService().init();
  Get.put(themeService);

  // 初始化懒加载服务
  Get.lazyPut(() => VideoService());
  Get.lazyPut(() => CommentService());
  Get.lazyPut(() => SearchService());
  Get.lazyPut(() => GalleryService());
  Get.lazyPut(() => PostService());
  Get.lazyPut(() => TagService());
  Get.lazyPut(() => LightService());
  Get.lazyPut(() => PlayListService());
  Get.lazyPut(() => ForumService());
  Get.lazyPut(() => ConversationService());
  Get.put(DownloadService());
  Get.put(TranslationService());
  Get.put(FavoriteService());
  Get.put(PlaybackHistoryService());

  // 初始化媒体服务
  MediaKit.ensureInitialized();

  // 注册历史记录仓库
  Get.put(HistoryRepository());
}

/// 初始化桌面端设置
Future<void> _initializeDesktop() async {
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow();
  await windowManager.setTitleBarStyle(
    TitleBarStyle.hidden,
    windowButtonVisibility: GetPlatform.isMacOS,
  );
  if (GetPlatform.isLinux) {
    await windowManager.setBackgroundColor(Colors.transparent);
  }
  await windowManager.setMinimumSize(const Size(200, 200));
  await windowManager.show();
  await windowManager.focus();
  
  // 添加应用关闭监听，确保日志写入完成
  windowManager.setPreventClose(true);
  windowManager.addListener(DesktopWindowListener());
}

/// 桌面窗口事件监听器
class DesktopWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    await _closeServices();
    await windowManager.destroy();
  }
}

/// 代理设置
class MyHttpOverrides extends HttpOverrides {
  final String url;

  MyHttpOverrides(this.url);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..findProxy = (uri) {
        return 'PROXY $url';
      }
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
  }
}

/// 确保在应用退出前关闭日志文件
Future<void> _closeServices() async {
  try {
    await LogUtils.close();
  } catch (e) {
    // 记录关闭服务时可能出现的错误
    print('关闭服务失败: $e');
  }
}

// 在应用启动时配置图片缓存
void configureImageCache() {
  // 适当调整图片缓存大小，平衡内存使用和性能
  PaintingBinding.instance.imageCache.maximumSize = 200; // 增加到200张图片
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 限制内存占用为100MB
  
  // 预热渲染管道
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _prewarmRendering();
  });
}

// 预热渲染管道，减少首次渲染时的卡顿
void _prewarmRendering() {
  // 创建一个离屏的图像进行渲染预热
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  
  // 预热一些常用的绘制操作
  final paint = Paint()
    ..color = Colors.transparent
    ..style = PaintingStyle.fill;
  
  canvas.drawRect(Rect.fromLTWH(0, 0, 100, 100), paint);
  canvas.drawRRect(RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, 100, 100),
    const Radius.circular(8.0),
  ), paint);
  
  // 确保预热的内容被光栅化
  final Picture picture = recorder.endRecording();
  picture.toImage(1, 1).then((image) {
    image.dispose(); // 释放图像资源
  });
}
