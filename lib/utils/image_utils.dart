import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:path/path.dart' as path;

import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/app/routes/app_routes.dart';

class ImageUtils {
  // 复制链接到剪贴板
  static void copyLink(ImageItem item) {
    String url =
        item.data.originalUrl.isEmpty ? item.data.url : item.data.originalUrl;
    if (url.isEmpty) {
      showToastWidget(MDToastWidget(
          message: slang.t.common.linkIsEmpty, type: MDToastType.error));
      return;
    }
    final data = DataWriterItem();
    data.add(Formats.plainText(url));
    SystemClipboard.instance?.write([data]);
    showToastWidget(MDToastWidget(
        message: slang.t.common.linkCopiedToClipboard,
        type: MDToastType.success));
  }

  // 复制图片到剪贴板
  static void copyImage(ImageItem item) async {
    String url =
        item.data.originalUrl.isEmpty ? item.data.url : item.data.originalUrl;
    if (url.isEmpty) {
      showToastWidget(MDToastWidget(
          message: slang.t.common.linkIsEmpty, type: MDToastType.error));
      return;
    }

    try {
      var apiService = await ApiService.getInstance();
      Uint8List bytes = (await apiService.dio
              .get(url, options: Options(responseType: ResponseType.bytes)))
          .data;
      final dataWriterItem =
          DataWriterItem(suggestedName: '${item.data.id}.png');
      dataWriterItem.add(Formats.png(bytes));
      SystemClipboard.instance?.write([dataWriterItem]);
      showToastWidget(MDToastWidget(
          message: slang.t.common.imageCopiedToClipboard,
          type: MDToastType.success));
    } catch (e) {
      showToastWidget(MDToastWidget(
          message: slang.t.common.copyImageFailed, type: MDToastType.error));
    }
  }

  // 下载图片: 移动端
  static void downloadImageForMobile(ImageItem item) async {
    try {
      String url = item.data.originalUrl.isEmpty ? item.data.url : item.data.originalUrl;
      if (url.isEmpty) {
        showToastWidget(MDToastWidget(
            message: slang.t.common.linkIsEmpty, type: MDToastType.error));
        return;
      }

      // 创建下载任务
      final task = DownloadTask(
        id: 'single_image_${item.data.id}',
        url: url,
        savePath: await _getSavePath(item.data.title ?? 'image', item.data.id),
        fileName: '${item.data.title ?? 'image'}_${item.data.id}.jpg',
        supportsRange: true,
      );

      await DownloadService.to.addTask(task);

      showToastWidget(MDToastWidget(
          message: '开始下载...',
          type: MDToastType.success));

      // 打开下载管理页面
      NaviService.navigateToDownloadTaskListPage();
    } catch (e) {
      LogUtils.e('添加下载任务失败', tag: 'ImageUtils', error: e);
      showToastWidget(MDToastWidget(
          message: '下载失败',
          type: MDToastType.error));
    }
  }

  // 获取图片的保存路径
  static Future<String> _getSavePath(String title, String id) async {
    final dir = await CommonUtils.getAppDirectory(pathSuffix: path.join('downloads', 'images'));
    final sanitizedTitle = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    return '${dir.path}/${sanitizedTitle}_$id.jpg';
  }

  // 下载图片: 桌面
  static Future<String> _getDefaultDownloadPath() async {
    if (Platform.isWindows || Platform.isLinux) {
      // Windows/Linux: 使用下载目录
      return (await getDownloadsDirectory())?.path ??
          (await getApplicationDocumentsDirectory()).path;
    } else if (Platform.isMacOS) {
      // macOS: 优先使用下载目录
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads.path;

      // 备选：文档目录
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      // 其他平台：使用应用文档目录
      return (await getApplicationDocumentsDirectory()).path;
    }
  }

  static void downloadImageForDesktop(ImageItem item) async {
    try {
      String? directoryPath = await getDirectoryPath();

      // 取消选择
      if (directoryPath == null) {
        return;
      }

      String url =
          item.data.originalUrl.isEmpty ? item.data.url : item.data.originalUrl;
      if (url.isEmpty) {
        showToastWidget(MDToastWidget(
            message: slang.t.common.linkIsEmpty, type: MDToastType.error));
        return;
      }

      // 确保文件名合法
      final String sanitizedFileName = _sanitizeFileName('${item.data.id}.png');
      final String filePath = path.join(directoryPath, sanitizedFileName);

      var apiService = await ApiService.getInstance();
      Uint8List bytes = (await apiService.dio
              .get(url, options: Options(responseType: ResponseType.bytes)))
          .data;

      await File(filePath).writeAsBytes(bytes);
      showToastWidget(MDToastWidget(
          message: '${slang.t.common.imageSavedTo}: $filePath',
          type: MDToastType.success));
    } catch (e) {
      LogUtils.e('下载图片失败', error: e, tag: 'ImageModelDetailContent');
      showToastWidget(MDToastWidget(
          message: slang.t.common.saveImageFailed, type: MDToastType.error));
    }
  }

  static String _sanitizeFileName(String fileName) {
    // 移除或替换不合法的文件名字符
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}
