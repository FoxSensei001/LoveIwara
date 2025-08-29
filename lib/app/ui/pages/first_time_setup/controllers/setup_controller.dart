import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import '../models/setup_step.dart';
import '../factories/setup_step_factory.dart';

/// 首次设置控制器
class SetupController extends GetxController {
  final ConfigService configService = Get.find<ConfigService>();
  
  // 步骤管理
  final SetupStepManager stepManager = SetupStepManager();
  final RxInt currentStepIndex = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeSteps();
    LogUtils.i('设置控制器已初始化', '设置控制器');
  }
  
  /// 初始化步骤
  void _initializeSteps() {
    // 根据平台构建步骤
    final steps = SetupStepFactory.buildStepsForPlatform();
    
    // 添加步骤到管理器
    for (final step in steps) {
      stepManager.addStep(step);
    }
    final stepNames = steps.map((step) => step.title).join(', ');
    LogUtils.i('初始化步骤完成，共 ${stepManager.totalSteps} 个步骤, 分别有 $stepNames', '设置控制器');
  }
  
  /// 检查是否可以继续
  bool canProceed() {
    final currentStep = stepManager.currentStep;
    if (currentStep == null) return false;

    // 根据当前步骤检查条件
    switch (currentStep.id) {
      case 'welcome':
        return true;
      case 'basic_settings':
        return true;
      case 'network_settings':
        // 检查代理设置
        final useProxy = configService[ConfigKey.USE_PROXY];
        final proxyUrl = configService[ConfigKey.PROXY_URL];
        return !useProxy || proxyUrl.isNotEmpty;
      case 'theme_settings':
        return true; // 主题设置总是可以继续
      case 'completion':
        return configService[ConfigKey.RULES_AGREEMENT_KEY];
      default:
        return true;
    }
  }
  
  /// 下一步
  void nextStep() {
    if (stepManager.next()) {
      currentStepIndex.value = stepManager.currentIndex;
    }
  }
  
  /// 上一步
  void previousStep() {
    if (stepManager.previous()) {
      currentStepIndex.value = stepManager.currentIndex;
    }
  }
  
  /// 完成设置
  Future<void> completeSetup() async {
    LogUtils.i('用户点击完成设置按钮', '设置控制器');
    
    if (!configService[ConfigKey.RULES_AGREEMENT_KEY]) {
      LogUtils.w('用户未同意协议，显示提示', '设置控制器');
      Get.snackbar(
        slang.t.common.tips,
        slang.t.firstTimeSetup.common.agreeAgreementSnackbar,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
      return;
    }
    
    LogUtils.i('开始保存设置...', '设置控制器');
    
    // 标记首次设置完成
    await configService.setSetting(ConfigKey.FIRST_TIME_SETUP_COMPLETED, true);
    
    LogUtils.i('设置保存完成，标记首次设置已完成', '设置控制器');
    
    // 震动反馈
    VibrateUtils.vibrate();
    
    // 跳转到主页
    LogUtils.i('准备跳转到主页', '设置控制器');
    Get.offAllNamed(Routes.HOME);
  }
  
  /// 获取当前步骤信息
  Map<String, dynamic> getCurrentStepInfo() {
    final step = stepManager.currentStep;
    if (step == null) return {};
    
    return {
      'title': step.title,
      'subtitle': step.subtitle,
      'description': step.description,
      'icon': step.icon,
      'currentIndex': stepManager.currentIndex,
      'totalSteps': stepManager.totalSteps,
    };
  }
}
