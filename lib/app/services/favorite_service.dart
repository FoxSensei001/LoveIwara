import 'dart:convert';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/favorite/favorite_folder.model.dart';
import 'package:i_iwara/app/models/favorite/favorite_item.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';

class FavoriteService {
  static FavoriteService get to => Get.find();
  
  late final CommonDatabase _db;
  final RxInt favoriteChangedNotifier = 0.obs;

  FavoriteService() {
    _db = DatabaseService().database;
  }

  // 获取所有收藏夹
  Future<List<FavoriteFolder>> getAllFolders() async {
    try {
      final stmt = _db.prepare('''
        SELECT 
          f.*,
          (SELECT COUNT(*) FROM favorite_items WHERE folder_id = f.id) as item_count
        FROM favorite_folders f
        ORDER BY created_at DESC
      ''');
      
      final results = stmt.select();
      return results.map((row) => FavoriteFolder.fromJson(row)).toList();
    } catch (e) {
      LogUtils.e('获取收藏夹列表失败', tag: 'FavoriteService', error: e);
      return [];
    }
  }

  // 创建收藏夹
  Future<FavoriteFolder?> createFolder({
    required String title,
    String? description,
  }) async {
    try {
      final folder = FavoriteFolder(
        title: title,
        description: description,
      );

      _db.prepare('''
        INSERT INTO favorite_folders (id, title, description, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?)
      ''').execute([
        folder.id,
        folder.title,
        folder.description,
        folder.createdAt.millisecondsSinceEpoch ~/ 1000,
        folder.updatedAt.millisecondsSinceEpoch ~/ 1000,
      ]);

      favoriteChangedNotifier.value++;
      return folder;
    } catch (e) {
      LogUtils.e('创建收藏夹失败', tag: 'FavoriteService', error: e);
      return null;
    }
  }

  // 删除收藏夹
  Future<bool> deleteFolder(String folderId) async {
    if (folderId == 'default') return false;
    
    try {
      // 开始事务
      _db.execute('BEGIN TRANSACTION');
      
      try {
        // 先删除文件夹中的所有收藏项
        _db.prepare('DELETE FROM favorite_items WHERE folder_id = ?')
          .execute([folderId]);
        
        // 再删除文件夹本身
        _db.prepare('DELETE FROM favorite_folders WHERE id = ?')
          .execute([folderId]);
        
        // 提交事务
        _db.execute('COMMIT');
        
        favoriteChangedNotifier.value++;
        return true;
      } catch (e) {
        // 如果出错，回滚事务
        _db.execute('ROLLBACK');
        rethrow;
      }
    } catch (e) {
      LogUtils.e('删除收藏夹失败', tag: 'FavoriteService', error: e);
      return false;
    }
  }

  // 获取收藏夹中的所有项目
  Future<List<FavoriteItem>> getFolderItems(String folderId, {
    int offset = 0,
    int limit = 20,
    String? searchText,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var sql = '''
        SELECT * FROM favorite_items 
        WHERE folder_id = ?
      ''';
      
      final List<dynamic> params = [folderId];

      if (searchText != null && searchText.isNotEmpty) {
        sql += ' AND title LIKE ?';
        params.add('%$searchText%');
      }

      if (startDate != null) {
        sql += ' AND created_at >= ?';
        params.add(startDate.millisecondsSinceEpoch ~/ 1000);
      }

      if (endDate != null) {
        // 确保包含结束日期的整天
        final endOfDay = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        );
        sql += ' AND created_at <= ?';
        params.add(endOfDay.millisecondsSinceEpoch ~/ 1000);
      }

      sql += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
      params.addAll([limit, offset]);
      
      final stmt = _db.prepare(sql);
      final results = stmt.select(params);
      return results.map((row) => FavoriteItem.fromJson(row)).toList();
    } catch (e) {
      LogUtils.e('获取收藏夹内容失败', tag: 'FavoriteService', error: e);
      return [];
    }
  }

  // 检查项目是否在指定文件夹中
  Future<bool> isItemInFolder(String itemId, String folderId) async {
    try {
      final stmt = _db.prepare('''
        SELECT COUNT(*) as count 
        FROM favorite_items 
        WHERE item_id = ? AND folder_id = ?
      ''');
      
      final result = stmt.select([itemId, folderId]);
      return result.first['count'] > 0;
    } catch (e) {
      LogUtils.e('检查项目是否在收藏夹中失败', tag: 'FavoriteService', error: e);
      return false;
    }
  }

  // 从收藏夹中移除指定项目
  Future<bool> removeItemFromFolder(String itemId, String folderId) async {
    try {
      _db.prepare('DELETE FROM favorite_items WHERE item_id = ? AND folder_id = ?')
        .execute([itemId, folderId]);
      
      favoriteChangedNotifier.value++;
      return true;
    } catch (e) {
      LogUtils.e('从收藏夹移除项目失败', tag: 'FavoriteService', error: e);
      return false;
    }
  }

  // 添加视频到收藏夹
  Future<bool> addVideoToFolder(Video video, String folderId) async {
    try {
      // 检查是否已在文件夹中
      final isInFolder = await isItemInFolder(video.id, folderId);
      if (isInFolder) {
        // 如果已在文件夹中,则移除
        return await removeItemFromFolder(video.id, folderId);
      }

      final item = FavoriteItem(
        folderId: folderId,
        itemType: FavoriteItemType.video,
        itemId: video.id,
        title: video.title ?? '',
        previewUrl: video.thumbnailUrl,
        authorName: video.user?.name,
        authorUsername: video.user?.username,
        authorAvatarUrl: video.user?.avatar?.avatarUrl,
        extData: video.toJson(),
      );

      _db.prepare('''
        INSERT INTO favorite_items (
          id, folder_id, item_type, item_id, title, preview_url,
          author_name, author_username, author_avatar_url, ext_data,
          created_at, updated_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''').execute([
        item.id,
        item.folderId,
        item.itemType.name,
        item.itemId,
        item.title,
        item.previewUrl,
        item.authorName,
        item.authorUsername,
        item.authorAvatarUrl,
        item.extData != null ? jsonEncode(item.extData) : null,
        item.createdAt.millisecondsSinceEpoch ~/ 1000,
        item.updatedAt.millisecondsSinceEpoch ~/ 1000,
      ]);

      favoriteChangedNotifier.value++;
      return true;
    } catch (e) {
      LogUtils.e('添加视频到收藏夹失败', tag: 'FavoriteService', error: e);
      return false;
    }
  }

  // 添加图片到收藏夹
  Future<bool> addImageToFolder(ImageModel image, String folderId) async {
    try {
      // 检查是否已在文件夹中
      final isInFolder = await isItemInFolder(image.id, folderId);
      if (isInFolder) {
        // 如果已在文件夹中,则移除
        return await removeItemFromFolder(image.id, folderId);
      }

      // 创建一个不包含 files 字段的新 ImageModel
      final imageWithoutFiles = image.copyWith(files: []);

      final item = FavoriteItem(
        folderId: folderId,
        itemType: FavoriteItemType.image,
        itemId: image.id,
        title: image.title,
        previewUrl: image.thumbnailUrl,
        authorName: image.user?.name,
        authorUsername: image.user?.username,
        authorAvatarUrl: image.user?.avatar?.avatarUrl,
        extData: imageWithoutFiles.toJson(),
      );

      _db.prepare('''
        INSERT INTO favorite_items (
          id, folder_id, item_type, item_id, title, preview_url,
          author_name, author_username, author_avatar_url, ext_data,
          created_at, updated_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''').execute([
        item.id,
        item.folderId,
        item.itemType.name,
        item.itemId,
        item.title,
        item.previewUrl,
        item.authorName,
        item.authorUsername,
        item.authorAvatarUrl,
        item.extData != null ? jsonEncode(item.extData) : null,
        item.createdAt.millisecondsSinceEpoch ~/ 1000,
        item.updatedAt.millisecondsSinceEpoch ~/ 1000,
      ]);

      favoriteChangedNotifier.value++;
      return true;
    } catch (e) {
      LogUtils.e('添加图片到收藏夹失败', tag: 'FavoriteService', error: e);
      return false;
    }
  }

  // 添加用户到收藏夹
  Future<bool> addUserToFolder(User user, String folderId) async {
    try {
      // 检查是否已在文件夹中
      final isInFolder = await isItemInFolder(user.id, folderId);
      if (isInFolder) {
        // 如果已在文件夹中,则移除
        return await removeItemFromFolder(user.id, folderId);
      }

      final item = FavoriteItem(
        folderId: folderId,
        itemType: FavoriteItemType.user,
        itemId: user.id,
        title: user.name,
        previewUrl: user.avatar?.avatarUrl,
        authorName: user.name,
        authorUsername: user.username,
        authorAvatarUrl: user.avatar?.avatarUrl,
        extData: user.toJson(),
      );

      _db.prepare('''
        INSERT INTO favorite_items (
          id, folder_id, item_type, item_id, title, preview_url,
          author_name, author_username, author_avatar_url, ext_data,
          created_at, updated_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''').execute([
        item.id,
        item.folderId,
        item.itemType.name,
        item.itemId,
        item.title,
        item.previewUrl,
        item.authorName,
        item.authorUsername,
        item.authorAvatarUrl,
        item.extData != null ? jsonEncode(item.extData) : null,
        item.createdAt.millisecondsSinceEpoch ~/ 1000,
        item.updatedAt.millisecondsSinceEpoch ~/ 1000,
      ]);

      favoriteChangedNotifier.value++;
      return true;
    } catch (e) {
      LogUtils.e('添加用户到收藏夹失败', tag: 'FavoriteService', error: e);
      return false;
    }
  }

  // 从收藏夹中移除项目
  Future<bool> removeFromFolder(String itemId) async {
    try {
      _db.prepare('DELETE FROM favorite_items WHERE id = ?')
        .execute([itemId]);
      
      favoriteChangedNotifier.value++;
      return true;
    } catch (e) {
      LogUtils.e('从收藏夹移除项目失败', tag: 'FavoriteService', error: e);
      return false;
    }
  }

  // 检查项目是否已在收藏夹中
  Future<List<FavoriteFolder>> getItemFolders(String itemId) async {
    try {
      final stmt = _db.prepare('''
        SELECT 
          f.*,
          (SELECT COUNT(*) FROM favorite_items WHERE folder_id = f.id) as item_count
        FROM favorite_folders f
        WHERE EXISTS (
          SELECT 1 FROM favorite_items 
          WHERE folder_id = f.id AND item_id = ?
        )
      ''');
      
      final results = stmt.select([itemId]);
      return results.map((row) => FavoriteFolder.fromJson(row)).toList();
    } catch (e) {
      LogUtils.e('获取项目所在收藏夹失败', tag: 'FavoriteService', error: e);
      return [];
    }
  }

  // 更新收藏夹
  Future<bool> updateFolder(String folderId, {
    required String title,
    String? description,
  }) async {
    if (folderId == 'default') return false;
    
    try {
      _db.prepare('''
        UPDATE favorite_folders 
        SET title = ?, description = ?, updated_at = ?
        WHERE id = ?
      ''').execute([
        title,
        description,
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        folderId,
      ]);

      favoriteChangedNotifier.value++;
      return true;
    } catch (e) {
      LogUtils.e('更新收藏夹失败', tag: 'FavoriteService', error: e);
      return false;
    }
  }
} 