import 'dart:convert';
import 'package:i_iwara/utils/logger_utils.dart';
import 'download_task_ext_data.model.dart';

class DownloadTask {
  final String id;
  final String url; // 下载链接
  final String savePath; // 保存路径
  final String fileName; // 文件名
  int totalBytes; // 文件总大小
  int downloadedBytes; // 已下载大小
  DownloadStatus status; // 下载状态
  bool supportsRange; // 是否支持断点续传
  String? error; // 错误信息
  DownloadTaskExtData? extData; // 额外数据
  int speed = 0; // 当前下载速度(bytes/s)
  DateTime? lastSpeedUpdateTime; // 上次速度更新时间
  int lastDownloadedBytes = 0; // 上次下载的字节数
  
  DownloadTask({
    required this.id,
    required this.url,
    required this.savePath,
    required this.fileName,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.status = DownloadStatus.pending,
    this.supportsRange = false,
    this.error,
    this.extData,
  });

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
      extData: extData,
    );
  }

  // 转换为数据库行
  Map<String, dynamic> toRow() {
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
      'ext_data': extData != null ? jsonEncode(extData!.toJson()) : null,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
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

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
}

class FileSystemException implements Exception {
  final String message;
  final FileErrorType type;

  FileSystemException({
    required this.message,
    required this.type,
  });
}

enum FileErrorType {
  accessDenied,     // 访问被拒绝
  notFound,         // 文件不存在
  alreadyExists,    // 文件已存在
  insufficientSpace,// 空间不足
  ioError,          // IO错误
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
  noNetwork,        // 无网络连接
  timeout,          // 连接超时
  serverError,      // 服务器错误
  invalidUrl,       // 无效URL
  canceledByUser,   // 用户取消
  storageNotEnough, // 存储空间不足
}