// 合并工具：把「原始标签元数据」+「AI 译名」+「人工修正」合并为 App / CDN 直接消费的紧凑文件。
//
// 合并优先级（后者胜）：原始元数据 → AI 译名 → overrides.json
//
// 输入：
//   - iwara_tags.json               原始抓取（含 id / type / sensitive）
//   - iwara_tags_localized.json     AI 译名（id -> {zh-CN, zh-TW, ja, en}）
//   - overrides.json                人工修正层，永远压过 AI 译名，重译不碰
//                                   （译名走 n，元数据走 meta:{type, sensitive}）
// 输出：
//   - iwara_tags_localized.min.json 压缩版 AI 译名
//   - iwara_tags.min.json           合并后的紧凑文件（App 打包资源 + jsDelivr CDN 源）
//   - ../../../assets/data/iwara_tags.min.json  同步一份到打包资源目录
//   - needs_review.json             上游 AI 值已偏离 override 记录的 prev，需人工复核
//
// 产物结构（紧凑，键名缩写以省体积）：
//   {"version":2,"rev":"<内容指纹>","count":2669,"tags":{
//      "mother":{"y":"general","s":0,"n":{"zh-CN":"母亲","zh-TW":"母親","ja":"母親","en":"Mother"}}
//   }}
//   y = type，s = sensitive(0/1)，n = 各语言译名。
//
// rev 是全量内容指纹：只改译名、条数不变时它也会变，App 靠它判断词库有没有更新。
//
// 用法（在仓库根目录执行）：
//   dart run tool/data/iwara_tags/build_localized_min.dart
import 'dart:convert';
import 'dart:io';

import '../../tag_overrides/overrides.dart';

void main() {
  final dir = File(Platform.script.toFilePath()).parent;
  final base = dir.path;

  final raw = jsonDecode(
    File('$base/iwara_tags.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  // 以 localized.json 为单一事实来源，min 版由本脚本产出（与 oreno3d 侧一致）。
  final loc = jsonDecode(
    File('$base/iwara_tags_localized.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  File('$base/iwara_tags_localized.min.json').writeAsStringSync(jsonEncode(loc));

  final meta = <String, Map<String, dynamic>>{
    for (final t in (raw['tags'] as List).cast<Map<String, dynamic>>())
      t['id'] as String: t,
  };

  final aiNames = <String, Map<String, String>>{
    for (final e in loc.entries)
      e.key: {
        for (final l in kLangs)
          if ((e.value as Map)[l] != null) l: '${(e.value as Map)[l]}',
      },
  };

  final ids = <String>{...meta.keys, ...loc.keys}.toList()..sort();

  final merged = mergeOverrides(
    aiNames: aiNames,
    overrides: loadOverrides('$base/overrides.json'),
    knownKeys: ids.toSet(),
  );

  final tags = <String, dynamic>{};
  for (final id in ids) {
    final m = meta[id] ?? const <String, dynamic>{};
    final names = merged.names[id] ?? const <String, String>{};
    final metaOv = merged.meta[id] ?? const <String, dynamic>{};

    final type = (metaOv['type'] as String?) ?? (m['type'] as String?) ?? 'general';
    final sensitive = metaOv.containsKey('sensitive')
        ? (metaOv['sensitive'] == true || metaOv['sensitive'] == 1)
        : m['sensitive'] == true;

    tags[id] = {
      'y': type,
      's': sensitive ? 1 : 0,
      'n': {for (final l in kLangs) l: names[l] ?? ''},
    };
  }

  final payload = {'count': tags.length, 'tags': tags};
  final rev = contentRev(payload);
  // builtAt 放在指纹载荷之外：它是「谁更新」的判据，不该反过来改变指纹。
  final out = {
    'version': 2,
    'rev': rev,
    'builtAt': buildStamp('$base/iwara_tags.min.json', rev),
    ...payload,
  };
  final encoded = jsonEncode(out);

  File('$base/iwara_tags.min.json').writeAsStringSync(encoded);
  final assetFile = File('$base/../../../assets/data/iwara_tags.min.json');
  assetFile.parent.createSync(recursive: true);
  assetFile.writeAsStringSync(encoded);

  stdout.writeln('合并完成：${tags.length} 个标签');
  stdout.writeln('人工修正生效 ${merged.appliedCount} 处');
  if (merged.orphanKeys.isNotEmpty) {
    stdout.writeln('⚠ overrides 里有 ${merged.orphanKeys.length} 条指向已不存在的标签：'
        '${merged.orphanKeys.take(5).join(', ')}');
  }
  final reviewFile = File('$base/needs_review.json');
  if (merged.needsReview.isEmpty) {
    if (reviewFile.existsSync()) reviewFile.deleteSync();
  } else {
    stdout.writeln('⚠ ${merged.needsReview.length} 处人工修正的上游值已变化，需复核：');
    for (final r in merged.needsReview.take(5)) {
      stdout.writeln('    $r');
    }
    reviewFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
      'rev': out['rev'],
      'items': merged.needsReview.map((e) => e.toJson()).toList(),
    }));
    stdout.writeln('  详情 -> ${reviewFile.path}');
  }
  stdout.writeln('  rev = ${out['rev']}');
  stdout.writeln('  -> $base/iwara_tags.min.json');
  stdout.writeln('  -> ${assetFile.path}');
}
