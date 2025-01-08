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