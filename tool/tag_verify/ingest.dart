/// 收回 AI 批次结果：**先校验，再合并**。
///
/// agent 是会偷懒、会漏条、会假装干完的。这个脚本的全部意义就是让那些情况
/// 变成一次响亮的失败，而不是悄悄混进词库——漏译的条目会伪装成「已处理」，
/// 编造的译名会伪装成「已核实」。
///
/// 校验不过 **整批打回**，一条都不合并。
///
/// 合并去向：
///   - `translate`  的新译名  -> `*_localized.json`（派生层，可被重译覆盖）
///   - `adjudicate` 的替换    -> `overrides.json`（人工层，永不被重译覆盖）
///
/// 用法：
///   dart run tool/tag_verify/ingest.dart                # 校验全部批次（不写盘）
///   dart run tool/tag_verify/ingest.dart --apply        # 校验通过后写盘
///   dart run tool/tag_verify/ingest.dart --only 002
library;

import 'dart:convert';
import 'dart:io';

const _dir = 'tool/tag_verify/out/batches';
const _langs = ['zh-CN', 'zh-TW', 'ja', 'en'];
final _url = RegExp(r'^https?://');

class Reject implements Exception {
  final String batch;
  final List<String> problems;
  Reject(this.batch, this.problems);
}

Map<String, dynamic> _json(File f) =>
    jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;

void main(List<String> args) {
  final apply = args.contains('--apply');
  final only = _opt(args, '--only');

  final dir = Directory(_dir);
  if (!dir.existsSync()) {
    stderr.writeln('没有批次目录，先跑 make_batches.dart');
    exitCode = 1;
    return;
  }

  final ins = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.in.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final accepted = <Map<String, dynamic>>[];
  final rejected = <Reject>[];
  var pending = 0;

  for (final inFile in ins) {
    final name = inFile.uri.pathSegments.last.replaceAll('.in.json', '');
    if (only != null && !name.contains(only)) continue;
    final outFile = File(inFile.path.replaceAll('.in.json', '.out.json'));
    if (!outFile.existsSync()) {
      pending++;
      continue;
    }

    final input = _json(inFile);
    final problems = <String>[];
    Map<String, dynamic>? output;
    try {
      output = _json(outFile);
    } catch (e) {
      rejected.add(Reject(name, ['$name.out.json 不是合法 JSON：$e']));
      continue;
    }

    // 先核对代际：批次文件名会跨代复用，指纹对不上说明这份 out 对应的是
    // 另一次生成的输入，此时报「漏了 N 条」只会把人引向错误方向。
    final wantFp = input['inputFingerprint'];
    final gotFp = output['inputFingerprint'];
    if (wantFp != null && gotFp != wantFp) {
      rejected.add(Reject(name, [
        '这份 .out.json 对应的不是当前的 .in.json'
            '（输入指纹 $wantFp，输出回带 ${gotFp ?? '缺失'}）。'
            '批次已重新生成过，请用当前的 .in.json 重跑。'
      ]));
      continue;
    }

    final inEntries = <String, Map<String, dynamic>>{
      for (final e in (input['entries'] as List).cast<Map<String, dynamic>>())
        e['key'] as String: e,
    };
    final outList = (output['entries'] as List?)?.cast<Map<String, dynamic>>();
    if (outList == null) {
      rejected.add(Reject(name, ['缺少 entries 数组']));
      continue;
    }

    final outEntries = <String, Map<String, dynamic>>{};
    for (final e in outList) {
      final k = e['key'] as String?;
      if (k == null) {
        problems.add('有一条没有 key');
        continue;
      }
      if (outEntries.containsKey(k)) problems.add('key 重复：$k');
      outEntries[k] = e;
    }

    // ---- 条数与 key 集合必须完全一致 ----
    if (outEntries.length != inEntries.length) {
      problems.add('条数不符：输入 ${inEntries.length}，输出 ${outEntries.length}');
    }
    final missing = inEntries.keys.where((k) => !outEntries.containsKey(k)).toList();
    final extra = outEntries.keys.where((k) => !inEntries.containsKey(k)).toList();
    if (missing.isNotEmpty) {
      problems.add('漏了 ${missing.length} 条：${missing.take(8).join(', ')}');
    }
    if (extra.isNotEmpty) {
      problems.add('凭空多出 ${extra.length} 条：${extra.take(8).join(', ')}');
    }

    // ---- 逐条校验 ----
    final merges = <Map<String, dynamic>>[];
    for (final entry in inEntries.entries) {
      final k = entry.key;
      final task = entry.value;
      final got = outEntries[k];
      if (got == null) continue;

      final names = (got['names'] as Map?)?.cast<String, dynamic>() ?? const {};
      final reason = '${got['reason'] ?? ''}'.trim();
      if (reason.isEmpty) problems.add('$k 缺 reason');

      for (final l in names.keys) {
        if (!_langs.contains(l)) problems.add('$k 出现未知语言 $l');
        if ('${names[l]}'.trim().isEmpty) problems.add('$k 的 $l 是空字符串');
      }

      if (task['type'] == 'translate') {
        final need = ((task['need'] as List?) ?? const []).map((e) => '$e');
        final absent = need.where((l) => !names.containsKey(l)).toList();
        if (absent.isNotEmpty) {
          problems.add('$k 该补 ${need.join('/')}，缺 ${absent.join('/')}');
        }
        final known = (task['known'] as Map?)?.cast<String, dynamic>() ?? const {};
        for (final l in known.keys) {
          if (names.containsKey(l) && '${names[l]}' != '${known[l]}') {
            problems.add('$k 改动了 known 里的 $l（不该动）');
          }
        }
        // known 里的值来自原始数据（如日文原名），是权威的——
        // 只写 agent 返回的语言会让新词条漏掉 ja。
        merges.add({
          'target': 'localized',
          'dataset': task['dataset'],
          'key': k,
          'names': {...known.map((a, b) => MapEntry(a, '$b')), ...names},
          'source': task['source'],
        });
      } else {
        final decision = '${got['decision'] ?? ''}';
        if (decision != 'keep' && decision != 'replace') {
          problems.add('$k 的 decision 必须是 keep 或 replace，得到「$decision」');
          continue;
        }
        if (decision == 'replace') {
          if (names.isEmpty) problems.add('$k decision=replace 却没给 names');
          final refs = ((got['ref'] as List?) ?? const []).map((e) => '$e').toList();
          if (refs.isEmpty || !refs.every(_url.hasMatch)) {
            problems.add('$k decision=replace 必须给可访问的 ref URL');
          }
          final cur = (task['current'] as Map?)?.cast<String, dynamic>() ?? const {};
          merges.add({
            'target': 'overrides',
            'dataset': task['dataset'],
            'key': k,
            'names': names,
            'prev': {
              for (final l in names.keys)
                if (cur[l] != null) l: '${cur[l]}',
            },
            'ref': refs,
            'reason': reason,
          });
        }
      }
    }

    if (problems.isNotEmpty) {
      rejected.add(Reject(name, problems));
    } else {
      accepted.add({'batch': name, 'merges': merges});
    }
  }

  // ---- 报告 ----
  if (pending > 0) stdout.writeln('还没有结果的批次：$pending 个');
  for (final r in rejected) {
    stdout.writeln('\n✗ ${r.batch} 打回（${r.problems.length} 个问题）');
    for (final p in r.problems.take(12)) {
      stdout.writeln('    $p');
    }
    if (r.problems.length > 12) {
      stdout.writeln('    …还有 ${r.problems.length - 12} 个');
    }
  }
  for (final a in accepted) {
    stdout.writeln('✓ ${a['batch']} 通过，可合并 ${(a['merges'] as List).length} 条');
  }
  if (rejected.isNotEmpty) {
    stdout.writeln('\n有批次被打回，**整批不合并**。修好 .out.json 再跑一次。');
    exitCode = 1;
  }
  if (!apply || accepted.isEmpty) {
    if (apply && accepted.isEmpty) stdout.writeln('没有可合并的批次。');
    if (!apply && accepted.isNotEmpty) stdout.writeln('\n（校验模式，未写盘。加 --apply 落盘）');
    return;
  }

  // ---- 合并 ----
  final files = {
    'localized:oreno3d': 'tool/data/oreno3d_tags/oreno3d_tags_localized.json',
    'localized:iwara': 'tool/data/iwara_tags/iwara_tags_localized.json',
    'overrides:oreno3d': 'tool/data/oreno3d_tags/overrides.json',
    'overrides:iwara': 'tool/data/iwara_tags/overrides.json',
  };
  final docs = <String, Map<String, dynamic>>{
    for (final e in files.entries) e.key: _json(File(e.value)),
  };
  var nLoc = 0, nOv = 0;

  for (final a in accepted) {
    for (final m in (a['merges'] as List).cast<Map<String, dynamic>>()) {
      final id = '${m['target']}:${m['dataset']}';
      final doc = docs[id]!;
      final key = m['key'] as String;
      final names = (m['names'] as Map).cast<String, dynamic>();

      if (m['target'] == 'localized') {
        final cur = (doc[key] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{'_src': m['source'] ?? key};
        cur.addAll(names);
        doc[key] = cur;
        nLoc++;
      } else {
        final entries = (doc['entries'] as Map).cast<String, dynamic>();
        entries[key] = {
          'n': names,
          'prev': m['prev'],
          'src': 'ai-batch',
          'by': a['batch'],
          'ref': m['ref'],
          'note': m['reason'],
        };
        doc['entries'] = entries;
        nOv++;
      }
    }
  }

  const enc = JsonEncoder.withIndent('  ');
  for (final e in files.entries) {
    File(e.value).writeAsStringSync(enc.convert(docs[e.key]));
  }
  stdout.writeln('\n已合并：译名层 $nLoc 条，人工修正层 $nOv 条');
  stdout.writeln('别忘了重跑 build_localized_min.dart 出包，并跑一遍闸门测试。');
}

String? _opt(List<String> a, String f) {
  final i = a.indexOf(f);
  return (i < 0 || i + 1 >= a.length) ? null : a[i + 1];
}
