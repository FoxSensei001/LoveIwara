// 合并工具：把「原始标签元数据」与「多语言译名」合并为 App / CDN 直接消费的紧凑文件。
//
// 输入：
//   - iwara_tags.json                  原始抓取（含 id / type / sensitive）
//   - iwara_tags_localized.min.json     AI 译名（id -> {zh-CN, zh-TW, ja, en}）
// 输出：
//   - iwara_tags.min.json               合并后的紧凑文件（App 打包资源 + jsDelivr CDN 源）
//   - ../../../assets/data/iwara_tags.min.json  同步一份到打包资源目录
//
// 产物结构（紧凑，键名缩写以省体积）：
//   {"version":1,"count":2669,"tags":{
//      "mother":{"y":"general","s":0,"n":{"zh-CN":"母亲","zh-TW":"母親","ja":"母親","en":"Mother"}}
//   }}
//   y = type，s = sensitive(0/1)，n = 各语言译名。
//
// 用法（在仓库根目录执行）：
//   dart run tool/data/iwara_tags/build_localized_min.dart
//
// 修改了 iwara_tags_localized.json 后，请重跑本脚本以同步 min 文件与打包资源。
import 'dart:convert';
import 'dart:io';

void main() {
  final dir = File(Platform.script.toFilePath()).parent;
  final base = dir.path;

  final raw = jsonDecode(
    File('$base/iwara_tags.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final loc = jsonDecode(
    File('$base/iwara_tags_localized.min.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  final meta = <String, Map<String, dynamic>>{
    for (final t in (raw['tags'] as List).cast<Map<String, dynamic>>())
      t['id'] as String: t,
  };

  final ids = <String>{...meta.keys, ...loc.keys}.toList()..sort();

  final tags = <String, dynamic>{};
  for (final id in ids) {
    final m = meta[id] ?? const {};
    final names = (loc[id] as Map<String, dynamic>?) ?? const {};
    tags[id] = {
      'y': (m['type'] as String?) ?? 'general',
      's': (m['sensitive'] == true) ? 1 : 0,
      'n': {
        'zh-CN': names['zh-CN'] ?? '',
        'zh-TW': names['zh-TW'] ?? '',
        'ja': names['ja'] ?? '',
        'en': names['en'] ?? '',
      },
    };
  }

  final out = {'version': 1, 'count': tags.length, 'tags': tags};
  final encoded = jsonEncode(out);

  File('$base/iwara_tags.min.json').writeAsStringSync(encoded);

  // 同步一份到打包资源目录（assets/data/）。
  final assetFile = File('$base/../../../assets/data/iwara_tags.min.json');
  assetFile.parent.createSync(recursive: true);
  assetFile.writeAsStringSync(encoded);

  stdout.writeln('合并完成：${tags.length} 个标签');
  stdout.writeln('  -> $base/iwara_tags.min.json');
  stdout.writeln('  -> ${assetFile.path}');
}
