import 'package:uuid/uuid.dart';
import 'dart:convert';

enum FavoriteItemType {
  video,
  image,
  user,
}

class FavoriteItem {
  final String id;
  final String folderId;
  final FavoriteItemType itemType;
  final String itemId;
  final String title;
  final String? previewUrl;
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final Map<String, dynamic>? extData;
  final DateTime createdAt;
  final DateTime updatedAt;

  FavoriteItem({
    String? id,
    required this.folderId,
    required this.itemType,
    required this.itemId,
    required this.title,
    this.previewUrl,
    this.authorName,
    this.authorUsername,
    this.authorAvatarUrl,
    this.extData,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'],
      folderId: json['folder_id'],
      itemType: FavoriteItemType.values.firstWhere(
        (e) => e.name == json['item_type'],
        orElse: () => FavoriteItemType.video,
      ),
      itemId: json['item_id'],
      title: json['title'],
      previewUrl: json['preview_url'],
      authorName: json['author_name'],
      authorUsername: json['author_username'],
      authorAvatarUrl: json['author_avatar_url'],
      extData: json['ext_data'] != null ? jsonDecode(json['ext_data']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] * 1000)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folder_id': folderId,
      'item_type': itemType.name,
      'item_id': itemId,
      'title': title,
      'preview_url': previewUrl,
      'author_name': authorName,
      'author_username': authorUsername,
      'author_avatar_url': authorAvatarUrl,
      'ext_data': extData,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  FavoriteItem copyWith({
    String? id,
    String? folderId,
    FavoriteItemType? itemType,
    String? itemId,
    String? title,
    String? previewUrl,
    String? authorName,
    String? authorUsername,
    String? authorAvatarUrl,
    Map<String, dynamic>? extData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      previewUrl: previewUrl ?? this.previewUrl,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      extData: extData ?? this.extData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 