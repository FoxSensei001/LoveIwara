import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return const SetupStep(
      id: 'welcome',
      title: '欢迎使用',
      subtitle: '让我们开始您的个性化设置之旅',
      description: '只需几步，即可为您量身定制最佳使用体验',
      icon: Icons.celebration,
      builder: _buildWelcomeStep,
    );
  }

  /// 创建基础设置步骤
  static SetupStep createBasicSettingsStep() {
    return const SetupStep(
      id: 'basic_settings',
      title: '基础设置',
      subtitle: '个性化您的使用体验',
      description: '选择适合您的功能偏好',
      icon: Icons.settings_suggest,
      builder: _buildBasicSettingsStep,
    );
  }

  /// 创建网络设置步骤（仅在桌面平台显示）
  static SetupStep createNetworkSettingsStep() {
    return const SetupStep(
      id: 'network_settings',
      title: '网络设置',
      subtitle: '配置网络连接选项',
      description: '根据您的网络环境进行相应配置',
      icon: Icons.network_check,
      showStatus: _shouldShowNetworkSettings, // 控制是否显示此步骤
      builder: _buildNetworkSettingsStep,
    );
  }

  /// 网络设置显示条件：仅在桌面平台显示
  static bool _shouldShowNetworkSettings() => GetPlatform.isDesktop;

  /// 创建主题设置步骤（示例：如何添加新步骤）
  static SetupStep createThemeStep() {
    return const SetupStep(
      id: 'theme_settings',
      title: '主题设置',
      subtitle: '选择您喜欢的界面主题',
      description: '个性化您的视觉体验',
      icon: Icons.palette,
      showStatus: _shouldShowThemeSettings, // 可控制是否显示主题设置
      builder: _buildThemeStep,
    );
  }

  /// 创建播放器设置步骤
  static SetupStep createPlayerSettingsStep() {
    return const SetupStep(
      id: 'player_settings',
      title: '播放器设置',
      subtitle: '配置播放控制偏好',
      description: '你可以在此快速设置常用的播放体验',
      icon: Icons.play_circle,
      builder: _buildPlayerSettingsStep,
    );
  }

  /// 主题设置显示条件：默认显示，可以通过配置控制
  static bool _shouldShowThemeSettings() => true; // 暂时总是显示，可以根据需要修改

  /// 创建完成设置步骤
  static SetupStep createCompletionStep() {
    return const SetupStep(
      id: 'completion',
      title: '完成设置',
      subtitle: '即将开始您的精彩之旅',
      description: '请阅读并同意相关协议',
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
    allSteps.add(createCompletionStep());

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
    return const WelcomeStepWidget(
      title: '欢迎使用',
      subtitle: '让我们开始您的个性化设置之旅',
      description: '只需几步，即可为您量身定制最佳使用体验',
      icon: Icons.celebration,
    );
  }

  static Widget _buildBasicSettingsStep(BuildContext context, bool isDesktop, bool isNarrow) {
    return const BasicSettingsStepWidget(
      title: '基础设置',
      subtitle: '个性化您的使用体验',
      description: '选择适合您的功能偏好',
      icon: Icons.settings_suggest,
    );
  }

  static Widget _buildNetworkSettingsStep(BuildContext context, bool isDesktop, bool isNarrow) {
    return const NetworkSettingsStepWidget(
      title: '网络设置',
      subtitle: '配置网络连接选项',
      description: '根据您的网络环境进行相应配置',
      icon: Icons.network_check,
    );
  }

  static Widget _buildThemeStep(BuildContext context, bool isDesktop, bool isNarrow) {
    return const ThemeStepWidget(
      title: '主题设置',
      subtitle: '选择您喜欢的界面主题',
      description: '个性化您的视觉体验',
      icon: Icons.palette,
    );
  }

  static Widget _buildPlayerSettingsStep(BuildContext context, bool isDesktop, bool isNarrow) {
    return const PlayerSettingsStepWidget(
      title: '播放器设置',
      subtitle: '配置播放控制偏好',
      description: '你可以在此快速设置常用的播放体验',
      icon: Icons.play_circle,
    );
  }

  static Widget _buildCompletionStep(BuildContext context, bool isDesktop, bool isNarrow) {
    return const CompletionStepWidget(
      title: '完成设置',
      subtitle: '即将开始您的精彩之旅',
      description: '请阅读并同意相关协议',
      icon: Icons.check_circle,
    );
  }
}
