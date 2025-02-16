import 'dart:io';

import 'package:flutter/services.dart';
import 'package:i_iwara/common/constants.dart';

/// 提供视频应用各类交互触觉反馈的工具类
/// HapticFeedback.vibrate,
/// HapticFeedback.heavyImpact,
/// HapticFeedback.mediumImpact,
/// HapticFeedback.lightImpact,
/// HapticFeedback.selectionClick,
class VibrateUtils {
  /// 单例实例

  static Future<void> vibrate({Future<void> Function() type = HapticFeedback.lightImpact}) async {
    if (!CommonConstants.enableVibration) return;
    await type();
  }

  static bool hasVibrator() {
    return Platform.isAndroid || Platform.isIOS;
  }
}
