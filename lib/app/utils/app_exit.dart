import 'package:flutter/services.dart';

/// Exits the application host, including the surrounding scene for an XR panel.
/// SystemNavigator.pop alone only backs out of the embedded Android activity.
class AppExit {
  AppExit._();

  static const _immersive = MethodChannel('i_iwara/immersive');

  static Future<void> exit() async {
    try {
      if (await _immersive.invokeMethod<bool>('exitApp') == true) return;
    } on MissingPluginException {
      // The standard build and desktop platforms have no immersive host.
    }
    await SystemNavigator.pop();
  }
}
