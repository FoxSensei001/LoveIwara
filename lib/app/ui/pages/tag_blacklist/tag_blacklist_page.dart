import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/ui/pages/tag_blacklist/widgets/black_list_search_tag_dialog.dart';
import 'package:i_iwara/app/ui/pages/tag_blacklist/controllers/tag_blacklist_controller.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

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

  void _showAddTagDialog() {
    showAppDialog(
      BlackListTagSearchDialog(
        onSave: (tags) async {
          final currentTagIds = controller.blacklistTags
              .map((tag) => tag.id)
              .toList();
          final newTags = tags
              .where((tag) => !currentTagIds.contains(tag.id))
              .toList();
          return controller.addTags(newTags);
        },
      ),
    );
  }

  /// 右侧动作胶囊：添加 · 保存（有未保存改动时挂红点，保存中换沙漏）· 刷新。
  Widget _buildActionGroup(BuildContext context) {
    return Obx(() {
      final bool saving = controller.isSaving.value;
      // hasUnsavedChanges 读的是两个 Rx 列表，Obx 能正常收集依赖
      final bool dirty = controller.hasUnsavedChanges;
      final bool loading = controller.isLoading.value;
      return GlassButtonGroup(
        children: [
          GlassIconButton(
            icon: const Icon(Icons.add),
            tooltip: t.tagSelector.addTag,
            onPressed: saving ? null : _showAddTagDialog,
          ),
          GlassIconButton(
            // 保存中图标原位换成沙漏，而不是整钮换 Shimmer
            icon: const Icon(Icons.save_outlined),
            loading: saving,
            tooltip: t.common.save,
            // 有未保存改动时挂小红点，保存成功后收缩消失
            showBadge: dirty,
            onPressed: controller.saveBlacklistTags,
          ),
          GlassIconButton(
            icon: const Icon(Icons.refresh),
            loading: loading,
            tooltip: t.common.refresh,
            onPressed: controller.fetchBlacklistTags,
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        body: RefreshIndicator(
          // 指示器从 header 下方弹出
          displacement: headerExtent,
          onRefresh: () => controller.fetchBlacklistTags(),
          child: Obx(() => _buildContent(context, headerExtent)),
        ),
        // header 行：左 返回圆钮 / 中 标题胶囊 / 右 动作胶囊
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.arrow_back),
                tooltip: t.common.back,
                onPressed: () => AppService.tryPop(),
              ),
              const SizedBox(width: 8),
              Expanded(child: GlassTitlePill(title: t.common.tagBlacklist)),
              const SizedBox(width: 8),
              _buildActionGroup(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 列表主体：骨架 / 错误 / 空 / 标签墙，四态共用同一套顶部让位。
  Widget _buildContent(BuildContext context, double headerExtent) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(
      16,
      headerExtent + 8,
      16,
      MediaQuery.paddingOf(context).bottom + 24,
    );

    if (controller.isLoading.value && controller.blacklistTags.isEmpty) {
      return ListView(
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [_buildSkeleton(context)],
      );
    }

    if (controller.hasError.value) {
      return ListView(
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 48),
          Column(
            children: [
              Text(t.errors.failedToFetchData),
              if (controller.errorMessage.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    controller.errorMessage.value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: controller.fetchBlacklistTags,
                icon: const Icon(Icons.refresh),
                label: Text(t.common.retry),
              ),
            ],
          ),
        ],
      );
    }

    if (controller.blacklistTags.isEmpty) {
      return ListView(
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (controller.hasUnsavedChanges) _buildUnsavedChangesBanner(context),
          const SizedBox(height: 48),
          MyEmptyWidget(message: t.common.noData),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonalIcon(
              onPressed: _showAddTagDialog,
              icon: const Icon(Icons.add),
              label: Text(t.tagSelector.addTag),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (controller.hasUnsavedChanges) _buildUnsavedChangesBanner(context),
        Text(
          '${t.common.tagLimit}: ${controller.blacklistTags.length}/${controller.tagLimit}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: controller.blacklistTags.map((tag) {
            return Chip(
              label: Text(TagLocalizationService.displayName(tag.id)),
              avatar: _buildTagIcon(tag),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => controller.removeTag(tag),
              labelStyle: TextStyle(
                color: tag.type == 'ecchi' ? Colors.red : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 未保存改动提醒条：dirty 时挂在列表顶部，随内容一起滚动
  Widget _buildUnsavedChangesBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t.common.unsavedChanges,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest,
          highlightColor: colorScheme.surface,
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
          children: List.generate(
            6,
            (index) => Shimmer.fromColors(
              baseColor: colorScheme.surfaceContainerHighest,
              highlightColor: colorScheme.surface,
              child: Container(
                width: 80 + (index % 2) * 20,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
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
