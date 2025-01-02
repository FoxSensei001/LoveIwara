import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:sqlite3/common.dart';

class DownloadTaskRepository {
  late final CommonDatabase _db;

  DownloadTaskRepository() {
    _db = DatabaseService().database;
  }

  Future<List<DownloadTask>> getAllTasks() async {
    final stmt = _db.prepare('''
      SELECT * FROM download_tasks 
      ORDER BY created_at DESC
    ''');
    
    final results = stmt.select([]);
    return results.map((row) => DownloadTask.fromRow(row)).toList();
  }

  Future<void> insertTask(DownloadTask task) async {
    _db.prepare('''
      INSERT INTO download_tasks 
      (id, url, save_path, file_name, total_bytes, downloaded_bytes, status, supports_range, error)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''').execute([
      task.id,
      task.url,
      task.savePath,
      task.fileName,
      task.totalBytes,
      task.downloadedBytes,
      task.status.name,
      task.supportsRange ? 1 : 0,
      task.error
    ]);
  }

  Future<void> updateTask(DownloadTask task) async {
    _db.prepare('''
      UPDATE download_tasks 
      SET url = ?, 
          save_path = ?, 
          file_name = ?, 
          total_bytes = ?, 
          downloaded_bytes = ?, 
          status = ?, 
          supports_range = ?, 
          error = ?, 
          updated_at = ?
      WHERE id = ?
    ''').execute([
      task.url,
      task.savePath,
      task.fileName,
      task.totalBytes,
      task.downloadedBytes,
      task.status.name,
      task.supportsRange ? 1 : 0,
      task.error,
      DateTime.now().millisecondsSinceEpoch,
      task.id
    ]);
  }

  Future<void> deleteTask(String taskId) async {
    _db.prepare('DELETE FROM download_tasks WHERE id = ?')
      .execute([taskId]);
  }

  Future<void> deleteAllTasks() async {
    _db.prepare('DELETE FROM download_tasks').execute();
  }
} 