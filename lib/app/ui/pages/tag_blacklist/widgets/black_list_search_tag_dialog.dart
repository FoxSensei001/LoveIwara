import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/services/tag_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class BlackListTagSearchDialog extends StatefulWidget {
  final Future<bool> Function(List<Tag>) onSave;

  const BlackListTagSearchDialog({super.key, required this.onSave});

  @override
  State<BlackListTagSearchDialog> createState() =>
      _BlackListTagSearchDialogState();
}

class _BlackListTagSearchDialogState extends State<BlackListTagSearchDialog> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();
  final TagService _tagService = Get.find<TagService>();

  final RxList<Tag> tags = <Tag>[].obs;
  final RxList<Tag> selectedTags = <Tag>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = false.obs;
  int currentPage = 0;

  /// 远端实际已加载的标签数量（不含首页合并进来的本地词库命中），
  /// 用于分页判断，避免本地结果让 `tags.length` 虚高、提前停止加载更多。
  int remoteLoadedCount = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    _searchTags();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isLoading.value && hasMore.value) {
        _searchTags(loadMore: true);
      }
    }
  }

  Future<void> _searchTags({bool loadMore = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    if (!loadMore) {
      currentPage = 0;
      remoteLoadedCount = 0;
      tags.clear();
      selectedTags.clear();
    }

    try {
      final result = await _tagService.fetchTags(
        page: currentPage,
        limit: 20,
        params: {'filter': textEditingController.text},
      );

      if (result.isSuccess && result.data != null) {
        if (loadMore) {
          // 加载更多：仅追加 API 结果，并按 id 去重，避免与首页合并的本地结果重复。
          final existing = tags.map((t) => t.id).toSet();
          tags.addAll(
            result.data!.results.where((t) => !existing.contains(t.id)),
          );
        } else {
          // 首页：把本地词库命中（当前语言译名 / 原始 key）合并到 API 结果前。
          final query = textEditingController.text.trim();
          tags.value = query.isEmpty
              ? result.data!.results
              : TagLocalizationService.mergeLocal(query, result.data!.results);
        }
        // 仅按远端已加载数量与总数比较,本地合并结果不参与分页判断。
        remoteLoadedCount += result.data!.results.length;
        hasMore.value = remoteLoadedCount < result.data!.count;
        currentPage++;
      } else {
        hasError.value = true;
        errorMessage.value = result.message;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1200,
          minWidth: 400,
          maxHeight: 800,
        ),
        child: Column(
          children: [
            // 标题行：图标 + 标题 + 玻璃关闭圆钮（全站弹窗铁律）
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: GlassComposerHeader(
                title: t.search.searchTags,
                icon: Icons.block,
                onClose: () => AppService.tryPop(),
              ),
            ),
            // 搜索行：玻璃输入壳 + 搜索圆钮
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: GlassInputSurface(
                      child: TextField(
                        controller: textEditingController,
                        decoration: glassFieldDecoration(
                          context,
                          hint: t.search.searchTags,
                        ),
                        onSubmitted: (value) => _searchTags(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.search),
                    tooltip: t.search.searchTags,
                    onPressed: () => _searchTags(),
                  ),
                ],
              ),
            ),
            Obx(() {
              if (isLoading.value && tags.isEmpty) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (tags.isEmpty) {
                if (hasError.value) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(t.errors.errorWhileFetching),
                          if (errorMessage.value.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                left: 16.0,
                                right: 16.0,
                              ),
                              child: Text(
                                errorMessage.value,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 16),
                          GlassButtonGroup(
                            children: [
                              GlassTextActionButton(
                                label: t.common.refresh,
                                emphasized: true,
                                onPressed: () => _searchTags(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
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
                      title: Text(
                        TagLocalizationService.displayNameWithId(tag.id),
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: _buildTagRatings(tag, context),
                      trailing: Obx(
                        () => Checkbox(
                          value: selectedTags.contains(tag),
                          onChanged: (bool? value) {
                            if (value == true) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                          },
                        ),
                      ),
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
            // 动作行：选中计数 + 确定（玻璃胶囊，长按会蠕动）
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Obx(
                () => Row(
                  children: [
                    Text(
                      t.common.selectedRecords(num: selectedTags.length),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    GlassButtonGroup(
                      children: [
                        GlassTextActionButton(
                          label: t.common.confirm,
                          emphasized: true,
                          onPressed: selectedTags.isEmpty
                              ? null
                              : () async {
                                  final bool success = await widget.onSave(
                                    selectedTags,
                                  );
                                  if (success) {
                                    AppService.tryPop();
                                  }
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
          Text(
            t.common.r18,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
        if (tag.sensitive) ...[
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
