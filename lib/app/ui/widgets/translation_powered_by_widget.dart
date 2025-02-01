

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';

Widget translationPoweredByWidget(BuildContext context, {double? fontSize}) {
  final configService = Get.find<ConfigService>();
  // 如果关闭了AI翻译，则显示Google翻译，否认则是ai翻译
  final useAI = configService[ConfigKey.USE_AI_TRANSLATION] as bool? ?? false;
  final poweredBy = useAI ? 'Powered by AI' : 'Powered by Google';
  return Text(
    poweredBy,
    style: TextStyle(
      fontSize: fontSize ?? 10,
      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
    ),
  );
}
