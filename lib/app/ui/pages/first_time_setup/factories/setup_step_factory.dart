import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../models/setup_step.dart';
import '../widgets/welcome_step_widget.dart';
import '../widgets/basic_settings_step_widget.dart';
import '../widgets/network_settings_step_widget.dart';
import '../widgets/completion_step_widget.dart';
import '../widgets/theme_step_widget.dart';
import '../widgets/player_settings_step_widget.dart';

/// 设置步骤工厂类
class SetupStepFactory {
  /// 创建欢迎步骤
  static SetupStep createWelcomeStep() {
    return SetupStep(
      id: 'welcome',
      title: slang.t.firstTimeSetup.welcome.title,
      subtitle: slang.t.firstTimeSetup.welcome.subtitle,
      description: slang.t.firstTimeSetup.welcome.description,
      icon: Icons.celebration,
      builder: _buildWelcomeStep,
    );
  }

  /// 创建基础设置步骤
  static SetupStep createBasicSettingsStep() {
    return SetupStep(
      id: 'basic_settings',
      title: slang.t.firstTimeSetup.basic.title,
      subtitle: slang.t.firstTimeSetup.basic.subtitle,
      description: slang.t.firstTimeSetup.basic.description,
      icon: Icons.settings_suggest,
      builder: _buildBasicSettingsStep,
    );
  }

  /// 创建网络设置步骤（仅在桌面平台显示）
  static SetupStep createNetworkSettingsStep() {
    return SetupStep(
      id: 'network_settings',
      title: slang.t.firstTimeSetup.network.title,
      subtitle: slang.t.firstTimeSetup.network.subtitle,
      description: slang.t.firstTimeSetup.network.description,
      icon: Icons.network_check,
      showStatus: _shouldShowNetworkSettings, // 控制是否显示此步骤
      builder: _buildNetworkSettingsStep,
    );
  }

  /// 网络设置显示条件：仅在桌面平台显示
  static bool _shouldShowNetworkSettings() => GetPlatform.isDesktop;

  /// 创建主题设置步骤（示例：如何添加新步骤）
  static SetupStep createThemeStep() {
    return SetupStep(
      id: 'theme_settings',
      title: slang.t.firstTimeSetup.theme.title,
      subtitle: slang.t.firstTimeSetup.theme.subtitle,
      description: slang.t.firstTimeSetup.theme.description,
      icon: Icons.palette,
      showStatus: _shouldShowThemeSettings, // 可控制是否显示主题设置
      builder: _buildThemeStep,
    );
  }

  /// 创建播放器设置步骤
  static SetupStep createPlayerSettingsStep() {
    return SetupStep(
      id: 'player_settings',
      title: slang.t.firstTimeSetup.player.title,
      subtitle: slang.t.firstTimeSetup.player.subtitle,
      description: slang.t.firstTimeSetup.player.description,
      icon: Icons.play_circle,
      builder: _buildPlayerSettingsStep,
    );
  }

  /// 主题设置显示条件：默认显示，可以通过配置控制
  static bool _shouldShowThemeSettings() => true; // 暂时总是显示，可以根据需要修改

  /// 创建完成设置步骤
  static SetupStep createCompletionStep() {
    return SetupStep(
      id: 'completion',
      title: slang.t.firstTimeSetup.completion.title,
      subtitle: slang.t.firstTimeSetup.completion.subtitle,
      description: slang.t.firstTimeSetup.completion.description,
      icon: Icons.check_circle,
      // 不设置showStatus，默认为总是显示
      builder: _buildCompletionStep,
    );
  }

  /// 构建完整的步骤列表（根据平台过滤）
  static List<SetupStep> buildStepsForPlatform() {
    final allSteps = <SetupStep>[];

    // 注册所有可能的步骤
    allSteps.add(createWelcomeStep());
    allSteps.add(createThemeStep());
    allSteps.add(createPlayerSettingsStep());
    allSteps.add(createBasicSettingsStep());
    allSteps.add(createNetworkSettingsStep());
    // allSteps.add(createCompletionStep());

    // 在注册时过滤，只保留应该显示的步骤
    return allSteps.where(_shouldShowStep).toList();
  }

  /// 检查步骤是否应该显示
  static bool _shouldShowStep(SetupStep step) {
    // 如果没有showStatus函数，默认为显示
    if (step.showStatus == null) return true;

    // 调用showStatus函数判断是否显示
    return step.showStatus!();
  }

  // 私有构建方法
  static Widget _buildWelcomeStep(BuildContext context, bool isDesktop, bool isNarrow) {
    return WelcomeStepWidget(
      title: slang.t.firstTimeSetup.welcome.title,
      subtitle: slang.t.firstTimeSetup.welcome.subtitle,
      description: slang.t.firstTimeSetup.welcome.description,
      icon: Icons.celebration,
    );
  }

  static Widget _buildBasicSettingsStep(BuildContext context, bool isDesktop, bool isNarrow) {
    return BasicSettingsStepWidget(
      title: slang.t.firstTimeSetup.basic.title,
      subtitle: slang.t.firstTimeSetup.basic.subtitle,
      description: slang.t.firstTimeSetup.basic.description,
      icon: Icons.settings_suggest,
    );
  }

  static Widget _buildNetworkSettingsStep(BuildContext context, bool isDesktop, bool isNarrow) {
    return NetworkSettingsStepWidget(
      title: slang.t.firstTimeSetup.network.title,
      subtitle: slang.t.firstTimeSetup.network.subtitle,
      description: slang.t.firstTimeSetup.network.description,
      icon: Icons.network_check,
    );
  }

  static Widget _buildThemeStep(BuildContext context, bool isDesktop, bool isNarrow) {
    return ThemeStepWidget(
      title: slang.t.firstTimeSetup.theme.title,
      subtitle: slang.t.firstTimeSetup.theme.subtitle,
      description: slang.t.firstTimeSetup.theme.description,
      icon: Icons.palette,
    );
  }

  static Widget _buildPlayerSettingsStep(BuildContext context, bool isDesktop, bool isNarrow) {
    return PlayerSettingsStepWidget(
      title: slang.t.firstTimeSetup.player.title,
      subtitle: slang.t.firstTimeSetup.player.subtitle,
      description: slang.t.firstTimeSetup.player.description,
      icon: Icons.play_circle,
    );
  }

  static Widget _buildCompletionStep(BuildContext context, bool isDesktop, bool isNarrow) {
    return CompletionStepWidget(
      title: slang.t.firstTimeSetup.completion.title,
      subtitle: slang.t.firstTimeSetup.completion.subtitle,
      description: slang.t.firstTimeSetup.completion.description,
      icon: Icons.check_circle,
    );
  }
}
