import 'dart:convert';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/snowflake_id_generator.dart';
import 'download_task_ext_data.model.dart';

class DownloadTask {
  final String id;
  String url; // 下载链接
  String savePath; // 保存路径
  final String fileName; // 文件名
  int totalBytes; // 文件总大小 [在图库下载中，可以用于表示图库中的图片总数量]
  int downloadedBytes; // 已下载大小 [在图库下载中，可以用于表示已下载的图片数量]
  DownloadStatus status; // 下载状态
  bool supportsRange; // 是否支持断点续传
  String? error; // 错误信息（自由文本，多为异常原文，用于排查）

  /// 失败原因分类（[DownloadErrorType] 的 name）。
  ///
  /// [error] 是给排查用的原文，会随语言 / 依赖库版本变化，程序不该去解析它；
  /// 这一列才是给程序和 UI 用的稳定语义：决定卡片上显示哪句人话、以及将来做
  /// 「只重试网络类失败」这种批量操作时的查询条件。历史数据为 null，视为未知。
  String? errorType;
  DownloadTaskExtData? extData; // 额外数据
  /// 媒体类型：'video' | 'gallery' 等，配合 mediaId/quality 用于快速索引
  String? mediaType;

  /// 媒体 ID，对应视频或图库的 id
  String? mediaId;

  /// 媒体质量，仅视频任务使用，例如 '1080', '720' 等
  String? quality;

  /// 所属分类（自定义文件夹）id；null 表示「未分类」。可变元数据。
  String? categoryId;

  /// 任务创建时间（来自数据库 created_at 字段，用于 UI 分组展示）
  final DateTime? createdAt;

  /// 任务最近更新时间（来自数据库 updated_at 字段）
  DateTime? updatedAt;

  /// 任务完成时间（来自数据库 completed_at 字段，用于历史按完成时间展示/排序）
  DateTime? completedAt;
  int speed = 0; // 当前下载速度(bytes/s)
  DateTime? lastSpeedUpdateTime; // 上次速度更新时间
  int lastDownloadedBytes = 0; // 上次下载的字节数

  DownloadTask({
    String? id,
    required this.url,
    required this.savePath,
    required this.fileName,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.status = DownloadStatus.pending,
    this.supportsRange = false,
    this.error,
    this.errorType,
    this.extData,
    this.mediaType,
    this.mediaId,
    this.quality,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  }) : id = id ?? SnowflakeIdGenerator.getInstance().nextId();

  /// 兼容「秒级 / 毫秒级」两种历史时间戳：
  /// created_at 用 strftime('%s') 存的是秒；updated_at/completed_at 由应用层
  /// 写的是毫秒。为容错历史数据，小于 1e12 的值按秒处理，否则按毫秒。
  static DateTime? _parseTimestamp(Object? raw) {
    if (raw is! int) return null;
    final ms = raw < 1000000000000 ? raw * 1000 : raw;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  // 从数据库行转换
  factory DownloadTask.fromRow(Map<String, dynamic> row) {
    DownloadTaskExtData? extData;
    try {
      if (row['ext_data'] != null) {
        // 尝试解析JSON字符串
        final jsonStr = row['ext_data'].toString().trim();
        final jsonMap = jsonDecode(jsonStr);
        extData = DownloadTaskExtData.fromJson(jsonMap);
      }
    } catch (e) {
      LogUtils.e('解析下载任务扩展数据失败', error: e);
    }

    return DownloadTask(
      id: row['id'],
      url: row['url'],
      savePath: row['save_path'],
      fileName: row['file_name'],
      totalBytes: row['total_bytes'] as int,
      downloadedBytes: row['downloaded_bytes'] as int,
      status: DownloadStatus.values.byName(row['status']),
      supportsRange: row['supports_range'] == 1,
      error: row['error'],
      // 防御式读取：兼容 v19 迁移前的旧行 / 测试注入的旧 schema
      errorType: row.containsKey('error_type')
          ? row['error_type'] as String?
          : null,
      extData: extData,
      mediaType: row['media_type'] as String?,
      mediaId: row['media_id'] as String?,
      quality: row['quality'] as String?,
      // 防御式读取：兼容 v18 迁移前的旧行 / 测试注入的旧 schema
      categoryId: row.containsKey('category_id')
          ? row['category_id'] as String?
          : null,
      createdAt: _parseTimestamp(row['created_at']),
      updatedAt: _parseTimestamp(row['updated_at']),
      completedAt: row.containsKey('completed_at')
          ? _parseTimestamp(row['completed_at'])
          : null,
    );
  }

  // 转换为数据库行
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'save_path': savePath,
      'file_name': fileName,
      'total_bytes': totalBytes,
      'downloaded_bytes': downloadedBytes,
      'status': status.name,
      'supports_range': supportsRange ? 1 : 0,
      'error': error,
      'error_type': errorType,
      'ext_data': extData != null ? jsonEncode(extData!.toJson()) : null,
      'media_type': mediaType,
      'media_id': mediaId,
      'quality': quality,
      'category_id': categoryId,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
    };
  }

  // 更新下载速度
  void updateSpeed() {
    final now = DateTime.now();
    if (lastSpeedUpdateTime != null) {
      final duration = now.difference(lastSpeedUpdateTime!).inSeconds;
      if (duration > 0) {
        final bytesDownloaded = downloadedBytes - lastDownloadedBytes;
        speed = (bytesDownloaded / duration).round();
      }
    }
    lastSpeedUpdateTime = now;
    lastDownloadedBytes = downloadedBytes;
  }
}

enum DownloadStatus { pending, downloading, paused, completed, failed }

/// 下载失败的原因分类。
///
/// 分类的用途有两个：让失败卡片能说人话（而不是甩一段异常字符串），以及让
/// 「哪些失败值得重试」这件事可判断、可查询。落库的是枚举名（见 v19 迁移）。
enum DownloadErrorType {
  /// 网络层问题：超时、连接中断、DNS / 代理异常。重试通常有意义。
  network,

  /// 服务端明确拒绝：401/403 等，多为登录态失效或权限不足。
  serverRejected,

  /// 资源已不存在：404 / 链接失效。视频任务可通过重新获取链接自愈。
  notFound,

  /// 磁盘空间不足。
  diskFull,

  /// 目标文件被占用（杀软扫描、播放器打开中等）。
  fileInUse,

  /// 无写入权限 / 目标路径不可写。
  permission,

  /// 用户取消。
  cancelled,

  /// 未能归类。
  unknown;

  /// 该类失败重试是否通常有意义（供批量重试等功能判断）。
  bool get isRetriable =>
      this == DownloadErrorType.network ||
      this == DownloadErrorType.notFound ||
      this == DownloadErrorType.diskFull ||
      this == DownloadErrorType.fileInUse;

  /// 从落库的字符串还原；未知 / 历史数据返回 [DownloadErrorType.unknown]。
  static DownloadErrorType parse(String? raw) {
    if (raw == null) return DownloadErrorType.unknown;
    for (final value in DownloadErrorType.values) {
      if (value.name == raw) return value;
    }
    return DownloadErrorType.unknown;
  }
}

class FileSystemException implements Exception {
  final String message;
  final FileErrorType type;

  FileSystemException({required this.message, required this.type});
}

enum FileErrorType {
  accessDenied, // 访问被拒绝
  notFound, // 文件不存在
  alreadyExists, // 文件已存在
  insufficientSpace, // 空间不足
  ioError, // IO错误
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final NetworkErrorType type;

  NetworkException({
    required this.message,
    this.statusCode,
    required this.type,
  });
}

enum NetworkErrorType {
  noNetwork, // 无网络连接
  timeout, // 连接超时
  serverError, // 服务器错误
  invalidUrl, // 无效URL
  canceledByUser, // 用户取消
  storageNotEnough, // 存储空间不足
}
