import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_selector/file_selector.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart' hide FormData;
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as path;

class UploadedImage {
  final String id;
  final String type;
  final String path;
  final String name;
  final String mime;
  final int size;
  final int width;
  final int height;
  final String hash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? md5;
  final String? userId;
  final bool? animatedPreview;
  final dynamic duration;
  final int? numThumbnails;

  UploadedImage({
    required this.id,
    required this.type,
    required this.path,
    required this.name,
    required this.mime,
    required this.size,
    required this.width,
    required this.height,
    required this.hash,
    required this.createdAt,
    required this.updatedAt,
    this.md5,
    this.userId,
    this.animatedPreview,
    this.duration,
    this.numThumbnails,
  });

  factory UploadedImage.fromJson(Map<String, dynamic> json) {
    return UploadedImage(
      id: json['id'],
      type: json['type'],
      path: json['path'],
      name: json['name'],
      mime: json['mime'],
      size: json['size'],
      width: json['width'],
      height: json['height'],
      hash: json['hash'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      md5: json['md5'],
      userId: json['userId'],
      animatedPreview: json['animatedPreview'],
      duration: json['duration'],
      numThumbnails: json['numThumbnails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'path': path,
      'name': name,
      'mime': mime,
      'size': size,
      'width': width,
      'height': height,
      'hash': hash,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'md5': md5,
      'userId': userId,
      'animatedPreview': animatedPreview,
      'duration': duration,
      'numThumbnails': numThumbnails,
    };
  }

  // 生成缩略图URL
  String get thumbnailUrl {
    return 'https://i.iwara.tv/image/thumbnail/$id/$name';
  }

  // 生成大图URL
  String get largeUrl {
    if (mime == 'image/gif') {
      return 'https://i.iwara.tv/image/original/$id/$name';
    }
    return 'https://i.iwara.tv/image/large/$id/$name';
  }

  // 原图
  String get originalUrl {
    return CommonConstants.avatarUrl(id, id);
  }
}

class UploadService extends GetxService {
  static UploadService? _instance;
  late ApiService _apiService;
  final String _tag = 'UploadService';

  UploadService._();

  static Future<UploadService> getInstance() async {
    _instance ??= await UploadService._().init();
    return _instance!;
  }

  Future<UploadService> init() async {
    _apiService = Get.find<ApiService>();
    return this;
  }

  /// 选择多个图片文件
  Future<List<File>> pickImageFiles() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // 移动平台使用 flutter_file_dialog，但只能选择单个文件
        const params = OpenFileDialogParams(
          fileExtensionsFilter: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'webm'],
        );
        final filePath = await FlutterFileDialog.pickFile(params: params);
        if (filePath == null) {
          return [];
        }
        return [File(filePath)];
      } else {
        // 桌面平台使用 file_selector
        const typeGroup = XTypeGroup(
          label: 'Images',
          extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'webm'],
        );
        final files = await openFiles(acceptedTypeGroups: [typeGroup]);
        return files.map((file) => File(file.path)).toList();
      }
    } catch (e) {
      LogUtils.e('选择图片文件失败', error: e, tag: _tag);
      return [];
    }
  }

  /// 上传单个图片文件
  Future<UploadedImage?> uploadImageFile(File file) async {
    try {
      LogUtils.d('开始上传图片: ${file.path}', _tag);

      // 检查文件是否存在
      if (!await file.exists()) {
        LogUtils.e('文件不存在: ${file.path}', tag: _tag);
        return null;
      }

      // 读取文件内容
      final bytes = await file.readAsBytes();

      // 创建FormData
      final formData = dio.FormData.fromMap({
        'file': dio.MultipartFile.fromBytes(
          bytes,
          filename: path.basename(file.path),
        ),
      });

      // 发送上传请求
      final response = await _apiService.dio.post(
        'https://files.iwara.tv/upload/image',
        data: formData,
        options: dio.Options(
          headers: {
            'Accept': '*/*',
            'Accept-Language': 'zh-CN,zh;q=0.9',
            'Origin': 'https://www.iwara.tv',
            'Referer': 'https://www.iwara.tv/',
            'Sec-Fetch-Dest': 'empty',
            'Sec-Fetch-Mode': 'cors',
            'Sec-Fetch-Site': 'same-site',
          },
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final uploadedImage = UploadedImage.fromJson(response.data);
        LogUtils.d('图片上传成功: ${uploadedImage.id}', _tag);
        return uploadedImage;
      } else {
        LogUtils.e('上传响应异常: ${response.statusCode}', tag: _tag);
        return null;
      }
    } catch (e) {
      LogUtils.e('上传图片失败: ${file.path}', error: e, tag: _tag);
      return null;
    }
  }

  /// 批量上传图片文件
  Future<List<UploadedImage>> uploadImageFiles(List<File> files) async {
    final List<UploadedImage> uploadedImages = [];
    final List<String> failedFiles = [];

    LogUtils.d('开始批量上传 ${files.length} 个图片文件', _tag);

    // 使用并发上传，但限制并发数量为3
    const int maxConcurrent = 3;
    final List<List<File>> batches = [];

    for (int i = 0; i < files.length; i += maxConcurrent) {
      final end = (i + maxConcurrent < files.length)
          ? i + maxConcurrent
          : files.length;
      batches.add(files.sublist(i, end));
    }

    for (int batchIndex = 0; batchIndex < batches.length; batchIndex++) {
      final batch = batches[batchIndex];
      LogUtils.d(
        '上传批次 ${batchIndex + 1}/${batches.length}, 包含 ${batch.length} 个文件',
        _tag,
      );

      final futures = batch.map((file) => uploadImageFile(file)).toList();
      final results = await Future.wait(futures);

      for (int i = 0; i < batch.length; i++) {
        final result = results[i];
        if (result != null) {
          uploadedImages.add(result);
        } else {
          failedFiles.add(path.basename(batch[i].path));
        }
      }
    }

    LogUtils.d(
      '批量上传完成: 成功 ${uploadedImages.length} 个, 失败 ${failedFiles.length} 个',
      _tag,
    );

    if (failedFiles.isNotEmpty) {
      LogUtils.w('上传失败的文件: ${failedFiles.join(', ')}', _tag);
    }

    return uploadedImages;
  }
}
