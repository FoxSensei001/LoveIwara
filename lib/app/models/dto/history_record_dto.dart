import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/video.model.dart';

/// 历史记录数据传输对象
/// 用于优化存储空间，只存储必要的数据
class HistoryRecordDTO {
  final String id;
  final String? title;
  final String? thumbnailUrl;
  final String? authorName;
  final String? authorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HistoryRecordDTO({
    required this.id,
    this.title,
    this.thumbnailUrl,
    this.authorName,
    this.authorId,
    this.createdAt,
    this.updatedAt,
  });

  factory HistoryRecordDTO.fromVideo(Video video) {
    return HistoryRecordDTO(
      id: video.id,
      title: video.title,
      thumbnailUrl: video.thumbnailUrl,
      authorName: video.user?.name,
      authorId: video.user?.id,
      createdAt: video.createdAt,
      updatedAt: video.updatedAt,
    );
  }

  factory HistoryRecordDTO.fromImageModel(ImageModel image) {
    return HistoryRecordDTO(
      id: image.id,
      title: image.title,
      thumbnailUrl: image.thumbnailUrl,
      authorName: image.user?.name,
      authorId: image.user?.id,
      createdAt: image.createdAt,
      updatedAt: image.updatedAt,
    );
  }

  factory HistoryRecordDTO.fromPost(PostModel post) {
    return HistoryRecordDTO(
      id: post.id,
      title: post.title,
      thumbnailUrl: null,
      authorName: post.user.name,
      authorId: post.user.id,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
    );
  }

  factory HistoryRecordDTO.fromThread(ForumThreadModel thread) {
    return HistoryRecordDTO(
      id: thread.id,
      title: thread.title,
      thumbnailUrl: null,
      authorName: thread.user.name,
      authorId: thread.user.id,
      createdAt: thread.createdAt,
      updatedAt: thread.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'authorName': authorName,
      'authorId': authorId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory HistoryRecordDTO.fromJson(Map<String, dynamic> json) {
    return HistoryRecordDTO(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      authorName: json['authorName'],
      authorId: json['authorId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
} 