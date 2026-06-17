// 合并工具：把「原始标签元数据」与「多语言译名」合并为 App / CDN 直接消费的紧凑文件。
//
// 输入：
//   - oreno3d_tags.json                  原始抓取（含 id, origins, characters, tags 等）
//   - oreno3d_tags_localized.min.json     AI 译名（name -> {zh-CN, zh-TW, ja, en}）
// 输出：
//   - oreno3d_tags.min.json               合并后的紧凑文件（App 打包资源 + jsDelivr CDN 源）
//   - ../../../assets/data/oreno3d_tags.min.json  同步一份到打包资源目录
//
// 产物结构（紧凑，键名缩写以省体积）：
//   {"version":1,"counts":{...},"origins":{"1":{"n":{"zh-CN":"..."},"w":123}},...}
//
// 用法（在仓库根目录执行）：
//   dart run tool/data/oreno3d_tags/build_localized_min.dart
//
// 修改了 oreno3d_tags_localized.json 后，请重跑本脚本以同步 min 文件与打包资源。
import 'dart:convert';
import 'dart:io';

void main() {
  final dir = File(Platform.script.toFilePath()).parent;
  final base = dir.path;

  // 1. 先压缩 localized json
  final locRaw = jsonDecode(
    File('$base/oreno3d_tags_localized.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final locEncoded = jsonEncode(locRaw);
  File('$base/oreno3d_tags_localized.min.json').writeAsStringSync(locEncoded);

  // 2. 准备合并
  final raw = jsonDecode(
    File('$base/oreno3d_tags.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  Map<String, dynamic> processItems(List<dynamic>? items) {
    final result = <String, dynamic>{};
    if (items == null) return result;

    for (final item in items) {
      final uid = item['id'].toString();
      final name = item['name'].toString();
      final loc = (locRaw[name] as Map<String, dynamic>?) ?? {};

      final n = {
        'zh-CN': loc['zh-CN'] ?? name,
        'zh-TW': loc['zh-TW'] ?? name,
        'ja': loc['ja'] ?? name,
        'en': loc['en'] ?? name,
      };

      final compact = <String, dynamic>{'n': n};
      if (item.containsKey('workCount')) compact['w'] = item['workCount'];
      if (item.containsKey('origin')) compact['o'] = item['origin'];
      if (item.containsKey('groupId')) compact['g'] = item['groupId'];

      result[uid] = compact;
    }
    return result;
  }

  final origins = processItems(raw['origins'] as List?);
  final characters = processItems(raw['characters'] as List?);
  final tags = processItems(raw['tags'] as List?);

  final out = {
    'version': 1,
    'counts': raw['counts'],
    'origins': origins,
    'characters': characters,
    'tags': tags,
  };

  final encoded = jsonEncode(out);

  File('$base/oreno3d_tags.min.json').writeAsStringSync(encoded);

  // 同步一份到打包资源目录
  final assetFile = File('$base/../../../assets/data/oreno3d_tags.min.json');
  assetFile.parent.createSync(recursive: true);
  assetFile.writeAsStringSync(encoded);

  stdout.writeln('合并完成：${origins.length} 原作, ${characters.length} 角色, ${tags.length} 标签');
  stdout.writeln('  -> $base/oreno3d_tags.min.json');
  stdout.writeln('  -> ${assetFile.path}');
}
