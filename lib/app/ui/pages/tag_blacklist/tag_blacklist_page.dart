import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/ui/pages/tag_blacklist/widgets/black_list_search_tag_dialog.dart';
import 'package:i_iwara/app/ui/pages/tag_blacklist/controllers/tag_blacklist_controller.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class TagBlacklistPage extends StatefulWidget {
  const TagBlacklistPage({super.key});

  @override
  State<TagBlacklistPage> createState() => _TagBlacklistPageState();
}

class _TagBlacklistPageState extends State<TagBlacklistPage> {
  late TagBlacklistController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TagBlacklistController());
  }

  @override
  void dispose() {
    Get.delete<TagBlacklistController>();
    super.dispose();
  }

  Widget _buildSaveButton() {
    return Obx(() {
      if (controller.isSaving.value) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          highlightColor: Theme.of(context).colorScheme.primary,
          child: TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.save),
            label: Text(
              t.common.save,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      }
      return TextButton.icon(
        onPressed: controller.saveBlacklistTags,
        icon: const Icon(Icons.save),
        label: Text(t.common.save),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.common.tagBlacklist),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.blacklistTags.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surfaceVariant,
                  highlightColor: Theme.of(context).colorScheme.surface,
                  child: Container(
                    width: 150,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: List.generate(6, (index) => Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.surfaceVariant,
                    highlightColor: Theme.of(context).colorScheme.surface,
                    child: Container(
                      width: 80 + (index % 2) * 20,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )),
                ),
              ],
            ),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t.errors.failedToFetchData),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.fetchBlacklistTags,
                  icon: const Icon(Icons.refresh),
                  label: Text(t.common.refresh),
                ),
              ],
            ),
          );
        }

        if (controller.blacklistTags.isEmpty) {
          return Column(
            children: [
              Expanded(
                child: MyEmptyWidget(
                  message: t.common.noData,
                ),
              ),
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        Get.dialog(
                          BlackListTagSearchDialog(
                            onSave: (tags) {
                              final currentTagIds = controller.blacklistTags.map((tag) => tag.id).toList();
                              final newTags = tags.where((tag) => !currentTagIds.contains(tag.id)).toList();
                              controller.addTags(newTags);
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchBlacklistTags(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${t.common.tagLimit}: ${controller.blacklistTags.length}/${controller.tagLimit}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: controller.blacklistTags.map((tag) {
                      return Chip(
                        label: Text(tag.id),
                        avatar: _buildTagIcon(tag),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => controller.removeTag(tag),
                        labelStyle: TextStyle(
                          color: tag.type == 'ecchi' ? Colors.red : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          Get.dialog(
                            BlackListTagSearchDialog(
                              onSave: (tags) {
                                final currentTagIds = controller.blacklistTags.map((tag) => tag.id).toList();
                                final newTags = tags.where((tag) => !currentTagIds.contains(tag.id)).toList();
                                controller.addTags(newTags);
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildSaveButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTagIcon(Tag tag) {
    if (tag.sensitive) {
      return const Icon(Icons.warning, size: 18, color: Colors.red);
    }
    return Icon(
      Icons.local_offer,
      size: 18,
      color: tag.type == 'ecchi' ? Colors.red : null,
    );
  }
} 