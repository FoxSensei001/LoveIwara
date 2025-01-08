
import 'package:i_iwara/common/constants.dart';

class MediaFile {
  final String id;
  final String type; // image, video
  final String path;
  final String name;
  final String mime;
  final int? size;
  final int? width;
  final int? height;
  final int? duration;
  final int? numThumbnails;
  final bool animatedPreview;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaFile({
    required this.id,
    required this.type,
    required this.path,
    required this.name,
    required this.mime,
    this.size,
    this.width,
    this.height,
    this.duration,
    this.numThumbnails,
    required this.animatedPreview,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'],
      type: json['type'],
      path: json['path'],
      name: json['name'],
      mime: json['mime'],
      size: json['size'],
      width: json['width'],
      height: json['height'],
      duration: json['duration'],
      numThumbnails: json['numThumbnails'],
      animatedPreview: json['animatedPreview'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // toJson
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
      'duration': duration,
      'numThumbnails': numThumbnails,
      'animatedPreview': animatedPreview,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getLargeImageUrl()  {
    String largeUrl = '${CommonConstants.iwaraImageBaseUrl}/image/large/$id/$name';
    // 在i站里，gif图没有large版，只有original版
    if (mime == 'image/gif') {
      return '${CommonConstants.iwaraImageBaseUrl}/image/original/$id/$name';
    }
    return largeUrl;
  }
  String getOriginalImageUrl() => '${CommonConstants.iwaraImageBaseUrl}/image/original/$id/$name';
}
