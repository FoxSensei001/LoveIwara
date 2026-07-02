import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/color_vision_filters.dart';

/// 色觉辅助滤镜包装层：包在任意视频画面（media_kit `Video` 等）外层即可生效。
///
/// 读取全局配置 [ConfigKey.COLOR_VISION_FILTER_ID]，作用于所有现有及未来的播放器，
/// 配置变更即时生效；关闭时原样返回 child，不增加渲染开销。
/// 滤镜作用于 mpv 渲染完成后的 Flutter 纹理，与 Anime4K(glsl-shaders) 互不影响。
class ColorVisionFilterWrapper extends StatelessWidget {
  final Widget child;

  const ColorVisionFilterWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();
    return Obx(() {
      final type = ColorVisionFilterType.fromId(
        configService[ConfigKey.COLOR_VISION_FILTER_ID] as String,
      );
      final colorFilter = ColorVisionFilters.colorFilterOf(type);
      if (colorFilter == null) return child;
      return ColorFiltered(colorFilter: colorFilter, child: child);
    });
  }
}
