import 'package:uuid/uuid.dart';

/// 下载分类（自定义文件夹）。
///
/// 一个下载任务至多归属一个分类（`DownloadTask.categoryId`）；
/// `categoryId == null` 表示「未分类」，未分类是虚拟桶，不对应此表中的行。
class DownloadCategory {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int displayOrder;

  /// 该分类下的任务数量（来自带 COUNT 的联表查询，可选）。
  final int? itemCount;

  DownloadCategory({
    String? id,
    required this.title,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.displayOrder = 0,
    this.itemCount,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 数据库以秒（strftime('%s')）存储 created_at/updated_at，这里 *1000 还原为毫秒。
  factory DownloadCategory.fromRow(Map<String, dynamic> row) {
    return DownloadCategory(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch((row['created_at'] as int) * 1000)
          : null,
      updatedAt: row['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch((row['updated_at'] as int) * 1000)
          : null,
      displayOrder: (row['display_order'] as int?) ?? 0,
      itemCount: row['item_count'] as int?,
    );
  }

  DownloadCategory copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? displayOrder,
    int? itemCount,
  }) {
    return DownloadCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      displayOrder: displayOrder ?? this.displayOrder,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}
