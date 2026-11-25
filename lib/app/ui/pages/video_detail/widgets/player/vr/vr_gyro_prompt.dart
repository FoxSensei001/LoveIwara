import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/vr/vr_gyro_tracker.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 第一次进 VR 全景环视时问一次「要不要用重力感应转视角」。
///
/// 只问一次：弹出那一刻就记下 [ConfigKey.VR_GYRO_PROMPT_SHOWN_KEY]，不管用户点
/// 开启、不用、还是点外面关掉，以后都不再弹——想改去设置里改。在弹出前就记，
/// 是为了弹窗开着时应用被杀掉也不会下次再问。
class VrGyroPrompt {
  const VrGyroPrompt._();

  /// 内嵌和全屏两块画面可能同一帧挂上，两边都会来问；只放一个过去。
  static bool _inFlight = false;

  /// [stillWanted]：探测要等一会儿，回来时那块环视画面可能已经被关掉或盖住，
  /// 这时不弹，留到下次进环视再问。
  static Future<void> maybeShow({required bool Function() stillWanted}) async {
    if (_inFlight || !VrGyroSupport.platformEligible) return;
    if (!Get.isRegistered<ConfigService>()) return;
    final config = Get.find<ConfigService>();
    if (_alreadySettled(config)) return;

    _inFlight = true;
    try {
      // 没有陀螺仪的机器上问了也白问。
      if (!await VrGyroSupport.ensureProbed()) return;
      if (_alreadySettled(config) || !stillWanted()) return;
      // 拿不到根 navigator 时 showAppDialog 什么都不弹，别先把「问过了」记上。
      if (rootNavigatorKey.currentContext == null) return;
      config[ConfigKey.VR_GYRO_PROMPT_SHOWN_KEY] = true;

      final t = slang.t;
      final enable = await showAppDialog<bool>(
        GlassAlertDialog(
          title: t.vrFormat.gyroPromptTitle,
          content: Text(t.vrFormat.gyroPromptBody),
          actions: [
            GlassDialogAction.pop(
              label: t.vrFormat.gyroPromptDecline,
              emphasized: false,
              result: false,
            ),
            GlassDialogAction.pop(
              label: t.vrFormat.gyroPromptEnable,
              result: true,
            ),
          ],
        ),
      );
      if (enable == true) {
        config[ConfigKey.VR_GYRO_CONTROL_KEY] = true;
      }
    } finally {
      _inFlight = false;
    }
  }

  /// 已经问过，或者用户早就在设置里自己打开了——都不必再问。
  static bool _alreadySettled(ConfigService config) =>
      config[ConfigKey.VR_GYRO_PROMPT_SHOWN_KEY] == true ||
      config[ConfigKey.VR_GYRO_CONTROL_KEY] == true;
}
