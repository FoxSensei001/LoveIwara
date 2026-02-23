import 'package:flutter/material.dart';
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
    final useFixedWidth = MediaQuery.sizeOf(context).width >= 520;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(slang.t.common.exitConfirmTip),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: useFixedWidth ? null : const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        width: useFixedWidth ? 400 : null,
      ),
    );
  }
}
