import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/batch_download_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 「只有批量下载」的媒体列表页（热门 / 订阅 / 搜索结果 / 作者页）共用的接线。
///
/// 把当前活跃的 [BatchSelectController] 的选择态包成 [BatchSelectionScope]
/// 往下广播：瀑布流模式由页面 `extra` 里的 [GlassSelectionDock] 取用，分页模式
/// 由深埋在 `MediaListView` 内部的 `PaginationBar` 取用——两边读的是同一份状态、
/// 同一组动作，所以两种布局下按钮语言完全一致。
///
/// **必须只套一层**：视频 / 图库两个 tab 各有一个控制器，但 InheritedWidget
/// 取的是「最近的那一个」，套两层的话分页栏永远读到内层那个（可能正是没在
/// 活跃的那个）。所以这里收 [controllers] 列表 + [activeIndex]，由本组件决定
/// 广播谁。
///
/// 用法：把页面的 `GlassHeaderOverlay(...)` 整个作为 [child] 传进来，并在它的
/// `extra` 里放一枚 `GlassSelectionDock(paginated: isPaginated)`。
class BatchDownloadSelectionScope extends StatelessWidget {
  const BatchDownloadSelectionScope({
    super.key,
    required this.controllers,
    required this.child,
    this.activeIndex,
  });

  /// 本页所有的批量选择控制器（单 tab 页传一个）。
  final List<BatchSelectController<dynamic>> controllers;

  final Widget child;

  /// 当前活跃控制器的下标；返回 null 或越界表示当前 tab 不支持批量。
  /// 不传时默认第 0 个。
  final int Function()? activeIndex;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Obx(() {
      // 把每个控制器的可观察状态都读一遍，这样任意一个变化都会重建——
      // 只读活跃那个的话，切 tab 时另一个的状态变化收不到通知。
      final states = [
        for (final c in controllers) (c.isMultiSelect.value, c.selectedCount),
      ];

      final int index = activeIndex?.call() ?? 0;
      final bool inRange = index >= 0 && index < controllers.length;
      final controller = inRange ? controllers[index] : null;
      final bool active = inRange && states[index].$1;
      final int count = inRange ? states[index].$2 : 0;

      return BatchSelectionScope(
        active: active,
        selectedCount: count,
        actions: [
          GlassSelectionAction(
            icon: Icons.download,
            label: t.download.download,
            onPressed: (count == 0 || controller == null)
                ? null
                : () => BatchDownloadDialog.show<dynamic>(
                    // T 传 dynamic 也没问题：对话框会按列表首项的真实类型
                    // 判断走视频还是图库分支（见 _isVideoDownload）
                    mediaItems: controller.selectedMediaList,
                    onComplete: controller.exitMultiSelect,
                  ),
          ),
        ],
        onClear: controller?.clearSelection ?? () {},
        // 系统返回 / iOS 侧滑 / Esc 先退选择态，而不是把整页弹掉
        child: SelectionPopScope(
          active: active,
          onExit: () => controller?.exitMultiSelect(),
          child: child,
        ),
      );
    });
  }
}
