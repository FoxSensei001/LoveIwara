import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart'
    show AppLifecycleListener, AppLifecycleState;
import 'package:get/get.dart';
import 'package:i_iwara/app/models/frame_interp/frame_interp_task.model.dart';
import 'package:i_iwara/app/repositories/frame_interp_task_repository.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/download/download_keep_alive.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/frame_interp/frame_interp_bindings.dart';
import 'package:i_iwara/app/services/frame_interp/frame_interp_component.dart';
import 'package:i_iwara/app/services/frame_interp/system_vulkan_loader.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// 一个视频为什么不能加入补帧队列。
enum FrameInterpReject {
  /// 这份安装里的补帧组件用不了。
  componentNotReady,
  sourceMissing,

  /// 这个文件本身就是补帧的成品。
  alreadyInterpolated,
  alreadyQueued,

  /// 已经有一份现成的补帧版本。
  alreadyDone,
  hdr,
  resolutionTooLarge,
  unreadable,
  noGpu,
}

/// 入队前交给调用方确认的那几样：片源探测出来的规格，和补完会是多少帧。
typedef FrameInterpPlan = ({
  int width,
  int height,
  double sourceFps,
  double outputFps,
  int durationMs,
});

class FrameInterpEnqueueResult {
  const FrameInterpEnqueueResult.queued(FrameInterpTask this.task)
    : reject = null,
      declined = false;
  const FrameInterpEnqueueResult.rejected(
    FrameInterpReject this.reject, {
    this.task,
  }) : declined = false;

  /// 检查都过了，用户在确认那一步自己取消了。不是错误，不用提示。
  const FrameInterpEnqueueResult.declined()
    : task = null,
      reject = null,
      declined = true;

  /// 入队成功时是新建的任务；被 [FrameInterpReject.alreadyQueued] /
  /// [FrameInterpReject.alreadyDone] 挡下时是已有的那一条。
  final FrameInterpTask? task;
  final FrameInterpReject? reject;
  final bool declined;

  bool get ok => reject == null && !declined;
}

/// 正在跑的那条任务的实时进度。只在内存里，不落库。
class FrameInterpProgress {
  const FrameInterpProgress({
    required this.taskId,
    required this.progress,
    required this.framesWritten,
    required this.framesPerSecond,
    required this.encoder,
  });

  final String taskId;

  /// 0.0 ~ 1.0
  final double progress;
  final int framesWritten;

  /// 成品帧的产出速度（帧/秒，整段平均）。和成品帧率相比就知道是几倍速。
  final double framesPerSecond;
  final String encoder;
}

class _ActiveJob {
  _ActiveJob({
    required this.taskId,
    required this.job,
    required this.tempPath,
    required this.spec,
  });

  final String taskId;
  final Pointer<FiJob> job;
  final String tempPath;
  final FrameInterpLibrarySpec spec;
  final Stopwatch clock = Stopwatch()..start();
  Timer? timer;

  /// 收尾（销毁作业、落库、清场）全部做完时完成。
  final Completer<void> done = Completer<void>();

  /// 用户在它跑着的时候点了删除：收尾时不留记录。
  bool deleteWhenStopped = false;

  /// iOS：应用切到后台，系统不让再用显卡，是我们替用户停的。收尾时记成
  /// [FrameInterpError.backgrounded]，回到前台自动重来。
  bool suspendedForBackground = false;

  /// 轮询过几拍了。
  int ticks = 0;

  /// 一旦为 true，[job] 指向的内存随时可能已经被释放：从这一刻起，除了拿到
  /// 销毁权的那一方，谁都不许再把这个指针交给引擎——哪怕只是读个状态。
  /// 置 true 的同时也就拿走了唯一的销毁权，所以销毁只会发生一次。
  bool finishing = false;
}

const int _vulkanLoaderUnsafe = -1;

typedef _ProbeOutcome = ({
  int code,
  int width,
  int height,
  double fps,
  bool isHdr,
  int durationMs,
});

Future<_ProbeOutcome> _probeInIsolate(
  FrameInterpLibrarySpec spec,
  String path,
) {
  return Isolate.run(() {
    final library = FrameInterpLibrary.open(spec);
    final result = calloc<FiProbeResult>();
    final nativePath = path.toNativeUtf8();
    try {
      result.ref.structSize = sizeOf<FiProbeResult>();
      final code = library.bindings.probe(nativePath, result);
      final r = result.ref;
      return (
        code: code,
        width: r.width,
        height: r.height,
        fps: r.fpsDen > 0 ? r.fpsNum / r.fpsDen : 0.0,
        isHdr: r.isHdr != 0,
        durationMs: r.durationUs ~/ 1000,
      );
    } finally {
      calloc.free(nativePath);
      calloc.free(result);
      library.close();
    }
  });
}

/// 可用显卡的数量。返回 [_vulkanLoaderUnsafe] 表示没数：进程里的 Vulkan
/// 加载器不是系统那份，这时一碰显卡整个应用就崩。
Future<int> _gpuCountInIsolate(FrameInterpLibrarySpec spec) {
  return Isolate.run(() {
    final library = FrameInterpLibrary.open(spec);
    try {
      if (!SystemVulkanLoader.isActive) return _vulkanLoaderUnsafe;
      return library.bindings.gpuCount();
    } finally {
      library.close();
    }
  });
}

Future<void> _destroyInIsolate(FrameInterpLibrarySpec spec, int jobAddress) {
  return Isolate.run(() {
    final library = FrameInterpLibrary.open(spec);
    try {
      library.bindings.jobDestroy(Pointer<FiJob>.fromAddress(jobAddress));
    } finally {
      library.close();
    }
  });
}

/// 离线补帧：把本地视频处理成两倍帧率的新文件。
///
/// # 为什么是「离线」
///
/// 实时补帧得在一帧的时间里（十几毫秒）算完，各平台只能各自去借厂商接口，覆盖
/// 参差不齐。离线处理没有这个时限，一套算法（RIFE）在所有平台上都能用；代价是
/// 要等，以及多占一份文件的空间。
///
/// 引擎是随安装包带着的一组原生库（见 [FrameInterpComponent]），这里通过
/// dart:ffi 调它。
///
/// # 几条不变式
///
/// - **一次只跑一条。** 补帧会把显卡吃满，并行只会让两条都更慢，显存还可能不够。
/// - **引擎的阻塞调用一律不上主 isolate。** 探测片源、数显卡、销毁作业都可能
///   卡上百毫秒到一两秒，统统丢进后台 isolate；主 isolate 只做「读几个原子量」
///   的轮询。
/// - **成品先写到 `.part`，跑完再改名。** 媒体库扫描随时可能扫到片源所在的
///   目录，不能让它把写到一半的文件当成视频收进去。
/// - **上次没跑完的任务不自动续跑。** 应用一启动就把显卡吃满是件很突兀的事，
///   由用户自己点重试。
class FrameInterpService extends GetxService {
  FrameInterpService({
    FrameInterpTaskRepository? repository,
    FrameInterpComponent? component,
    void Function(FrameInterpTask task)? onTaskFinished,
  }) : _repositoryOverride = repository,
       component = component ?? FrameInterpComponent(),
       _onTaskFinished = onTaskFinished ?? _announce;

  /// 任务跑完（成功或失败）时叫一声。默认弹 toast；测试里换成别的。
  final void Function(FrameInterpTask task) _onTaskFinished;

  /// 补帧动辄几分钟，用户多半早就离开任务页了，跑完得主动告诉他。
  /// 取消不提示：那是用户自己刚点的。
  static void _announce(FrameInterpTask task) {
    final t = slang.t.frameInterp;
    final completed = task.status == FrameInterpStatus.completed;
    showAppToast(
      completed
          ? t.toast.completed(title: task.title)
          : t.toast.failed(title: task.title),
      type: completed ? AppToastType.success : AppToastType.error,
      actionLabel: t.viewTasks,
      onAction: NaviService.navigateToFrameInterpTaskListPage,
    );
  }

  void _notifyFinished(FrameInterpTask task) {
    try {
      _onTaskFinished(task);
    } catch (e) {
      LogUtils.w('补帧结束提示失败: $e', _tag);
    }
  }

  static const String _tag = 'FrameInterpService';

  /// 长边上限。再大的画面显存吃不消，而且这类片源本身就罕见。
  static const int maxLongSide = 4096;

  /// 成品文件名在扩展名前面插的标记。
  static const String outputMarker = '.fi2x';

  /// 服务没注册时安全地返回 null（启动早期、测试里）。
  static FrameInterpService? get maybe => Get.isRegistered<FrameInterpService>()
      ? Get.find<FrameInterpService>()
      : null;

  final FrameInterpTaskRepository? _repositoryOverride;
  late final FrameInterpTaskRepository _repository =
      _repositoryOverride ?? FrameInterpTaskRepository();

  final FrameInterpComponent component;

  /// 全部任务，新的在前。
  final RxList<FrameInterpTask> tasks = <FrameInterpTask>[].obs;

  /// 正在跑的那条的实时进度；没有任务在跑时为 null。
  final Rx<FrameInterpProgress?> activeProgress = Rx<FrameInterpProgress?>(
    null,
  );

  /// 「哪些文件是补帧成品 / 哪些片源有补帧版本」这组事实每变一次就加一。
  /// 卡片在 Obx 里读它，就能在任务完成、被删时自己刷新角标。
  final RxInt revision = 0.obs;

  /// 成品还在磁盘上的已完成任务：成品路径 key → 任务。
  final Map<String, FrameInterpTask> _byOutputKey = {};

  /// 每个片源最新的一条任务：片源路径 key → 任务。
  final Map<String, FrameInterpTask> _bySourceKey = {};

  /// 记录是「已完成」但成品文件已经不在了的任务 id。
  final Set<String> _missingOutputs = {};

  _ActiveJob? _active;
  int? _gpuCount;
  bool _pumping = false;

  /// 应用正在退出：不再接新活，也不再从队列里拉下一条。
  bool _shuttingDown = false;

  /// iOS：应用在后台。这期间不开新作业（系统不让后台用显卡），回到前台再接着排。
  bool _suspended = false;
  AppLifecycleListener? _lifecycle;

  /// 安卓常驻通知里补帧那一项的键，见 [DownloadKeepAlive.extras]。
  static const String _keepAliveKey = 'frameInterp';

  /// 启动时那次恢复。入队要等它跑完——恢复的最后一步是拿库里读出来的列表
  /// 整个覆盖 [tasks]，在那之前插进去的任务会被它抹掉。
  late final Future<void> _restored;

  /// 这一版应用、这台设备上有没有补帧功能可言。入口该不该露就看它。
  bool get isSupported => component.isReady;

  @override
  void onInit() {
    super.onInit();
    _restored = _restore();
    if (Platform.isIOS) {
      _lifecycle = AppLifecycleListener(onStateChange: _onLifecycleChanged);
    }
  }

  @override
  void onClose() {
    _lifecycle?.dispose();
    _lifecycle = null;
    super.onClose();
  }

  /// iOS 不许后台程序用显卡：提交上去的计算会直接报错，任务就会以「处理失败」
  /// 收场，看起来像是片子有问题。所以一离开前台就主动停掉，记成「切到后台」，
  /// 回到前台再从头跑——补帧没法从断点续上。
  void _onLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden || AppLifecycleState.paused:
        if (_suspended) return;
        _suspended = true;
        final active = _active;
        if (active != null && !active.finishing) {
          active.suspendedForBackground = true;
          component.load().bindings.jobCancel(active.job);
        }
      case AppLifecycleState.resumed:
        if (!_suspended) return;
        _suspended = false;
        final interrupted = tasks
            .where(
              (task) =>
                  task.status == FrameInterpStatus.cancelled &&
                  task.errorCode == FrameInterpError.backgrounded,
            )
            .map((task) => task.id)
            .toList();
        // retry 会顺手拉起队列；一条都没有时也得拉一下，后台期间排进来的还等着。
        for (final id in interrupted) {
          retry(id);
        }
        unawaited(_pump());
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _restore() async {
    try {
      await component.refresh();
      if (!isSupported) return;

      final loaded = await _rebaseStaleContainerPaths(_repository.loadAll());
      final now = DateTime.now().millisecondsSinceEpoch;
      final restored = <FrameInterpTask>[];
      for (final task in loaded) {
        if (task.status.isActive) {
          // 上次退出时还没跑完。不自动续跑，标成「被打断」等用户重试。
          final interrupted = task.copyWith(
            status: FrameInterpStatus.cancelled,
            errorCode: FrameInterpError.interrupted,
            updatedAt: now,
          );
          _repository.updateState(interrupted);
          unawaited(_deleteTemp(task));
          restored.add(interrupted);
        } else {
          // 退出时没等到引擎停下来的那种情况：记录已经写成「被打断」，
          // 半成品却还被引擎占着删不掉，留到这里补删。
          if (task.errorCode == FrameInterpError.interrupted) {
            unawaited(_deleteTemp(task));
          }
          restored.add(task);
        }
      }
      for (final task in restored) {
        if (task.status == FrameInterpStatus.completed &&
            !await File(task.outputPath).exists()) {
          _missingOutputs.add(task.id);
        }
      }
      tasks.assignAll(restored);
      _rebuildIndexes();
    } catch (e, stack) {
      LogUtils.e('恢复补帧任务失败: $e', tag: _tag, error: e, stackTrace: stack);
    }
  }

  /// iOS 更新应用后沙盒容器换了路径，库里记的片源 / 成品 / 本地封面还指着旧
  /// 容器。和下载记录的修正是同一件事，见
  /// `DownloadRelocationService.repairSandboxContainerPaths`。
  ///
  /// 只在原路径不在、换到当前容器后**确实有**东西时才改：片源、封面、已完成的
  /// 成品要求文件在；还没生成的成品要求它的文件夹在。别的应用容器里的路径
  /// （用户从文件 App 选来的）形状一样，这条核对挡住把它们误改进本应用容器。
  ///
  /// 出任何错都原样返回 [loaded]：修不了路径不该连任务列表一起丢掉。
  Future<List<FrameInterpTask>> _rebaseStaleContainerPaths(
    List<FrameInterpTask> loaded,
  ) async {
    if (!Platform.isIOS || loaded.isEmpty) return loaded;
    try {
      final anchor = await DownloadPathService.currentContainerAnchor();
      Future<bool> exists(String path) async =>
          await FileSystemEntity.type(path) != FileSystemEntityType.notFound;
      Future<String?> rebase(String? path, {bool parentOnly = false}) async {
        if (path == null || !p.isAbsolute(path)) return null;
        final rebased = DownloadPathService.rebaseSandboxPath(path, anchor);
        if (rebased == null || await exists(path)) return null;
        final normalized = p.normalize(rebased);
        final probe = parentOnly ? p.dirname(normalized) : normalized;
        return await exists(probe) ? normalized : null;
      }

      final result = <FrameInterpTask>[];
      var fixed = 0;
      for (final task in loaded) {
        final source = await rebase(task.sourcePath);
        final output = await rebase(
          task.outputPath,
          parentOnly: task.status != FrameInterpStatus.completed,
        );
        final thumbnail = await rebase(task.thumbnail);
        if (source == null && output == null && thumbnail == null) {
          result.add(task);
          continue;
        }
        final moved = task.copyWith(
          sourcePath: source,
          outputPath: output,
          thumbnail: thumbnail,
        );
        _repository.updatePaths(moved);
        result.add(moved);
        fixed++;
      }
      if (fixed > 0) {
        LogUtils.i('沙盒容器换了路径，已把 $fixed 条补帧任务改指到新容器', _tag);
      }
      return result;
    } catch (e, stack) {
      LogUtils.e('修正补帧任务路径失败，按原样恢复', tag: _tag, error: e, stackTrace: stack);
      return loaded;
    }
  }

  // ---- 查询 ---------------------------------------------------------------

  /// 这个文件是不是补帧的成品。
  bool isInterpolatedOutput(String path) =>
      _byOutputKey.containsKey(FrameInterpTask.pathKey(path));

  /// 这个文件作为成品对应的任务（用来取帧率等信息）。
  FrameInterpTask? taskForOutput(String path) =>
      _byOutputKey[FrameInterpTask.pathKey(path)];

  /// 这个片源最新的一条任务，不管什么状态。
  FrameInterpTask? taskForSource(String path) =>
      _bySourceKey[FrameInterpTask.pathKey(path)];

  /// 这个片源现成可播的补帧版本的路径；没有则为 null。
  String? completedOutputFor(String sourcePath) {
    final task = taskForSource(sourcePath);
    if (task == null || task.status != FrameInterpStatus.completed) return null;
    return _missingOutputs.contains(task.id) ? null : task.outputPath;
  }

  /// 记录显示已完成，但成品文件已经被用户在别处删掉 / 挪走了。
  bool isOutputMissing(FrameInterpTask task) =>
      _missingOutputs.contains(task.id);

  int get activeCount => tasks.where((task) => task.status.isActive).length;

  void _rebuildIndexes() {
    _byOutputKey.clear();
    _bySourceKey.clear();
    // tasks 是新的在前；倒着走，让每个片源最后留下的是最新那条。
    for (final task in tasks.reversed) {
      _bySourceKey[task.sourceKey] = task;
      if (task.status == FrameInterpStatus.completed &&
          !_missingOutputs.contains(task.id)) {
        _byOutputKey[task.outputKey] = task;
      }
    }
    revision.value++;
    // 任务的增删、状态变化都从这里过，所以「要不要撑着进程 / 亮着屏」也在这里判。
    _syncKeepAlive();
    _syncWakelock();
  }

  bool _wakelockHeld = false;

  /// iOS：锁屏就等于切到后台，任务会被停掉重来，所以跑着的时候别让屏幕自己
  /// 熄掉。安卓靠前台服务里的唤醒锁，熄屏照样跑，不需要亮屏。
  void _syncWakelock({bool refresh = false}) {
    if (!Platform.isIOS) return;
    final want = tasks.any((task) => task.status == FrameInterpStatus.running);
    if (want == _wakelockHeld && !(want && refresh)) return;
    _wakelockHeld = want;
    // 播放器停播时会无差别地把常亮关掉，所以跑着的时候隔一阵再开一次（refresh）。
    unawaited(
      (want ? WakelockPlus.enable() : WakelockPlus.disable()).catchError(
        (Object e) => LogUtils.w('切换屏幕常亮失败: $e', _tag),
      ),
    );
  }

  // ---- 入队 ---------------------------------------------------------------

  /// 成品放在片源旁边，文件名多一个 [outputMarker]。
  ///
  /// 容器跟着片源走：mp4 还是 mp4，其余一律 mkv——mkv 什么音轨都收，不会出现
  /// 「片源的音频编码 mp4 不认」而整单失败。mov 也归 mkv：相机拍出来的 mov
  /// 常带 PCM 音轨，mp4 不收。
  ///
  /// [taken] 判断一个候选路径是不是已经被别的任务占了。同目录下的
  /// `clip.mp4` 和 `clip.m4v` 本来会落到同一个成品名上，后跑完的会把先跑完的
  /// 覆盖掉；撞了就把原扩展名也编进文件名里。
  static String outputPathFor(
    String sourcePath, {
    bool Function(String candidate)? taken,
  }) {
    final extension = p.extension(sourcePath).toLowerCase();
    const mp4Family = {'.mp4', '.m4v'};
    final outputExtension = mp4Family.contains(extension) ? '.mp4' : '.mkv';
    final base = p.withoutExtension(sourcePath);
    final plain = '$base$outputMarker$outputExtension';
    if (taken == null || !taken(plain)) return plain;
    final tag = extension.isEmpty ? '' : '.${extension.substring(1)}';
    var candidate = '$base$tag$outputMarker$outputExtension';
    for (var n = 2; taken(candidate); n++) {
      candidate = '$base$tag$outputMarker.$n$outputExtension';
    }
    return candidate;
  }

  /// 这个成品路径是不是已经归某条任务了。
  bool _outputTaken(String outputPath) {
    final key = FrameInterpTask.pathKey(outputPath);
    return tasks.any((task) => task.outputKey == key);
  }

  static String _formatNameFor(String outputPath) =>
      p.extension(outputPath).toLowerCase() == '.mp4' ? 'mp4' : 'matroska';

  /// 把一个本地视频加入补帧队列。
  ///
  /// [title] / [thumbnail] 只用于任务页的展示，取发起补帧的那张卡片上的即可。
  ///
  /// [confirm] 在所有检查都通过、片源帧率已经探测出来之后才调用：用户看到
  /// 的「X 帧 → Y 帧」是真实值，被拒的视频也不会先弹一次确认。返回 false
  /// 得到 [FrameInterpEnqueueResult.declined]。
  Future<FrameInterpEnqueueResult> enqueue({
    required String sourcePath,
    String? title,
    String? thumbnail,
    Future<bool> Function(FrameInterpPlan plan)? confirm,
  }) async {
    await _restored;
    if (_shuttingDown || !component.isReady) {
      return const FrameInterpEnqueueResult.rejected(
        FrameInterpReject.componentNotReady,
      );
    }
    final spec = component.spec!;
    // 先在主 isolate 上把引擎加载起来并一直开着。后面的探测是在后台 isolate
    // 里开了再关的，要是进程里没有别人拿着句柄，每探测一次整套 DLL 就被卸载
    // 一次——ncnn 和 OpenMP 运行时未必经得起反复装卸。
    try {
      component.load();
    } catch (_) {
      return const FrameInterpEnqueueResult.rejected(
        FrameInterpReject.componentNotReady,
      );
    }
    final key = FrameInterpTask.pathKey(sourcePath);
    if (_byOutputKey.containsKey(key)) {
      return const FrameInterpEnqueueResult.rejected(
        FrameInterpReject.alreadyInterpolated,
      );
    }
    final existing = _bySourceKey[key];
    if (existing != null) {
      if (existing.status.isActive) {
        return FrameInterpEnqueueResult.rejected(
          FrameInterpReject.alreadyQueued,
          task: existing,
        );
      }
      if (existing.status == FrameInterpStatus.completed &&
          !_missingOutputs.contains(existing.id)) {
        return FrameInterpEnqueueResult.rejected(
          FrameInterpReject.alreadyDone,
          task: existing,
        );
      }
    }

    final source = File(sourcePath);
    if (!await source.exists()) {
      return const FrameInterpEnqueueResult.rejected(
        FrameInterpReject.sourceMissing,
      );
    }
    final sourceSize = await source.length();

    final _ProbeOutcome probe;
    try {
      probe = await _probeInIsolate(spec, sourcePath);
    } catch (e) {
      LogUtils.e('探测片源失败: $e', tag: _tag, error: e);
      return const FrameInterpEnqueueResult.rejected(
        FrameInterpReject.unreadable,
      );
    }
    if (probe.code != FrameInterpError.none || probe.fps <= 0) {
      return const FrameInterpEnqueueResult.rejected(
        FrameInterpReject.unreadable,
      );
    }
    if (probe.isHdr) {
      return const FrameInterpEnqueueResult.rejected(FrameInterpReject.hdr);
    }
    if (probe.width > maxLongSide || probe.height > maxLongSide) {
      return const FrameInterpEnqueueResult.rejected(
        FrameInterpReject.resolutionTooLarge,
      );
    }

    try {
      _gpuCount ??= await _gpuCountInIsolate(spec);
    } catch (e) {
      LogUtils.e('检测显卡失败: $e', tag: _tag, error: e);
      _gpuCount = null;
      return const FrameInterpEnqueueResult.rejected(FrameInterpReject.noGpu);
    }
    if (_gpuCount == _vulkanLoaderUnsafe) {
      // 不记下来：这一步没碰显卡，下次入队再看一眼不费什么。
      _gpuCount = null;
      LogUtils.w('进程里的 vulkan-1.dll 不是系统那份，不碰显卡', _tag);
      return const FrameInterpEnqueueResult.rejected(FrameInterpReject.noGpu);
    }
    if (_gpuCount == 0) {
      return const FrameInterpEnqueueResult.rejected(FrameInterpReject.noGpu);
    }

    if (confirm != null) {
      final accepted = await confirm((
        width: probe.width,
        height: probe.height,
        sourceFps: probe.fps,
        outputFps: probe.fps * 2,
        durationMs: probe.durationMs,
      ));
      if (!accepted) return const FrameInterpEnqueueResult.declined();
      // 弹窗开着的时候用户可能去把片源删了。
      if (!await source.exists()) {
        return const FrameInterpEnqueueResult.rejected(
          FrameInterpReject.sourceMissing,
        );
      }
    }

    // 上面几步都是 await（含等用户确认），期间同一个片源可能已经被另一次
    // 点击排进去了。
    final raced = _bySourceKey[key];
    if (raced != null && raced.status.isActive) {
      return FrameInterpEnqueueResult.rejected(
        FrameInterpReject.alreadyQueued,
        task: raced,
      );
    }
    if (_shuttingDown) {
      return const FrameInterpEnqueueResult.rejected(
        FrameInterpReject.componentNotReady,
      );
    }
    // 这个片源以前失败 / 取消过的旧记录：新任务顶替它们，不留着。否则旧的
    // 那条之后被点「重试」，就会和新任务抢同一个成品文件。
    final stale = tasks
        .where(
          (task) =>
              task.sourceKey == key &&
              !(task.status == FrameInterpStatus.completed &&
                  !_missingOutputs.contains(task.id)),
        )
        .toList();
    for (final old in stale) {
      _repository.delete(old.id);
      _missingOutputs.remove(old.id);
      tasks.removeWhere((task) => task.id == old.id);
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final resolvedTitle = (title == null || title.trim().isEmpty)
        ? p.basenameWithoutExtension(sourcePath)
        : title.trim();
    final task = FrameInterpTask(
      id: const Uuid().v4(),
      sourcePath: sourcePath,
      outputPath: outputPathFor(sourcePath, taken: _outputTaken),
      title: resolvedTitle,
      thumbnail: thumbnail,
      status: FrameInterpStatus.pending,
      width: probe.width,
      height: probe.height,
      sourceFps: probe.fps,
      durationMs: probe.durationMs,
      sourceSize: sourceSize,
      createdAt: now,
      updatedAt: now,
    );
    _repository.insert(task);
    tasks.insert(0, task);
    _rebuildIndexes();
    unawaited(_pump());
    return FrameInterpEnqueueResult.queued(task);
  }

  // ---- 管理 ---------------------------------------------------------------

  /// 取消一条排队中或正在跑的任务。记录留着，可以重试。
  void cancel(String taskId) {
    final active = _active;
    if (active != null && active.taskId == taskId) {
      // 已经在收尾的作业不用再取消（它跑完了），指针也不能再碰。
      if (!active.finishing) {
        component.load().bindings.jobCancel(active.job);
      }
      return; // 状态由轮询在引擎真正停下之后改。
    }
    final task = _find(taskId);
    if (task == null || task.status != FrameInterpStatus.pending) return;
    _replace(
      task.copyWith(
        status: FrameInterpStatus.cancelled,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// 把一条失败 / 已取消 / 成品已丢失的任务重新排队。
  void retry(String taskId) {
    final task = _find(taskId);
    if (task == null || task.status.isActive) return;
    if (task.status == FrameInterpStatus.completed &&
        !_missingOutputs.contains(task.id)) {
      return;
    }
    // 同一个片源或同一个成品名上已经有别的任务在排、在跑、或已经做完：
    // 再跑这一条只会把人家的成品覆盖掉。
    final conflict = tasks.any(
      (other) =>
          other.id != task.id &&
          (other.sourceKey == task.sourceKey ||
              other.outputKey == task.outputKey) &&
          (other.status.isActive ||
              (other.status == FrameInterpStatus.completed &&
                  !_missingOutputs.contains(other.id))),
    );
    if (conflict || _shuttingDown) return;
    _missingOutputs.remove(task.id);
    _replace(
      task.copyWith(
        status: FrameInterpStatus.pending,
        progress: 0,
        clearError: true,
        clearCompletedAt: true,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    unawaited(_pump());
  }

  /// 删掉一条任务记录。[deleteOutput] 为 true 时连成品文件一起删。
  ///
  /// 正在跑的任务会先被取消，等引擎停下来之后记录才真正消失。
  ///
  /// 返回 false 表示要删的成品删了之后**还在**（权限、被占用）：这时记录留着
  /// ——记录一删，成品就不再藏在原片那张卡后面，变成一张单独的卡，用户看到的
  /// 是「删了反而多出一张」。成品本来就读不到（已被删 / 卷没挂上）时照旧删记录、
  /// 返回 true，否则任务页里一条成品早没了的记录就永远删不掉。
  Future<bool> delete(String taskId, {bool deleteOutput = false}) async {
    final active = _active;
    if (active != null && active.taskId == taskId) {
      if (!active.finishing) {
        active.deleteWhenStopped = true;
        component.load().bindings.jobCancel(active.job);
        return true;
      }
      // 正好撞上收尾：指针不能再碰，等它收完，再按一条普通的已结束任务删。
      await active.done.future;
    }
    final task = _find(taskId);
    if (task == null) return true;
    if (deleteOutput && task.status == FrameInterpStatus.completed) {
      await _deleteQuietly(task.outputPath);
      final output = File(task.outputPath);
      if (await output.exists()) {
        LogUtils.w('补帧成品没删掉，保留任务记录: ${task.outputPath}', _tag);
        return false;
      }
      // 本机文件库里那一行也要一起去掉：记录删了以后成品不再被原片那张卡
      // 代表（见 LocalMediaRepository._itemFilter），留着就是一张指向已删
      // 文件的空卡，要等下次扫描才消失。
      // ⛔ 「文件不在」不等于「删掉了」：卷没挂上时 exists 一样是 false，文件
      // 其实还在。用父目录可达来分辨（同本机文件删除那套判据），读不到就别动库行。
      if (await output.parent.exists()) {
        try {
          LocalMediaRepository().deleteItemsByPath(task.outputPath);
        } catch (e) {
          LogUtils.w('清理补帧成品的本机文件条目失败: $e', _tag);
        }
      }
    }
    _remove(task);
    return true;
  }

  /// 播放一个本地视频时实际该打开的文件：有现成的补帧成品就用成品。
  ///
  /// 「默认看补帧版」是永久的（2026-11-21 用户定）：不记「上次看的是原片」，
  /// 每次都从这里重新判；只有菜单里的「播放原视频」会绕开它。
  ///
  /// ⛔ 成品在不在要现问一次：[_missingOutputs] 只在启动恢复时填，运行期间成品
  /// 被用户在文件管理器里删了 / 外置卷没挂上，内存里还当它在。这里是**默认**
  /// 播放路径，不问的话点卡片就是一个「文件不存在」，而原片明明还在。发现没了
  /// 就记下来（角标、菜单、详情页跟着刷新），这一次退回原片。
  static String preferredPlaybackPath(String path) {
    final service = maybe;
    final output = service?.completedOutputFor(path);
    if (service == null || output == null) return path;
    try {
      if (File(output).existsSync()) return output;
    } catch (_) {}
    final task = service.taskForSource(path);
    if (task != null && service._missingOutputs.add(task.id)) {
      // 推迟一拍：调用方可能正处在某次 build / 初始化里，同步改 revision 会让
      // 订阅它的 Obx 在 build 中途被标脏。
      scheduleMicrotask(service._rebuildIndexes);
    }
    return path;
  }

  /// 清掉所有已结束的任务记录（成品文件不动）。
  void clearFinished() {
    final finished = tasks.where((task) => !task.status.isActive).toList();
    if (finished.isEmpty) return;
    for (final task in finished) {
      _repository.delete(task.id);
      _missingOutputs.remove(task.id);
    }
    tasks.removeWhere((task) => !task.status.isActive);
    _rebuildIndexes();
  }

  FrameInterpTask? _find(String taskId) =>
      tasks.firstWhereOrNull((task) => task.id == taskId);

  void _replace(FrameInterpTask next) {
    final index = tasks.indexWhere((task) => task.id == next.id);
    if (index < 0) return;
    final previous = tasks[index];
    _repository.updateState(next);
    tasks[index] = next;
    _rebuildIndexes();
    // 所有改状态的路都从这里过，所以「跑完了」只在这一处判断：从进行中
    // 落到完成或失败。
    if (previous.status.isActive &&
        (next.status == FrameInterpStatus.completed ||
            next.status == FrameInterpStatus.failed)) {
      _notifyFinished(next);
    }
  }

  void _remove(FrameInterpTask task) {
    _repository.delete(task.id);
    _missingOutputs.remove(task.id);
    tasks.removeWhere((item) => item.id == task.id);
    _rebuildIndexes();
  }

  static Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      LogUtils.w('删除文件失败 $path: $e', _tag);
    }
  }

  /// 写到一半的成品放哪。
  ///
  /// 桌面和 iOS：成品旁边的 `.part`，跑完在同一块盘上改名，又快又不会被媒体库
  /// 当成视频收进去。
  ///
  /// 安卓：应用自己的外部缓存目录，挑和成品同一个存储卷的那个。共享存储里的
  /// 目录按文件类型收东西（`Movies/` 只收视频），`.part` 这种认不出类型的文件
  /// 根本建不出来；而直接写成 `.mp4` 的话，系统媒体库会把写到一半的文件收进相册。
  static Future<String> _tempPathFor(FrameInterpTask task) async {
    if (!Platform.isAndroid) return '${task.outputPath}.part';
    Directory? base;
    try {
      final candidates = await getExternalCacheDirectories() ?? const [];
      for (final dir in candidates) {
        if (_storageVolumeOf(dir.path) == _storageVolumeOf(task.outputPath)) {
          base = dir;
          break;
        }
      }
      base ??= candidates.firstOrNull;
    } catch (e) {
      LogUtils.w('取外部缓存目录失败: $e', _tag);
    }
    base ??= await getTemporaryDirectory();
    final folder = Directory(p.join(base.path, 'frame_interp'));
    await folder.create(recursive: true);
    return p.join(folder.path, '${task.id}.part');
  }

  /// 安卓路径所在的存储卷：`/storage/emulated/0`、`/storage/1234-ABCD` 这样。
  /// 认不出来时返回路径的头一段，只用来比「是不是同一个卷」。
  static String _storageVolumeOf(String path) {
    final parts = p.posix.split(p.posix.normalize(path));
    if (parts.length >= 4 && parts[1] == 'storage' && parts[2] == 'emulated') {
      return p.posix.joinAll(parts.take(4));
    }
    if (parts.length >= 3 && parts[1] == 'storage') {
      return p.posix.joinAll(parts.take(3));
    }
    return parts.length >= 2 ? p.posix.joinAll(parts.take(2)) : path;
  }

  static Future<void> _deleteTemp(FrameInterpTask task) async =>
      _deleteQuietly(await _tempPathFor(task));

  /// 把写好的成品挪到最终位置。同一块盘上就是改名；跨了卷（安卓的缓存目录和
  /// 成品不在一个卷上时）只能拷过去再删原件。
  static Future<void> _moveInto(String from, String to) async {
    try {
      await File(from).rename(to);
      return;
    } on FileSystemException catch (e) {
      LogUtils.i('改名不成（$e），改为拷贝', _tag);
    }
    await File(from).copy(to);
    await _deleteQuietly(from);
  }

  /// 安卓：补帧在跑或在排时，借下载的前台服务撑着进程，熄屏、切走都不停；
  /// 常驻通知里没有下载时就显示补帧进度。别的平台上这张表没人看，写了也无害。
  void _syncKeepAlive() {
    if (!Platform.isAndroid) return;
    final running = tasks.firstWhereOrNull(
      (task) => task.status == FrameInterpStatus.running,
    );
    final queued = tasks
        .where((task) => task.status == FrameInterpStatus.pending)
        .length;
    if (running == null && queued == 0) {
      DownloadKeepAlive.extras.remove(_keepAliveKey);
      return;
    }
    final t = slang.t.frameInterp.notification;
    final live = activeProgress.value;
    final fraction = running != null && live?.taskId == running.id
        ? live!.progress
        : null;
    final extra = KeepAliveExtra(
      title: queued > 0 ? t.titleWithQueue(count: queued) : t.title,
      text: running == null
          ? t.waiting
          : fraction == null
          ? running.title
          : '${running.title} · ${(fraction * 100).floor()}%',
      fraction: fraction,
    );
    if (DownloadKeepAlive.extras[_keepAliveKey] != extra) {
      DownloadKeepAlive.extras[_keepAliveKey] = extra;
    }
  }

  // ---- 执行 ---------------------------------------------------------------

  Future<void> _pump() async {
    if (_pumping || _active != null || _shuttingDown || _suspended) return;
    _pumping = true;
    try {
      // 最早排进来的先跑；tasks 是新的在前，所以从尾部找。
      FrameInterpTask? next;
      for (final task in tasks.reversed) {
        if (task.status == FrameInterpStatus.pending) {
          next = task;
          break;
        }
      }
      if (next == null) return;
      await _start(next);
    } finally {
      _pumping = false;
    }
    // _start 以失败告终时没有活跃作业，接着看下一条。
    if (_active == null &&
        !_shuttingDown &&
        tasks.any((task) => task.status == FrameInterpStatus.pending)) {
      unawaited(_pump());
    }
  }

  void _fail(FrameInterpTask task, int code, [String? detail]) {
    LogUtils.w('补帧任务失败 ${task.title}: code=$code $detail', _tag);
    _replace(
      task.copyWith(
        status: FrameInterpStatus.failed,
        errorCode: code,
        error: detail,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> _start(FrameInterpTask task) async {
    final spec = component.spec;
    if (!component.isReady || spec == null) {
      _fail(task, FrameInterpError.componentUnavailable);
      return;
    }
    final FrameInterpBindings bindings;
    try {
      bindings = component.load().bindings;
    } catch (e) {
      _fail(task, FrameInterpError.componentUnavailable, '$e');
      return;
    }
    // 入队时查过一次，但「重试」不经过入队。
    if (!SystemVulkanLoader.isActive) {
      _fail(
        task,
        FrameInterpError.noGpu,
        'vulkan-1.dll is not the system loader',
      );
      return;
    }
    if (!await File(task.sourcePath).exists()) {
      _fail(task, FrameInterpError.sourceMissing);
      return;
    }
    final tempPath = await _tempPathFor(task);
    await _deleteQuietly(tempPath);
    // 上面有 await：任务可能已经被用户取消或删掉了，应用也可能正在退出，或者
    // （iOS）刚切到后台——那就留在队列里，回到前台再开。
    final current = _find(task.id);
    if (_shuttingDown ||
        _suspended ||
        current == null ||
        current.status != FrameInterpStatus.pending) {
      return;
    }

    final options = calloc<FiJobOptions>();
    final input = task.sourcePath.toNativeUtf8();
    final output = tempPath.toNativeUtf8();
    final model = spec.modelDirectory.toNativeUtf8();
    final format = _formatNameFor(task.outputPath).toNativeUtf8();
    final Pointer<FiJob> job;
    try {
      options.ref
        ..structSize = sizeOf<FiJobOptions>()
        ..gpuIndex = -1
        ..inputPath = input
        ..outputPath = output
        ..modelDir = model
        ..codec = FiCodec.h264
        ..quality = FiQuality.balanced
        ..sceneDetect = 1
        ..reserved = 0
        ..outputFormat = format;
      job = bindings.jobCreate(options);
    } finally {
      // 引擎在 fi_job_create 里已经把这些串拷走了。
      calloc.free(input);
      calloc.free(output);
      calloc.free(model);
      calloc.free(format);
      calloc.free(options);
    }
    if (job == nullptr) {
      _fail(current, FrameInterpError.invalidArgument);
      return;
    }
    final started = bindings.jobStart(job);
    if (started != FrameInterpError.none) {
      try {
        await _destroyInIsolate(spec, job.address);
      } catch (e) {
        LogUtils.e('销毁补帧作业失败: $e', tag: _tag, error: e);
      }
      _fail(current, started);
      return;
    }

    final active = _ActiveJob(
      taskId: task.id,
      job: job,
      tempPath: tempPath,
      spec: spec,
    );
    _active = active;
    _replace(
      current.copyWith(
        status: FrameInterpStatus.running,
        progress: 0,
        clearError: true,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    activeProgress.value = FrameInterpProgress(
      taskId: task.id,
      progress: 0,
      framesWritten: 0,
      framesPerSecond: 0,
      encoder: '',
    );
    active.timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _poll(active, bindings),
    );
  }

  void _poll(_ActiveJob active, FrameInterpBindings bindings) {
    if (active.finishing) return;
    final state = bindings.jobState(active.job);
    final frames = bindings.jobFramesWritten(active.job);
    final seconds = active.clock.elapsedMilliseconds / 1000;
    activeProgress.value = FrameInterpProgress(
      taskId: active.taskId,
      progress: bindings.jobProgress(active.job).clamp(0.0, 1.0),
      framesWritten: frames,
      framesPerSecond: seconds > 0 ? frames / seconds : 0,
      encoder: bindings.jobEncoder(active.job).toDartString(),
    );
    _syncKeepAlive();
    // 500ms 一拍，20 拍约十秒。
    if (++active.ticks % 20 == 0) _syncWakelock(refresh: true);
    if (!FiState.isTerminal(state)) return;
    active.finishing = true;
    active.timer?.cancel();
    unawaited(_finish(active, bindings, state));
  }

  Future<void> _finish(
    _ActiveJob active,
    FrameInterpBindings bindings,
    int state,
  ) async {
    // 进到这里时 finishing 已经是 true：销毁权在我们手里，别人不会再碰指针。
    // 下面这几样必须赶在销毁之前读出来。
    var errorCode = FrameInterpError.unknown;
    var errorText = '';
    var encoder = '';
    var progress = 0.0;
    try {
      errorCode = bindings.jobErrorCode(active.job);
      progress = bindings.jobProgress(active.job).clamp(0.0, 1.0);
      encoder = bindings.jobEncoder(active.job).toDartString();
      errorText = bindings.jobError(active.job).toDartString();
    } catch (e) {
      // 字符串不是合法 UTF-8 之类。读不出来就用默认值，收尾照常往下走——
      // 在这里抛出去，作业没人销毁、队列也再不会动。
      LogUtils.w('读取补帧作业结果失败: $e', _tag);
    }
    try {
      // 销毁要等作业线程退出，放后台做。
      await _destroyInIsolate(active.spec, active.job.address);
    } catch (e) {
      LogUtils.e('销毁补帧作业失败: $e', tag: _tag, error: e);
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final task = _find(active.taskId);
    try {
      if (task == null) {
        await _deleteQuietly(active.tempPath);
      } else if (active.deleteWhenStopped) {
        await _deleteQuietly(active.tempPath);
        _remove(task);
      } else if (state == FiState.done) {
        await _complete(task, active.tempPath, encoder, now);
      } else if (state == FiState.cancelled || active.suspendedForBackground) {
        // 切到后台被我们停掉的，哪怕引擎赶在停下之前因为显卡被收走而报了错，
        // 根子也在「切到后台」，按它记，回到前台自动重来。
        await _deleteQuietly(active.tempPath);
        _replace(
          task.copyWith(
            status: FrameInterpStatus.cancelled,
            progress: progress,
            errorCode: active.suspendedForBackground
                ? FrameInterpError.backgrounded
                : null,
            encoder: encoder,
            updatedAt: now,
          ),
        );
      } else {
        await _deleteQuietly(active.tempPath);
        LogUtils.w('补帧任务失败 ${task.title}: code=$errorCode $errorText', _tag);
        _replace(
          task.copyWith(
            status: FrameInterpStatus.failed,
            progress: progress,
            errorCode: errorCode == FrameInterpError.none
                ? FrameInterpError.unknown
                : errorCode,
            error: errorText,
            encoder: encoder,
            updatedAt: now,
          ),
        );
      }
    } catch (e, stack) {
      LogUtils.e('补帧任务收尾失败: $e', tag: _tag, error: e, stackTrace: stack);
    } finally {
      // shutdownSync 可能已经把 _active 清掉了；只清自己的。
      if (identical(_active, active)) _active = null;
      activeProgress.value = null;
      _syncKeepAlive();
      active.done.complete();
      unawaited(_pump());
    }
  }

  Future<void> _complete(
    FrameInterpTask task,
    String tempPath,
    String encoder,
    int now,
  ) async {
    try {
      // 重试「成品已丢失」之外的情形下，目标位置不该有文件；真有就是上一次
      // 留下的同名成品，以这次的为准。
      await _deleteQuietly(task.outputPath);
      await _moveInto(tempPath, task.outputPath);
      final size = await File(task.outputPath).length();
      _missingOutputs.remove(task.id);
      _replace(
        task.copyWith(
          status: FrameInterpStatus.completed,
          progress: 1,
          outputSize: size,
          encoder: encoder,
          clearError: true,
          updatedAt: now,
          completedAt: now,
        ),
      );
      LogUtils.i('补帧完成 ${task.title} -> ${task.outputPath}', _tag);
    } catch (e) {
      await _deleteQuietly(tempPath);
      _replace(
        task.copyWith(
          status: FrameInterpStatus.failed,
          errorCode: FrameInterpError.finalizeFailed,
          error: '$e',
          encoder: encoder,
          updatedAt: now,
        ),
      );
    }
  }

  // ---- 退出 ---------------------------------------------------------------

  /// 应用退出前同步收尾：停掉正在跑的作业并销毁它。
  ///
  /// ⛔ 必须在进程结束前把作业销毁掉。引擎持有一个进程级的 Vulkan 实例，带着
  /// 活的实例退出，驱动的清理代码会崩（见 native/frame_interp 里 GpuSession
  /// 的注释）。这里是同步的、会短暂阻塞——退出路径上没有别的选择：异步的话
  /// 进程可能在它跑完之前就没了。
  void shutdownSync({Duration limit = const Duration(milliseconds: 2500)}) {
    _shuttingDown = true;
    final active = _active;
    if (active == null) return;
    active.timer?.cancel();
    // 已经在收尾：引擎早就停了（它的 GPU 实例在状态翻成终态之前就释放了），
    // 销毁权在 _finish 手里，这里什么都不该碰。
    if (active.finishing) return;
    active.finishing = true;
    try {
      final bindings = component.load().bindings;
      bindings.jobCancel(active.job);
      final clock = Stopwatch()..start();
      while (!FiState.isTerminal(bindings.jobState(active.job)) &&
          clock.elapsed < limit) {
        sleep(const Duration(milliseconds: 20));
      }
      final stopped = FiState.isTerminal(bindings.jobState(active.job));
      if (stopped) bindings.jobDestroy(active.job);
      final task = _find(active.taskId);
      if (task != null) {
        _repository.updateState(
          task.copyWith(
            status: FrameInterpStatus.cancelled,
            errorCode: FrameInterpError.interrupted,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
      // 没等到引擎停下来时文件还被它占着，删不掉；下次启动恢复时会补删。
      if (stopped) {
        final temp = File(active.tempPath);
        if (temp.existsSync()) temp.deleteSync();
      }
    } catch (e) {
      LogUtils.w('退出前收尾补帧作业失败: $e', _tag);
    } finally {
      _active = null;
    }
  }
}
