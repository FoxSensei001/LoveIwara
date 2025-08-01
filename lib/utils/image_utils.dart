import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:path/path.dart' as path;

import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

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

  // 下载图片
  static void downloadImageToAppDirectory(ImageItem item) async {
    try {
      String url = item.data.originalUrl.isEmpty ? item.data.url : item.data.originalUrl;
      // https://i.iwara.tv/image/original/5d80d601-6689-4728-80bd-b585d83eac9e/5d80d601-6689-4728-80bd-b585d83eac9e.webm
      if (url.isEmpty) {
        showToastWidget(MDToastWidget(
            message: slang.t.common.linkIsEmpty, type: MDToastType.error));
        return;
      }

      Uri uri = Uri.parse(url);
      // 通过uri获取文件名
      String fileName = uri.pathSegments.last;

      // 创建下载任务
      // 确保title不包含扩展名
      String title = item.data.title ?? path.basenameWithoutExtension(fileName);
      if (title.contains('.')) {
        title = path.basenameWithoutExtension(title);
      }

      final task = DownloadTask(
        url: url,
        savePath: await _getSavePath(title, fileName),
        supportsRange: true,
        fileName: fileName,
      );

      await DownloadService.to.addTask(task);

      showToastWidget(MDToastWidget(
          message: slang.t.download.downloading,
          type: MDToastType.success));

      // 打开下载管理页面
      NaviService.navigateToDownloadTaskListPage();
    } catch (e) {
      LogUtils.e('添加下载任务失败', tag: 'ImageUtils', error: e);
      showToastWidget(MDToastWidget(
          message: slang.t.download.failed,
          type: MDToastType.error));
    }
  }

  /// title: 可能为空字符串
  static Future<String> _getSavePath(String title, String fileName) async {
    // 使用下载路径服务
    final downloadPathService = Get.find<DownloadPathService>();

    return await downloadPathService.getImageDownloadPath(
      title: title,
      authorName: null,
      authorUsername: null,
      id: null,
      originalFilename: fileName,
    );
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
