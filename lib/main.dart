import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/comment_service.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/services/deep_link_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/light_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/services/search_service.dart';
import 'package:i_iwara/app/services/tag_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/proxy/proxy_util.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'app/my_app.dart';
import 'app/services/api_service.dart';
import 'app/services/auth_service.dart';
import 'app/services/config_service.dart';
import 'app/services/global_search_service.dart';
import 'app/services/storage_service.dart';
import 'app/services/user_preference_service.dart';
import 'app/services/user_service.dart';
import 'db/database_service.dart';
import 'app/services/translation_service.dart';
import 'i18n/strings.g.dart';
import 'app/services/theme_service.dart';
import 'app/services/version_service.dart';
import 'app/repositories/history_repository.dart';

void main() {

  // 确保Flutter初始化
  runZonedGuarded(() async {
    // 日志初始化
    LogUtils.init();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent.withAlpha(0x01)/*Android=28,不能用全透明 */
    ));

    // 确保Flutter初始化
    WidgetsFlutterBinding.ensureInitialized();

    // 设置最高刷新率(仅Android)
    if (Platform.isAndroid) {
      try {
        await FlutterDisplayMode.setHighRefreshRate();
        LogUtils.i('已设置最高刷新率', '启动初始化');
      } catch (e) {
        LogUtils.e('设置刷新率失败', tag: '启动初始化', error: e);
      }
    }

    // 初始化深度链接服务
    final deepLinkService = DeepLinkService();
    await deepLinkService.init();
    Get.put(deepLinkService);
    // 现在有 简中、英文、日文
    // 获取系统语言，如果是支持的语言，则使用，如果不是，则使用英文；
    String systemLanguage = CommonUtils.getDeviceLocale();
    if (systemLanguage == 'zh' || systemLanguage == 'zh-CN' || systemLanguage == 'ja' || systemLanguage == 'zh-TW') {
      LocaleSettings.useDeviceLocale();
    } else if (systemLanguage == 'zh-HK') {
      LocaleSettings.setLocaleRaw('zh-TW');
    } else {
      LocaleSettings.setLocaleRaw('en');
    }

    final dbService = DatabaseService();
    await dbService.init();

    // 初始化Getx和视频组件
    await GetStorage.init();
    await StorageService().init();
    Get.put(AppService());
    var configService = await ConfigService().init();
    Get.put(configService);

    // 尝试设置代理
    if (ProxyUtil.isSupportedPlatform()) {
      bool useProxy = configService.settings[ConfigService.USE_PROXY].value;
      if (useProxy) {
        // 先从配置中获取代理信息
        String proxyUrl = configService.settings[ConfigService.PROXY_URL].value;
        HttpOverrides.global = MyHttpOverrides(proxyUrl);
        LogUtils.i('设置代理: $proxyUrl', '启动初始化');
      } else {
        LogUtils.i('未启用代理', '启动初始化');
      }
    }

    var userPreferenceService = await UserPreferenceService().init();
    Get.put(userPreferenceService);
    AuthService authService = await AuthService().init();
    Get.put(authService);
    ApiService apiService = await ApiService.getInstance();
    Get.put(apiService);
    UserService userService = await UserService().init();
    Get.put(userService);
        // 在 main() 函数中初始化服务
    var versionService = await VersionService().init();
    Get.put(versionService);
    var themeService = await ThemeService().init();
    Get.put(themeService);
    Get.lazyPut(() => VideoService());
    Get.lazyPut(() => CommentService());
    Get.lazyPut(() => SearchService());
    Get.lazyPut(() => GalleryService());
    Get.lazyPut(() => PostService());
    Get.lazyPut(() => TagService());
    Get.lazyPut(() => LightService());
    Get.lazyPut(() => GlobalSearchService());
    Get.lazyPut(() => PlayListService());
    Get.lazyPut(() => ForumService());
    Get.lazyPut(() => ConversationService());
    Get.put(TranslationService());
    // 初始化 MediaKit
    MediaKit.ensureInitialized();

    // 注册 HistoryRepository 为单例
    Get.put(HistoryRepository());

    // 运行应用
    runApp(TranslationProvider(child: const MyApp()));

    if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
      await windowManager.ensureInitialized();
      windowManager.waitUntilReadyToShow().then((_) async {
        await windowManager.setTitleBarStyle(
          TitleBarStyle.hidden,
          windowButtonVisibility: GetPlatform.isMacOS,
        );
        if (GetPlatform.isLinux) {
          await windowManager.setBackgroundColor(Colors.transparent);
        }
        await windowManager.setMinimumSize(const Size(500, 600));
        await windowManager.show();
        await windowManager.focus();
      });
    }

  }, (error, stackTrace) {
    // 在这里处理未捕获的异常
    LogUtils.e('未捕获的异常: $error', tag: '全局异常处理', stackTrace: stackTrace);
  });
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
