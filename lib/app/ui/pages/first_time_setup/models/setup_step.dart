import 'package:flutter/material.dart';

/// 设置步骤模型
class SetupStep {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final bool Function()? showStatus;
  final bool Function()? canProceed;
  final Widget Function(BuildContext, bool, bool) builder;

  const SetupStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.showStatus,
    this.canProceed,
    required this.builder,
  });

  /// 检查是否可以继续到下一步
  bool get proceedable {
    if (canProceed != null) return canProceed!();
    return true;
  }
}

/// 设置步骤管理器
class SetupStepManager {
  final List<SetupStep> _steps = [];
  int _currentIndex = 0;

  /// 添加步骤
  void addStep(SetupStep step) {
    _steps.add(step);
  }

  /// 获取所有步骤
  List<SetupStep> get steps => List.unmodifiable(_steps);

  /// 获取当前步骤
  SetupStep? get currentStep => _currentIndex < _steps.length ? _steps[_currentIndex] : null;

  /// 获取当前步骤索引
  int get currentIndex => _currentIndex;

  /// 获取总步骤数
  int get totalSteps => _steps.length;

  /// 检查是否可以前进到下一步
  bool canProceed() {
    final step = currentStep;
    if (step == null) return false;
    return step.proceedable;
  }

  /// 前进到下一步
  bool next() {
    if (_currentIndex < _steps.length - 1) {
      _currentIndex++;
      return true;
    }
    return false;
  }

  /// 后退到上一步
  bool previous() {
    if (_currentIndex > 0) {
      _currentIndex--;
      return true;
    }
    return false;
  }

  /// 跳转到指定步骤
  bool jumpTo(int index) {
    if (index >= 0 && index < _steps.length) {
      _currentIndex = index;
      return true;
    }
    return false;
  }

  /// 获取所有步骤（已在注册时过滤，无需再次过滤）
  List<SetupStep> get effectiveSteps => steps;

  /// 重置到第一步
  void reset() {
    _currentIndex = 0;
  }
}
