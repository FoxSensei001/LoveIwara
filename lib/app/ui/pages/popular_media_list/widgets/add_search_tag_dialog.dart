import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_picker_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../../../../../common/enums/media_enums.dart';
import '../../../../models/tag.model.dart';
import '../controllers/tag_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return GlassPickerDialog(
      title: t.favoriteTags.addIwaraTag,
      constraints: const BoxConstraints(
        maxWidth: 1200,
        minWidth: 400,
        maxHeight: 800,
      ),
      rows: [
        // 搜索行：玻璃输入胶囊 + 搜索圆钮（远程检索，显式触发）
        GlassPickerRow.field(
          child: Row(
            children: [
              Expanded(
                child: GlassPickerField(
                  controller: textEditingController,
                  hintText: t.search.searchTags,
                  icon: Icons.search,
                  onSubmitted: (value) {
                    tagController.getTags(refresh: true);
                  },
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
      bodyBuilder: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context, double headerExtent) {
    return Obx(() {
      if (tagController.isLoading.value && tagController.tags.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: headerExtent),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (tagController.tags.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: headerExtent),
          child: const MyEmptyWidget(),
        );
      }

      return ListView.builder(
        controller: scrollController,
        // headerExtent 由 GlassPickerDialog 实测下发（已含 8px 尾部留白）：
        // 蒙层的尾巴还会往下压一小段，但走到 header 底缘时已经淡到峰值的两成
        // 出头，首屏条目是从渐变里「溶」出来的，不是被一条硬边切开。
        padding: EdgeInsets.only(top: headerExtent, bottom: 12),
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
