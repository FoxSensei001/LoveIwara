// ignore_for_file: constant_identifier_names

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
      await saveSetting(ConfigKey.DEFAULT_LANGUAGE_KEY, savedLanguage);
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
      await saveSetting(ConfigKey.USER_TARGET_LANGUAGE_KEY, savedTargetLanguage);
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
        } else if (defaultVal is Map) {
          // 处理 Map 类型的反序列化
          try {
            final decoded = jsonDecode(storedValue);
            if (decoded is Map) {
              // 根据默认值的类型进行类型转换
              if (defaultVal is Map<String, int>) {
                parsedValue = Map<String, int>.from(decoded.map((key, value) => 
                  MapEntry(key.toString(), value is int ? value : int.tryParse(value.toString()) ?? 0)));
              } else if (defaultVal is Map<String, String>) {
                parsedValue = Map<String, String>.from(decoded.map((key, value) => 
                  MapEntry(key.toString(), value.toString())));
              } else {
                parsedValue = Map<String, dynamic>.from(decoded);
              }
            } else {
              parsedValue = defaultVal;
            }
          } catch (e) {
            parsedValue = defaultVal;
          }
        } else {
          parsedValue = storedValue;
        }
        settings[key]!.value = parsedValue;
      } else {
        await saveSetting(key, key.defaultValue);
        settings[key]!.value = key.defaultValue;
      }
    }
  }

  Future<void> saveSetting(ConfigKey key, dynamic value) async {
    String valueStr;
    if (value is List || value is Map) {
      valueStr = jsonEncode(value);
    } else {
      valueStr = value.toString();
    }
    _db.execute('''
      INSERT OR REPLACE INTO app_config (key, value)
      VALUES (?, ?)
    ''', [key.key, valueStr]);
  }

  // 通过 setSetting 同步更新内存和数据库，同时处理隐私模式变更
  Future<void> setSetting(ConfigKey key, dynamic value, {bool save = true}) async {
    settings[key]!.value = value;
    if (save) {
      await saveSetting(key, value);
    }
    if (GetPlatform.isAndroid && key == ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE) {
      if (value == true) {
        await screenshotChannel.invokeMethod('preventScreenshot');
      } else {
        await screenshotChannel.invokeMethod('allowScreenshot');
      }
    }

    // 处理翻译方式互斥逻辑
    if (value == true) {
      if (key == ConfigKey.USE_AI_TRANSLATION) {
        // 启用AI翻译时，禁用DeepLX翻译
        if (settings[ConfigKey.USE_DEEPLX_TRANSLATION]!.value == true) {
          settings[ConfigKey.USE_DEEPLX_TRANSLATION]!.value = false;
          if (save) {
            await saveSetting(ConfigKey.USE_DEEPLX_TRANSLATION, false);
          }
        }
      } else if (key == ConfigKey.USE_DEEPLX_TRANSLATION) {
        // 启用DeepLX翻译时，禁用AI翻译
        if (settings[ConfigKey.USE_AI_TRANSLATION]!.value == true) {
          settings[ConfigKey.USE_AI_TRANSLATION]!.value = false;
          if (save) {
            await saveSetting(ConfigKey.USE_AI_TRANSLATION, false);
          }
        }
      }
    }
  }

  dynamic operator [](ConfigKey key) => settings[key]!.value;
  void operator []=(ConfigKey key, dynamic value) {
    setSetting(key, value, save: true);
  }

  void updateApplicationLocale(String localeStr) {
    setSetting(ConfigKey.APPLICATION_LOCALE, localeStr);
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
    await saveSetting(key, value);
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
  // DeepLX 翻译相关配置
  USE_DEEPLX_TRANSLATION,
  DEEPLX_BASE_URL,
  DEEPLX_API_KEY,
  DEEPLX_ENDPOINT_TYPE, // Free, Pro, Official
  DEEPLX_DL_SESSION, // Pro 模式需要的 dl_session
  ENABLE_SIGNATURE_KEY,  // 是否启用小尾巴
  SIGNATURE_CONTENT_KEY, // 小尾巴内容
  ENABLE_VIBRATION, // 是否开启震动
  SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN, // 是否在工具栏隐藏时显示进度条
  SHOW_FOLLOW_TIP_COUNT, // 告诉用户关注功能的次数，默认两次
  DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE, // 默认是否保持刚进入视频页时工具栏常驻
  VIDEO_TOOLBAR_LOCK_BUTTON_POSITION, // 视频工具栏锁定按钮位置
  DEFAULT_PAGINATION_MODE, // 默认分页模式
  WINDOW_WIDTH, // 窗口宽度
  WINDOW_HEIGHT, // 窗口高度
  WINDOW_X, // 窗口X坐标
  WINDOW_Y, // 窗口Y坐标
  APPLICATION_LOCALE, // 应用语言
  // 播放器手势控制开关
  ENABLE_LEFT_DOUBLE_TAP_REWIND, // 左侧双击后退
  ENABLE_RIGHT_DOUBLE_TAP_FAST_FORWARD, // 右侧双击快进
  ENABLE_DOUBLE_TAP_PAUSE, // 双击暂停
  ENABLE_LEFT_VERTICAL_SWIPE_BRIGHTNESS, // 左侧上下滑动调整亮度
  ENABLE_RIGHT_VERTICAL_SWIPE_VOLUME, // 右侧上下滑动调整音量
  ENABLE_LONG_PRESS_FAST_FORWARD, // 长按快进
  ENABLE_MOUSE_HOVER_SHOW_TOOLBAR, // 鼠标悬浮显示工具栏
  ENABLE_HORIZONTAL_DRAG_SEEK, // 横向滑动调整进度
  // 下载设置
  CUSTOM_DOWNLOAD_PATH, // 自定义下载路径
  ENABLE_CUSTOM_DOWNLOAD_PATH, // 启用自定义下载路径
  VIDEO_FILENAME_TEMPLATE, // 视频文件命名模板
  GALLERY_FILENAME_TEMPLATE, // 图库文件命名模板
  IMAGE_FILENAME_TEMPLATE, // 单张图片文件命名模板
  // 音视频配置
  EXPAND_BUFFER, // 扩大缓冲区
  VIDEO_SYNC, // 视频同步
  HARDWARE_DECODING, // 硬解模式
  ENABLE_HARDWARE_ACCELERATION, // 启用硬件加速
  USE_OPENSLES, // 使用OpenSLES音频输出
  DEFAULT_EMOJI_SIZE, // 默认表情包大小
  COMMENT_SORT_ORDER, // 评论排序方式，true为倒序，false为正序
  // 布局相关配置
  LAYOUT_MODE, // 布局模式：auto(自动), manual(手动)
  MANUAL_COLUMNS_COUNT, // 手动设置的列数
  LAYOUT_BREAKPOINTS, // 布局断点配置
  // 导航相关配置
  NAVIGATION_ORDER, // 导航项排序
  // 全屏方向配置
  FULLSCREEN_ORIENTATION, // 进入全屏后的屏幕方向
  // 首次设置相关
  FIRST_TIME_SETUP_COMPLETED, // 首次设置是否已完成
  // Anime4K 预设配置
  ANIME4K_PRESET_ID, // 当前选中的 Anime4K 预设 ID，空字符串表示禁用
  // 教程指导相关配置
  SHOW_SUBSCRIPTION_TUTORIAL, // 是否显示订阅页面教程指导
  // 下载相关配置
  LAST_DOWNLOAD_QUALITY, // 上次下载的视频清晰度
  // CDN 内容分发策略
  CDN_DISTRIBUTION_STRATEGY, // 内容分发策略: no_change, auto, special
  CDN_SPECIAL_SERVER, // 指定的分发服务器子域名
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
      case ConfigKey.USE_DEEPLX_TRANSLATION: return 'use_deeplx_translation';
      case ConfigKey.DEEPLX_BASE_URL: return 'deeplx_base_url';
      case ConfigKey.DEEPLX_API_KEY: return 'deeplx_api_key';
      case ConfigKey.DEEPLX_ENDPOINT_TYPE: return 'deeplx_endpoint_type';
      case ConfigKey.DEEPLX_DL_SESSION: return 'deeplx_dl_session';
      case ConfigKey.USER_TARGET_LANGUAGE_KEY: return 'user_target_language';
      case ConfigKey.ENABLE_SIGNATURE_KEY: return 'enable_signature';
      case ConfigKey.SIGNATURE_CONTENT_KEY: return 'signature_content';
      case ConfigKey.ENABLE_VIBRATION: return 'enable_vibration';
      case ConfigKey.SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN: return 'show_video_progress_bottom_bar_when_toolbar_hidden';
      case ConfigKey.SHOW_FOLLOW_TIP_COUNT: return 'show_follow_tip_count';
      case ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE: return 'default_keep_video_toolbar_visable';
      case ConfigKey.VIDEO_TOOLBAR_LOCK_BUTTON_POSITION: return 'video_toolbar_lock_button_position';
      case ConfigKey.DEFAULT_PAGINATION_MODE: return 'default_pagination_mode';
      case ConfigKey.WINDOW_WIDTH: return 'window_width';
      case ConfigKey.WINDOW_HEIGHT: return 'window_height';
      case ConfigKey.WINDOW_X: return 'window_x';
      case ConfigKey.WINDOW_Y: return 'window_y';
      case ConfigKey.APPLICATION_LOCALE: return 'application_locale';
      case ConfigKey.ENABLE_LEFT_DOUBLE_TAP_REWIND: return 'enable_left_double_tap_rewind';
      case ConfigKey.ENABLE_RIGHT_DOUBLE_TAP_FAST_FORWARD: return 'enable_right_double_tap_fast_forward';
      case ConfigKey.ENABLE_DOUBLE_TAP_PAUSE: return 'enable_double_tap_pause';
      case ConfigKey.ENABLE_LEFT_VERTICAL_SWIPE_BRIGHTNESS: return 'enable_left_vertical_swipe_brightness';
      case ConfigKey.ENABLE_RIGHT_VERTICAL_SWIPE_VOLUME: return 'enable_right_vertical_swipe_volume';
      case ConfigKey.ENABLE_LONG_PRESS_FAST_FORWARD: return 'enable_long_press_fast_forward';
      case ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR: return 'enable_mouse_hover_show_toolbar';
      case ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK: return 'enable_horizontal_drag_seek';
      case ConfigKey.CUSTOM_DOWNLOAD_PATH: return 'custom_download_path';
      case ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH: return 'enable_custom_download_path';
      case ConfigKey.VIDEO_FILENAME_TEMPLATE: return 'video_filename_template';
      case ConfigKey.GALLERY_FILENAME_TEMPLATE: return 'gallery_filename_template';
      case ConfigKey.IMAGE_FILENAME_TEMPLATE: return 'image_filename_template';
      case ConfigKey.EXPAND_BUFFER: return 'expand_buffer';
      case ConfigKey.VIDEO_SYNC: return 'video_sync';
      case ConfigKey.HARDWARE_DECODING: return 'hardware_decoding';
      case ConfigKey.ENABLE_HARDWARE_ACCELERATION: return 'enable_hardware_acceleration';
      case ConfigKey.USE_OPENSLES: return 'use_opensles';
      case ConfigKey.DEFAULT_EMOJI_SIZE: return 'default_emoji_size';
      case ConfigKey.COMMENT_SORT_ORDER: return 'comment_sort_order';
      case ConfigKey.LAYOUT_MODE: return 'layout_mode';
      case ConfigKey.MANUAL_COLUMNS_COUNT: return 'manual_columns_count';
      case ConfigKey.LAYOUT_BREAKPOINTS: return 'layout_breakpoints';
      case ConfigKey.NAVIGATION_ORDER: return 'navigation_order';
      case ConfigKey.FULLSCREEN_ORIENTATION: return 'fullscreen_orientation';
      case ConfigKey.FIRST_TIME_SETUP_COMPLETED: return 'first_time_setup_completed';
      case ConfigKey.ANIME4K_PRESET_ID: return 'anime4k_preset_id';
      case ConfigKey.SHOW_SUBSCRIPTION_TUTORIAL: return 'show_subscription_tutorial';
      case ConfigKey.LAST_DOWNLOAD_QUALITY: return 'last_download_quality';
      case ConfigKey.CDN_DISTRIBUTION_STRATEGY: return 'cdn_distribution_strategy';
      case ConfigKey.CDN_SPECIAL_SERVER: return 'cdn_special_server';
    }
  }

  dynamic get defaultValue {
    switch (this) {
      case ConfigKey.AUTO_PLAY_KEY:
        return false;
      case ConfigKey.DEFAULT_BRIGHTNESS_KEY:
        return 0.5;
      case ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY:
        return 1.75;
      case ConfigKey.FAST_FORWARD_SECONDS_KEY:
        return 10;
      case ConfigKey.REWIND_SECONDS_KEY:
        return 10;
      case ConfigKey.DEFAULT_QUALITY_KEY:
        return '540';
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
        return true;
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
      case ConfigKey.USE_DEEPLX_TRANSLATION:
        return false;
      case ConfigKey.DEEPLX_BASE_URL:
        return '';
      case ConfigKey.DEEPLX_API_KEY:
        return '';
      case ConfigKey.DEEPLX_ENDPOINT_TYPE:
        return 'Free'; // Free, Pro, Official
      case ConfigKey.DEEPLX_DL_SESSION:
        return '';
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
      case ConfigKey.WINDOW_WIDTH:
        return 800.0;
      case ConfigKey.WINDOW_HEIGHT:
        return 600.0;
      case ConfigKey.WINDOW_X:
        return -1.0;
      case ConfigKey.WINDOW_Y:
        return -1.0;
      case ConfigKey.APPLICATION_LOCALE:
        return 'system';
      case ConfigKey.ENABLE_LEFT_DOUBLE_TAP_REWIND:
        return true;
      case ConfigKey.ENABLE_RIGHT_DOUBLE_TAP_FAST_FORWARD:
        return true;
      case ConfigKey.ENABLE_DOUBLE_TAP_PAUSE:
        return true;
      case ConfigKey.ENABLE_LEFT_VERTICAL_SWIPE_BRIGHTNESS:
        return true;
      case ConfigKey.ENABLE_RIGHT_VERTICAL_SWIPE_VOLUME:
        return true;
      case ConfigKey.ENABLE_LONG_PRESS_FAST_FORWARD:
        return true;
      case ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR:
        return true;
      case ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK:
        return true; // 默认开启横向滑动调整进度
      case ConfigKey.CUSTOM_DOWNLOAD_PATH:
        return '';
      case ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH:
        return false;
      case ConfigKey.VIDEO_FILENAME_TEMPLATE:
        return '%title_%quality';
      case ConfigKey.GALLERY_FILENAME_TEMPLATE:
        return '%title_%id';
      case ConfigKey.IMAGE_FILENAME_TEMPLATE:
        return '%title_%filename';
      case ConfigKey.EXPAND_BUFFER:
        return false;
      case ConfigKey.VIDEO_SYNC:
        return 'display-resample';
      case ConfigKey.HARDWARE_DECODING:
        return 'auto-safe';
      case ConfigKey.ENABLE_HARDWARE_ACCELERATION:
        return true;
      case ConfigKey.USE_OPENSLES:
        return true;
      case ConfigKey.DEFAULT_EMOJI_SIZE:
        return 'mid-i'; // 默认使用中等大小
      case ConfigKey.COMMENT_SORT_ORDER:
        return true; // 默认倒序
      case ConfigKey.LAYOUT_MODE:
        return 'auto'; // 默认自动模式
      case ConfigKey.MANUAL_COLUMNS_COUNT:
        return 3; // 默认3列
      case ConfigKey.LAYOUT_BREAKPOINTS:
        return <String, int>{
          '600': 2,
          '900': 3,
          '1200': 4,
          '1500': 5,
          '9999': 6,
        }; // 默认断点配置
      case ConfigKey.NAVIGATION_ORDER:
        return <String>['video', 'gallery', 'subscription', 'forum']; // 默认导航顺序
      case ConfigKey.FULLSCREEN_ORIENTATION:
        return 'landscape_left'; // 默认左侧横屏
      case ConfigKey.FIRST_TIME_SETUP_COMPLETED:
        return false;
      case ConfigKey.ANIME4K_PRESET_ID:
        return ''; // 默认禁用 Anime4K（空字符串表示禁用）
      case ConfigKey.SHOW_SUBSCRIPTION_TUTORIAL:
        return true; // 默认显示订阅页面教程指导
      case ConfigKey.LAST_DOWNLOAD_QUALITY:
        return 'source'; // 默认清晰度为 source
      case ConfigKey.CDN_DISTRIBUTION_STRATEGY:
        return 'auto'; // 默认不修改
      case ConfigKey.CDN_SPECIAL_SERVER:
        return ''; // 默认空
    }
  }
}
