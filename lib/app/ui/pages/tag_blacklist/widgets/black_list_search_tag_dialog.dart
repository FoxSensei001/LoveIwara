import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/tag_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class BlackListTagSearchDialog extends StatefulWidget {
  final Function(List<Tag>) onSave;

  const BlackListTagSearchDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<BlackListTagSearchDialog> createState() => _BlackListTagSearchDialogState();
}

class _BlackListTagSearchDialogState extends State<BlackListTagSearchDialog> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();
  final TagService _tagService = Get.find<TagService>();
  
  final RxList<Tag> tags = <Tag>[].obs;
  final RxList<Tag> selectedTags = <Tag>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = false.obs;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    _searchTags();
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (!isLoading.value && hasMore.value) {
        _searchTags(loadMore: true);
      }
    }
  }

  Future<void> _searchTags({bool loadMore = false}) async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    if (!loadMore) {
      currentPage = 0;
      tags.clear();
      selectedTags.clear();
    }

    try {
      final result = await _tagService.fetchTags(
          page: currentPage, limit: 20, params: {
        'filter': textEditingController.text,
      });

      if (result.isSuccess && result.data != null) {
        if (loadMore) {
          tags.addAll(result.data!.results);
        } else {
          tags.value = result.data!.results;
        }
        hasMore.value = tags.length < result.data!.count;
        currentPage++;
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      onSubmitted: (value) => _searchTags(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchTags(),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onSave(selectedTags);
                      AppService.tryPop();
                    },
                    child: Text(t.common.confirm),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      AppService.tryPop();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (isLoading.value && tags.isEmpty) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (tags.isEmpty) {
                return Expanded(child: MyEmptyWidget(message: t.common.noData));
              }

              return Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: tags.length + (hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == tags.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final tag = tags[index];
                    return ListTile(
                      title: Text(tag.id, style: const TextStyle(fontSize: 16)),
                      subtitle: _buildTagRatings(tag, context),
                      trailing: Obx(() => Checkbox(
                        value: selectedTags.contains(tag),
                        onChanged: (bool? value) {
                          if (value == true) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        },
                      )),
                      onTap: () {
                        if (selectedTags.contains(tag)) {
                          selectedTags.remove(tag);
                        } else {
                          selectedTags.add(tag);
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
    return Row(
      children: [
        if (tag.type == 'general') ...[
          const Icon(Icons.local_offer, size: 16),
          const SizedBox(width: 4),
          Text(t.common.general, style: const TextStyle(fontSize: 12)),
        ],
        if (tag.type == 'ecchi') ...[
          const Icon(Icons.local_offer, size: 16, color: Colors.red),
          const SizedBox(width: 4),
          Text(t.common.r18, style: const TextStyle(fontSize: 12, color: Colors.red)),
        ],
        if (tag.sensitive) ...[
          const SizedBox(width: 8),
          const Icon(Icons.warning, size: 16, color: Colors.red),
          const SizedBox(width: 4),
          Text(t.common.sensitive, style: const TextStyle(fontSize: 12, color: Colors.red)),
        ]
      ],
    );
  }
} 