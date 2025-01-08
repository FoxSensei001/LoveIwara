import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import '../models/theme_mode.model.dart';
import 'package:dynamic_color/dynamic_color.dart';

class ThemeService extends GetxService {
  final _themeMode = AppThemeMode.system.obs;
  final _useDynamicColor = true.obs;

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
  ];

  ThemeService() {
    assert(
      presetColors.length >= AppThemeMode.values.length - AppThemeMode.preset1.index,
      '预设颜色的数量必须大于或等于 AppThemeMode 中预设主题的数量',
    );
  }

  AppThemeMode get themeMode => _themeMode.value;
  bool get useDynamicColor => _useDynamicColor.value;

  // 获取当前主题
  ThemeData getTheme(BuildContext context, {ColorScheme? dynamicLight, ColorScheme? dynamicDark}) {
    switch (_themeMode.value) {
      case AppThemeMode.system:
        final brightness = MediaQuery.platformBrightnessOf(context);
        if (brightness == Brightness.light) {
          return ThemeData(
            colorScheme: dynamicLight?.harmonized() ?? ColorScheme.fromSeed(seedColor: Colors.orange),
            useMaterial3: true,
          );
        } else {
          return _getDarkTheme(dynamicDark);
        }
      case AppThemeMode.light:
        return _getLightTheme(dynamicLight);
      case AppThemeMode.dark:
        return _getDarkTheme(dynamicDark);
      case AppThemeMode.preset1:
        return _getPresetTheme(presetColors[0]);
      case AppThemeMode.preset2:
        return _getPresetTheme(presetColors[1]);
      case AppThemeMode.preset3:
        return _getPresetTheme(presetColors[2]);
      case AppThemeMode.preset4:
        return _getPresetTheme(presetColors[3]);
      case AppThemeMode.preset5:
        return _getPresetTheme(presetColors[4]);
      case AppThemeMode.preset6:
        return _getPresetTheme(presetColors[5]);
      case AppThemeMode.preset7:
        return _getPresetTheme(presetColors[6]);
      case AppThemeMode.preset8:
        return _getPresetTheme(presetColors[7]);
      default:
        return _getLightTheme(dynamicLight);
    }
  }

  ThemeData _getLightTheme(ColorScheme? dynamicLight) {
    if (_useDynamicColor.value && dynamicLight != null) {
      return ThemeData(
        colorScheme: dynamicLight,
        useMaterial3: true,
      );
    }
    return ThemeData.light(useMaterial3: true);
  }

  ThemeData _getDarkTheme(ColorScheme? dynamicDark) {
    if (_useDynamicColor.value && dynamicDark != null) {
      return ThemeData(
        colorScheme: dynamicDark,
        useMaterial3: true,
      );
    }
    return ThemeData.dark(useMaterial3: true);
  }

  ThemeData _getPresetTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    );
  }

  void setThemeMode(AppThemeMode mode) {
    _themeMode.value = mode;
    Get.find<ConfigService>().setSetting(ConfigService.THEME_MODE_KEY, mode.index);

    // 使用 changeTheme 而不是 forceAppUpdate
    final newTheme = getTheme(Get.context!);
    Get.changeTheme(newTheme);
  }

  Future<ThemeService> init() async {
    final savedThemeMode = Get.find<ConfigService>()[ConfigService.THEME_MODE_KEY] ?? AppThemeMode.system.index;
    _themeMode.value = AppThemeMode.values[savedThemeMode];
    return this;
  }
}