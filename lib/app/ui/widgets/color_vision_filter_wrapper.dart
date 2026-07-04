import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/color_vision_filters.dart';

/// 色觉辅助滤镜包装层：包在任意画面（media_kit `Video`、图片等）外层即可生效。
///
/// 读取 [configKey] 指向的配置（默认播放器 [ConfigKey.COLOR_VISION_FILTER_ID]，
/// 图库可传 [ConfigKey.GALLERY_COLOR_VISION_FILTER_ID] 以使用独立开关），
/// 配置变更即时生效；关闭时原样返回 child，不增加渲染开销。
/// 滤镜作用于 mpv 渲染完成后的 Flutter 纹理，与 Anime4K(glsl-shaders) 互不影响。
class ColorVisionFilterWrapper extends StatelessWidget {
  final Widget child;

  /// 读取的色觉辅助配置键；默认播放器全局开关，图库场景传入独立的图库开关。
  final ConfigKey configKey;

  const ColorVisionFilterWrapper({
    super.key,
    required this.child,
    this.configKey = ConfigKey.COLOR_VISION_FILTER_ID,
  });

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();
    return Obx(() {
      final type = ColorVisionFilterType.fromId(
        configService[configKey] as String,
      );
      final colorFilter = ColorVisionFilters.colorFilterOf(type);
      if (colorFilter == null) return child;
      return ColorFiltered(colorFilter: colorFilter, child: child);
    });
  }
}
