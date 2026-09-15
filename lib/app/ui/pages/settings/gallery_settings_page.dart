import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/xr_capability.dart';
import 'package:i_iwara/app/services/xr_immersive_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/color_vision_settings_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/common/gallery_image_quality.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class GallerySettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const GallerySettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));
    // 空间形态：图库走原生空间画廊（一块幕布 + 面板胶片）。
    // 非响应式读取即可，理由见 [xrImmersiveAvailableNow] 的注释。
    final spatial = xrImmersiveAvailableNow;

    return GlassSettingsScaffold(
      title: slang.t.settings.gallerySettings.gallerySettingsTitle,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                slang.t.settings.gallerySettings.gallerySettingsSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              // 头显上图库走的是原生空间画廊，这一区排最前：它才是这台设备上
              // 「看图」的主路径，下面两张卡片说的都是这块面板里的 2D 查看器。
              if (spatial) ...[
                _spatialGalleryCard(context, configService),
                const SizedBox(height: 20),
              ],
              Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slang
                                .t
                                .settings
                                .gallerySettings
                                .defaultViewerQuality,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            slang
                                .t
                                .settings
                                .gallerySettings
                                .defaultViewerQualityDesc,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Obx(() {
                      final currentQuality = normalizeGalleryImageQuality(
                        configService[ConfigKey
                            .GALLERY_VIEWER_DEFAULT_IMAGE_QUALITY],
                      );

                      return RadioGroup<String>(
                        groupValue: currentQuality,
                        onChanged: (value) {
                          if (value == null) return;
                          configService[ConfigKey
                                  .GALLERY_VIEWER_DEFAULT_IMAGE_QUALITY] =
                              value;
                        },
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: Text(slang.t.common.imageQualityStandard),
                              value: galleryImageQualityStandard,
                            ),
                            RadioListTile<String>(
                              title: Text(slang.t.common.imageQualityOriginal),
                              value: galleryImageQualityOriginal,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 图库色觉辅助（与播放器色觉辅助为独立开关）。走 embedded 模式，
              // 套本页统一的 Card 外壳，与上面的「查看质量」卡片同一套视觉语言，
              // 而不是组件自带的那份独立卡片样式（阴影/圆角/取色都跟全站对不上）。
              Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ColorVisionSettingsWidget(
                  embedded: true,
                  configKey: ConfigKey.GALLERY_COLOR_VISION_FILTER_ID,
                  // ⛔ 头显上要说清楚它只管这块面板：空间幕布上的图由原生 Coil 画，
                  // 滤镜是 Flutter 绘制期的 ColorFilter，够不着那边。不加这句的话
                  // 就是「开了却没变化」——最难排查的那类问题。
                  descriptionOverride: spatial
                      ? slang.t.colorVisionAssist.galleryDescriptionSpatial
                      : slang.t.colorVisionAssist.galleryDescription,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  /// 空间画廊那张卡片：一个真开关 + 一个「唤出原生空间面板」的入口。
  ///
  /// ⛔ 幻灯片间隔、短片单条循环、幕布曲率**不镜像到这里**：它们躺在原生
  /// SharedPreferences（`xr_player_v2`）里，由空间面板自己读写，Dart 这边没有
  /// 通道也不该再开一条——两处各存一份必然对不上。
  ///
  /// 与视频不同，「自动进空间画廊」是一枚**真开关**：关掉之后这块面板里的 2D
  /// 大图页照常打开（见 `gallery_image_scroller_widget` 里那条分叉），不像视频
  /// 那样没有退路。
  Widget _spatialGalleryCard(BuildContext context, ConfigService config) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slang.t.vrFormat.spatialGallerySectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slang.t.vrFormat.spatialGalleryPanelDesc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(
            () => GlassSwitchItem(
              icon: Icons.photo_library_outlined,
              title: Text(
                slang.t.vrFormat.autoEnterGallery,
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: Text(
                slang.t.vrFormat.autoEnterGalleryDesc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value:
                  config.settings[ConfigKey.XR_GALLERY_AUTO_ENTER_KEY]!.value
                      as bool,
              onChanged: (value) {
                config[ConfigKey.XR_GALLERY_AUTO_ENTER_KEY] = value;
              },
            ),
          ),
          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(
              Icons.open_with,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(
              slang.t.vrFormat.spatialPanelEntry,
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              slang.t.vrFormat.spatialPanelEntryDesc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              if (!Get.isRegistered<XrImmersiveService>()) return;
              unawaited(Get.find<XrImmersiveService>().togglePanelControls());
            },
          ),
        ],
      ),
    );
  }
}
