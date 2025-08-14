import 'package:i_iwara/db/database_service.dart';
import 'package:get/get.dart';

class EmojiGroup {
  final int groupId;
  final String name;
  final String? coverUrl;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmojiGroup({
    required this.groupId,
    required this.name,
    this.coverUrl,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmojiGroup.fromMap(Map<String, dynamic> map) {
    return EmojiGroup(
      groupId: map['group_id'] as int,
      name: map['name'] as String,
      coverUrl: map['cover_url'] as String?,
      sortOrder: map['sort_order'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class EmojiImage {
  final int imageId;
  final int groupId;
  final String url;
  final String? thumbnailUrl;

  EmojiImage({
    required this.imageId,
    required this.groupId,
    required this.url,
    this.thumbnailUrl,
  });

  factory EmojiImage.fromMap(Map<String, dynamic> map) {
    return EmojiImage(
      imageId: map['image_id'] as int,
      groupId: map['group_id'] as int,
      url: map['url'] as String,
      thumbnailUrl: map['thumbnail_url'] as String?,
    );
  }
}

class EmojiLibraryService extends GetxService {
  late final DatabaseService _databaseService;

  @override
  void onInit() {
    super.onInit();
    _databaseService = Get.find<DatabaseService>();
  }

  // 获取所有表情包分组
  List<EmojiGroup> getEmojiGroups() {
    final db = _databaseService.database;
    final stmt = db.prepare('''
      SELECT * FROM EmojiGroups 
      ORDER BY sort_order ASC, created_at DESC
    ''');
    
    final result = stmt.select([]);
    stmt.dispose();
    
    return result.map((row) => EmojiGroup.fromMap(row)).toList();
  }

  // 创建新的表情包分组
  int createEmojiGroup(String name) {
    final db = _databaseService.database;
    
    // 获取当前最大排序值
    final maxSortStmt = db.prepare('''
      SELECT COALESCE(MAX(sort_order), -1) + 1 as next_sort 
      FROM EmojiGroups
    ''');
    final maxSortResult = maxSortStmt.select([]);
    maxSortStmt.dispose();
    
    final nextSort = maxSortResult.first['next_sort'] as int;
    
    final stmt = db.prepare('''
      INSERT INTO EmojiGroups (name, sort_order) VALUES (?, ?)
    ''');
    
    stmt.execute([name, nextSort]);
    stmt.dispose();
    
    final lastInsertStmt = db.prepare('SELECT last_insert_rowid() as id');
    final result = lastInsertStmt.select([]);
    lastInsertStmt.dispose();
    
    return result.first['id'] as int;
  }

  // 更新表情包分组名称
  void updateEmojiGroupName(int groupId, String name) {
    final db = _databaseService.database;
    final stmt = db.prepare('''
      UPDATE EmojiGroups 
      SET name = ?, updated_at = CURRENT_TIMESTAMP 
      WHERE group_id = ?
    ''');
    
    stmt.execute([name, groupId]);
    stmt.dispose();
  }

  // 删除表情包分组（级联删除所有图片）
  void deleteEmojiGroup(int groupId) {
    final db = _databaseService.database;
    final stmt = db.prepare('DELETE FROM EmojiGroups WHERE group_id = ?');
    
    stmt.execute([groupId]);
    stmt.dispose();
  }

  // 获取指定分组的表情图片
  List<EmojiImage> getEmojiImages(int groupId) {
    final db = _databaseService.database;
    final stmt = db.prepare('''
      SELECT * FROM EmojiImages 
      WHERE group_id = ? 
      ORDER BY image_id ASC
    ''');
    
    final result = stmt.select([groupId]);
    stmt.dispose();
    
    return result.map((row) => EmojiImage.fromMap(row)).toList();
  }

  // 获取分组的图片数量
  int getEmojiImageCount(int groupId) {
    final db = _databaseService.database;
    final stmt = db.prepare('''
      SELECT COUNT(*) as count FROM EmojiImages 
      WHERE group_id = ?
    ''');
    
    final result = stmt.select([groupId]);
    stmt.dispose();
    
    return result.first['count'] as int;
  }

  // 添加表情图片到分组
  void addEmojiImage(int groupId, String url, {String? thumbnailUrl}) {
    final db = _databaseService.database;
    
    // 检查URL是否已存在（去重）
    final checkStmt = db.prepare('''
      SELECT COUNT(*) as count FROM EmojiImages 
      WHERE group_id = ? AND url = ?
    ''');
    final checkResult = checkStmt.select([groupId, url]);
    checkStmt.dispose();
    
    if ((checkResult.first['count'] as int) > 0) {
      return; // URL已存在，跳过
    }
    
    // 插入新图片
    final insertStmt = db.prepare('''
      INSERT INTO EmojiImages (group_id, url, thumbnail_url) 
      VALUES (?, ?, ?)
    ''');
    insertStmt.execute([groupId, url, thumbnailUrl ?? url]);
    insertStmt.dispose();
    
    // 更新分组封面（如果是第一张图片）
    _updateGroupCoverIfNeeded(groupId);
  }

  // 批量添加表情图片
  void addEmojiImagesBatch(int groupId, List<String> urls) {
    final db = _databaseService.database;
    
    db.execute('BEGIN TRANSACTION');
    try {
      for (final url in urls) {
        addEmojiImage(groupId, url);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  // 删除表情图片
  void deleteEmojiImage(int imageId) {
    final db = _databaseService.database;
    
    // 获取图片信息
    final getImageStmt = db.prepare('''
      SELECT group_id FROM EmojiImages WHERE image_id = ?
    ''');
    final imageResult = getImageStmt.select([imageId]);
    getImageStmt.dispose();
    
    if (imageResult.isEmpty) return;
    
    final groupId = imageResult.first['group_id'] as int;
    
    // 删除图片
    final deleteStmt = db.prepare('DELETE FROM EmojiImages WHERE image_id = ?');
    deleteStmt.execute([imageId]);
    deleteStmt.dispose();
    
    // 更新分组封面
    _updateGroupCoverIfNeeded(groupId);
  }

  // 更新表情包分组排序
  void updateEmojiGroupOrder(int groupId, int newSortOrder) {
    final db = _databaseService.database;
    final stmt = db.prepare('''
      UPDATE EmojiGroups 
      SET sort_order = ?, updated_at = CURRENT_TIMESTAMP 
      WHERE group_id = ?
    ''');
    
    stmt.execute([newSortOrder, groupId]);
    stmt.dispose();
  }

  // 批量更新表情包分组排序
  void updateEmojiGroupsOrder(List<EmojiGroup> groups) {
    final db = _databaseService.database;
    
    db.execute('BEGIN TRANSACTION');
    try {
      for (int i = 0; i < groups.length; i++) {
        updateEmojiGroupOrder(groups[i].groupId, i);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  // 私有方法：更新分组封面（如果需要）
  void _updateGroupCoverIfNeeded(int groupId) {
    final db = _databaseService.database;
    
    // 获取分组的第一张图片作为封面
    final firstImageStmt = db.prepare('''
      SELECT url FROM EmojiImages 
      WHERE group_id = ? 
      ORDER BY image_id ASC 
      LIMIT 1
    ''');
    final firstImageResult = firstImageStmt.select([groupId]);
    firstImageStmt.dispose();
    
    String? coverUrl;
    if (firstImageResult.isNotEmpty) {
      coverUrl = firstImageResult.first['url'] as String;
    }
    
    // 更新分组封面
    final updateCoverStmt = db.prepare('''
      UPDATE EmojiGroups 
      SET cover_url = ?, updated_at = CURRENT_TIMESTAMP 
      WHERE group_id = ?
    ''');
    updateCoverStmt.execute([coverUrl, groupId]);
    updateCoverStmt.dispose();
  }
}