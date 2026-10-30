import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/common/constants.dart';
import 'log_models.dart';

class LogPaths {
  final String logDir;
  final String currentLogFile;
  final String crashMarkerFile;
  final String fatalSnapshotFile;
  final String hangEventsFile;

  /// 系统退出记录的本地存档（见 CrashDetectionService 的存档说明）。
  final String exitArchiveFile;

  /// 存档里各条记录的 tombstone / ANR 线程栈，一条一个文件，只留最近几份。
  final String exitTraceDir;
  final String exportDir;

  LogPaths._({
    required this.logDir,
    required this.currentLogFile,
    required this.crashMarkerFile,
    required this.fatalSnapshotFile,
    required this.hangEventsFile,
    required this.exitArchiveFile,
    required this.exitTraceDir,
    required this.exportDir,
  });

  /// 冷启动分段计时的落点。用 getter 而不是构造参数：它只是 [logDir] 下的一个
  /// 固定名字，两个构造器都不必各抄一遍。
  String get startupTraceFile =>
      p.join(logDir, LogConstants.startupTraceFileName);

  String rotatedFile(int index) =>
      p.join(logDir, '${LogConstants.logFileName}.$index');

  static Future<LogPaths> resolve() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appName = CommonConstants.applicationName ?? 'i_iwara';
    final logDir = p.join(appDocDir.path, appName, 'logs');

    await Directory(logDir).create(recursive: true);

    final tempDir = await getTemporaryDirectory();
    final exportDir = p.join(tempDir.path, 'log_export');
    await Directory(exportDir).create(recursive: true);

    return LogPaths._(
      logDir: logDir,
      currentLogFile: p.join(logDir, LogConstants.logFileName),
      crashMarkerFile: p.join(logDir, LogConstants.crashMarkerFileName),
      fatalSnapshotFile: p.join(logDir, LogConstants.fatalSnapshotFileName),
      hangEventsFile: p.join(logDir, LogConstants.hangEventsFileName),
      exitArchiveFile: p.join(logDir, LogConstants.exitArchiveFileName),
      exitTraceDir: p.join(logDir, 'exit_traces'),
      exportDir: exportDir,
    );
  }

  factory LogPaths.forTesting({
    required String logDir,
    required String exportDir,
  }) {
    Directory(logDir).createSync(recursive: true);
    Directory(exportDir).createSync(recursive: true);
    return LogPaths._(
      logDir: logDir,
      currentLogFile: p.join(logDir, LogConstants.logFileName),
      crashMarkerFile: p.join(logDir, LogConstants.crashMarkerFileName),
      fatalSnapshotFile: p.join(logDir, LogConstants.fatalSnapshotFileName),
      hangEventsFile: p.join(logDir, LogConstants.hangEventsFileName),
      exitArchiveFile: p.join(logDir, LogConstants.exitArchiveFileName),
      exitTraceDir: p.join(logDir, 'exit_traces'),
      exportDir: exportDir,
    );
  }
}
