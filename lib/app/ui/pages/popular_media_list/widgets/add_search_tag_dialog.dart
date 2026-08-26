import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../../../../../common/enums/media_enums.dart';
import '../../../../models/tag.model.dart';
import '../controllers/tag_controller.dart';

// header 各行的显式尺寸--列表要用 paddingTop 让出这些高度，让内容可以从
// header 背后滚过去（与 add_video_to_playlist_dialog 同一套弹窗玻璃配方）。
const double _kTitleRowHeight = 16 + 44 + 4;
const double _kSearchRowHeight = 8 + 44;
const double _kHeaderTailSpacing = 8;
const double _kHeaderExtent =
    _kTitleRowHeight + _kSearchRowHeight + _kHeaderTailSpacing;

class AddSearchTagDialog extends StatefulWidget {
  const AddSearchTagDialog({super.key});

  @override
  State<AddSearchTagDialog> createState() => _AddSearchTagDialogState();
}

class _AddSearchTagDialogState extends State<AddSearchTagDialog> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();
  final TagController tagController = Get.put(TagController());
  final UserPreferenceService userPreferenceService =
      Get.find<UserPreferenceService>();

  @override
  void initState() {
    super.initState();
    tagController.searchInput = '';
    tagController.getTags(refresh: true);
    textEditingController.addListener(() {
      tagController.searchInput = textEditingController.text;
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          tagController.hasMore.value) {
        tagController.getTags(); // Load more tags when reaching bottom
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  /// 玻璃胶囊输入框容器：半透明底色 + 细描边，与全局玻璃控件一致。
  Widget _buildGlassField(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: GlassTokens.fill(colorScheme),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GlassTokens.stroke(colorScheme), width: 0.6),
      ),
      child: child,
    );
  }

  InputDecoration _fieldDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: slang.t.search.searchTags,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1200,
          minWidth: 400,
          maxHeight: 800,
        ),
        child: Stack(
          children: [
            // 主体：列表铺满整个区域，用 paddingTop 让出 header 高度，
            // 让条目可以从上方玻璃 header 背后滚过去。
            Positioned.fill(child: _buildBody(context)),
            // 顶部渐变蒙层：只有标题行恒定不透明，搜索行连同伸进内容区的
            // 尾巴一起走 smoothstep（曲线与页面档一致）。
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: EdgeFadeScrim.headerOverlay(
                headerExtent: _kHeaderExtent,
                plateauExtent: _kTitleRowHeight,
              ),
            ),
            // 顶部玻璃控件行：标题 / 关闭 / 搜索
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // 标题行：标题 + 玻璃关闭圆钮
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.favoriteTags.addIwaraTag,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        GlassIconButton(
                          standalone: true,
                          icon: const Icon(Icons.close),
                          tooltip: t.common.close,
                          onPressed: () => AppService.tryPop(),
                        ),
                      ],
                    ),
                  ),
                  // 搜索行：玻璃输入胶囊 + 搜索圆钮（远程检索，显式触发）
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildGlassField(
                            context,
                            child: TextField(
                              controller: textEditingController,
                              decoration: _fieldDecoration(context),
                              onSubmitted: (value) {
                                tagController.getTags(refresh: true);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GlassIconButton(
                          standalone: true,
                          icon: const Icon(Icons.search),
                          tooltip: t.common.search,
                          onPressed: () {
                            tagController.getTags(refresh: true);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (tagController.isLoading.value && tagController.tags.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: _kHeaderExtent),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (tagController.tags.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: _kHeaderExtent),
          child: MyEmptyWidget(),
        );
      }

      return ListView.builder(
        controller: scrollController,
        // paddingTop 只让出 header 本身：蒙层的尾巴还会往下压一小段，但走到
        // header 底缘时已经淡到峰值的两成出头，首屏条目是从渐变里「溶」出来的，
        // 不是被一条硬边切开（与页面档同一条曲线，见 EdgeFadeScrim.headerOverlay）。
        padding: const EdgeInsets.only(top: _kHeaderExtent, bottom: 12),
        itemCount:
            tagController.tags.length + (tagController.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == tagController.tags.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final tag = tagController.tags[index];
          return ListTile(
            title: Text(
              TagLocalizationService.displayNameWithId(tag.id),
              style: const TextStyle(fontSize: 16),
            ),
            subtitle: _buildTagRatings(tag, context),
            trailing: Obx(
              () => IconButton(
                icon: Icon(
                  userPreferenceService.isUserSearchTagObject(tag)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: userPreferenceService.isUserSearchTagObject(tag)
                      ? Colors.red
                      : null,
                ),
                onPressed: () {
                  if (userPreferenceService.isUserSearchTagObject(tag)) {
                    userPreferenceService.removeVideoSearchTag(tag);
                  } else {
                    userPreferenceService.addVideoSearchTag(tag);
                  }
                },
              ),
            ),
            onTap: () {
              if (userPreferenceService.isUserSearchTagObject(tag)) {
                userPreferenceService.removeVideoSearchTag(tag);
              } else {
                userPreferenceService.addVideoSearchTag(tag);
              }
            },
          );
        },
      );
    });
  }

  Widget _buildTagRatings(Tag tag, BuildContext context) {
    bool sensitive = tag.sensitive;
    final t = slang.Translations.of(context);
    return Row(
      children: [
        if (tag.type == MediaRating.GENERAL.value) ...[
          const Icon(Icons.local_offer, size: 16),
          const SizedBox(width: 4),
          Text(t.common.general, style: const TextStyle(fontSize: 12)),
        ],
        if (tag.type == MediaRating.ECCHI.value) ...[
          const Icon(Icons.local_offer, size: 16, color: Colors.red),
          const SizedBox(width: 4),
          Text(
            t.common.r18,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
        // 敏感标签
        if (sensitive) ...[
          const SizedBox(width: 8),
          const Icon(Icons.warning, size: 16, color: Colors.red),
          const SizedBox(width: 4),
          Text(
            t.common.sensitive,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      ],
    );
  }
}
