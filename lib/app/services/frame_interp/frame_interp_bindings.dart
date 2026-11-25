import 'dart:ffi';

import 'package:ffi/ffi.dart';

/// 补帧引擎（native/frame_interp）的 dart:ffi 绑定。
///
/// ⛔ 这里的结构体布局和函数签名必须与 `native/frame_interp/include/frame_interp.h`
/// 逐字段对上。引擎是按需下载的组件，应用和它不是同一次构建出来的，对不上不会
/// 编译报错，只会在运行时读到错位的内存。改头文件就改这里，并把两边的 ABI 版本号
/// 一起加一（[FrameInterpBindings.expectedAbi] / `FI_ABI_VERSION`）。

final class FiJobOptions extends Struct {
  @Uint32()
  external int structSize;

  @Int32()
  external int gpuIndex;

  external Pointer<Utf8> inputPath;
  external Pointer<Utf8> outputPath;
  external Pointer<Utf8> modelDir;

  @Int32()
  external int codec;

  @Int32()
  external int quality;

  @Int32()
  external int sceneDetect;

  @Int32()
  external int reserved;

  external Pointer<Utf8> outputFormat;
}

final class FiProbeResult extends Struct {
  @Uint32()
  external int structSize;

  @Int32()
  external int width;

  @Int32()
  external int height;

  @Int32()
  external int fpsNum;

  @Int32()
  external int fpsDen;

  @Int32()
  external int isHdr;

  @Int64()
  external int durationUs;

  @Int64()
  external int frameCount;
}

final class FiJob extends Opaque {}

/// 引擎一侧的作业状态（`FI_STATE_*`）。
abstract final class FiState {
  static const int pending = 0;
  static const int running = 1;
  static const int done = 2;
  static const int failed = 3;
  static const int cancelled = 4;

  static bool isTerminal(int state) => state >= done;
}

abstract final class FiCodec {
  static const int h264 = 0;
  static const int hevc = 1;
}

abstract final class FiQuality {
  static const int balanced = 0;
  static const int high = 1;
}

class FrameInterpBindings {
  FrameInterpBindings(DynamicLibrary library)
    : abiVersion = library.lookupFunction<Int32 Function(), int Function()>(
        'fi_abi_version',
      ),
      gpuCount = library.lookupFunction<Int32 Function(), int Function()>(
        'fi_gpu_count',
      ),
      probe = library
          .lookupFunction<
            Int32 Function(Pointer<Utf8>, Pointer<FiProbeResult>),
            int Function(Pointer<Utf8>, Pointer<FiProbeResult>)
          >('fi_probe'),
      jobCreate = library
          .lookupFunction<
            Pointer<FiJob> Function(Pointer<FiJobOptions>),
            Pointer<FiJob> Function(Pointer<FiJobOptions>)
          >('fi_job_create'),
      jobStart = library
          .lookupFunction<
            Int32 Function(Pointer<FiJob>),
            int Function(Pointer<FiJob>)
          >('fi_job_start'),
      jobCancel = library
          .lookupFunction<
            Void Function(Pointer<FiJob>),
            void Function(Pointer<FiJob>)
          >('fi_job_cancel'),
      jobState = library
          .lookupFunction<
            Int32 Function(Pointer<FiJob>),
            int Function(Pointer<FiJob>)
          >('fi_job_state'),
      jobProgress = library
          .lookupFunction<
            Double Function(Pointer<FiJob>),
            double Function(Pointer<FiJob>)
          >('fi_job_progress'),
      jobFramesWritten = library
          .lookupFunction<
            Int64 Function(Pointer<FiJob>),
            int Function(Pointer<FiJob>)
          >('fi_job_frames_written'),
      jobErrorCode = library
          .lookupFunction<
            Int32 Function(Pointer<FiJob>),
            int Function(Pointer<FiJob>)
          >('fi_job_error_code'),
      jobError = library
          .lookupFunction<
            Pointer<Utf8> Function(Pointer<FiJob>),
            Pointer<Utf8> Function(Pointer<FiJob>)
          >('fi_job_error'),
      jobEncoder = library
          .lookupFunction<
            Pointer<Utf8> Function(Pointer<FiJob>),
            Pointer<Utf8> Function(Pointer<FiJob>)
          >('fi_job_encoder'),
      jobDestroy = library
          .lookupFunction<
            Void Function(Pointer<FiJob>),
            void Function(Pointer<FiJob>)
          >('fi_job_destroy');

  /// 应用认的引擎 ABI 版本。组件报出来的不是这个数，就当作组件不可用。
  static const int expectedAbi = 1;

  final int Function() abiVersion;

  /// ⛔ 会临时建一次 Vulkan 实例，耗时在百毫秒量级：不要在主 isolate 上调。
  final int Function() gpuCount;

  /// ⛔ 要打开文件、读流信息：不要在主 isolate 上调。
  final int Function(Pointer<Utf8>, Pointer<FiProbeResult>) probe;

  final Pointer<FiJob> Function(Pointer<FiJobOptions>) jobCreate;
  final int Function(Pointer<FiJob>) jobStart;
  final void Function(Pointer<FiJob>) jobCancel;

  // 下面这几个只读原子量，随便在哪调都行。
  final int Function(Pointer<FiJob>) jobState;
  final double Function(Pointer<FiJob>) jobProgress;
  final int Function(Pointer<FiJob>) jobFramesWritten;
  final int Function(Pointer<FiJob>) jobErrorCode;
  final Pointer<Utf8> Function(Pointer<FiJob>) jobError;
  final Pointer<Utf8> Function(Pointer<FiJob>) jobEncoder;

  /// ⛔ 会等作业线程收尾（手头那一帧处理完 + 释放模型和 GPU 实例），可能阻塞
  /// 上百毫秒到一两秒：不要在主 isolate 上调。
  final void Function(Pointer<FiJob>) jobDestroy;
}
