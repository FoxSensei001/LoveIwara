import 'package:i_iwara/common/constants.dart';

class UserAvatar {
  final String id;
  final String type;
  final String path;
  final String name;
  final String mime;
  final int? size;
  final int? width;
  final int? height;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? hash;

  UserAvatar({
    required this.id,
    required this.type,
    required this.path,
    required this.name,
    required this.mime,
    required this.size,
    this.width,
    this.height,
    required this.createdAt,
    required this.updatedAt,
    this.hash,
  });

  factory UserAvatar.fromJson(Map<String, dynamic> json) {
    return UserAvatar(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mime: json['mime']?.toString() ?? '',
      size: (json['size'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      hash: json['hash']?.toString(),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['path'] = path;
    data['name'] = name;
    data['mime'] = mime;
    data['size'] = size;
    data['width'] = width;
    data['height'] = height;
    data['createdAt'] = createdAt.toIso8601String();
    data['updatedAt'] = updatedAt.toIso8601String();
    data['hash'] = hash;
    return data;
  }

  String get avatarUrl {
    final isAnimated =
        mime == 'image/gif' || mime == 'image/webp' || mime == 'image/apng';
    if (isAnimated) {
      return CommonConstants.avatarOriginalUrl(id, name);
    }
    return CommonConstants.avatarUrl(id, name);
  }

  String get headerUrl {
    final isAnimated =
        mime == 'image/gif' || mime == 'image/webp' || mime == 'image/apng';
    if (isAnimated) {
      return CommonConstants.avatarOriginalUrl(id, name);
    }
    return '${CommonConstants.iwaraImageBaseUrl}/image/profileHeader/$id/$name';
  }
}
