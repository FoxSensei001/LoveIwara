import 'package:get/get.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';

/// 作者首见名缓存（issue #126 下载子文件夹归档）。
///
/// `%authorcache` 变量的存储后端：key 是作者 ID（唯一句柄，永不漂移），
/// value 是第一次下载该作者内容时的显示名（可读）。作者改昵称后，新下载仍
/// 解析出同一个文件夹名，归档不会裂成两半。
///
/// 设计取舍：
/// - 纯加速缓存，允许丢。随清数据/换设备蒸发后，后果只是「改名作者再下载会
///   另起新文件夹」，v2.1 整理工具可收敛——所以不做任何持久化花活。
/// - 只做存取，不做清洗。文件夹名的合法性（非法字符/长度/保留名）由调用方
///   在写入前用 `FilenameTemplateService.sanitizePathSegment` 保证，这里原样
///   落库、原样吐出，读回来的值可以放心直接拼路径。
/// - 「首见」语义由调用方把关：回退值（如作者缺失时的 unknown）不是首见名，
///   绝不能写进来，否则会被钉死成永久文件夹名。
class AuthorFolderCacheService extends GetxService {
  static AuthorFolderCacheService get to => Get.find();

  final CommonDatabase _db;

  AuthorFolderCacheService([CommonDatabase? database])
    : _db = database ?? DatabaseService().database;

  /// 查作者的首见文件夹名。未写入过（或读库出错）返回 null，调用方回退到
  /// 当前显示名。
  String? folderNameFor(String authorId) {
    try {
      final result = _db.select(
        'SELECT folder_name FROM author_folder_cache WHERE author_id = ?;',
        [authorId],
      );
      if (result.isEmpty) return null;
      final value = result.first['folder_name'];
      return value is String && value.isNotEmpty ? value : null;
    } catch (e) {
      LogUtils.e('查询作者首见名缓存失败: $authorId', tag: 'AuthorFolderCache', error: e);
      return null;
    }
  }

  /// 记录作者的首见文件夹名。已存在的记录**不覆盖**——「首见」只有一次；
  /// 覆盖语义（手动刷新）留给 v2 的缓存管理入口。
  void recordFirstSeen(String authorId, String folderName) {
    try {
      _db.execute(
        'INSERT OR IGNORE INTO author_folder_cache(author_id, folder_name) VALUES (?, ?);',
        [authorId, folderName],
      );
    } catch (e) {
      LogUtils.e('写入作者首见名缓存失败: $authorId', tag: 'AuthorFolderCache', error: e);
    }
  }
}
