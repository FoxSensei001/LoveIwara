import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';

Widget translationPoweredByWidget(BuildContext context, {double? fontSize}) {
  final configService = Get.find<ConfigService>();
  final useAI = configService[ConfigKey.USE_AI_TRANSLATION] as bool? ?? false;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: useAI 
          ? Colors.black.withOpacity(0.05)
          : Colors.grey.withOpacity(0.05),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        if (useAI)
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6B8DE3), Color(0xFF8B5CF6)],
            ).createShader(bounds),
            child: const Icon(Icons.auto_awesome,
              size: 14,
            ),
          )
        else
          Row(
            children: [
              Container(
                width: 14,
                height: 14, 
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4285F4), // Google Blue
                      Color(0xFF34A853), // Google Green  
                      Color(0xFFFBBC05), // Google Yellow
                      Color(0xFFEA4335), // Google Red
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "G",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        Text(
          useAI ? 'Powered by AI' : 'Powered by Google',
          style: TextStyle(
            fontSize: fontSize ?? 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
