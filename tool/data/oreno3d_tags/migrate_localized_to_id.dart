// 一次性迁移：把 oreno3d 译名词典的主键从「日文原名」改成「type/id」。
//
// 为什么必须迁：
//   2554 个词条只有 2515 个不同的日文名——38 组同名词条（跨作品的同名角色，
//   如 スプラトゥーン 的 ホタル 与 崩壊:スターレイル 的 ホタル）在旧结构里
//   共享同一份译名，**结构上就无法分别翻译**。
//   另外上游一改名，按名字挂的译名会直接变成孤儿且无人察觉。
//
// 迁移是无损的：每个 id 继承它当前那份（可能是共享的）译名；
// 迁完之后那 38 组会各自拥有独立条目，可以分别修改。
//
// 用法（仓库根目录执行）：
//   dart run tool/data/oreno3d_tags/migrate_localized_to_id.dart          # 预演，只报告
//   dart run tool/data/oreno3d_tags/migrate_localized_to_id.dart --write  # 真正写入
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final write = args.contains('--write');
  final base = File(Platform.script.toFilePath()).parent.path;

  final raw = jsonDecode(
    File('$base/oreno3d_tags.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final locText = File('$base/oreno3d_tags_localized.json').readAsStringSync();
  final loc = jsonDecode(locText) as Map<String, dynamic>;

  // 已经是新格式（key 形如 characters/123）就直接退出，避免重复迁移。
  final alreadyMigrated =
      loc.keys.any((k) => RegExp(r'^(origins|characters|tags)/\d+$').hasMatch(k));
  if (alreadyMigrated) {
    stdout.writeln('译名文件已是 type/id 主键，无需迁移。');
    exit(0);
  }

  final entries = <Map<String, dynamic>>[];
  for (final cat in ['origins', 'characters', 'tags']) {
    for (final e in (raw[cat] as List)) {
      entries.add({...(e as Map).cast<String, dynamic>(), '_cat': cat});
    }
  }

  final byName = <String, List<String>>{};
  for (final e in entries) {
    byName
        .putIfAbsent(e['name'] as String, () => [])
        .add('${e['_cat']}/${e['id']}');
  }

  final out = <String, dynamic>{};
  final unmatched = <String>[];
  final collisions = <String, List<String>>{};

  for (final e in entries) {
    final key = '${e['_cat']}/${e['id']}';
    final name = e['name'] as String;
    final names = loc[name];
    if (names == null) {
      unmatched.add(key);
      continue;
    }
    out[key] = {
      ...(names as Map).cast<String, dynamic>(),
      // 保留日文原名：既是给人看的锚点，也是 localizeByName 反查表的来源。
      '_src': name,
    };
    if (byName[name]!.length > 1) collisions[name] = byName[name]!;
  }

  // 译名文件里存在、但原始数据里已经没有的名字（上游删名/改名的遗留）。
  final rawNames = byName.keys.toSet();
  final orphans = loc.keys.where((k) => !rawNames.contains(k)).toList();

  final sortedOut = <String, dynamic>{
    for (final k in out.keys.toList()..sort(_keyCompare)) k: out[k],
  };

  stdout.writeln('原始词条 ${entries.length} 条，不同日文名 ${byName.length} 个');
  stdout.writeln('迁移后主键 ${sortedOut.length} 条');
  stdout.writeln('缺译名（迁移后无条目）: ${unmatched.length}');
  stdout.writeln('孤儿译名（原始数据里已无此名）: ${orphans.length}');
  stdout.writeln('同名冲突 ${collisions.length} 组，迁移后各自独立、可分别修改：');
  for (final e in collisions.entries.take(8)) {
    stdout.writeln('  ${e.key} -> ${e.value.join(', ')}');
  }
  if (collisions.length > 8) {
    stdout.writeln('  …其余 ${collisions.length - 8} 组见 migration_report.json');
  }

  final report = {
    'entriesBefore': loc.length,
    'entriesAfter': sortedOut.length,
    'unmatched': unmatched,
    'orphans': orphans,
    'collisions': collisions,
  };
  File('$base/migration_report.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(report));

  if (!write) {
    stdout.writeln('\n（预演模式，未写入。确认无误后加 --write 重跑）');
    return;
  }

  File('$base/oreno3d_tags_localized.legacy_by_name.json')
      .writeAsStringSync(locText);
  File('$base/oreno3d_tags_localized.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(sortedOut));
  stdout.writeln('\n已写入：');
  stdout.writeln('  oreno3d_tags_localized.json                 （新，type/id 主键）');
  stdout.writeln('  oreno3d_tags_localized.legacy_by_name.json  （旧格式备份）');
  stdout.writeln('  migration_report.json                       （迁移报告）');
}

/// 按 类别 → 数字 id 排序，让 diff 稳定可读。
int _keyCompare(String a, String b) {
  final pa = a.split('/');
  final pb = b.split('/');
  final c = pa[0].compareTo(pb[0]);
  if (c != 0) return c;
  return (int.tryParse(pa[1]) ?? 0).compareTo(int.tryParse(pb[1]) ?? 0);
}
