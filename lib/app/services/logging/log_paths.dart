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
  final String exportDir;

  LogPaths._({
    required this.logDir,
    required this.currentLogFile,
    required this.crashMarkerFile,
    required this.fatalSnapshotFile,
    required this.hangEventsFile,
    required this.exportDir,
  });

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
      exportDir: exportDir,
    );
  }
}
