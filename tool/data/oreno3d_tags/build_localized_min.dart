// 合并工具：把「原始标签元数据」+「AI 译名」+「人工修正」合并为 App / CDN 直接消费的紧凑文件。
//
// 合并优先级（后者胜）：原始元数据 → AI 译名 → overrides.json
//
// 输入：
//   - oreno3d_tags.json               原始抓取（含 id, origins, characters, tags 等）
//   - oreno3d_tags_localized.json     AI 译名（**type/id -> {zh-CN, zh-TW, ja, en}**）
//   - overrides.json                  人工修正层，永远压过 AI 译名，重译不碰
// 输出：
//   - oreno3d_tags_localized.min.json 压缩版 AI 译名
//   - oreno3d_tags.min.json           合并后的紧凑文件（App 打包资源 + jsDelivr CDN 源）
//   - ../../../assets/data/oreno3d_tags.min.json  同步一份到打包资源目录
//   - needs_review.json               上游 AI 值已偏离 override 记录的 prev，需人工复核
//
// 产物结构（紧凑，键名缩写以省体积）：
//   {"version":2,"rev":"<内容指纹>","counts":{...},
//    "origins":{"1":{"n":{"zh-CN":"..."},"w":123}},...}
//
// rev 是全量内容指纹：只改译名、条数不变时它也会变，App 靠它判断词库有没有更新。
//
// 用法（在仓库根目录执行）：
//   dart run tool/data/oreno3d_tags/build_localized_min.dart
import 'dart:convert';
import 'dart:io';

import '../../tag_overrides/overrides.dart';

void main() {
  final dir = File(Platform.script.toFilePath()).parent;
  final base = dir.path;

  final locRaw = jsonDecode(
    File('$base/oreno3d_tags_localized.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  if (!locRaw.keys.any(
      (k) => RegExp(r'^(origins|characters|tags)/\d+$').hasMatch(k))) {
    stderr.writeln('译名文件还是「日文原名」主键。'
        '先跑 dart run tool/data/oreno3d_tags/migrate_localized_to_id.dart --write');
    exit(2);
  }

  File('$base/oreno3d_tags_localized.min.json')
      .writeAsStringSync(jsonEncode(locRaw));

  final raw = jsonDecode(
    File('$base/oreno3d_tags.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  // 主键 → AI 译名
  final aiNames = <String, Map<String, String>>{};
  for (final e in locRaw.entries) {
    final m = (e.value as Map).cast<String, dynamic>();
    aiNames[e.key] = {
      for (final l in kLangs)
        if (m[l] != null) l: '${m[l]}',
    };
  }

  final knownKeys = <String>{};
  for (final cat in ['origins', 'characters', 'tags']) {
    for (final e in (raw[cat] as List)) {
      knownKeys.add('$cat/${(e as Map)['id']}');
    }
  }

  final merged = mergeOverrides(
    aiNames: aiNames,
    overrides: loadOverrides('$base/overrides.json'),
    knownKeys: knownKeys,
  );

  Map<String, dynamic> processItems(String cat, List<dynamic>? items) {
    final result = <String, dynamic>{};
    if (items == null) return result;
    for (final item in items) {
      final uid = item['id'].toString();
      final name = item['name'].toString();
      final names = merged.names['$cat/$uid'] ?? const {};

      final compact = <String, dynamic>{
        // 缺译名一律回退日文原名，App 侧不需要再判空。
        'n': {for (final l in kLangs) l: names[l] ?? name},
      };
      if (item.containsKey('workCount')) compact['w'] = item['workCount'];
      if (item.containsKey('origin')) compact['o'] = item['origin'];
      if (item.containsKey('groupId')) compact['g'] = item['groupId'];
      result[uid] = compact;
    }
    return result;
  }

  final origins = processItems('origins', raw['origins'] as List?);
  final characters = processItems('characters', raw['characters'] as List?);
  final tags = processItems('tags', raw['tags'] as List?);

  final payload = {
    'counts': raw['counts'],
    'origins': origins,
    'characters': characters,
    'tags': tags,
  };
  final rev = contentRev(payload);
  // builtAt 放在指纹载荷之外：它是「谁更新」的判据，不该反过来改变指纹。
  final out = {
    'version': 2,
    'rev': rev,
    'builtAt': buildStamp('$base/oreno3d_tags.min.json', rev),
    ...payload,
  };
  final encoded = jsonEncode(out);

  File('$base/oreno3d_tags.min.json').writeAsStringSync(encoded);
  final assetFile = File('$base/../../../assets/data/oreno3d_tags.min.json');
  assetFile.parent.createSync(recursive: true);
  assetFile.writeAsStringSync(encoded);

  _reportOverrides(base, merged, out['rev'] as String);

  stdout.writeln(
      '合并完成：${origins.length} 原作, ${characters.length} 角色, ${tags.length} 标签');
  stdout.writeln('  rev = ${out['rev']}');
  stdout.writeln('  -> $base/oreno3d_tags.min.json');
  stdout.writeln('  -> ${assetFile.path}');
}

void _reportOverrides(String base, MergeResult merged, String rev) {
  stdout.writeln('人工修正生效 ${merged.appliedCount} 处');
  if (merged.orphanKeys.isNotEmpty) {
    stdout.writeln('⚠ overrides 里有 ${merged.orphanKeys.length} 条指向已不存在的词条：'
        '${merged.orphanKeys.take(5).join(', ')}');
  }
  final f = File('$base/needs_review.json');
  if (merged.needsReview.isEmpty) {
    if (f.existsSync()) f.deleteSync();
    return;
  }
  stdout.writeln('⚠ ${merged.needsReview.length} 处人工修正的上游值已变化，需复核：');
  for (final r in merged.needsReview.take(5)) {
    stdout.writeln('    $r');
  }
  f.writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
    'rev': rev,
    'items': merged.needsReview.map((e) => e.toJson()).toList(),
  }));
  stdout.writeln('  详情 -> $base/needs_review.json');
}
