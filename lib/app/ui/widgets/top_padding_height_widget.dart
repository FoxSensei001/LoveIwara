import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';

class TopPaddingHeightWidget extends StatelessWidget {
  final AppService appService = Get.find<AppService>();

  TopPaddingHeightWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 如果是DeskTop设备，则监听
    var paddingTop = MediaQuery.paddingOf(context).top;
    if (GetPlatform.isDesktop) {
      return Obx(() {
        if (appService.showTitleBar) {
          return const SizedBox(height: AppService.titleBarHeight);
        } else {
          return const SizedBox(height: 0);
        }
      });
    } else {
      return SizedBox(height: paddingTop);
    }
  }
}
