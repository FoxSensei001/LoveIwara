import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ExitConfirmUtil {
  static DateTime? _lastExitTime;

  /// 处理退出操作
  /// 在 HomeShellScaffold 中，只在 home root 时调用此方法
  static void handleExit(BuildContext context, VoidCallback action) {
    if (checkCanExitAndShowMessage(context)) {
      action();
    }
  }

  static bool checkCanExitAndShowMessage(BuildContext context) {
    if (_lastExitTime == null) {
      _lastExitTime = DateTime.now();
      _showExitTip(context);
      return false;
    }

    final now = DateTime.now();
    if (now.difference(_lastExitTime!) <= const Duration(seconds: 5)) {
      _lastExitTime = null;
      return true;
    } else {
      _lastExitTime = now;
      _showExitTip(context);
      return false;
    }
  }

  static void _showExitTip(BuildContext context) {
    showGlassToast(
      slang.t.common.exitConfirmTip,
      type: GlassToastType.warning,
    );
  }
}
