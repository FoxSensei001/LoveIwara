class DownloadTaskExtData {
  final String type; // 下载任务类型，例如 'video', 'image', etc.
  final Map<String, dynamic> data; // 具体的数据

  DownloadTaskExtData({
    required this.type,
    required this.data,
  });

  factory DownloadTaskExtData.fromJson(Map<String, dynamic> json) {
    return DownloadTaskExtData(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
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

  VideoDownloadExtData({
    this.id,
    this.title,
    this.thumbnail,
    this.authorName,
    this.authorUsername,
    this.authorAvatar,
    this.duration,
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
    };
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

  GalleryDownloadExtData({
    this.id,
    this.title,
    this.previewUrls = const [],
    this.authorName,
    this.authorUsername,
    this.authorAvatar,
    this.totalImages = 0,
    this.imageList = const [],
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
    };
  }
} 