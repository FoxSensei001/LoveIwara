import 'dart:convert';

import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/post.model.dart';

class HistoryRecord {
  final int id;
  final String itemId; // 记录ID (视频ID或图库ID)
  final String itemType; // 记录类型 (video/image)
  final String title; // 标题
  final String? thumbnailUrl; // 缩略图URL
  final String? author; // 作者名
  final String? authorId; // 作者ID
  final String data; // 完整数据JSON
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HistoryRecord({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.title,
    this.thumbnailUrl,
    this.author,
    this.authorId,
    required this.data,
    this.createdAt,
    this.updatedAt,
  });

  // 从Video创建历史记录
  factory HistoryRecord.fromVideo(Video video) {
    return HistoryRecord(
      id: 0,
      itemId: video.id,
      itemType: 'video',
      title: video.title ?? '无标题',
      thumbnailUrl: video.thumbnailUrl,
      author: video.user?.name,
      authorId: video.user?.id,
      data: jsonEncode(video.toJson()),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 从ImageModel创建历史记录
  factory HistoryRecord.fromImageModel(ImageModel image) {
    return HistoryRecord(
      id: 0,
      itemId: image.id,
      itemType: 'image',
      title: image.title,
      thumbnailUrl: image.thumbnailUrl,
      author: image.user?.name,
      authorId: image.user?.id,
      data: jsonEncode(image.toJson()),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 添加从PostModel创建历史记录的工厂方法
  factory HistoryRecord.fromPost(PostModel post) {
    return HistoryRecord(
      id: 0,
      itemId: post.id,
      itemType: 'post',
      title: post.title,
      thumbnailUrl: null, // 帖子可能没有缩略图
      author: post.user.name,
      authorId: post.user.id,
      data: jsonEncode(post.toJson()),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 从ForumThreadModel创建历史记录
  factory HistoryRecord.fromThread(ForumThreadModel thread) {
    return HistoryRecord(
      id: 0,
      itemId: thread.id,
      itemType: 'thread',
      title: thread.title,
      thumbnailUrl: null, // 帖子没有缩略图
      author: thread.user.name,
      authorId: thread.user.id,
      data: jsonEncode(thread.toJson()),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 获取原始数据对象
  dynamic getOriginalData() {
    final Map<String, dynamic> jsonData = jsonDecode(data);
    switch (itemType) {
      case 'video':
        return Video.fromJson(jsonData);
      case 'image':
        return ImageModel.fromJson(jsonData);
      case 'post':
        return PostModel.fromJson(jsonData);
      case 'thread':
        return ForumThreadModel.fromJson(jsonData);
      default:
        throw Exception('未知的记录类型: $itemType');
    }
  }

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      id: json['id'],
      itemId: json['item_id'],
      itemType: json['item_type'],
      title: json['title'],
      thumbnailUrl: json['thumbnail_url'],
      author: json['author'],
      authorId: json['author_id'],
      data: json['data'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'item_type': itemType,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'author': author,
      'author_id': authorId,
      'data': data,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
