import 'package:flutter/material.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 可刷新页面的抽象接口
abstract class HomeWidgetInterface {
  void refreshCurrent();
}

/// 可刷新的 StatefulWidget 基类
mixin RefreshableMixin on Widget implements HomeWidgetInterface {
  @override
  void refreshCurrent() {
    LogUtils.d('RefreshableMixin.refreshCurrent() called on $runtimeType', 'RefreshableMixin');
  }
} 