import 'package:sqlite3/common.dart' show CommonDatabase;

Future<CommonDatabase> openSqliteDb({String? customPath}) async {
  throw UnsupportedError('Sqlite3 is unsupported on this platform.');
}
