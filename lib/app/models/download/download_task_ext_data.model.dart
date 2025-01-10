import 'package:i_iwara/app/models/video.model.dart';

enum DownloadTaskExtDataType {
  video,
  gallery,;
}

class DownloadTaskExtData {
  final DownloadTaskExtDataType type; // 下载任务类型，例如 'video', 'image', etc.
  final Map<String, dynamic> data; // 具体的数据

  DownloadTaskExtData({
    required this.type,
    required this.data,
  });

  factory DownloadTaskExtData.fromJson(Map<String, dynamic> json) {
    return DownloadTaskExtData(
      type: DownloadTaskExtDataType.values.byName(json['type']), // 解析时也需要将字符串转换回枚举
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name, // 将枚举类型转换为字符串
      'data': data,
    };
  }
}


class VideoDownloadExtData {
  final String? id;
  final String? title;
  final String? thumbnail;
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatar;
  final int? duration;
  final String? quality;

  VideoDownloadExtData({
    this.id,
    this.title,
    this.thumbnail,
    this.authorName,
    this.authorUsername,
    this.authorAvatar,
    this.duration,
    this.quality,
  });

  factory VideoDownloadExtData.fromJson(Map<String, dynamic> json) {
    return VideoDownloadExtData(
      id: json['id'] as String?,
      title: json['title'] as String?,
      thumbnail: json['thumbnail'] as String?,
      authorName: json['author_name'] as String?,
      authorUsername: json['author_username'] as String?,
      authorAvatar: json['author_avatar'] as String?,
      duration: json['duration'] as int?,
      quality: json['quality'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'author_name': authorName,
      'author_username': authorUsername,
      'author_avatar': authorAvatar,
      'duration': duration,
      'quality': quality,
    };
  }

  static String genExtDataIdByVideoInfo(Video videoInfo, String sourceName) {
    return '${videoInfo.id}_$sourceName';
  }
}

class GalleryDownloadExtData {
  final String? id;
  final String? title;
  final List<String> previewUrls; // 前三张预览图的URL
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatar;
  final int totalImages; // 图片总数
  final List<Map<String, String>> imageList; // 所有图片的信息列表，包含id、url等
  final Map<String, String> localPaths; // 新增：存储下载后的本地文件路径，key为imageId，value为本地路径

  GalleryDownloadExtData({
    this.id,
    this.title,
    this.previewUrls = const [],
    this.authorName,
    this.authorUsername,
    this.authorAvatar,
    this.totalImages = 0,
    this.imageList = const [],
    this.localPaths = const {}, // 新增字段的默认值
  });

  factory GalleryDownloadExtData.fromJson(Map<String, dynamic> json) {
    return GalleryDownloadExtData(
      id: json['id'] as String?,
      title: json['title'] as String?,
      previewUrls: (json['preview_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      authorName: json['author_name'] as String?,
      authorUsername: json['author_username'] as String?,
      authorAvatar: json['author_avatar'] as String?,
      totalImages: json['total_images'] as int? ?? 0,
      imageList: (json['image_list'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      localPaths: (json['local_paths'] as Map<String, dynamic>?)?.cast<String, String>() ?? {}, // 新增：从JSON解析localPaths
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'preview_urls': previewUrls,
      'author_name': authorName,
      'author_username': authorUsername,
      'author_avatar': authorAvatar,
      'total_images': totalImages,
      'image_list': imageList,
      'local_paths': localPaths, // 新增：将localPaths添加到JSON中
    };
  }

  static String genExtDataIdByGalleryInfo(String id) {
    return '${DownloadTaskExtDataType.gallery}_$id';
  }
} 