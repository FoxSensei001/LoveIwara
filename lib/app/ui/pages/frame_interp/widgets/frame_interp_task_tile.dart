import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import 'package:i_iwara/app/models/frame_interp/frame_interp_task.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/frame_interp/frame_interp_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_scale.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_task_tile.dart'
    show formatDownloadBytes;
import 'package:i_iwara/app/ui/pages/download/widgets/relocation_detail_widgets.dart'
    show revealInFileManager;
import 'package:i_iwara/app/ui/pages/frame_interp/frame_interp_launcher.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_container_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_image.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/motion/ios_motion.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

enum _TaskAction { play, revealInFolder, cancel, retry, delete }

bool get _isDesktop =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

/// 补帧任务的一行。
///
/// 外形照抄下载页的长条卡（封面贴左沿、两行标题、右上角 ⋮、桌面右键同一张
/// 菜单）：两页挨着用，同一类东西长两个样子会让人以为是两种东西。
class FrameInterpTaskTile extends StatelessWidget {
  const FrameInterpTaskTile({
    super.key,
    required this.task,
    required this.service,
  });

  final FrameInterpTask task;
  final FrameInterpService service;

  static const EdgeInsetsDirectional _pad = EdgeInsetsDirectional.fromSTEB(
    12,
    9,
    0,
    9,
  );
  static const double _gap = 4;

  /// 进度条的高度。所有行都按「有进度条」留位：排队中的任务一开跑，行高不跳。
  static const double _barHeight = 3;

  bool get _outputMissing =>
      task.status == FrameInterpStatus.completed &&
      service.isOutputMissing(task);

  bool get _playable =>
      task.status == FrameInterpStatus.completed && !_outputMissing;

  List<_TaskAction> get _actions => switch (task.status) {
    FrameInterpStatus.completed =>
      _outputMissing
          ? const [_TaskAction.retry, _TaskAction.delete]
          : [
              _TaskAction.play,
              if (_isDesktop) _TaskAction.revealInFolder,
              _TaskAction.delete,
            ],
    FrameInterpStatus.pending ||
    FrameInterpStatus.running => const [_TaskAction.cancel],
    FrameInterpStatus.failed || FrameInterpStatus.cancelled => const [
      _TaskAction.retry,
      _TaskAction.delete,
    ],
  };

  Future<void> _openMenu(BuildContext anchorContext, {Offset? at}) async {
    final t = slang.t.frameInterp.actions;
    final entries = <GlassMenuEntry>[];
    for (final action in _actions) {
      // 删除记录单独成组，和「播放 / 重试」这类无害动作隔开。
      if (action == _TaskAction.delete && entries.isNotEmpty) {
        entries.add(const GlassMenuSeparator());
      }
      entries.add(
        GlassMenuOption<_TaskAction>(
          value: action,
          icon: switch (action) {
            _TaskAction.play => Icons.play_circle_outline,
            _TaskAction.revealInFolder => Icons.folder_open,
            _TaskAction.cancel => Icons.cancel_outlined,
            _TaskAction.retry => Icons.refresh,
            _TaskAction.delete => Icons.delete_outline,
          },
          label: switch (action) {
            _TaskAction.play => t.play,
            _TaskAction.revealInFolder => t.revealInFolder,
            _TaskAction.cancel => t.cancel,
            _TaskAction.retry => t.retry,
            _TaskAction.delete => t.delete,
          },
          destructive: action == _TaskAction.delete,
        ),
      );
    }
    final picked = await showGlassMenu<_TaskAction>(
      anchorContext: anchorContext,
      globalAnchor: at == null ? null : at & Size.zero,
      entries: entries,
    );
    if (picked != null) await _run(picked);
  }

  Future<void> _run(_TaskAction action) async {
    switch (action) {
      case _TaskAction.play:
        NaviService.navigateToLocalVideoPlayerPageFromPath(task.outputPath);
      case _TaskAction.revealInFolder:
        await revealInFileManager(task.outputPath);
      case _TaskAction.cancel:
        await _cancel();
      case _TaskAction.retry:
        service.retry(task.id);
      case _TaskAction.delete:
        await _delete();
    }
  }

  /// 排队中的取消什么都不丢，直接取消；跑着的会丢掉已算的进度，先问一句。
  ///
  /// 菜单是照着开菜单那一刻的状态建的，选完时它可能已经开跑了，所以这里以
  /// 服务的实时进度为准再判一次。
  Future<void> _cancel() async {
    final running =
        task.status == FrameInterpStatus.running ||
        service.activeProgress.value?.taskId == task.id;
    if (running) {
      final t = slang.t;
      final confirmed = await showGlassAlertDialog<bool>(
        title: t.frameInterp.confirm.cancelTitle,
        content: Text(t.frameInterp.confirm.cancelContent),
        actions: [
          GlassDialogAction.pop(label: t.common.cancel, emphasized: false),
          GlassDialogAction.pop(
            label: t.frameInterp.actions.cancel,
            result: true,
            destructive: true,
          ),
        ],
      );
      if (confirmed != true) return;
    }
    service.cancel(task.id);
  }

  /// 只有成品还在时才给「同时删除补帧文件」：文件已经不在了，勾不勾都一样。
  Future<void> _delete() async {
    final t = slang.t;
    final withOutputOption = _playable;
    final deleteOutput = ValueNotifier<bool>(false);
    final confirmed = await showGlassAlertDialog<bool>(
      title: t.frameInterp.confirm.deleteTitle,
      content: withOutputOption
          ? _DeleteContent(deleteOutput: deleteOutput)
          : Text(t.frameInterp.confirm.deleteContent),
      actions: [
        GlassDialogAction.pop(label: t.common.cancel, emphasized: false),
        GlassDialogAction.pop(
          label: t.common.delete,
          result: true,
          destructive: true,
        ),
      ],
    );
    // ⛔ 不 dispose：future 在 pop 那一刻就完成，退场动画期间复选框还挂着它。
    final withOutput = deleteOutput.value;
    if (confirmed != true) return;
    await service.delete(task.id, deleteOutput: withOutputOption && withOutput);
  }

  static double _rowHeight(BuildContext context, double coverWidth) {
    final text =
        _pad.vertical +
        LocalCardText.titleExtent(context) +
        _gap +
        LocalCardText.metaExtent(context) +
        _gap +
        LocalCardText.metaExtent(context) +
        _gap +
        _barHeight;
    return math.max(coverWidth * 9 / 16, text).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final coverWidth = narrow ? 118.0 : 132.0;
    final shape = RoundedSuperellipseBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(LocalCardShell.radius),
      ),
      side: BorderSide(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
    );

    return RepaintBoundary(
      child: GestureDetector(
        onSecondaryTapUp: _isDesktop
            ? (details) => _openMenu(context, at: details.globalPosition)
            : null,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: shape,
            shadows: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: PressScale(
            onTap: _playable
                ? () => NaviService.navigateToLocalVideoPlayerPageFromPath(
                    task.outputPath,
                  )
                : null,
            builder: (context, press) => Transform.scale(
              scale: 1 - 0.025 * press,
              child: Material(
                color: theme.colorScheme.surface,
                clipBehavior: Clip.antiAlias,
                shape: shape,
                child: Stack(
                  children: [
                    _buildBody(context, coverWidth),
                    if (press > 0)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ColoredBox(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.06 * press.clamp(0.0, 1.0),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, double coverWidth) {
    final ft = slang.Translations.of(context).frameInterp;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 2,
      child: Builder(
        builder: (context) => SizedBox(
          height: _rowHeight(context, coverWidth),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: coverWidth, child: _buildCover(context)),
              Expanded(
                child: Padding(
                  padding: _pad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: LocalCardText.titleExtent(context),
                        child: Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          strutStyle: const StrutStyle(
                            fontSize: 14,
                            height: 1.22,
                            forceStrutHeight: true,
                          ),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 14,
                                height: 1.22,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const Spacer(),
                      LocalCardText.metaText(
                        context,
                        ft.specLine(
                          width: task.width,
                          height: task.height,
                          from: formatFrameRate(task.sourceFps),
                          to: formatFrameRate(task.outputFps),
                        ),
                      ),
                      const SizedBox(height: _gap),
                      _buildStatus(context),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 2),
                child: Align(
                  alignment: Alignment.topCenter,
                  // 按 ⋮ 时整张卡别跟着缩。
                  child: PressScaleClaim(
                    child: DownloadMoreButton(
                      tooltip: slang.Translations.of(context).common.more,
                      onPressed: (anchorContext) => _openMenu(anchorContext),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: cs.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.movie_outlined, color: cs.onSurfaceVariant),
      ),
    );
    final thumbnail = task.thumbnail;
    if (thumbnail == null || thumbnail.isEmpty) return placeholder;
    if (thumbnail.startsWith('http://') || thumbnail.startsWith('https://')) {
      return LayoutBuilder(
        builder: (context, constraints) => CachedNetworkImage(
          imageUrl: thumbnail,
          fit: BoxFit.cover,
          memCacheWidth: LocalCoverImage.cacheWidthFor(
            context,
            constraints.maxWidth,
          ),
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => placeholder,
        ),
      );
    }
    // 本地封面走本机文件那套：解码尺寸有上限，路径指向视频时也认得出旁边的封面。
    return LocalCoverImage(path: thumbnail, placeholder: placeholder);
  }

  /// 说明行下面那一行状态（跑着的再加一条进度条），所有状态占同样的高。
  Widget _buildStatus(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ft = slang.Translations.of(context).frameInterp;
    final Widget line;
    switch (task.status) {
      case FrameInterpStatus.running:
        return _RunningProgress(taskId: task.id, service: service);
      case FrameInterpStatus.completed:
        line = _outputMissing
            ? LocalCardText.metaText(context, ft.outputMissing, color: cs.error)
            : LocalCardText.metaText(
                context,
                [
                  frameInterpStatusText(task.status),
                  if (task.outputSize > 0) formatDownloadBytes(task.outputSize),
                ].join(' · '),
              );
      case FrameInterpStatus.failed:
        line = LocalCardText.metaText(
          context,
          frameInterpErrorText(task.errorCode),
          color: cs.error,
        );
      case FrameInterpStatus.cancelled:
        // 「被应用退出打断」和「用户自己取消」都落在 cancelled，前者得说清楚，
        // 不然用户会以为是自己点的。
        line = LocalCardText.metaText(
          context,
          task.errorCode == FrameInterpError.interrupted ||
                  task.errorCode == FrameInterpError.backgrounded
              ? frameInterpErrorText(task.errorCode)
              : frameInterpStatusText(task.status),
        );
      case FrameInterpStatus.pending:
        line = LocalCardText.metaText(
          context,
          frameInterpStatusText(task.status),
        );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        line,
        const SizedBox(height: _gap + _barHeight),
      ],
    );
  }
}

/// 跑着的那条的进度。
///
/// 单独一层 Obx：进度每秒刷两次，只该重建这一小块，不能把整张列表带着一起重建。
class _RunningProgress extends StatelessWidget {
  const _RunningProgress({required this.taskId, required this.service});

  final String taskId;
  final FrameInterpService service;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ft = slang.Translations.of(context).frameInterp;
    return Obx(() {
      final live = service.activeProgress.value;
      // 第一帧落盘之前引擎在加载模型、建 GPU 实例，进度恒为 0；这时显示
      // 「0% · 0.0 帧/秒」像是卡死了，所以按「准备中」算。
      final shown =
          live != null && live.taskId == taskId && live.framesWritten > 0
          ? live
          : null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LocalCardText.metaText(
            context,
            shown == null
                ? ft.preparing
                : ft.runningDetail(
                    percent: (shown.progress * 100).floor(),
                    speed: shown.framesPerSecond.toStringAsFixed(1),
                  ),
            color: cs.primary,
          ),
          const SizedBox(height: FrameInterpTaskTile._gap),
          ClipRRect(
            borderRadius: BorderRadius.circular(FrameInterpTaskTile._barHeight),
            child: LinearProgressIndicator(
              value: shown?.progress,
              minHeight: FrameInterpTaskTile._barHeight,
            ),
          ),
        ],
      );
    });
  }
}

class _DeleteContent extends StatelessWidget {
  const _DeleteContent({required this.deleteOutput});

  final ValueNotifier<bool> deleteOutput;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).frameInterp.confirm;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.deleteContent),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: deleteOutput,
          builder: (context, value, _) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: value,
            onChanged: (v) => deleteOutput.value = v ?? false,
            title: Text(t.deleteOutput),
          ),
        ),
      ],
    );
  }
}
