import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_iwara/app/services/config_service.dart';

Widget translationPoweredByWidget(BuildContext context, {double? fontSize}) {
  final configService = Get.find<ConfigService>();
  final useAI = configService[ConfigKey.USE_AI_TRANSLATION] as bool? ?? false;
  final useDeepLX = configService[ConfigKey.USE_DEEPLX_TRANSLATION] as bool? ?? false;

  // 确定使用的翻译服务
  String provider;
  Widget icon;
  Color backgroundColor;

  if (useDeepLX) {
    provider = 'Powered by DeepLX';
    backgroundColor = Colors.blue.withValues(alpha: 0.05);
    icon = SvgPicture.asset(
      'assets/svg/deepl.svg',
      width: 14,
      height: 14,
    );
  } else if (useAI) {
    provider = 'Powered by AI';
    backgroundColor = Colors.black.withValues(alpha: 0.05);
    icon = ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF6B8DE3), Color(0xFF8B5CF6)],
      ).createShader(bounds),
      child: const Icon(Icons.auto_awesome, size: 14),
    );
  } else {
    provider = 'Powered by Google';
    backgroundColor = Colors.grey.withValues(alpha: 0.05);
    icon = SvgPicture.asset(
      'assets/svg/google.svg',
      width: 14,
      height: 14,
    );
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: backgroundColor,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        icon,
        const SizedBox(width: 2),
        Text(
          provider,
          style: TextStyle(
            fontSize: fontSize ?? 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
