import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 把下载落盘/删除的结果告诉安卓系统媒体库（MediaStore）。
///
/// 下载是 `dart:io` 按绝对路径直接写共享存储的，系统不一定会自己登记——
/// 登记不上的话 Telegram / WhatsApp / 相册这类读 MediaStore 的应用就看不到，
/// 要等重启或手动广播重扫才出现（#124）。删除同理：不扫的话媒体库里会留一条
/// 指向空文件的记录。
class MediaScanService {
  MediaScanService._();

  static const _tag = 'MediaScanService';
  static const MethodChannel _channel = MethodChannel(
    'com.example.i_iwara/media_store',
  );

  /// [paths] 可以是文件或目录（原生侧递归展开目录）；已经删掉的文件路径也照传，
  /// 系统扫到「不存在」就会把索引移除。应用专属目录（`Android/data`、`Android/obb`）
  /// 本来就不进媒体库，直接跳过。失败只记日志，绝不影响下载本身。
  static Future<void> scan(Iterable<String> paths) async {
    if (!GetPlatform.isAndroid) return;
    final targets = paths
        .where((p) => p.isNotEmpty && !_isAppSpecific(p))
        .toSet()
        .toList();
    if (targets.isEmpty) return;
    try {
      await _channel.invokeMethod<void>('scanFiles', {'paths': targets});
    } catch (e) {
      LogUtils.w('通知媒体库扫描失败: $e', _tag);
    }
  }

  /// 删除目录前先把里面的文件列出来：目录删掉以后就不知道要移除哪些索引了。
  static List<String> listFilesForRemoval(String dirPath) {
    if (!GetPlatform.isAndroid || _isAppSpecific(dirPath)) return const [];
    try {
      return Directory(dirPath)
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .map((f) => f.path)
          .toList();
    } catch (e) {
      LogUtils.w('列出待删除目录失败: $e', _tag);
      return const [];
    }
  }

  static bool _isAppSpecific(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.contains('/Android/data/') ||
        normalized.contains('/Android/obb/');
  }
}
