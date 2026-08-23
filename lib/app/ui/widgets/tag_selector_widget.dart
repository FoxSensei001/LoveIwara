import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/tag_controller.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// 通用标签选择器组件
class TagSelectorWidget extends StatefulWidget {
  final List<String> selectedTags; // 当前选中的标签ID列表
  final Function(List<String>) onTagsChanged; // 标签选择变化的回调
  final String? hintText; // 提示文本
  final String? labelText; // 标签文本

  const TagSelectorWidget({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
    this.hintText,
    this.labelText,
  });

  @override
  State<TagSelectorWidget> createState() => _TagSelectorWidgetState();
}

class _TagSelectorWidgetState extends State<TagSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: _showTagSelectionDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(child: _buildSelectedTagsDisplay()),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedTagsDisplay() {
    final t = slang.Translations.of(context);
    if (widget.selectedTags.isEmpty) {
      return Text(
        widget.hintText ?? t.tagSelector.clickToSelectTags,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: widget.selectedTags.map((tagId) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tagId,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showTagSelectionDialog() {
    showGlassBottomSheet(
      context: context,
      builder: (context) => TagSelectionDialog(
        selectedTags: widget.selectedTags,
        onTagsChanged: widget.onTagsChanged,
      ),
    );
  }
}

/// 标签选择对话框
class TagSelectionDialog extends StatefulWidget {
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;

  const TagSelectionDialog({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  @override
  State<TagSelectionDialog> createState() => _TagSelectionDialogState();
}

class _TagSelectionDialogState extends State<TagSelectionDialog> {
  final UserPreferenceService _userPreferenceService =
      Get.find<UserPreferenceService>();
  late List<String> _currentSelectedTags;

  @override
  void initState() {
    super.initState();
    _currentSelectedTags = List.from(widget.selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return GlassBottomSheet(
      maxHeightFactor: 0.8,
      showCloseButton: false,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.tagSelector.selectTags,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.onTagsChanged(_currentSelectedTags);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(t.common.confirm),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 操作按钮 - 居右排布
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    showGlassToast(t.tagSelector.usageInstructions);
                  },
                  icon: const Icon(Icons.help_outline, color: Colors.blue),
                  tooltip: t.tagSelector.usageInstructionsTooltip,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showRemoveTagDialog,
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                  tooltip: t.tagSelector.removeTagTooltip,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showAddTagDialog,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.green,
                  ),
                  tooltip: t.tagSelector.addTagTooltip,
                ),
              ],
            ),
          ),

          // 标签列表 - 使用Wrap布局提高空间利用率，居左对齐
          Expanded(
            child: Obx(() {
              final availableTags =
                  _userPreferenceService.videoSearchTagHistory.value;

              if (availableTags.isEmpty) {
                return const Center(child: MyEmptyWidget());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: availableTags.map((tag) {
                      final isSelected = _currentSelectedTags.contains(tag.id);

                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(TagLocalizationService.displayName(tag.id)),
                            if (tag.type == MediaRating.ECCHI.value ||
                                tag.sensitive) ...[
                              const SizedBox(width: 4),
                              Icon(
                                tag.type == MediaRating.ECCHI.value
                                    ? Icons.local_offer
                                    : Icons.warning,
                                size: 12,
                                color: Colors.red,
                              ),
                            ],
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              if (!_currentSelectedTags.contains(tag.id)) {
                                _currentSelectedTags.add(tag.id);
                              }
                            } else {
                              _currentSelectedTags.remove(tag.id);
                            }
                          });
                        },
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        checkmarkColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog() {
    showAppDialog(const AddTagDialog());
  }

  void _showRemoveTagDialog() {
    showGlassBottomSheet(
      context: context,
      builder: (context) => RemoveTagDialog(
        onRemoveIds: (List<String> removedTags) {
          for (var id in removedTags) {
            _userPreferenceService.removeVideoSearchTagById(id);
          }
          setState(() {
            _currentSelectedTags.removeWhere(
              (tagId) => removedTags.contains(tagId),
            );
          });
        },
        videoSearchTagHistory: _userPreferenceService.videoSearchTagHistory,
      ),
    );
  }
}

/// 添加标签对话框
class AddTagDialog extends StatefulWidget {
  const AddTagDialog({super.key});

  @override
  State<AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<AddTagDialog> {
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
        tagController.getTags();
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
    return GlassAlertDialog(
      title: null,
      showCloseButton: false,
      maxWidth: 900,
      scrollable: false,
      content: SizedBox(
        // GlassAlertDialog 只限宽不限高，内部 ListView 需要有界高度才能滚动，
        // 沿用原来 ConstrainedBox(maxHeight: 800) 的思路钉一个合理高度。
        height: 600,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GlassInputSurface(
                    child: TextField(
                      controller: textEditingController,
                      decoration: glassFieldDecoration(
                        context,
                        hint: t.search.searchTags,
                      ),
                      onSubmitted: (value) {
                        tagController.getTags(refresh: true);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GlassIconButton(
                  icon: const Icon(Icons.search),
                  tooltip: t.search.searchTags,
                  onPressed: () {
                    tagController.getTags(refresh: true);
                  },
                ),
                const SizedBox(width: 8),
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.close),
                  tooltip: t.common.close,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
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
                  itemCount:
                      tagController.tags.length +
                      (tagController.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == tagController.tags.length) {
                      return const Center(child: CircularProgressIndicator());
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
                            color:
                                userPreferenceService.isUserSearchTagObject(tag)
                                ? Colors.red
                                : null,
                          ),
                          onPressed: () {
                            if (userPreferenceService.isUserSearchTagObject(
                              tag,
                            )) {
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
          Text(
            t.common.r18,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
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

/// 删除标签对话框
class RemoveTagDialog extends StatefulWidget {
  final Function(List<String>) onRemoveIds;
  final RxList<Tag> videoSearchTagHistory;

  const RemoveTagDialog({
    super.key,
    required this.onRemoveIds,
    required this.videoSearchTagHistory,
  });

  @override
  State<RemoveTagDialog> createState() => _RemoveTagDialogState();
}

class _RemoveTagDialogState extends State<RemoveTagDialog> {
  Set<String> selectedIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassBottomSheet(
      maxHeightFactor: 0.6,
      scrollable: true,
      title: t.tagSelector.deleteTag,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 删除动作（原来放在标题行右侧，标题/关闭已交给 GlassBottomSheet）
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: selectedIds.isEmpty
                    ? null
                    : () {
                        widget.onRemoveIds(selectedIds.toList());
                        Navigator.of(context).pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(t.tagSelector.delete),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: selectedIds.isEmpty
                      ? null
                      : () {
                          setState(() {
                            selectedIds.clear();
                          });
                        },
                  child: Text(t.tagSelector.cancelSelection),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.videoSearchTagHistory.isEmpty
                      ? null
                      : () {
                          setState(() {
                            if (selectedIds.length ==
                                widget.videoSearchTagHistory.length) {
                              selectedIds.clear();
                            } else {
                              selectedIds = widget.videoSearchTagHistory
                                  .map((tag) => tag.id)
                                  .toSet();
                            }
                          });
                        },
                  child: Text(
                    selectedIds.length == widget.videoSearchTagHistory.length
                        ? t.tagSelector.cancelSelectAll
                        : t.tagSelector.selectAll,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: widget.videoSearchTagHistory.map((tag) {
                return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(TagLocalizationService.displayName(tag.id)),
                          if (tag.type == MediaRating.ECCHI.value ||
                              tag.sensitive) ...[
                            const SizedBox(width: 4),
                            Icon(
                              tag.type == MediaRating.ECCHI.value
                                  ? Icons.local_offer
                                  : Icons.warning,
                              size: 12,
                              color: Colors.red,
                            ),
                          ],
                        ],
                      ),
                      selected: selectedIds.contains(tag.id),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            selectedIds.add(tag.id);
                          } else {
                            selectedIds.remove(tag.id);
                          }
                        });
                      },
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.errorContainer,
                      checkmarkColor: Theme.of(
                        context,
                      ).colorScheme.onErrorContainer,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    );
                  }).toList(),
                ),
              ),
        ],
      ),
    );
  }
}
