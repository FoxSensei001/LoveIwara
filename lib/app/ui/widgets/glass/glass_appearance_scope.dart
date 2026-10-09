import 'package:flutter/widgets.dart';
import 'package:i_iwara/app/models/glass_appearance_settings.dart';

final glassAppearance = ValueNotifier(GlassAppearanceSettings.defaults);

/// Changes material in existing routes and overlays without recreating them.
class GlassAppearanceScope
    extends InheritedNotifier<ValueNotifier<GlassAppearanceSettings>> {
  GlassAppearanceScope({super.key, required super.child})
    : super(notifier: glassAppearance);

  static GlassAppearanceSettings of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<GlassAppearanceScope>()
          ?.notifier
          ?.value ??
      glassAppearance.value;
}
