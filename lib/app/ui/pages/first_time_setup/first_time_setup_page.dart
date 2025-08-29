import 'package:flutter/material.dart';
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
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late SetupController _controller;

  @override
  void initState() {
    super.initState();
    LogUtils.i('新的首次设置页面已初始化', '首次设置页面');

    _controller = Get.put(SetupController());

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 启动初始动画
    _fadeController.forward();

    LogUtils.i('新的首次设置页面初始化完成', '首次设置页面');
  }

  @override
  void dispose() {
    _slideController.dispose();
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
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
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
        child: Column(
          children: [
            // 主要内容区域
            Expanded(
              child: GestureDetector(
                onPanEnd: (details) {
                  // 检查滑动速度和方向
                  if (details.velocity.pixelsPerSecond.dx.abs() > 300) {
                    if (details.velocity.pixelsPerSecond.dx > 0) {
                      // 向右滑动 - 上一步
                      if (_controller.currentStepIndex.value > 0) {
                        _previousStep();
                      }
                    } else {
                      // 向左滑动 - 下一步
                      if (_controller.currentStepIndex.value < _controller.stepManager.totalSteps - 1 && _controller.canProceed()) {
                        _nextStep();
                      } else if (_controller.currentStepIndex.value == _controller.stepManager.totalSteps - 1 && _controller.canProceed()) {
                        _completeSetup();
                      }
                    }
                  }
                },
                child: Obx(() => Stack(
                  children: List.generate(_controller.stepManager.totalSteps, (index) {
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                      left: (index - _controller.currentStepIndex.value) * MediaQuery.of(context).size.width,
                      right: -(index - _controller.currentStepIndex.value) * MediaQuery.of(context).size.width,
                      top: 0,
                      bottom: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: index == _controller.currentStepIndex.value ? 1.0 : 0.0,
                        child: IgnorePointer(
                          ignoring: index != _controller.currentStepIndex.value,
                          child: _buildStepContent(context, index, isDesktop, isNarrow),
                        ),
                      ),
                    );
                  }),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, int step, bool isDesktop, bool isNarrow) {
    final currentStep = _controller.stepManager.currentStep;
    if (currentStep == null) return const SizedBox.shrink();
    
    return currentStep.builder(context, isDesktop, isNarrow);
  }
}
