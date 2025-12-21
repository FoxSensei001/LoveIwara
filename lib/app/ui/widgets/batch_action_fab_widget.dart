import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/batch_download_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 批量操作悬浮按钮列组件
/// 统一管理退出多选、清空选择和批量下载按钮
///
/// 注意：该组件必须作为 [Stack] 的直接子组件（或者仅被 [StatelessWidget]/[StatefulWidget] 包裹），
/// 因为它根部返回的是 [Positioned] 挂载点。
class BatchActionFabColumn<T> extends StatelessWidget {
  /// 批量选择控制器
  final BatchSelectController<T> controller;

  /// Hero 动画标签前缀，用于区分不同页面的按钮
  final String heroTagPrefix;

  /// 是否处于分页模式（用于自动调整底部间距）
  final bool isPaginated;

  /// 额外的底部间距
  final double extraBottomPadding;

  /// 额外的显示条件
  final bool Function()? visible;

  const BatchActionFabColumn({
    super.key,
    required this.controller,
    required this.heroTagPrefix,
    this.isPaginated = false,
    this.extraBottomPadding = 0,
    this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMultiSelect = controller.isMultiSelect.value;
      final isExtraVisible = visible?.call() ?? true;

      // 如果不显示，直接传 false 给 BatchActionFab，由它处理隐藏动画或 SizedBox
      if (!isMultiSelect || !isExtraVisible) {
        return const SizedBox.shrink();
      }

      final selectedCount = controller.selectedCount;

      return BatchActionFab(
        isMultiSelect: true,
        selectedCount: selectedCount,
        heroTagPrefix: heroTagPrefix,
        isPaginated: isPaginated,
        extraBottomPadding: extraBottomPadding,
        onExit: () => controller.exitMultiSelect(),
        onClear: () => controller.clearSelection(),
        customActionBuilder: (context) {
          return FloatingActionButton.small(
            heroTag: 'batchDownloadFAB_$heroTagPrefix',
            onPressed: () {
              BatchDownloadDialog.show<T>(
                mediaItems: controller.selectedMediaList,
                onComplete: () => controller.exitMultiSelect(),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: const Icon(Icons.download),
          );
        },
      );
    });
  }
}

/// 通用的批量操作悬浮按钮组件
/// 纯 UI 组件，不依赖具体控制器
class BatchActionFab extends StatelessWidget {
  /// 是否处于多选模式
  final bool isMultiSelect;

  /// 选中数量
  final int selectedCount;

  /// Hero 动画标签前缀
  final String heroTagPrefix;

  /// 是否处于分页模式
  final bool isPaginated;

  /// 额外的底部间距
  final double extraBottomPadding;

  /// 退出回调
  final VoidCallback onExit;

  /// 清空回调
  final VoidCallback onClear;

  /// 自定义动作按钮构建器（如下载、删除等）
  final WidgetBuilder customActionBuilder;

  const BatchActionFab({
    super.key,
    required this.isMultiSelect,
    required this.selectedCount,
    required this.heroTagPrefix,
    this.isPaginated = false,
    this.extraBottomPadding = 0,
    required this.onExit,
    required this.onClear,
    required this.customActionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // 根部必须稳定返回 Positioned
    return Positioned(
      left: 16,
      bottom: 0,
      child: Builder(
        builder: (context) {
          if (!isMultiSelect) {
            return const SizedBox.shrink();
          }

          final t = slang.Translations.of(context);
          final bottomSafeNow = MediaQuery.of(context).padding.bottom;

          // 计算底部总间距
          final double finalBottomPadding =
              (isPaginated ? 46 : 0) + bottomSafeNow + 20 + extraBottomPadding;

          return Padding(
            padding: EdgeInsets.only(bottom: finalBottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 退出多选按钮
                FloatingActionButton.small(
                  heroTag: 'exitMultiSelect_$heroTagPrefix',
                  onPressed: onExit,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onSecondaryContainer,
                  tooltip: t.common.exitEditMode,
                  child: const Icon(Icons.close),
                ),
                const SizedBox(height: 12),
                // 功能按钮组
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.vertical,
                          child: ScaleTransition(
                            scale: animation,
                            alignment: Alignment.bottomCenter,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                        );
                      },
                  child: selectedCount > 0
                      ? Column(
                          key: const ValueKey('batch_active_actions'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 清空已选按钮
                            FloatingActionButton.small(
                              heroTag: 'clearSelection_$heroTagPrefix',
                              onPressed: onClear,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.tertiaryContainer,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onTertiaryContainer,
                              tooltip: t.common.clearSelection,
                              child: const Icon(Icons.layers_clear),
                            ),
                            const SizedBox(height: 4),
                            // 自定义操作按钮
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Badge(
                                label: Text(selectedCount.toString()),
                                child: customActionBuilder(context),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('batch_inactive_actions'),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
