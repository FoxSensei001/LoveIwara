import 'dart:io';

import 'package:i_iwara/app/models/frame_interp/frame_interp_task.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/frame_interp/frame_interp_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 补帧功能在界面上共用的几样东西：发起补帧的唯一入口，以及把服务层的
/// 状态码翻成文案。
///
/// 「本机文件」和「下载列表」两处的菜单都从 [requestFrameInterpolation] 进，
/// 这样被拒绝时的提示、成功后的去向只有一份。

/// 这台设备、这一版应用有没有补帧可言。菜单项该不该露就看它。
bool get isFrameInterpSupported =>
    FrameInterpService.maybe?.isSupported ?? false;

/// 把一个本地视频加入补帧队列，并用 toast 告诉用户结果。
///
/// [title] / [thumbnail] 取发起补帧的那张卡片上的，只用于任务页展示。
Future<void> requestFrameInterpolation({
  required String sourcePath,
  String? title,
  String? thumbnail,
}) async {
  final service = FrameInterpService.maybe;
  final t = slang.t.frameInterp;
  if (service == null || !service.isSupported) {
    showAppToast(t.component.unsupported, type: AppToastType.warning);
    return;
  }
  final result = await service.enqueue(
    sourcePath: sourcePath,
    title: title,
    thumbnail: thumbnail,
    confirm: _confirmFrameInterpPlan,
  );
  if (result.declined) return;
  final reject = result.reject;
  if (reject == null) {
    showAppToast(
      t.toast.queued,
      type: AppToastType.success,
      actionLabel: t.viewTasks,
      onAction: NaviService.navigateToFrameInterpTaskListPage,
    );
    return;
  }
  // 这两种被拒，用户下一步要去的都是任务页：看排队、找成品。
  final leadsToTaskPage =
      reject == FrameInterpReject.alreadyQueued ||
      reject == FrameInterpReject.alreadyDone;
  showAppToast(
    frameInterpRejectText(reject),
    type: AppToastType.warning,
    actionLabel: leadsToTaskPage ? t.viewTasks : null,
    onAction: leadsToTaskPage
        ? NaviService.navigateToFrameInterpTaskListPage
        : null,
  );
}

/// 卡片 ⋮ 菜单里的「删除补帧版本」：确认后只删 [sourcePath] 的补帧成品（文件 +
/// 任务记录），原片不动。下载列表与本机文件两处共用这一份。
///
/// 删除本身走 [FrameInterpService.delete]（与「删除原片时连带补帧版」同一条
/// 路，库里成品那一行也由它清）。返回 true 表示确实删掉了。
Future<bool> confirmAndDeleteInterpolated(String sourcePath) async {
  final service = FrameInterpService.maybe;
  if (service == null || service.completedOutputFor(sourcePath) == null) {
    return false;
  }
  final t = slang.t.frameInterp;
  final confirmed = await showGlassAlertDialog<bool>(
    title: t.deleteInterpolatedOnlyTitle,
    content: Text(t.deleteInterpolatedOnlyBody),
    actions: [
      GlassDialogAction.pop(label: slang.t.common.cancel, emphasized: false),
      GlassDialogAction.pop(
        label: slang.t.common.delete,
        result: true,
        destructive: true,
      ),
    ],
  );
  if (confirmed != true) return false;
  // 弹窗开着时成品可能已经被别处删掉 / 换了一条任务：按现在的状态重新取。
  final task = service.taskForSource(sourcePath);
  if (task == null || task.status != FrameInterpStatus.completed) return false;
  final ok = await service.delete(task.id, deleteOutput: true);
  showAppToast(
    ok ? t.interpolatedDeleted : t.deleteInterpolatedFailed,
    type: ok ? AppToastType.success : AppToastType.error,
  );
  return ok;
}

/// 入队前的确认：这一份会从多少帧补到多少帧，以及哪些情况会让它从头来。
Future<bool> _confirmFrameInterpPlan(FrameInterpPlan plan) async {
  final t = slang.t.frameInterp.confirm;
  final confirmed = await showGlassAlertDialog<bool>(
    title: t.enqueueTitle,
    content: _FrameInterpPlanContent(plan: plan),
    actions: [
      GlassDialogAction.pop(label: slang.t.common.cancel, emphasized: false),
      GlassDialogAction.pop(label: t.enqueueAction, result: true),
    ],
  );
  return confirmed == true;
}

/// 确认弹窗的正文，三层由主到次：
///   1. 帧率变化（大字）——这是用户真正关心的那一个数；
///   2. 规格与「另存为新文件」（一行灰字）；
///   3. 什么情况会从头重来（浅底色提示块）——没有断点续跑，得事先说清
///      （2026-11-21 用户要求），但不能喧宾夺主，所以收进一块、列成短句。
class _FrameInterpPlanContent extends StatelessWidget {
  const _FrameInterpPlanContent({required this.plan});

  final FrameInterpPlan plan;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).frameInterp.confirm;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: cs.onSurfaceVariant,
    );
    final spec = [
      '${plan.width}×${plan.height}',
      if (plan.durationMs > 0) _formatDuration(plan.durationMs),
    ].join(' · ');
    final resetCases = [
      // iOS 切后台系统就不让用显卡了，任务被停下（FrameInterpError.backgrounded）；
      // 安卓 / 桌面有前台保活，切走照样跑，不该吓唬那边的用户。
      if (Platform.isIOS) t.resetBackground,
      t.resetClosed,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formatFrameRate(plan.sourceFps),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, size: 20, color: cs.primary),
            ),
            Text(
              formatFrameRate(plan.outputFps),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(t.fpsUnit, style: muted),
          ],
        ),
        const SizedBox(height: 4),
        Text(spec, style: muted),
        Text(t.saveNote, style: muted),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.restart_alt,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.resetTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      for (final line in resetCases)
                        Text('· $line', style: muted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(h > 0 ? 2 : 1, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$sec' : '$m:$sec';
  }
}

String frameInterpRejectText(FrameInterpReject reject) {
  final t = slang.t.frameInterp.reject;
  return switch (reject) {
    FrameInterpReject.componentNotReady =>
      slang.t.frameInterp.error.componentUnavailable,
    FrameInterpReject.sourceMissing => t.sourceMissing,
    FrameInterpReject.alreadyInterpolated => t.alreadyInterpolated,
    FrameInterpReject.alreadyQueued => t.alreadyQueued,
    FrameInterpReject.alreadyDone => t.alreadyDone,
    FrameInterpReject.hdr => t.hdr,
    FrameInterpReject.resolutionTooLarge => t.resolutionTooLarge,
    FrameInterpReject.unreadable => t.unreadable,
    FrameInterpReject.noGpu => t.noGpu,
  };
}

/// 任务失败 / 被打断的原因，给人看的那一句。
String frameInterpErrorText(int code) {
  final t = slang.t.frameInterp.error;
  return switch (code) {
    FrameInterpError.openInput => t.openInput,
    FrameInterpError.noVideo => t.noVideo,
    FrameInterpError.decoder => t.decoder,
    FrameInterpError.hdrUnsupported => t.hdrUnsupported,
    FrameInterpError.noGpu => t.noGpu,
    FrameInterpError.model => t.model,
    FrameInterpError.encoder => t.encoder,
    FrameInterpError.openOutput => t.openOutput,
    FrameInterpError.write => t.write,
    FrameInterpError.interpolate => t.interpolate,
    FrameInterpError.componentUnavailable => t.componentUnavailable,
    FrameInterpError.interrupted => t.interrupted,
    FrameInterpError.finalizeFailed => t.finalizeFailed,
    FrameInterpError.sourceMissing => t.sourceMissing,
    FrameInterpError.backgrounded => t.backgrounded,
    _ => t.unknown,
  };
}

String frameInterpStatusText(FrameInterpStatus status) {
  final t = slang.t.frameInterp.status;
  return switch (status) {
    FrameInterpStatus.pending => t.pending,
    FrameInterpStatus.running => t.running,
    FrameInterpStatus.completed => t.completed,
    FrameInterpStatus.failed => t.failed,
    FrameInterpStatus.cancelled => t.cancelled,
  };
}

/// 帧率的展示写法：整数帧率不带小数（`60`），其余保留两位（`59.94`）。
String formatFrameRate(double fps) {
  final rounded = fps.roundToDouble();
  return (fps - rounded).abs() < 0.01
      ? rounded.toStringAsFixed(0)
      : fps.toStringAsFixed(2);
}
