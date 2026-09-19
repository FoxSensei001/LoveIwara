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

  /// 观看进度（只有视频、且看过超过几秒才有；由列表查询 JOIN 进度表带出）。
  final int? playedMs;
  final int? totalMs;

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
    this.playedMs,
    this.totalMs,
  });

  /// 播放器把「看完」记成 played == total（见 PlaybackHistoryService.savePlaybackHistory）。
  bool get isFinished =>
      playedMs != null &&
      totalMs != null &&
      totalMs! > 0 &&
      playedMs! >= totalMs!;

  /// 0~1；没有进度记录时为 null。
  double? get progress {
    final played = playedMs, total = totalMs;
    if (played == null || total == null || total <= 0) return null;
    return (played / total).clamp(0.0, 1.0);
  }

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

  /// 原始数据对象，首次访问时解一次后缓存。
  ///
  /// ⛔ 以前每次调用都 jsonDecode + fromJson，而它被放在卡片的 Obx 里：
  /// 勾选一项、列表重建，整屏卡片就在 UI 线程上把 JSON 重解一遍。
  /// 坏数据答 null，不让一行脏记录把整页 build 炸掉。
  late final Object? originalData = _decodeOriginalData();

  // 获取原始数据对象（兼容旧调用点）
  dynamic getOriginalData() => originalData;

  Object? _decodeOriginalData() {
    try {
      return _decode();
    } catch (_) {
      return null;
    }
  }

  Object _decode() {
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
    DateTime? parseFlexible(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      // SQLite datetime('now') 产生的 "YYYY-MM-DD HH:MM:SS" 是 **UTC** 且不带时区后缀；
      // DateTime.tryParse 会把它当本地时间，UTC+8 下「刚刚看的」显示成「8 小时前」。
      // 没有时区标记就补 Z 按 UTC 解析，再转回本地。
      final hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(s);
      final parsed = DateTime.tryParse(
        hasZone ? s : '${s.replaceFirst(' ', 'T')}Z',
      );
      return parsed?.toLocal();
    }

    return HistoryRecord(
      id: json['id'],
      itemId: json['item_id'],
      itemType: json['item_type'],
      title: json['title'],
      thumbnailUrl: json['thumbnail_url'],
      author: json['author'],
      authorId: json['author_id'],
      data: json['data'],
      createdAt: parseFlexible(json['created_at']),
      updatedAt: parseFlexible(json['updated_at']),
      playedMs: json['progress_played_ms'] as int?,
      totalMs: json['progress_total_ms'] as int?,
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
