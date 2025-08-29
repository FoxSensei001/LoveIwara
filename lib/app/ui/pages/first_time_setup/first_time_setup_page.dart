import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'controllers/setup_controller.dart';

class FirstTimeSetupPage extends StatefulWidget {
  const FirstTimeSetupPage({super.key});

  @override
  State<FirstTimeSetupPage> createState() => _FirstTimeSetupPageState();
}

class _FirstTimeSetupPageState extends State<FirstTimeSetupPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late SetupController _controller;

  @override
  void initState() {
    super.initState();
    LogUtils.i('新的首次设置页面已初始化', '首次设置页面');

    _controller = Get.put(SetupController());

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // 启动初始动画
    _fadeController.forward();

    LogUtils.i('新的首次设置页面初始化完成', '首次设置页面');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_controller.canProceed()) {
      _controller.nextStep();
    }
  }

  void _previousStep() {
    _controller.previousStep();
  }

  void _completeSetup() async {
    await _controller.completeSetup();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final isNarrow = screenWidth < 400;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Obx(() {
          final stepInfo = _controller.getCurrentStepInfo();
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_controller.currentStepIndex.value),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stepInfo['title'] ?? '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_controller.currentStepIndex.value + 1} / ${_controller.stepManager.totalSteps}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }),
        actions: [
          // 上一步按钮
          Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _controller.currentStepIndex.value > 0
                ? Container(
                    key: const ValueKey('prev'),
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _previousStep,
                        borderRadius: BorderRadius.circular(12),
                        child: Icon(
                          Icons.chevron_left,
                          color: theme.colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('empty'), width: 48, height: 40),
          )),
          // 下一步/完成按钮
          Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 16),
            child: Material(
              color: _controller.canProceed()
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _controller.canProceed()
                    ? (_controller.currentStepIndex.value == _controller.stepManager.totalSteps - 1 ? _completeSetup : _nextStep)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    key: ValueKey(_controller.currentStepIndex.value == _controller.stepManager.totalSteps - 1),
                    _controller.currentStepIndex.value == _controller.stepManager.totalSteps - 1 ? Icons.done : Icons.chevron_right,
                    color: _controller.canProceed()
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    size: 24,
                  ),
                ),
              ),
            ),
          )),
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 主要内容区域
            Expanded(
              child: Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _buildStepContent(context, _controller.currentStepIndex.value, isDesktop, isNarrow),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, int step, bool isDesktop, bool isNarrow) {
    final currentStep = _controller.stepManager.currentStep;
    if (currentStep == null) return const SizedBox.shrink();
    
    return Container(
      key: ValueKey(step),
      child: currentStep.builder(context, isDesktop, isNarrow),
    );
  }
}
