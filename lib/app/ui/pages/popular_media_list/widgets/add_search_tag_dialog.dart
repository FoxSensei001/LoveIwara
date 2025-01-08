import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../../../../../common/enums/media_enums.dart';
import '../../../../models/tag.model.dart';
import '../controllers/tag_controller.dart';

class AddSearchTagDialog extends StatefulWidget {
  const AddSearchTagDialog({super.key});

  @override
  _AddSearchTagDialogState createState() => _AddSearchTagDialogState();
}

class _AddSearchTagDialogState extends State<AddSearchTagDialog> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();
  final TagController tagController = Get.put(TagController());
  final UserPreferenceService userPreferenceService = Get.find<UserPreferenceService>();

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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1200,
          minWidth: 400,
          maxHeight: 800,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: t.search.searchTags,
                      ),
                      onSubmitted: (value) {
                        tagController.getTags(refresh: true);
                      },
                    ),
                  ),
                  // 搜索按钮
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      tagController.getTags(refresh: true);
                    },
                  ),
                  // 关闭按钮
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (tagController.isLoading.value && tagController.tags.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (tagController.tags.isEmpty) {
                return const MyEmptyWidget();
              }

              return Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: tagController.tags.length +
                      (tagController.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == tagController.tags.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final tag = tagController.tags[index];
                    return ListTile(
                      title: Text(tag.id, style: const TextStyle(fontSize: 16)),
                      subtitle: _buildTagRatings(tag, context),
                      trailing: Obx(() => IconButton(
                        icon: Icon(
                          userPreferenceService.isUserSearchTagObject(tag) ? Icons.favorite : Icons.favorite_border,
                          color: userPreferenceService.isUserSearchTagObject(tag) ? Colors.red : null,
                        ),
                        onPressed: () {
                          if (userPreferenceService.isUserSearchTagObject(tag)) {
                            userPreferenceService.removeVideoSearchTag(tag);
                          } else {
                            userPreferenceService.addVideoSearchTag(tag);
                          }
                        },
                      )),
                      onTap: () {
                        if (userPreferenceService.isUserSearchTagObject(tag)) {
                          userPreferenceService.removeVideoSearchTag(tag);
                        } else {
                          userPreferenceService.addVideoSearchTag(tag);
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
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
          Text(t.common.r18, style: const TextStyle(fontSize: 12, color: Colors.red)),
        ],
        // 敏感标签
        if (sensitive) ...[
          const SizedBox(width: 8),
          const Icon(Icons.warning, size: 16, color: Colors.red),
          const SizedBox(width: 4),
          Text(t.common.sensitive, style: const TextStyle(fontSize: 12, color: Colors.red)),
        ]
      ],
    );
  }
}
