import 'package:flutter/material.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 可刷新页面的抽象基类
mixin RefreshableInterface {
  void refreshCurrent();
}

/// 可刷新的 StatefulWidget 基类
abstract class RefreshablePage extends StatefulWidget implements RefreshableInterface {
  const RefreshablePage({super.key});

  @override
  void refreshCurrent() {
    LogUtils.d('RefreshablePage.refreshCurrent() called on $runtimeType', 'RefreshablePage');
  }
} 