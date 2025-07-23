import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:sqlite3/common.dart';
import 'dart:convert';

class ConfigService extends GetxService {
  static const screenshotChannel = MethodChannel('i_iwara/screenshot');

  // 修改初始化方式
  final settings = <ConfigKey, Rx<dynamic>>{};

  late final CommonDatabase _db;

  final Rx<Sort> _currentTranslationSort = CommonConstants.translationSorts.first.obs;
  Sort get currentTranslationSort => _currentTranslationSort.value;
  String get currentTranslationLanguage => currentTranslationSort.extData;

  // 新增目标语言相关字段
  late final Rx<Sort> _currentTargetLanguageSort; // 当前翻译目标语言
  Sort get currentTargetLanguageSort => _currentTargetLanguageSort.value;
  String get currentTargetLanguage => currentTargetLanguageSort.extData;

  Future<ConfigService> init() async {
    // 初始化 settings Map
    for (final key in ConfigKey.values) {
      settings[key] = Rx<dynamic>(key.defaultValue);
    }

    _db = DatabaseService().database;
    await _loadSettings();

    // 检查隐私模式（仅在安卓下执行）
    if (settings[ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE]!.value == true && GetPlatform.isAndroid) {
      await screenshotChannel.invokeMethod('preventScreenshot');
    }

    // 初始化翻译语言
    String savedLanguage = settings[ConfigKey.DEFAULT_LANGUAGE_KEY]!.value;
    _currentTranslationSort.value = CommonConstants.translationSorts.firstWhere(
      (sort) => sort.extData == savedLanguage,
      orElse: () => CommonConstants.translationSorts.first,
    );

    // 如果 _currentTranslationSort 的 extData 和 savedLanguage 不一致，则更新 savedLanguage
    if (_currentTranslationSort.value.extData != savedLanguage) {
      savedLanguage = _currentTranslationSort.value.extData;
      await _saveSetting(ConfigKey.DEFAULT_LANGUAGE_KEY, savedLanguage);
    }

    // 初始化目标翻译语言（处理方式与源语言相同）
    String savedTargetLanguage = settings[ConfigKey.USER_TARGET_LANGUAGE_KEY]!.value;
    _currentTargetLanguageSort = Rx<Sort>(CommonConstants.translationSorts.firstWhere(
      (sort) => sort.extData == savedTargetLanguage,
      orElse: () => CommonConstants.translationSorts.firstWhere(
        (sort) => sort.extData == ConfigKey.USER_TARGET_LANGUAGE_KEY.defaultValue
      ),
    ));

    // 同步目标语言设置到数据库（如果不一致）
    if (_currentTargetLanguageSort.value.extData != savedTargetLanguage) {
      savedTargetLanguage = _currentTargetLanguageSort.value.extData;
      await _saveSetting(ConfigKey.USER_TARGET_LANGUAGE_KEY, savedTargetLanguage);
    }

    // 初始化其他配置
    CommonConstants.themeMode = settings[ConfigKey.THEME_MODE_KEY]!.value;
    CommonConstants.useDynamicColor = settings[ConfigKey.USE_DYNAMIC_COLOR_KEY]!.value;
    CommonConstants.customThemeColors = List<String>.from(settings[ConfigKey.CUSTOM_THEME_COLORS_KEY]!.value);
    CommonConstants.usePresetColor = settings[ConfigKey.USE_PRESET_COLOR_KEY]!.value;
    CommonConstants.currentPresetIndex = settings[ConfigKey.CURRENT_PRESET_INDEX_KEY]!.value;
    CommonConstants.currentCustomHex = settings[ConfigKey.CURRENT_CUSTOM_HEX_KEY]!.value;
    CommonConstants.enableHistory = settings[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS]!.value;
    CommonConstants.enableVibration = settings[ConfigKey.ENABLE_VIBRATION]!.value;
    CommonConstants.isPaginated = settings[ConfigKey.DEFAULT_PAGINATION_MODE]!.value;
    // 更新日志相关常量
    CommonConstants.maxLogDatabaseSize = settings[ConfigKey.MAX_LOG_DATABASE_SIZE]!.value;
    CommonConstants.enableLogPersistence = settings[ConfigKey.ENABLE_LOG_PERSISTENCE]!.value;
    return this;
  }

  // 从数据库加载配置，若不存在则写入默认值
  Future<void> _loadSettings() async {
    for (final key in ConfigKey.values) {
      final result = _db.select('SELECT value FROM app_config WHERE key = ?', [key.key]);
      if (result.isNotEmpty) {
        final storedValue = result.first['value'] as String;
        dynamic parsedValue;
        final defaultVal = key.defaultValue;
        if (defaultVal is bool) {
          parsedValue = storedValue.toLowerCase() == 'true';
        } else if (defaultVal is int) {
          parsedValue = int.tryParse(storedValue) ?? defaultVal;
        } else if (defaultVal is double) {
          parsedValue = double.tryParse(storedValue) ?? defaultVal;
        } else if (defaultVal is List) {
          parsedValue = jsonDecode(storedValue);
        } else {
          parsedValue = storedValue;
        }
        settings[key]!.value = parsedValue;
      } else {
        await _saveSetting(key, key.defaultValue);
        settings[key]!.value = key.defaultValue;
      }
    }
  }

  Future<void> _saveSetting(ConfigKey key, dynamic value) async {
    String valueStr = value is List ? jsonEncode(value) : value.toString();
    _db.execute('''
      INSERT OR REPLACE INTO app_config (key, value)
      VALUES (?, ?)
    ''', [key.key, valueStr]);
  }

  // 通过 setSetting 同步更新内存和数据库，同时处理隐私模式变更
  Future<void> setSetting(ConfigKey key, dynamic value, {bool save = true}) async {
    settings[key]!.value = value;
    if (save) {
      await _saveSetting(key, value);
    }
    if (GetPlatform.isAndroid && key == ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE) {
      if (value == true) {
        await screenshotChannel.invokeMethod('preventScreenshot');
      } else {
        await screenshotChannel.invokeMethod('allowScreenshot');
      }
    }
  }

  dynamic operator [](ConfigKey key) => settings[key]!.value;
  void operator []=(ConfigKey key, dynamic value) {
    setSetting(key, value, save: true);
  }
  
  void updateTranslationLanguage(Sort sort) {
    _currentTranslationSort.value = sort;
    setSetting(ConfigKey.DEFAULT_LANGUAGE_KEY, sort.extData);
  }

  // 新增目标语言更新方法
  void updateTargetLanguage(Sort sort) {
    _currentTargetLanguageSort.value = sort;
    setSetting(ConfigKey.USER_TARGET_LANGUAGE_KEY, sort.extData);
  }

  // 更新内存中的设置值，不立即保存到数据库
  void updateSetting(ConfigKey key, dynamic value) {
    settings[key]!.value = value;
  }

  // 将指定键的设置保存到持久化存储
  Future<void> saveSettingToStorage(ConfigKey key, dynamic value) async {
    await _saveSetting(key, value);
  }
}

enum ConfigKey {
  AUTO_PLAY_KEY,
  DEFAULT_BRIGHTNESS_KEY,
  LONG_PRESS_PLAYBACK_SPEED_KEY,
  FAST_FORWARD_SECONDS_KEY,
  REWIND_SECONDS_KEY,
  DEFAULT_QUALITY_KEY,
  REPEAT_KEY,
  VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO,
  BRIGHTNESS_KEY,
  KEEP_LAST_BRIGHTNESS_KEY,
  VOLUME_KEY,
  KEEP_LAST_VOLUME_KEY,
  USE_PROXY,
  PROXY_URL,
  RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN,
  ACTIVE_BACKGROUND_PRIVACY_MODE,
  DEFAULT_LANGUAGE_KEY,
  USER_TARGET_LANGUAGE_KEY,
  THEATER_MODE_KEY,
  REMOTE_REPO_RELEASE_URL,
  REMOTE_REPO_URL,
  SETTINGS_SELECTED_INDEX_KEY,
  REMOTE_REPO_UPDATE_LOGS_YAML_URL,
  IGNORED_VERSION,
  LAST_CHECK_UPDATE_TIME,
  AUTO_CHECK_UPDATE,
  RULES_AGREEMENT_KEY,
  AUTO_RECORD_HISTORY_KEY,
  SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY,
  DISABLE_FORUM_REPLY_QUOTE_KEY,
  THEME_MODE_KEY,
  USE_DYNAMIC_COLOR_KEY,
  USE_PRESET_COLOR_KEY,
  CURRENT_PRESET_INDEX_KEY,
  CURRENT_CUSTOM_HEX_KEY,
  CUSTOM_THEME_COLORS_KEY,
  RECORD_AND_RESTORE_VIDEO_PROGRESS,
  USE_AI_TRANSLATION,
  AI_TRANSLATION_BASE_URL,
  AI_TRANSLATION_MODEL,
  AI_TRANSLATION_API_KEY,
  AI_TRANSLATION_MAX_TOKENS,
  AI_TRANSLATION_TEMPERATURE,
  REMEMBER_ME_KEY,
  AI_TRANSLATION_PROMPT,
  AI_TRANSLATION_SUPPORTS_STREAMING,
  ENABLE_SIGNATURE_KEY,  // 是否启用小尾巴
  SIGNATURE_CONTENT_KEY, // 小尾巴内容
  ENABLE_VIBRATION, // 是否开启震动
  SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN, // 是否在工具栏隐藏时显示进度条
  SHOW_FOLLOW_TIP_COUNT, // 告诉用户关注功能的次数，默认两次
  DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE, // 默认是否保持刚进入视频页时工具栏常驻
  VIDEO_TOOLBAR_LOCK_BUTTON_POSITION, // 视频工具栏锁定按钮位置
  DEFAULT_PAGINATION_MODE, // 默认分页模式
  ENABLE_LOG_PERSISTENCE, // 是否持久化日志
  MAX_LOG_DATABASE_SIZE, // 日志数据库大小上限(字节)
  WINDOW_WIDTH, // 窗口宽度
  WINDOW_HEIGHT, // 窗口高度
  ENABLE_HARDWARE_ACCELERATION, // 是否开启硬件加速
}

extension ConfigKeyExtension on ConfigKey {
  String get key {
    switch (this) {
      case ConfigKey.AUTO_PLAY_KEY: return 'auto_play';
      case ConfigKey.DEFAULT_BRIGHTNESS_KEY: return 'default_brightness';
      case ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY: return 'long_press_playback_speed';
      case ConfigKey.FAST_FORWARD_SECONDS_KEY: return 'fast_forward_seconds';
      case ConfigKey.REWIND_SECONDS_KEY: return 'rewind_seconds';
      case ConfigKey.DEFAULT_QUALITY_KEY: return 'default_quality';
      case ConfigKey.REPEAT_KEY: return 'repeat';
      case ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO: return 'video_left_and_right_control_area_ratio';
      case ConfigKey.BRIGHTNESS_KEY: return 'brightness';
      case ConfigKey.KEEP_LAST_BRIGHTNESS_KEY: return 'keep_last_brightness';
      case ConfigKey.VOLUME_KEY: return 'volume';
      case ConfigKey.KEEP_LAST_VOLUME_KEY: return 'keep_last_volume';
      case ConfigKey.USE_PROXY: return 'use_proxy';
      case ConfigKey.PROXY_URL: return 'proxy_url';
      case ConfigKey.RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN: return 'render_vertical_video_in_vertical_screen';
      case ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE: return 'active_background_privacy_mode';
      case ConfigKey.DEFAULT_LANGUAGE_KEY: return 'default_language';
      case ConfigKey.THEATER_MODE_KEY: return 'theater_mode';
      case ConfigKey.REMOTE_REPO_RELEASE_URL: return 'remote_repo_release_url';
      case ConfigKey.REMOTE_REPO_URL: return 'remote_repo_url';
      case ConfigKey.SETTINGS_SELECTED_INDEX_KEY: return 'settings_selected_index';
      case ConfigKey.REMOTE_REPO_UPDATE_LOGS_YAML_URL: return 'remote_repo_update_logs_yaml_url';
      case ConfigKey.IGNORED_VERSION: return 'ignored_version';
      case ConfigKey.LAST_CHECK_UPDATE_TIME: return 'last_check_update_time';
      case ConfigKey.AUTO_CHECK_UPDATE: return 'auto_check_update';
      case ConfigKey.RULES_AGREEMENT_KEY: return 'rules_agreement';
      case ConfigKey.AUTO_RECORD_HISTORY_KEY: return 'auto_record_history';
      case ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY: return 'show_unprocessed_markdown_text';
      case ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY: return 'disable_forum_reply_quote';
      case ConfigKey.THEME_MODE_KEY: return 'current_theme_mode';
      case ConfigKey.USE_DYNAMIC_COLOR_KEY: return 'use_dynamic_color';
      case ConfigKey.USE_PRESET_COLOR_KEY: return 'use_preset_color';
      case ConfigKey.CURRENT_PRESET_INDEX_KEY: return 'current_preset_index';
      case ConfigKey.CURRENT_CUSTOM_HEX_KEY: return 'current_custom_hex';
      case ConfigKey.CUSTOM_THEME_COLORS_KEY: return 'custom_theme_colors';
      case ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS: return 'record_and_restore_video_progress';
      case ConfigKey.USE_AI_TRANSLATION: return 'use_ai_translation';
      case ConfigKey.AI_TRANSLATION_BASE_URL: return 'ai_translation_base_url';
      case ConfigKey.AI_TRANSLATION_MODEL: return 'ai_translation_model';
      case ConfigKey.AI_TRANSLATION_API_KEY: return 'ai_translation_api_key';
      case ConfigKey.AI_TRANSLATION_MAX_TOKENS: return 'ai_translation_max_tokens';
      case ConfigKey.AI_TRANSLATION_TEMPERATURE: return 'ai_translation_temperature';
      case ConfigKey.REMEMBER_ME_KEY: return 'remember_me';
      case ConfigKey.AI_TRANSLATION_PROMPT: return 'ai_translation_prompt';
      case ConfigKey.AI_TRANSLATION_SUPPORTS_STREAMING: return 'ai_translation_supports_streaming';
      case ConfigKey.USER_TARGET_LANGUAGE_KEY: return 'user_target_language';
      case ConfigKey.ENABLE_SIGNATURE_KEY: return 'enable_signature';
      case ConfigKey.SIGNATURE_CONTENT_KEY: return 'signature_content';
      case ConfigKey.ENABLE_VIBRATION: return 'enable_vibration';
      case ConfigKey.SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN: return 'show_video_progress_bottom_bar_when_toolbar_hidden';
      case ConfigKey.SHOW_FOLLOW_TIP_COUNT: return 'show_follow_tip_count';
      case ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE: return 'default_keep_video_toolbar_visable';
      case ConfigKey.VIDEO_TOOLBAR_LOCK_BUTTON_POSITION: return 'video_toolbar_lock_button_position';
      case ConfigKey.DEFAULT_PAGINATION_MODE: return 'default_pagination_mode';
      case ConfigKey.ENABLE_LOG_PERSISTENCE: return 'enable_log_persistence';
      case ConfigKey.MAX_LOG_DATABASE_SIZE: return 'max_log_database_size';
      case ConfigKey.WINDOW_WIDTH: return 'window_width';
      case ConfigKey.WINDOW_HEIGHT: return 'window_height';
      case ConfigKey.ENABLE_HARDWARE_ACCELERATION: return 'enable_hardware_acceleration';
    }
  }

  dynamic get defaultValue {
    switch (this) {
      case ConfigKey.AUTO_PLAY_KEY:
        return false;
      case ConfigKey.DEFAULT_BRIGHTNESS_KEY:
        return 0.5;
      case ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY:
        return 2.0;
      case ConfigKey.FAST_FORWARD_SECONDS_KEY:
        return 10;
      case ConfigKey.REWIND_SECONDS_KEY:
        return 10;
      case ConfigKey.DEFAULT_QUALITY_KEY:
        return '360';
      case ConfigKey.REPEAT_KEY:
        return false;
      case ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO:
        return 0.2;
      case ConfigKey.BRIGHTNESS_KEY:
        return 0.5;
      case ConfigKey.KEEP_LAST_BRIGHTNESS_KEY:
        return true;
      case ConfigKey.VOLUME_KEY:
        return 0.4;
      case ConfigKey.KEEP_LAST_VOLUME_KEY:
        return false;
      case ConfigKey.USE_PROXY:
        return false;
      case ConfigKey.PROXY_URL:
        return '';
      case ConfigKey.RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN:
        return true;
      case ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE:
        return false;
      case ConfigKey.DEFAULT_LANGUAGE_KEY:
        return 'zh-CN';
      case ConfigKey.USER_TARGET_LANGUAGE_KEY:
        return 'en-US';
      case ConfigKey.THEATER_MODE_KEY:
        return false;
      case ConfigKey.REMOTE_REPO_RELEASE_URL:
        return 'https://github.com/FoxSensei001/i_iwara/releases';
      case ConfigKey.REMOTE_REPO_URL:
        return 'https://github.com/FoxSensei001/i_iwara';
      case ConfigKey.SETTINGS_SELECTED_INDEX_KEY:
        return 0;
      case ConfigKey.REMOTE_REPO_UPDATE_LOGS_YAML_URL:
        return 'https://raw.githubusercontent.com/FoxSensei001/i_iwara/master/update_logs.yaml';
      case ConfigKey.IGNORED_VERSION:
        return '';
      case ConfigKey.LAST_CHECK_UPDATE_TIME:
        return 0;
      case ConfigKey.AUTO_CHECK_UPDATE:
        return true;
      case ConfigKey.RULES_AGREEMENT_KEY:
        return false;
      case ConfigKey.AUTO_RECORD_HISTORY_KEY:
        return true;
      case ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY:
        return false;
      case ConfigKey.DISABLE_FORUM_REPLY_QUOTE_KEY:
        return false;
      case ConfigKey.THEME_MODE_KEY:
        return 0;
      case ConfigKey.USE_DYNAMIC_COLOR_KEY:
        return true;
      case ConfigKey.USE_PRESET_COLOR_KEY:
        return true;
      case ConfigKey.CURRENT_PRESET_INDEX_KEY:
        return 0;
      case ConfigKey.CURRENT_CUSTOM_HEX_KEY:
        return '';
      case ConfigKey.CUSTOM_THEME_COLORS_KEY:
        return <String>[];
      case ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS:
        return true;
      case ConfigKey.USE_AI_TRANSLATION:
        return false;
      case ConfigKey.AI_TRANSLATION_BASE_URL:
        return '';
      case ConfigKey.AI_TRANSLATION_MODEL:
        return '';
      case ConfigKey.AI_TRANSLATION_API_KEY:
        return '';
      case ConfigKey.AI_TRANSLATION_MAX_TOKENS:
        return 1024;
      case ConfigKey.AI_TRANSLATION_TEMPERATURE:
        return 0.3;
      case ConfigKey.REMEMBER_ME_KEY:
        return false;
      case ConfigKey.AI_TRANSLATION_PROMPT:
        return "You are a translation expert. Translate from the input language to ${CommonConstants.defaultLanguagePlaceholder}. Provide the translation result directly without any explanation and keep the original format. Do not translate if the target language is the same as the source language. Additionally, if the content contains illegal or NSFW elements, sensitive words or sentences within it should be replaced.";
      case ConfigKey.AI_TRANSLATION_SUPPORTS_STREAMING:
        return true;
      case ConfigKey.ENABLE_SIGNATURE_KEY:
        return false;
      case ConfigKey.SIGNATURE_CONTENT_KEY:
        return '\n\n---\nSent from ${CommonConstants.applicationNickname}';
      case ConfigKey.ENABLE_VIBRATION:
        return true;
      case ConfigKey.SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN:
        return true;
      case ConfigKey.SHOW_FOLLOW_TIP_COUNT:
        return 2;
      case ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE:
        return true;
      case ConfigKey.VIDEO_TOOLBAR_LOCK_BUTTON_POSITION:
        return 2;
      case ConfigKey.DEFAULT_PAGINATION_MODE:
        return false;
      case ConfigKey.ENABLE_LOG_PERSISTENCE:
        return false;
      case ConfigKey.MAX_LOG_DATABASE_SIZE:
        return 1024 * 1024 * 1024; // 1GB
      case ConfigKey.WINDOW_WIDTH:
        return 800.0;
      case ConfigKey.WINDOW_HEIGHT:
        return 600.0;
      case ConfigKey.ENABLE_HARDWARE_ACCELERATION:
        return true;
      default:
        throw Exception("Unknown ConfigKey: $this");
    }
  }
}
