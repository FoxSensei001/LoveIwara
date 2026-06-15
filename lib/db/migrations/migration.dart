import 'dart:async';

import 'package:sqlite3/common.dart';

/// 迁移基类
abstract class Migration {
  /// 迁移版本
  int get version;

  /// 迁移描述
  String get description;

  /// 执行迁移操作（允许同步或异步实现）
  FutureOr<void> up(CommonDatabase db);

  /// 回滚迁移操作（可选，允许同步或异步实现）
  FutureOr<void> down(CommonDatabase db);
}
