import 'package:i_iwara/app/models/frame_interp/frame_interp_task.model.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:sqlite3/common.dart';

/// 补帧任务表的读写。
///
/// 任务数量是「用户手动点出来的」量级（几十到几百条），所以这里不做分页，
/// 服务启动时整表读进内存，之后内存为准、逐条落库。
class FrameInterpTaskRepository {
  FrameInterpTaskRepository([CommonDatabase? database])
    : _db = database ?? DatabaseService().database;

  final CommonDatabase _db;

  /// 新的在前。
  List<FrameInterpTask> loadAll() {
    final rows = _db.select(
      'SELECT * FROM frame_interp_tasks ORDER BY created_at DESC, id DESC',
    );
    return [for (final row in rows) FrameInterpTask.fromRow(row)];
  }

  void insert(FrameInterpTask task) {
    _db.execute(
      '''
      INSERT INTO frame_interp_tasks(
        id, source_path, source_key, output_path, output_key, title, thumbnail,
        status, progress, error_code, error, width, height, source_fps,
        duration_ms, source_size, output_size, encoder,
        created_at, updated_at, completed_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        task.id,
        task.sourcePath,
        task.sourceKey,
        task.outputPath,
        task.outputKey,
        task.title,
        task.thumbnail,
        task.status.name,
        task.progress,
        task.errorCode,
        task.error,
        task.width,
        task.height,
        task.sourceFps,
        task.durationMs,
        task.sourceSize,
        task.outputSize,
        task.encoder,
        task.createdAt,
        task.updatedAt,
        task.completedAt,
      ],
    );
  }

  /// 只写会变的那几列：路径、片源参数这些在任务建好之后就不动了。
  void updateState(FrameInterpTask task) {
    _db.execute(
      '''
      UPDATE frame_interp_tasks
      SET status = ?, progress = ?, error_code = ?, error = ?,
          output_size = ?, encoder = ?, updated_at = ?, completed_at = ?
      WHERE id = ?
      ''',
      [
        task.status.name,
        task.progress,
        task.errorCode,
        task.error,
        task.outputSize,
        task.encoder,
        task.updatedAt,
        task.completedAt,
        task.id,
      ],
    );
  }

  /// 片源 / 成品 / 本地封面被挪了地方（iOS 更新后沙盒容器换了路径）时改指过去。
  void updatePaths(FrameInterpTask task) {
    _db.execute(
      '''
      UPDATE frame_interp_tasks
      SET source_path = ?, source_key = ?, output_path = ?, output_key = ?,
          thumbnail = ?
      WHERE id = ?
      ''',
      [
        task.sourcePath,
        task.sourceKey,
        task.outputPath,
        task.outputKey,
        task.thumbnail,
        task.id,
      ],
    );
  }

  void delete(String id) {
    _db.execute('DELETE FROM frame_interp_tasks WHERE id = ?', [id]);
  }
}
