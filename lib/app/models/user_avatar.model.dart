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
      id: json['id'],
      type: json['type'],
      path: json['path'],
      name: json['name'],
      mime: json['mime'],
      size: json['size'],
      width: json['width'],
      height: json['height'],
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['updatedAt']),
      hash: json['hash'],
    );
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
