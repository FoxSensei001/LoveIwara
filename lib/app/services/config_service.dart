import 'package:get/get.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class ConfigService extends GetxService {
  late final StorageService storage;

  // 配置的键
  static const String AUTO_PLAY_KEY = 'auto_play'; // 自动播放
  static const String DEFAULT_BRIGHTNESS_KEY = 'default_brightness'; // 默认亮度
  static const String LONG_PRESS_PLAYBACK_SPEED_KEY =
      'long_press_playback_speed'; // 长按播放速度
  static const String FAST_FORWARD_SECONDS_KEY = 'fast_forward_seconds'; // 快进秒数
  static const String REWIND_SECONDS_KEY = 'rewind_seconds'; // 倒退秒数
  static const String DEFAULT_QUALITY_KEY = 'default_quality'; // 默认画质
  static const String REPEAT_KEY = 'repeat'; // 重复播放
  static const String VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO =
      'video_left_and_right_control_area_ratio'; // 视频左右控制区域比例
  static const String BRIGHTNESS_KEY = 'brightness'; // 亮度
  static const String KEEP_LAST_BRIGHTNESS_KEY =
      'keep_last_brightness'; // 保持最后亮度
  static const String VOLUME_KEY = 'volume'; // 音量
  static const String KEEP_LAST_VOLUME_KEY = 'keep_last_volume'; // 保持最后音量
  static const String USE_PROXY = 'use_proxy'; // 使用代理
  static const String PROXY_URL = 'proxy_url'; // 代理地址
  static const String RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN =
      'render_vertical_video_in_vertical_screen'; // 在竖屏中渲染竖向视频
  static const String ACTIVE_BACKGROUND_PRIVACY_MODE =
      'active_background_privacy_mode'; // 激活后台隐私模式
  static const String DEFAULT_LANGUAGE_KEY = 'default_language'; // 默认语言
  static const String THEME_MODE_KEY = 'theme_mode'; // 添加主题模式配置键
  static const String _TRANSLATION_LANGUAGE = 'translation_language';
  static const String REMOTE_REPO_RELEASE_URL = 'remote_repo_release_url'; // 远程仓库的 release 地址
  static const String REMOTE_REPO_URL = 'remote_repo_url'; // 远程仓库的 url
  static const String SETTINGS_SELECTED_INDEX_KEY = 'settings_selected_index';
  static const String REMOTE_REPO_UPDATE_LOGS_YAML_URL = 'remote_repo_update_logs_yaml_url';
  static const String IGNORED_VERSION = 'ignored_version';
  static const String LAST_CHECK_UPDATE_TIME = 'last_check_update_time';
  static const String AUTO_CHECK_UPDATE = 'auto_check_update';

  // 所有配置项的 Map
  final settings = <String, dynamic>{
    AUTO_PLAY_KEY: false.obs,
    DEFAULT_BRIGHTNESS_KEY: 0.5.obs,
    LONG_PRESS_PLAYBACK_SPEED_KEY: 2.0.obs,
    FAST_FORWARD_SECONDS_KEY: 10.obs,
    REWIND_SECONDS_KEY: 10.obs,
    DEFAULT_QUALITY_KEY: '360'.obs, // 360、540、Source、预览
    REPEAT_KEY: false.obs,
    VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO: .2.obs,
    BRIGHTNESS_KEY: 0.5.obs,
    KEEP_LAST_BRIGHTNESS_KEY: true.obs,
    VOLUME_KEY: 0.4.obs,
    KEEP_LAST_VOLUME_KEY: false.obs,
    USE_PROXY: false.obs,
    PROXY_URL: ''.obs,
    RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN: true.obs,
    ACTIVE_BACKGROUND_PRIVACY_MODE: false.obs,
    DEFAULT_LANGUAGE_KEY: 'zh-CN'.obs,
    THEME_MODE_KEY: 4.obs, // 添加主题模式配置，默认为0(system)
    REMOTE_REPO_RELEASE_URL: 'https://github.com/FoxSensei001/i_iwara/releases'.obs,
    REMOTE_REPO_URL: 'https://github.com/FoxSensei001/i_iwara'.obs,
    SETTINGS_SELECTED_INDEX_KEY: 0.obs,
    REMOTE_REPO_UPDATE_LOGS_YAML_URL: 'https://raw.githubusercontent.com/FoxSensei001/i_iwara/master/update_logs.yaml'.obs,
    IGNORED_VERSION: ''.obs,
    LAST_CHECK_UPDATE_TIME: 0.obs,
    AUTO_CHECK_UPDATE: true.obs,
  }.obs;

  late final Rx<Sort> _currentTranslationSort;

  Sort get currentTranslationSort => _currentTranslationSort.value;
  String get currentTranslationLanguage => currentTranslationSort.extData;

  // 初始化配置
  Future<ConfigService> init() async {
    storage = StorageService();
    await _loadSettings();

    // 单独初始化翻译语言
    final savedLanguage = storage.readData(_TRANSLATION_LANGUAGE) ?? settings[DEFAULT_LANGUAGE_KEY]!.value;
    _currentTranslationSort = (CommonConstants.translationSorts.firstWhere(
      (sort) => sort.extData == savedLanguage,
      orElse: () => CommonConstants.translationSorts.first,
    )).obs;
    return this;
  }

  // 加载配置
  Future<void> _loadSettings() async {
    // 加载配置
    settings.forEach((key, value) {
      try {
        final storedValue = storage.readData(key);
        if (storedValue != null) {
          if (value is RxBool) value.value = storedValue;
          if (value is RxDouble) value.value = storedValue;
          if (value is RxInt) value.value = storedValue;
          if (value is RxString) value.value = storedValue;
          if (value is RxList) value.value = storedValue;
        }
      } catch (e) {
        LogUtils.e('加载配置失败: $key', tag: 'ConfigService', error: e);
      }
    });
  }

  // 保存配置
  Future<void> _saveSetting(String key, dynamic value) async {
    await storage.writeData(key, value);
  }

  // 设置配置时自动更新 Map 和存储
  Future<void> setSetting(String key, dynamic value) async {
    if (settings.containsKey(key)) {
      settings[key]!.value = value;
      await _saveSetting(key, value);
    } else {
      throw Exception("未知的配置键: $key");
    }
  }

  /// 动态访问配置
  /// ```dart
  /// ConfigService configService = Get.find();
  /// bool autoPlay = configService[ConfigService.AUTO_PLAY_KEY];
  /// ```
  dynamic operator [](String key) {
    if (settings.containsKey(key)) {
      return settings[key]!.value;
    }
    throw Exception("未知的配置键: $key");
  }

  /// 设置配置
  /// ```dart
  /// ConfigService configService = Get.find();
  /// configService[ConfigService.AUTO_PLAY_KEY] = true;
  /// ```
  void operator []=(String key, dynamic value) {
    setSetting(key, value);
  }

  void updateTranslationLanguage(Sort sort) {
    _currentTranslationSort.value = sort;
    storage.writeData(_TRANSLATION_LANGUAGE, sort.extData);
  }
}
