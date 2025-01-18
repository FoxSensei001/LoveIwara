import 'package:uuid/uuid.dart';

class FavoriteFolder {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? itemCount; // 收藏项数量，可选

  FavoriteFolder({
    String? id,
    required this.title,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.itemCount,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory FavoriteFolder.fromJson(Map<String, dynamic> json) {
    return FavoriteFolder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] * 1000)
          : null,
      itemCount: json['item_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
      'item_count': itemCount,
    };
  }

  FavoriteFolder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? itemCount,
  }) {
    return FavoriteFolder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itemCount: itemCount ?? this.itemCount,
    );
  }
} 