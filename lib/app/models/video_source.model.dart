// video_source.model.dart

class VideoSource {
  final String id;
  final String? name; // 清晰度，例如 "360", "540", "720"
  final String? viewUrl;
  final String? downloadUrl;
  final String? type; // 视频类型，例如 "video/mp4"
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VideoSrc? src;

  VideoSource({
    required this.id,
    this.name,
    this.viewUrl,
    this.downloadUrl,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.src,
  });

  factory VideoSource.fromJson(Map<String, dynamic> json) {
    return VideoSource(
      id: json['id'],
      name: json['name'],
      viewUrl: json['src'] != null ? 'https:${json['src']['view']}' : null,
      downloadUrl: json['src'] != null ? 'https:${json['src']['download']}' : null,
      type: json['type'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      src: json['src'] != null ? VideoSrc.fromJson(json['src']) : null,
    );
  }
}

class VideoSrc {
  final String? view;
  final String? download;

  VideoSrc({
    this.view, // 视频播放源
    this.download,
  });

  factory VideoSrc.fromJson(Map<String, dynamic> json) {
    return VideoSrc(
      view: json['view'], // 视频播放源
      download: json['download'],
    );
  }
}