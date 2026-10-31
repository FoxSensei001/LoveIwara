import 'package:file_selector/file_selector.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;

/// 桌面端「另存为」系统对话框的唯一入口。全仓的 `getSaveLocation` 都走这里。
///
/// # 为什么要收口
///
/// Flutter 3.47 在 Windows 上默认把 Dart UI 跑在平台线程上（引擎
/// `UIThreadPolicy::Default`），而 `file_selector_windows` 在平台线程上**同步**
/// 调 `IFileDialog::Show`。对话框一旦在创建阶段卡住，Dart 和窗口消息一起停，
/// 整个应用变成「未响应」，用户只能强关（2026-10-31 群友报的「无响应闪退」）。
///
/// 对话框不传起始目录时，会打开上次用过的目录。那是断开的网络盘 / NAS / 拔掉的
/// 移动盘时，Windows 会在这里卡很久。所以：
/// - 起始目录固定用系统「下载」文件夹（本地）；
/// - 弹框前后各打一条 INFO：卡住时日志停在「弹出」那条，下次报障能直接定位。
///
/// [purpose] 只用于日志，说明是谁弹的框。
Future<FileSaveLocation?> showDesktopSaveDialog({
  required String purpose,
  String? suggestedName,
  List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
}) async {
  String? initialDirectory;
  try {
    initialDirectory = (await path_provider.getDownloadsDirectory())?.path;
  } catch (e) {
    LogUtils.w('取系统下载文件夹失败，保存框不指定起始目录: $e', 'DesktopSaveDialog');
  }

  // 只记盘符 / 共享根，不记完整路径（里面有用户名）。下载文件夹被重定向到网络
  // 共享时，根是 `\\server\share`，一眼能看出来。
  final root = initialDirectory == null
      ? '未指定'
      : p.rootPrefix(initialDirectory);
  LogUtils.i('弹出系统保存对话框（用途: $purpose，起始目录根: $root）', 'DesktopSaveDialog');
  final stopwatch = Stopwatch()..start();
  try {
    final result = await getSaveLocation(
      suggestedName: suggestedName,
      initialDirectory: initialDirectory,
      acceptedTypeGroups: acceptedTypeGroups,
    );
    LogUtils.i(
      '系统保存对话框已关闭（用途: $purpose，${result == null ? '取消' : '已选择'}，'
          '用时 ${stopwatch.elapsedMilliseconds}ms）',
      'DesktopSaveDialog',
    );
    return result;
  } catch (e) {
    LogUtils.e(
      '系统保存对话框出错（用途: $purpose，用时 ${stopwatch.elapsedMilliseconds}ms）',
      tag: 'DesktopSaveDialog',
      error: e,
    );
    rethrow;
  }
}
