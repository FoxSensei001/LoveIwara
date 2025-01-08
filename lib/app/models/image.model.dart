import 'package:i_iwara/app/models/media_file.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/common/constants.dart';

import 'custom_thumbnail.model.dart';

class ImageModel {
  final String id;
  final String status; // 默认active
  final String body; // 描述
  final String slug; // 图库的slug
  final String title; // 标题
  final CustomThumbnail? thumbnail; // 缩略图
  final String rating; // general, ecchi 分别代表 一般, 色情
  final bool liked; // 是否被我点赞
  final int numImages; // 图片数量
  final int numLikes; // 点赞数量
  final int numViews; // 浏览数量
  final int numComments; // 评论数量

  final User? user; // 作者
  final DateTime? createdAt; // 创建时间
  final DateTime? updatedAt; // 更新时间

  final List<MediaFile> files; // 图片列表
  final List<Tag> tags; // 标签列表

  ImageModel({
    required this.id,
    this.status = 'active',
    this.body = '',
    this.slug = '',
    this.title = '',
    this.thumbnail,
    this.rating = 'ecchi',
    this.liked = false,
    this.numImages = 0,
    this.numLikes = 0,
    this.numViews = 0,
    this.numComments = 0,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.files = const [],
    this.tags = const [],
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] ?? '',
      status: json['status'] ?? 'active',
      body: json['body'] ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] != null
          ? CustomThumbnail.fromJson(json['thumbnail'])
          : null,
      rating: json['rating'] ?? 'ecchi',
      liked: json['liked'] ?? false,
      numImages: json['numImages'] ?? 0,
      numLikes: json['numLikes'] ?? 0,
      numViews: json['numViews'] ?? 0,
      numComments: json['numComments'] ?? 0,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      files: json['files'] != null
          ? (json['files'] as List)
              .map((file) => MediaFile.fromJson(file))
              .toList()
          : [],
      tags: json['tags'] != null
          ? (json['tags'] as List).map((tag) => Tag.fromJson(tag)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'body': body,
      'slug': slug,
      'title': title,
      'thumbnail': thumbnail?.toJson(),
      'rating': rating,
      'liked': liked,
      'numImages': numImages,
      'numLikes': numLikes,
      'numViews': numViews,
      'numComments': numComments,
      'user': user?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'files': files.map((file) => file.toJson()).toList(),
      'tags': tags.map((tag) => tag.toJson()).toList(),
    };
  }


  ImageModel copyWith({
    String? id,
    String? status,
    String? body,
    String? slug,
    String? title,
    CustomThumbnail? thumbnail,
    String? rating,
    bool? liked,
    int? numImages,
    int? numLikes,
    int? numViews,
    int? numComments,
    User? user,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MediaFile>? files,
    List<Tag>? tags,
  }) {
    return ImageModel(
      id: id ?? this.id,
      status: status ?? this.status,
      body: body ?? this.body,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      rating: rating ?? this.rating,
      liked: liked ?? this.liked,
      numImages: numImages ?? this.numImages,
      numLikes: numLikes ?? this.numLikes,
      numViews: numViews ?? this.numViews,
      numComments: numComments ?? this.numComments,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      files: files ?? this.files,
      tags: tags ?? this.tags,
    );
  }

  // 头图
  String get thumbnailUrl {
    if (thumbnail != null) {
      String url = 'https://i.iwara.tv/image/thumbnail/${thumbnail!.id}/${thumbnail!.name}';
      // 将最后的.文件类型 换为 .jpg
      return url.replaceAll('.${thumbnail!.name.split('.').last}', '.jpg');
    } else {
      return CommonConstants.defaultThumbnailUrl;
    }
  }
}
