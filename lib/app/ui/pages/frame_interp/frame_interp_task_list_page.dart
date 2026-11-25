import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/frame_interp/frame_interp_service.dart';
import 'package:i_iwara/app/ui/pages/frame_interp/widgets/frame_interp_task_tile.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_grid_metrics.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

const _menuClearFinished = 'clearFinished';

/// 补帧任务管理页。
///
/// 页面自己不存任何状态，全部读 [FrameInterpService] 的 Rx——任务多半是在别的
/// 页面发起、在用户离开这里之后跑完的，以服务为唯一真源才不会两边对不上。
class FrameInterpTaskListPage extends StatelessWidget {
  const FrameInterpTaskListPage({super.key});

  /// 与下载列表同一套留白与分栏，两页切换时卡片边缘对得齐。
  static const double _gutter = 12;
  static const double _itemGap = 10;
  static const double _wideBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return Scaffold(
      body: GlassHeaderOverlay(
        liquid: true,
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        body: _buildBody(context, headerExtent),
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
              Expanded(child: GlassTitlePill(title: t.frameInterp.title)),
              const SizedBox(width: 8),
              GlassButtonGroup(
                children: [
                  Builder(
                    builder: (anchorContext) => GlassIconButton(
                      icon: const Icon(Icons.more_vert),
                      tooltip: t.common.more,
                      opensOverlay: true,
                      onPressed: () => _openMoreMenu(anchorContext),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMoreMenu(BuildContext anchorContext) async {
    final service = FrameInterpService.maybe;
    if (service == null) return;
    final t = slang.Translations.of(anchorContext).frameInterp;
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        GlassMenuOption<String>(
          value: _menuClearFinished,
          icon: Icons.cleaning_services_outlined,
          label: t.clearFinished,
        ),
      ],
    );
    switch (picked) {
      case _menuClearFinished:
        await _clearFinished(service);
    }
  }

  Future<void> _clearFinished(FrameInterpService service) async {
    final t = slang.t;
    final confirmed = await showGlassAlertDialog<bool>(
      title: t.frameInterp.confirm.clearTitle,
      content: Text(t.frameInterp.confirm.clearContent),
      actions: [
        GlassDialogAction.pop(label: t.common.cancel, emphasized: false),
        GlassDialogAction.pop(
          label: t.common.confirm,
          result: true,
          destructive: true,
        ),
      ],
    );
    if (confirmed == true) service.clearFinished();
  }

  Widget _buildBody(BuildContext context, double headerExtent) {
    final service = FrameInterpService.maybe;
    final t = slang.Translations.of(context).frameInterp;
    if (service == null || !service.isSupported) {
      return Padding(
        padding: EdgeInsets.only(top: headerExtent),
        child: MyEmptyWidget(message: t.component.unsupported),
      );
    }
    final double bottomInset =
        computeBottomSafeInset(MediaQuery.of(context)) + 16;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // 宽屏把行排成几列（一行最宽 560，再宽读起来太散），与下载列表一致。
        final columns = width >= _wideBreakpoint
            ? LocalGridMetrics.resolve(
                availableWidth: width - _gutter * 2,
                maxCellWidth: 560,
                spacing: _itemGap,
              ).crossAxisCount
            : 1;
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(padding: EdgeInsets.only(top: headerExtent + 8)),
            Obx(() {
              // 「成品是否已丢失」不在任务本身上，改动时只有 revision 会动。
              service.revision.value;
              final tasks = service.tasks.toList();
              if (tasks.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    // MyEmptyWidget 只有一行文案，提示接在主文案后面另起一行。
                    child: MyEmptyWidget(message: '${t.empty}\n${t.emptyHint}'),
                  ),
                );
              }
              final rows = (tasks.length / columns).ceil();
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(_gutter, 0, _gutter, bottomInset),
                sliver: SliverList.builder(
                  itemCount: rows,
                  itemBuilder: (context, row) {
                    final start = row * columns;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: _itemGap),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: _itemGap,
                        children: [
                          for (var c = 0; c < columns; c++)
                            Expanded(
                              child: start + c < tasks.length
                                  ? FrameInterpTaskTile(
                                      key: ValueKey(tasks[start + c].id),
                                      task: tasks[start + c],
                                      service: service,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
