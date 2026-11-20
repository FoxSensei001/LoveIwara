import 'package:i_iwara/app/models/frame_interp/frame_interp_task.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/frame_interp/frame_interp_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
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
  );
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

String frameInterpRejectText(FrameInterpReject reject) {
  final t = slang.t.frameInterp.reject;
  return switch (reject) {
    FrameInterpReject.componentNotReady =>
      slang.t.frameInterp.error.componentUnavailable,
    FrameInterpReject.sourceMissing => t.sourceMissing,
    FrameInterpReject.alreadyInterpolated => t.alreadyInterpolated,
    FrameInterpReject.alreadyQueued => t.alreadyQueued,
    FrameInterpReject.alreadyDone => t.alreadyDone,
    FrameInterpReject.highFrameRate => t.highFrameRate,
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
