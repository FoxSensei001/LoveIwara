import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/common.dart';

/// 补帧任务的状态。
///
/// 没有「暂停」：补帧中途停下来没法从断点接着跑（编码器状态、封装器的索引都在
/// 内存里），所以只有「取消」，取消后的任务可以整条重来。
enum FrameInterpStatus {
  pending,
  running,
  completed,
  failed,
  cancelled;

  static FrameInterpStatus parse(String? raw) {
    for (final value in FrameInterpStatus.values) {
      if (value.name == raw) return value;
    }
    return FrameInterpStatus.failed;
  }

  bool get isActive =>
      this == FrameInterpStatus.pending || this == FrameInterpStatus.running;
}

/// 失败原因。1~99 与引擎的 `FI_ERR_*` 一一对应（native/frame_interp 的头文件），
/// 100 以上是 Dart 这一侧自己的。界面按这个码挑文案，[FrameInterpTask.error]
/// 里的原文只进日志。
abstract final class FrameInterpError {
  static const int none = 0;
  static const int unknown = 1;
  static const int invalidArgument = 2;
  static const int openInput = 3;
  static const int noVideo = 4;
  static const int decoder = 5;
  static const int hdrUnsupported = 6;
  static const int noGpu = 7;
  static const int model = 8;
  static const int encoder = 9;
  static const int openOutput = 10;
  static const int write = 11;
  static const int interpolate = 12;

  /// 组件没装，或装的那份和应用对不上。
  static const int componentUnavailable = 100;

  /// 应用在任务跑到一半时退出了。
  static const int interrupted = 101;

  /// 成品写完了，却没能挪到最终位置。
  static const int finalizeFailed = 102;

  /// 片源文件不见了。
  static const int sourceMissing = 103;

  /// iOS：应用切到后台，系统不让再用显卡，任务被停下。回到前台会自动重来。
  static const int backgrounded = 104;
}

class FrameInterpTask {
  const FrameInterpTask({
    required this.id,
    required this.sourcePath,
    required this.outputPath,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnail,
    this.progress = 0,
    this.errorCode = FrameInterpError.none,
    this.error,
    this.width = 0,
    this.height = 0,
    this.sourceFps = 0,
    this.durationMs = 0,
    this.sourceSize = 0,
    this.outputSize = 0,
    this.encoder,
    this.completedAt,
  });

  final String id;
  final String sourcePath;
  final String outputPath;
  final String title;

  /// 封面：网络地址或本地文件路径，取自发起补帧的那张卡片。可空。
  final String? thumbnail;
  final FrameInterpStatus status;

  /// 0.0 ~ 1.0。只在任务结束或被打断时落库一次——跑的过程中进度走内存，
  /// 见 FrameInterpService.activeProgress。
  final double progress;
  final int errorCode;
  final String? error;
  final int width;
  final int height;
  final double sourceFps;
  final int durationMs;
  final int sourceSize;
  final int outputSize;

  /// 实际用上的编码器名（如 `h264_nvenc`），排查「为什么这么慢」时有用。
  final String? encoder;
  final int createdAt;
  final int updatedAt;
  final int? completedAt;

  String get sourceKey => pathKey(sourcePath);
  String get outputKey => pathKey(outputPath);

  /// 成品的帧率：固定是片源的两倍。
  double get outputFps => sourceFps * 2;

  /// 用来比对路径的规范形式。Windows 的文件系统不分大小写，同一个文件从
  /// 下载记录里读出来和从媒体库里读出来，盘符大小写、斜杠方向都可能不一样。
  static String pathKey(String path) {
    final normalized = p.normalize(path);
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }

  factory FrameInterpTask.fromRow(Row row) {
    return FrameInterpTask(
      id: row['id'] as String,
      sourcePath: row['source_path'] as String,
      outputPath: row['output_path'] as String,
      title: row['title'] as String,
      thumbnail: row['thumbnail'] as String?,
      status: FrameInterpStatus.parse(row['status'] as String?),
      progress: (row['progress'] as num?)?.toDouble() ?? 0,
      errorCode: (row['error_code'] as int?) ?? FrameInterpError.none,
      error: row['error'] as String?,
      width: (row['width'] as int?) ?? 0,
      height: (row['height'] as int?) ?? 0,
      sourceFps: (row['source_fps'] as num?)?.toDouble() ?? 0,
      durationMs: (row['duration_ms'] as int?) ?? 0,
      sourceSize: (row['source_size'] as int?) ?? 0,
      outputSize: (row['output_size'] as int?) ?? 0,
      encoder: row['encoder'] as String?,
      createdAt: row['created_at'] as int,
      updatedAt: row['updated_at'] as int,
      completedAt: row['completed_at'] as int?,
    );
  }

  FrameInterpTask copyWith({
    FrameInterpStatus? status,
    double? progress,
    int? errorCode,
    String? error,
    bool clearError = false,
    int? outputSize,
    String? encoder,
    int? updatedAt,
    int? completedAt,
    bool clearCompletedAt = false,
  }) {
    return FrameInterpTask(
      id: id,
      sourcePath: sourcePath,
      outputPath: outputPath,
      title: title,
      thumbnail: thumbnail,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorCode: clearError ? FrameInterpError.none : errorCode ?? this.errorCode,
      error: clearError ? null : error ?? this.error,
      width: width,
      height: height,
      sourceFps: sourceFps,
      durationMs: durationMs,
      sourceSize: sourceSize,
      outputSize: outputSize ?? this.outputSize,
      encoder: encoder ?? this.encoder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }
}
