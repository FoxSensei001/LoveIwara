import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class ConfigService extends GetxService {
  late final StorageService storage;
  static const screenshotChannel = MethodChannel('i_iwara/screenshot');

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
      'active_background_privacy_mode'; // 激活隐私模式
  static const String DEFAULT_LANGUAGE_KEY = 'default_language'; // 默认语言
  static const String THEATER_MODE_KEY = 'theater_mode'; // 剧院模式
  static const String _TRANSLATION_LANGUAGE = 'translation_language';
  static const String REMOTE_REPO_RELEASE_URL = 'remote_repo_release_url'; // 远程仓库的 release 地址
  static const String REMOTE_REPO_URL = 'remote_repo_url'; // 远程仓库的 url
  static const String SETTINGS_SELECTED_INDEX_KEY = 'settings_selected_index';
  static const String REMOTE_REPO_UPDATE_LOGS_YAML_URL = 'remote_repo_update_logs_yaml_url';
  static const String IGNORED_VERSION = 'ignored_version';
  static const String LAST_CHECK_UPDATE_TIME = 'last_check_update_time';
  static const String AUTO_CHECK_UPDATE = 'auto_check_update';
  static const String RULES_AGREEMENT_KEY = 'rules_agreement'; // 规则同意
  static const String AUTO_RECORD_HISTORY_KEY = 'auto_record_history'; // 自动记录历史记录
  static const String SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY = 'show_unprocessed_markdown_text'; // 显示未处理的markdown文本
  static const String DISABLE_FORUM_REPLY_QUOTE_KEY = 'disable_forum_reply_quote'; // 禁用论坛回复引用

  static const String THEME_MODE_KEY = 'current_theme_mode'; // 当前主题模式 0 跟随系统 1 亮色 2 暗色
  static const String USE_DYNAMIC_COLOR_KEY = 'use_dynamic_color'; // 是否使用动态颜色
  static const String USE_PRESET_COLOR_KEY = 'use_preset_color'; // 是否使用预设颜色
  static const String CURRENT_PRESET_INDEX_KEY = 'current_preset_index'; // 当前预设颜色索引
  static const String CURRENT_CUSTOM_HEX_KEY = 'current_custom_hex'; // 当前自定义颜色
  static const String CUSTOM_THEME_COLORS_KEY = 'custom_theme_colors'; // 用户自定义的主题颜色列表

  static const String RECORD_AND_RESTORE_VIDEO_PROGRESS = 'record_and_restore_video_progress'; // 播放器初始化时恢复播放进度 [同时也决定了是否向数据库中写入播放进度]
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
    THEATER_MODE_KEY: true.obs, // 默认开启剧院模式
    REMOTE_REPO_RELEASE_URL: 'https://github.com/FoxSensei001/i_iwara/releases'.obs,
    REMOTE_REPO_URL: 'https://github.com/FoxSensei001/i_iwara'.obs,
    SETTINGS_SELECTED_INDEX_KEY: 0.obs,
    REMOTE_REPO_UPDATE_LOGS_YAML_URL: 'https://raw.githubusercontent.com/FoxSensei001/i_iwara/master/update_logs.yaml'.obs,
    IGNORED_VERSION: ''.obs,
    LAST_CHECK_UPDATE_TIME: 0.obs,
    AUTO_CHECK_UPDATE: true.obs,
    RULES_AGREEMENT_KEY: false.obs,
    AUTO_RECORD_HISTORY_KEY: true.obs,
    SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY: false.obs,
    DISABLE_FORUM_REPLY_QUOTE_KEY: false.obs,

    THEME_MODE_KEY: 0.obs,
    USE_DYNAMIC_COLOR_KEY: true.obs,
    USE_PRESET_COLOR_KEY: true.obs,
    CURRENT_PRESET_INDEX_KEY: 0.obs,
    CURRENT_CUSTOM_HEX_KEY: ''.obs,
    CUSTOM_THEME_COLORS_KEY: <String>[].obs,

    RECORD_AND_RESTORE_VIDEO_PROGRESS: true.obs,
  }.obs;

  late final Rx<Sort> _currentTranslationSort;

  Sort get currentTranslationSort => _currentTranslationSort.value;
  String get currentTranslationLanguage => currentTranslationSort.extData;

  // 初始化配置
  Future<ConfigService> init() async {
    storage = StorageService();
    await _loadSettings();

    // 检查是否需要激活隐私模式
    if (settings[ACTIVE_BACKGROUND_PRIVACY_MODE]!.value == true && GetPlatform.isAndroid) {
      await screenshotChannel.invokeMethod('preventScreenshot');
    }

    // [翻译] 单独初始化翻译语言
    final savedLanguage = storage.readData(_TRANSLATION_LANGUAGE) ?? settings[DEFAULT_LANGUAGE_KEY]!.value;
    _currentTranslationSort = (CommonConstants.translationSorts.firstWhere(
      (sort) => sort.extData == savedLanguage,
      orElse: () => CommonConstants.translationSorts.first,
    )).obs;

    // [历史记录] 单独初始化是否记录历史记录
    final savedAutoRecordHistory = storage.readData(AUTO_RECORD_HISTORY_KEY) ?? settings[AUTO_RECORD_HISTORY_KEY]!.value;
    CommonConstants.enableHistory = savedAutoRecordHistory;

    // [主题] 单独初始化主题模式
    final savedThemeMode = storage.readData(THEME_MODE_KEY) ?? settings[THEME_MODE_KEY]!.value;
    CommonConstants.themeMode = savedThemeMode;

    // [主题] 单独初始化是否使用动态颜色
    final savedUseDynamicColor = storage.readData(USE_DYNAMIC_COLOR_KEY) ?? settings[USE_DYNAMIC_COLOR_KEY]!.value;
    CommonConstants.useDynamicColor = savedUseDynamicColor;

    // [主题] 单独初始化自定义主题颜色
    final savedCustomThemeColors = storage.readData(CUSTOM_THEME_COLORS_KEY);
    if (savedCustomThemeColors != null) {
      final List<String> colorsList = (savedCustomThemeColors as List<dynamic>).map((e) => e.toString()).toList();
      settings[CUSTOM_THEME_COLORS_KEY]!.value = colorsList;
      CommonConstants.customThemeColors = colorsList;
    } else {
      CommonConstants.customThemeColors = [];
    }

    // [主题] 单独初始化是否使用预设颜色
    final savedUsePresetColor = storage.readData(USE_PRESET_COLOR_KEY) ?? settings[USE_PRESET_COLOR_KEY]!.value;
    CommonConstants.usePresetColor = savedUsePresetColor;

    // [主题] 单独初始化预设颜色索引
    final savedCurrentPresetIndex = storage.readData(CURRENT_PRESET_INDEX_KEY) ?? settings[CURRENT_PRESET_INDEX_KEY]!.value;
    CommonConstants.currentPresetIndex = savedCurrentPresetIndex;

    // [主题] 单独初始化自定义颜色
    final savedCurrentCustomHex = storage.readData(CURRENT_CUSTOM_HEX_KEY) ?? settings[CURRENT_CUSTOM_HEX_KEY]!.value;
    CommonConstants.currentCustomHex = savedCurrentCustomHex;

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
  Future<void> setSetting(String key, dynamic value, {bool save = true}) async {
    if (settings.containsKey(key)) {
      settings[key]!.value = value;
      if (save) {
        await _saveSetting(key, value);
      }

      // 处理隐私模式的变更
      // 如果是安卓模式
      if (GetPlatform.isAndroid) {
        if (key == ACTIVE_BACKGROUND_PRIVACY_MODE) {
          if (value == true) {
            await screenshotChannel.invokeMethod('preventScreenshot');
          } else {
            await screenshotChannel.invokeMethod('allowScreenshot');
          }
        }
      }
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
