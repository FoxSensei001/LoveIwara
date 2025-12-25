import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'holiday_config.dart';
import 'effects/snow_effect.dart';
import 'effects/lunar_new_year_effect.dart';

class HolidayThemeOverlay extends StatelessWidget {
  const HolidayThemeOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final AppService appService = Get.find<AppService>();

    return Obx(() {
      final mode = appService.holidayMode;
      if (mode == HolidayMode.none) {
        return const SizedBox.shrink();
      }

      switch (mode) {
        case HolidayMode.christmas:
          return const IgnorePointer(ignoring: true, child: SnowEffect());
        case HolidayMode.lunarNewYear:
          return const IgnorePointer(
            ignoring: true,
            child: LunarNewYearEffect(),
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }
}
