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
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/proxy/proxy_util.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:i_iwara/app/services/config_service.dart';

import 'dart:ui' show Canvas, PaintingStyle, Picture, PictureRecorder, Rect;

import 'app/my_app.dart';
import 'app/services/api_service.dart';
import 'app/services/auth_service.dart';
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
import 'app/services/download_path_service.dart';
import 'app/services/filename_template_service.dart';
import 'app/services/permission_service.dart';
import 'app/services/upload_service.dart';
import 'package:i_iwara/app/services/config_backup_service.dart';
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:i_iwara/utils/refresh_rate_helper.dart';
import 'package:i_iwara/utils/glsl_shader_service.dart';

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
      
      FlutterError.presentError(details);
    };

    // 初始化基础服务
    await _initializeBaseServices();

    // 初始化业务服务
    await _initializeBusinessServices();

    // 运行应用
    runApp(TranslationProvider(child: const MyApp()));

    if (GetPlatform.isDesktop) {
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
    
    // TODO: 可以在这里添加额外处理，例如显示错误页面或重启应用
  });
}

/// 初始化基础服务
Future<void> _initializeBaseServices() async {

  // 初始化深度链接服务
  final deepLinkService = DeepLinkService();
  await deepLinkService.init();
  Get.put(deepLinkService);

  // 初始化存储服务
  await GetStorage.init();
  await StorageService().init();

  // 初始化数据库服务
  final dbService = DatabaseService();
  await dbService.init();
  Get.put(dbService);

  // 清理旧的日志数据库文件
  await dbService.cleanupLogDatabase();

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

   // 初始化语言设置
  String applicationLocale = configService[ConfigKey.APPLICATION_LOCALE];
  if (applicationLocale == 'system') {
    LocaleSettings.useDeviceLocale();
  } else {
    AppLocale? targetLocale;
    for (final locale in AppLocale.values) {
      if (locale.languageTag.toLowerCase() == applicationLocale.toLowerCase()) {
        targetLocale = locale;
        break;
      }
    }
    if (targetLocale != null) {
      LocaleSettings.setLocale(targetLocale);
    } else {
      LocaleSettings.useDeviceLocale();
    }
  }
  
  LogUtils.i('日志系统已简化，仅支持控制台输出', '启动初始化');

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
    AuthService authService = await AuthService().init();
    Get.put(authService);

    LogUtils.d('开始初始化API服务', '启动初始化');
    ApiService apiService = await ApiService.getInstance();
    Get.put(apiService);

    // 初始化用户服务 - 改进：不再依赖网络请求成功
    try {
      LogUtils.d('开始初始化用户服务', '启动初始化');
      UserService userService = UserService();
      Get.put(userService);
      LogUtils.d('用户服务初始化完成', '启动初始化');
    } catch (e) {
      LogUtils.e('用户服务初始化失败', tag: '启动初始化', error: e);
      // 即使初始化失败，也要注册基本服务，不清理认证状态
      Get.put(UserService());
    }
  } catch (e) {
    LogUtils.e('认证相关服务初始化失败', tag: '启动初始化', error: e);
    // 即使认证失败，也要注册基本服务，但不清理认证状态
    Get.put(UserService());
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
  Get.put(PermissionService());
  Get.put(DownloadService());
  Get.put(DownloadPathService());
  Get.put(FilenameTemplateService());
  Get.put(TranslationService());
  Get.put(FavoriteService());
  Get.put(PlaybackHistoryService());
  Get.put(EmojiLibraryService());

  // 初始化上传服务
  final uploadService = await UploadService.getInstance();
  Get.put(uploadService);

  // 初始化媒体服务
  MediaKit.ensureInitialized();

  // 初始化 GLSL 着色器服务
  final glslShaderService = await GlslShaderService().init();
  Get.put(glslShaderService);

  // 注册历史记录仓库
  Get.put(HistoryRepository());
}

/// 初始化桌面端设置
Future<void> _initializeDesktop() async {
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow();

  final configService = Get.find<ConfigService>();
  double? storedWidth = configService.settings[ConfigKey.WINDOW_WIDTH]?.value;
  double? storedHeight = configService.settings[ConfigKey.WINDOW_HEIGHT]?.value;
  double? storedX = configService.settings[ConfigKey.WINDOW_X]?.value;
  double? storedY = configService.settings[ConfigKey.WINDOW_Y]?.value;

  // 设置一个合理的默认最小尺寸，以防存储的值无效
  const defaultWidth = 800.0;
  const defaultHeight = 600.0;
  const minWidth = 200.0;
  const minHeight = 200.0;

  // 先设置窗口大小（不需要补偿，因为此时标题栏还未隐藏）
  if (storedWidth != null && storedHeight != null &&
      storedWidth >= minWidth && storedHeight >= minHeight) {
    await windowManager.setSize(Size(storedWidth, storedHeight));
    LogUtils.d('已从配置恢复窗口大小: ${storedWidth}x$storedHeight', '桌面初始化');
  } else {
    // 如果没有存储的尺寸或尺寸无效，则使用默认尺寸
    await windowManager.setSize(const Size(defaultWidth, defaultHeight));
     LogUtils.d('使用默认窗口大小: ${defaultWidth}x$defaultHeight', '桌面初始化');
  }

  // 先设置标题栏样式为隐藏
  await windowManager.setTitleBarStyle(
    TitleBarStyle.hidden,
    windowButtonVisibility: GetPlatform.isMacOS,
  );
  // if (GetPlatform.isLinux) {
  //   await windowManager.setBackgroundColor(Colors.transparent);
  // }

  // 在隐藏标题栏之后再恢复窗口位置，此时需要减去系统标题栏高度进行补偿
  if (storedX != null && storedY != null && storedX != -1.0 && storedY != -1.0) {
    final adjustedY = storedY;
    await windowManager.setPosition(Offset(storedX, adjustedY));
    LogUtils.d('已从配置恢复窗口位置: x=$storedX, y=$storedY (调整后: x=$storedX, y=$adjustedY)', '桌面初始化');
  }

  await windowManager.show();
  await windowManager.focus();

  // --- 修改：添加窗口大小变化监听器 ---
  windowManager.addListener(DesktopWindowListener());

  // 添加应用关闭监听，确保日志写入完成
  windowManager.setPreventClose(true);
}

/// 桌面窗口事件监听器
class DesktopWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    await _closeServices();
    await windowManager.destroy();
  }

  @override
  void onWindowResized() {
    _saveWindowSize();
  }

  @override
  void onWindowMoved() {
    _saveWindowPosition();
  }

  @override
  void onWindowMaximize() {
    LogUtils.d('窗口最大化', '桌面监听器');
    _saveWindowSize();
    _saveWindowPosition();
  }

  @override
  void onWindowUnmaximize() {
    LogUtils.d('窗口取消最大化', '桌面监听器');
  }

  @override
  void onWindowEnterFullScreen() {
    LogUtils.d('窗口进入全屏', '桌面监听器');
  }

  @override
  void onWindowLeaveFullScreen() {
    LogUtils.d('窗口退出全屏', '桌面监听器');
  }

  Future<void> _saveWindowSize() async {
    try {
      final size = await windowManager.getSize();
      final configService = Get.find<ConfigService>();

      // 更新配置服务中的值（内存中）
      configService.updateSetting(ConfigKey.WINDOW_WIDTH, size.width);
      configService.updateSetting(ConfigKey.WINDOW_HEIGHT, size.height);

      // 异步保存到持久化存储
      unawaited(
        configService.saveSettingToStorage(ConfigKey.WINDOW_WIDTH, size.width)
          .then((_) => configService.saveSettingToStorage(ConfigKey.WINDOW_HEIGHT, size.height))
          .then((_) {
            LogUtils.d('窗口大小已保存: ${size.width}x${size.height}', '桌面监听器');
          })
          .catchError((error, stackTrace) {
            LogUtils.e('保存窗口大小失败', tag: '桌面监听器', error: error, stackTrace: stackTrace);
          })
      );
    } catch (e, s) {
        LogUtils.e('获取或保存窗口大小时出错', tag: '桌面监听器', error: e, stackTrace: s);
    }
  }

  Future<void> _saveWindowPosition() async {
    try {
      final position = await windowManager.getPosition();
      final configService = Get.find<ConfigService>();

      final adjustedY = position.dy;

      configService.updateSetting(ConfigKey.WINDOW_X, position.dx);
      configService.updateSetting(ConfigKey.WINDOW_Y, adjustedY);

      unawaited(
        configService.saveSettingToStorage(ConfigKey.WINDOW_X, position.dx)
          .then((_) => configService.saveSettingToStorage(ConfigKey.WINDOW_Y, adjustedY))
          .then((_) {
            LogUtils.d('窗口位置已保存: x=${position.dx}, y=${position.dy} (存储为: x=${position.dx}, y=$adjustedY)', '桌面监听器');
          })
          .catchError((error, stackTrace) {
            LogUtils.e('保存窗口位置失败', tag: '桌面监听器', error: error, stackTrace: stackTrace);
          })
      );
    } catch (e, s) {
      LogUtils.e('获取或保存窗口位置时出错', tag: '桌面监听器', error: e, stackTrace: s);
    }
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
    LogUtils.e('关闭服务失败', error: e);
  }
}

// 在应用启动时配置图片缓存
void configureImageCache() {
  // 适当调整图片缓存大小，平衡内存使用和性能
  PaintingBinding.instance.imageCache.maximumSize = 100; // 减少到100张图片
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 限制内存占用为50MB

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
