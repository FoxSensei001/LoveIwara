import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/my_app.dart' show buildThemeData, appLightTheme, appDarkTheme, appThemeMode;
import 'package:i_iwara/common/constants.dart';
import '../models/theme_mode.model.dart';

class ThemeService extends GetxService {
  final _themeMode = AppThemeMode.system.obs;
  final _useDynamicColor = true.obs;
  final _usePresetColor = true.obs; // 是否使用预设颜色
  final _currentPresetIndex = 0.obs; // 当前预设颜色索引
  final _currentCustomHex = ''.obs; // 当前自定义颜色
  final _customThemeColors = <String>[].obs;

  // 预设的主题色
  static const List<Color> presetColors = [
    Colors.blue,      // 蓝色
    Colors.purple,    // 紫色
    Colors.green,     // 绿色
    Colors.orange,    // 橙色
    Colors.pink,      // 粉色
    Colors.red,       // 红色
    Colors.cyan,      // 青色
    Colors.brown,     // 棕色
    Colors.teal,      // 蓝绿色
    Colors.indigo,    // 靛蓝色
    Colors.amber,     // 琥珀色
    Colors.deepPurple,// 深紫色
  ];

  ThemeService() {
    final configService = Get.find<ConfigService>();
    _useDynamicColor.value = configService[ConfigKey.USE_DYNAMIC_COLOR_KEY];
    _usePresetColor.value = configService[ConfigKey.USE_PRESET_COLOR_KEY];
    _currentPresetIndex.value = configService[ConfigKey.CURRENT_PRESET_INDEX_KEY];
    _currentCustomHex.value = configService[ConfigKey.CURRENT_CUSTOM_HEX_KEY];
    _customThemeColors.value = List<String>.from(configService[ConfigKey.CUSTOM_THEME_COLORS_KEY]);
  }

  bool get useDynamicColor => _useDynamicColor.value;
  bool get usePresetColor => _usePresetColor.value;
  int get currentPresetIndex => _currentPresetIndex.value;
  String get currentCustomHex => _currentCustomHex.value;
  List<String> get customThemeColors => _customThemeColors;
  AppThemeMode get themeMode => _themeMode.value;

  // 检查颜色是否被选中
  bool isColorSelected(Color color) {
    if (useDynamicColor) return false;
    if (!usePresetColor) return false;
    return currentPresetIndex == presetColors.indexOf(color);
  }

  bool isCustomColorSelected(String hex) {
    if (useDynamicColor) return false;
    if (usePresetColor) return false;
    return currentCustomHex.toUpperCase() == hex.toUpperCase();
  }

  // 设置预设颜色
  void setPresetColor(int index) {
    if (useDynamicColor) {
      return;
    }
    _usePresetColor.value = true;
    _currentPresetIndex.value = index;
    Get.find<ConfigService>()[ConfigKey.USE_PRESET_COLOR_KEY] = true;
    Get.find<ConfigService>()[ConfigKey.CURRENT_PRESET_INDEX_KEY] = index;
    CommonConstants.usePresetColor = true;
    CommonConstants.currentPresetIndex = index;
    _updateTheme();
  }

  // 设置自定义颜色
  void setCustomColor(String hex) {
    if (useDynamicColor) {
      return;
    }
    _usePresetColor.value = false;
    _currentCustomHex.value = hex;
    Get.find<ConfigService>()[ConfigKey.USE_PRESET_COLOR_KEY] = false;
    Get.find<ConfigService>()[ConfigKey.CURRENT_CUSTOM_HEX_KEY] = hex;
    CommonConstants.usePresetColor = false;
    CommonConstants.currentCustomHex = hex;
    _updateTheme();
  }

  void setUseDynamicColor(bool value) {
    _useDynamicColor.value = value;
    Get.find<ConfigService>()[ConfigKey.USE_DYNAMIC_COLOR_KEY] = value;
    CommonConstants.useDynamicColor = value;
    
    if (value && CommonConstants.dynamicLightColorScheme != null && CommonConstants.dynamicDarkColorScheme != null) {
      // 如果开启动态颜色且有可用的动态颜色方案，立即应用
      _updateTheme();
    } else if (!value) {
      // 如果关闭动态颜色，使用自定义颜色
      _updateTheme();
    }
  }

  void addCustomThemeColor(String hex) {
    if (useDynamicColor) {
      return;
    }
    if (!_customThemeColors.contains(hex)) {
      _customThemeColors.add(hex);
      Get.find<ConfigService>()[ConfigKey.CUSTOM_THEME_COLORS_KEY] = _customThemeColors.toList();
      CommonConstants.customThemeColors = _customThemeColors.toList();
      setCustomColor(hex);
    }
  }

  void removeCustomThemeColor(String hex) {
    if (hex.toUpperCase() == currentCustomHex.toUpperCase() && !usePresetColor) {
      // 如果删除的是当前选中的自定义颜色
      if (_customThemeColors.length > 1) {
        // 如果还有其他自定义颜色，选择第一个不是当前颜色的
        String newHex = _customThemeColors.firstWhere((h) => h.toUpperCase() != hex.toUpperCase());
        setCustomColor(newHex);
      } else {
        // 如果没有其他自定义颜色，回到预设颜色
        setPresetColor(0);
      }
    }
    
    _customThemeColors.remove(hex);
    Get.find<ConfigService>()[ConfigKey.CUSTOM_THEME_COLORS_KEY] = _customThemeColors.toList();
    CommonConstants.customThemeColors = _customThemeColors.toList();
  }
  
  void setThemeMode(AppThemeMode mode) {
    _themeMode.value = mode;
    Get.find<ConfigService>()[ConfigKey.THEME_MODE_KEY] = mode.index;
    CommonConstants.themeMode = mode.index;

    // 更新响应式 themeMode 变量
    appThemeMode.value = mode == AppThemeMode.system
        ? ThemeMode.system
        : mode == AppThemeMode.light
            ? ThemeMode.light
            : ThemeMode.dark;

    // 更新主题颜色
    _updateTheme();
  }

  void _updateTheme() {
    final bool systemIsLight = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
    ColorScheme colorScheme;

    if (_useDynamicColor.value &&
        CommonConstants.dynamicLightColorScheme != null &&
        CommonConstants.dynamicDarkColorScheme != null) {
      // 使用动态颜色
      colorScheme = _themeMode.value == AppThemeMode.light
          ? CommonConstants.dynamicLightColorScheme!
          : _themeMode.value == AppThemeMode.dark
              ? CommonConstants.dynamicDarkColorScheme!
              : systemIsLight
                  ? CommonConstants.dynamicLightColorScheme!
                  : CommonConstants.dynamicDarkColorScheme!;
    } else {
      // 使用自定义颜色
      final Color seedColor = getCurrentThemeColor();
      colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: _themeMode.value == AppThemeMode.light
            ? Brightness.light
            : _themeMode.value == AppThemeMode.dark
                ? Brightness.dark
                : systemIsLight
                    ? Brightness.light
                    : Brightness.dark,
      );
    }

    // 使用响应式变量代替 Get.changeTheme
    appLightTheme.value = buildThemeData(colorScheme: colorScheme);
  }

  Future<ThemeService> init() async {
    final savedThemeMode = Get.find<ConfigService>()[ConfigKey.THEME_MODE_KEY] ?? AppThemeMode.system.index;
    _themeMode.value = AppThemeMode.values[savedThemeMode];
    return this;
  }

  Color getCurrentThemeColor() {
    if (_usePresetColor.value) {
      return presetColors[_currentPresetIndex.value];
    } else {
      return Color(int.parse('0xFF${_currentCustomHex.value}'));
    }
  }
}