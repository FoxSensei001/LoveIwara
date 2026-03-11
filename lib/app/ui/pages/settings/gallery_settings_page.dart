import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: slang.t.settings.gallerySettings.gallerySettingsTitle,
            isWideScreen: isWideScreen,
          ),
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
                                title: Text(
                                  slang.t.common.imageQualityStandard,
                                ),
                                value: galleryImageQualityStandard,
                              ),
                              RadioListTile<String>(
                                title: Text(
                                  slang.t.common.imageQualityOriginal,
                                ),
                                value: galleryImageQualityOriginal,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
