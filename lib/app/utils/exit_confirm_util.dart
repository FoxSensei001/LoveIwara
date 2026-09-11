import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ExitConfirmUtil {
  static DateTime? _lastExitTime;

  /// 仅供测试：清掉「上一次按返回」的记忆。
  ///
  /// ⛔ [_lastExitTime] 是 static 的，测试之间会互相串：一个测试按了一下没退成，
  /// 下一个测试的第一下就成了「5 秒内的第二下」，于是它不按两下也能退出——两条
  /// 测试就这么靠残留耦合在一起，单跑和全量跑结果还不一样。每个测试自己 setUp
  /// 里清一次。
  @visibleForTesting
  static void resetForTest() => _lastExitTime = null;

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
    showAppToast(
      slang.t.common.exitConfirmTip,
      type: AppToastType.warning,
    );
  }
}
