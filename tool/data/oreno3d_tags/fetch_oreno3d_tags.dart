import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

// 抓取 oreno3d 的三类元数据：原作(origins) / 角色(characters) / 标签(tags)，
// 保存为一份原始 JSON 快照，供后续本地化使用。
//
// oreno3d 全站受 Cloudflare 保护，数据中心 IP 会被弹交互式人机验证而 403。
// 实测：日本住宅类节点可直接 200 放行；阿里云/机房节点会被拦。
// 因此本工具默认建议挂代理：--proxy 127.0.0.1:7890
//
// 站点结构（已逆向确认）：
//   /origins                 → 「原作一覧」单页全量，a.group-list-li-a，约 809 条
//   /characters              → 「キャラクター一覧」单页全量，约 1579 条（含所属原作）
//                              ?page=N 对主列表无效，每页都返回相同全量，按 id 去重即可
//   /tags                    → 「タググループ一覧」，列出 tag-group（/tag-groups/:id）
//   /tag-groups/:id          → 该组下的标签列表，a.group-list-li-a，约 166 条合计
//
//   单条结构通用：
//     <a href="/{kind}/{id}" class="group-list-li-a ...">
//       <div class="group-list-li-a-flex1">
//         <div class="group-list-li-a-number">1位</div>            // 仅角色有「排名」
//         <div class="group-list-li-a-chara ...">名称<span
//             class="group-list-li-a-chara-origins">(所属原作)</span></div>
//       </div>
//       <div class="group-list-li-a-number">12345作品</div>        // 作品数
//     </a>
//
// 用法（仓库根目录执行）：
//   dart run tool/data/oreno3d_tags/fetch_oreno3d_tags.dart --proxy 127.0.0.1:7890

const String _baseUrl = 'https://oreno3d.com';
const String _defaultOutputPath = 'tool/data/oreno3d_tags/oreno3d_tags.json';
const String _userAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

Future<void> main(List<String> args) async {
  try {
    if (args.contains('--help') || args.contains('-h')) {
      _printUsage();
      return;
    }

    final config = _parseArgs(args);
    final client = _Oreno3dFetcher(
      proxy: config.proxy,
      cookieHeader: config.cookieHeader,
    );

    final snapshot = await client.fetchAll();

    stdout.writeln('抓取完成：');
    stdout.writeln('  原作 origins    : ${snapshot.origins.length}');
    stdout.writeln('  角色 characters : ${snapshot.characters.length}');
    stdout.writeln(
      '  标签 tags       : ${snapshot.tags.length}'
      ' （${snapshot.tagGroups.length} 个分组）',
    );

    // 与上一次快照对比，输出增量（新增 / 删除 / 改名），便于增量重抓与后续只翻译新条目。
    if (!config.noDiff) {
      final previous = _readPreviousSnapshot(config.outputPath);
      final diff = _Diff.compute(previous, snapshot);
      diff.printSummary();
      if (config.changesPath != null) {
        await _writeChanges(config.changesPath!, diff, snapshot.fetchedAt);
        stdout.writeln('已写出变更清单到 ${config.changesPath}');
      }
    }

    await _writeSnapshot(outputPath: config.outputPath, snapshot: snapshot);
    stdout.writeln('已保存快照到 ${config.outputPath}');
    client.close();
  } on ArgumentError catch (error) {
    stderr.writeln('参数错误: ${error.message}');
    stderr.writeln('');
    _printUsage();
    exitCode = 64;
  } on _CloudflareChallengeException catch (error) {
    stderr.writeln(error.message);
    exitCode = 2;
  } catch (error, stack) {
    stderr.writeln('抓取 oreno3d 失败: $error');
    stderr.writeln(stack);
    exitCode = 1;
  }
}

void _printUsage() {
  stdout.writeln('抓取 oreno3d 的原作 / 角色 / 标签元数据并保存为 JSON。');
  stdout.writeln('');
  stdout.writeln('用法:');
  stdout.writeln(
    '  dart run tool/data/oreno3d_tags/fetch_oreno3d_tags.dart '
    '[--output <path>] [--proxy <host:port>] [--cookie <header>]',
  );
  stdout.writeln('');
  stdout.writeln('选项:');
  stdout.writeln('  --output <path>      输出 JSON 路径。默认: $_defaultOutputPath');
  stdout.writeln('  --proxy <host:port>  HTTP 代理（如 127.0.0.1:7890）。');
  stdout.writeln('                        oreno3d 受 Cloudflare 保护，机房 IP 会被 403，');
  stdout.writeln('                        建议挂日本住宅类节点。');
  stdout.writeln('  --cookie <header>    可选 Cookie 头（如已有 cf_clearance）。');
  stdout.writeln('  --changes <path>     额外写出「相比旧快照的变更清单」JSON（增量重抓用）。');
  stdout.writeln('  --no-diff           跳过与旧快照的对比。');
}

_ScriptConfig _parseArgs(List<String> args) {
  String outputPath = _defaultOutputPath;
  String? proxy;
  String? cookieHeader;
  String? changesPath;
  bool noDiff = false;

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--output':
        if (i + 1 >= args.length) throw ArgumentError('缺少 --output 的值');
        outputPath = args[++i];
        break;
      case '--proxy':
        if (i + 1 >= args.length) throw ArgumentError('缺少 --proxy 的值');
        proxy = args[++i].trim();
        if (proxy.isEmpty) throw ArgumentError('--proxy 不能为空');
        break;
      case '--cookie':
        if (i + 1 >= args.length) throw ArgumentError('缺少 --cookie 的值');
        cookieHeader = args[++i].trim();
        if (cookieHeader.isEmpty) throw ArgumentError('--cookie 不能为空');
        break;
      case '--changes':
        if (i + 1 >= args.length) throw ArgumentError('缺少 --changes 的值');
        changesPath = args[++i].trim();
        if (changesPath.isEmpty) throw ArgumentError('--changes 不能为空');
        break;
      case '--no-diff':
        noDiff = true;
        break;
      default:
        throw ArgumentError('未知参数: $arg');
    }
  }

  return _ScriptConfig(
    outputPath: outputPath,
    proxy: proxy,
    cookieHeader: cookieHeader,
    changesPath: changesPath,
    noDiff: noDiff,
  );
}

Future<void> _writeSnapshot({
  required String outputPath,
  required _Snapshot snapshot,
}) async {
  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(snapshot.toJson()),
  );
}

/// 读取上一次快照（若存在且可解析），返回 {category: {id: name}}。
Map<String, Map<String, String>>? _readPreviousSnapshot(String path) {
  final file = File(path);
  if (!file.existsSync()) return null;
  try {
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    Map<String, String> indexById(String key) {
      final list = (json[key] as List?) ?? const [];
      return {
        for (final e in list.cast<Map<String, dynamic>>())
          e['id'].toString(): (e['name'] ?? '').toString(),
      };
    }

    return {
      'origins': indexById('origins'),
      'characters': indexById('characters'),
      'tags': indexById('tags'),
    };
  } catch (_) {
    // 旧文件损坏/格式不符则视为无历史。
    return null;
  }
}

Future<void> _writeChanges(
  String path,
  _Diff diff,
  DateTime fetchedAt,
) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert({
      'generatedAt': fetchedAt.toIso8601String(),
      'hasPrevious': diff.hasPrevious,
      'categories': {
        for (final c in diff.categories.entries) c.key: c.value.toJson(),
      },
    }),
  );
}

/// 单类别（origins/characters/tags）的增量。
class _CategoryDiff {
  _CategoryDiff(this.added, this.removed, this.renamed);

  final List<MapEntry<String, String>> added; // id -> name
  final List<MapEntry<String, String>> removed; // id -> oldName
  final List<List<String>> renamed; // [id, oldName, newName]

  bool get isEmpty =>
      added.isEmpty && removed.isEmpty && renamed.isEmpty;

  Map<String, dynamic> toJson() => {
    'added': [
      for (final e in added) {'id': e.key, 'name': e.value},
    ],
    'removed': [
      for (final e in removed) {'id': e.key, 'name': e.value},
    ],
    'renamed': [
      for (final r in renamed) {'id': r[0], 'old': r[1], 'new': r[2]},
    ],
  };
}

class _Diff {
  _Diff(this.hasPrevious, this.categories);

  final bool hasPrevious;
  final Map<String, _CategoryDiff> categories;

  static _Diff compute(
    Map<String, Map<String, String>>? previous,
    _Snapshot snapshot,
  ) {
    final current = <String, Map<String, String>>{
      'origins': {for (final e in snapshot.origins) e.id: e.name},
      'characters': {for (final e in snapshot.characters) e.id: e.name},
      'tags': {for (final e in snapshot.tags) e.id: e.name},
    };

    final categories = <String, _CategoryDiff>{};
    for (final kind in const ['origins', 'characters', 'tags']) {
      final old = previous?[kind] ?? const {};
      final cur = current[kind]!;
      final added = <MapEntry<String, String>>[];
      final removed = <MapEntry<String, String>>[];
      final renamed = <List<String>>[];

      for (final entry in cur.entries) {
        if (!old.containsKey(entry.key)) {
          added.add(entry);
        } else if (old[entry.key] != entry.value) {
          renamed.add([entry.key, old[entry.key]!, entry.value]);
        }
      }
      for (final entry in old.entries) {
        if (!cur.containsKey(entry.key)) removed.add(entry);
      }

      int byId(MapEntry<String, String> a, MapEntry<String, String> b) =>
          (int.tryParse(a.key) ?? 0).compareTo(int.tryParse(b.key) ?? 0);
      added.sort(byId);
      removed.sort(byId);
      categories[kind] = _CategoryDiff(added, removed, renamed);
    }
    return _Diff(previous != null, categories);
  }

  void printSummary() {
    if (!hasPrevious) {
      stdout.writeln('增量对比：未找到上一次快照（首次抓取，全部视为新增）。');
      return;
    }
    final allEmpty = categories.values.every((c) => c.isEmpty);
    if (allEmpty) {
      stdout.writeln('增量对比：与上一次快照一致，无变化。');
      return;
    }
    stdout.writeln('增量对比（相比上一次快照）：');
    const labels = {
      'origins': '原作',
      'characters': '角色',
      'tags': '标签',
    };
    for (final kind in const ['origins', 'characters', 'tags']) {
      final c = categories[kind]!;
      stdout.writeln(
        '  ${labels[kind]} $kind: +${c.added.length} 新增  '
        '-${c.removed.length} 删除  ~${c.renamed.length} 改名',
      );
      _previewList('    新增', c.added.map((e) => '${e.key} ${e.value}').toList());
      _previewList('    删除', c.removed.map((e) => '${e.key} ${e.value}').toList());
      _previewList(
        '    改名',
        c.renamed.map((r) => '${r[0]} ${r[1]} → ${r[2]}').toList(),
      );
    }
  }

  void _previewList(String label, List<String> items, {int cap = 15}) {
    if (items.isEmpty) return;
    final shown = items.take(cap).join('、');
    final extra = items.length > cap ? ' …(共 ${items.length})' : '';
    stdout.writeln('$label: $shown$extra');
  }
}

class _ScriptConfig {
  const _ScriptConfig({
    required this.outputPath,
    this.proxy,
    this.cookieHeader,
    this.changesPath,
    this.noDiff = false,
  });

  final String outputPath;
  final String? proxy;
  final String? cookieHeader;
  final String? changesPath;
  final bool noDiff;
}

class _Oreno3dFetcher {
  _Oreno3dFetcher({String? proxy, String? cookieHeader})
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 90),
          headers: {
            'User-Agent': _userAgent,
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'ja,zh-CN;q=0.9,zh;q=0.8,en;q=0.7',
            'Upgrade-Insecure-Requests': '1',
            if (cookieHeader != null && cookieHeader.isNotEmpty)
              'Cookie': cookieHeader,
          },
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) => status != null && status < 600,
        ),
      ) {
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 30);
        client.badCertificateCallback = (cert, host, port) => true;
        if (proxy != null && proxy.isNotEmpty) {
          client.findProxy = (_) => 'PROXY $proxy';
        }
        return client;
      },
    );
  }

  final Dio _dio;

  Future<_Snapshot> fetchAll() async {
    final origins = await _fetchListing('origins', '/origins');
    final characters = await _fetchCharacters();
    final tagResult = await _fetchTags();

    return _Snapshot(
      source: _baseUrl,
      fetchedAt: DateTime.now().toUtc(),
      origins: origins,
      characters: characters,
      tagGroups: tagResult.groups,
      tags: tagResult.tags,
    );
  }

  /// 抓取「单页全量」型列表（origins）。tags 走分组、characters 单独处理。
  Future<List<_Entity>> _fetchListing(String kind, String path) async {
    final document = await _getDocument(path);
    final entities = _parseEntities(document, kind);
    stdout.writeln('  $path → ${entities.length} 条');
    return _dedup(entities);
  }

  Future<List<_Entity>> _fetchCharacters() async {
    final document = await _getDocument('/characters');
    final entities = _parseEntities(document, 'characters', withOrigin: true);
    stdout.writeln('  /characters → ${entities.length} 条（去重前）');
    return _dedup(entities);
  }

  Future<_TagResult> _fetchTags() async {
    final indexDoc = await _getDocument('/tags');
    final groups = <_TagGroup>[];
    for (final a in indexDoc.querySelectorAll('a.group-list-li-a')) {
      final href = a.attributes['href'] ?? '';
      final id = _extractId(href, 'tag-groups');
      if (id == null) continue;
      final name = _charaName(a);
      groups.add(_TagGroup(id: id, name: name));
    }
    stdout.writeln('  /tags → ${groups.length} 个分组');

    final tags = <_Entity>[];
    for (final group in groups) {
      final doc = await _getDocument('/tag-groups/${group.id}');
      final groupTags = _parseEntities(doc, 'tags');
      for (final tag in groupTags) {
        tags.add(tag.copyWithGroup(group.id, group.name));
      }
      stdout.writeln('    分组 ${group.id} (${group.name}) → ${groupTags.length} 条');
    }
    return _TagResult(groups: groups, tags: _dedup(tags));
  }

  /// 解析主体 a.group-list-li-a 列表项为实体。
  List<_Entity> _parseEntities(
    Document document,
    String kind, {
    bool withOrigin = false,
  }) {
    final result = <_Entity>[];
    for (final a in document.querySelectorAll('a.group-list-li-a')) {
      final href = a.attributes['href'] ?? '';
      final id = _extractId(href, kind);
      if (id == null) continue;

      final name = _charaName(a);
      if (name.isEmpty) continue;

      String? origin;
      if (withOrigin) {
        final originEl = a.querySelector('.group-list-li-a-chara-origins');
        origin = _stripParens(originEl?.text.trim() ?? '');
        if (origin.isEmpty) origin = null;
      }

      result.add(
        _Entity(
          id: id,
          name: name,
          url: '$_baseUrl/$kind/$id',
          workCount: _workCount(a),
          origin: origin,
        ),
      );
    }
    return result;
  }

  /// 取 .group-list-li-a-chara 的文本，剔除嵌套的所属原作 span。
  String _charaName(Element a) {
    final chara = a.querySelector('.group-list-li-a-chara');
    if (chara == null) return '';
    final buffer = StringBuffer();
    for (final node in chara.nodes) {
      if (node is Element &&
          node.classes.contains('group-list-li-a-chara-origins')) {
        continue;
      }
      buffer.write(node.text ?? '');
    }
    return buffer.toString().trim();
  }

  /// 取含「作品」的 .group-list-li-a-number 数字（排除「N位」排名）。
  int? _workCount(Element a) {
    for (final el in a.querySelectorAll('.group-list-li-a-number')) {
      final text = el.text.trim();
      if (text.contains('作品')) {
        final digits = RegExp(r'[\d,]+').firstMatch(text)?.group(0);
        if (digits != null) return int.tryParse(digits.replaceAll(',', ''));
      }
    }
    return null;
  }

  String _stripParens(String s) =>
      s.replaceAll(RegExp(r'^[（(]|[）)]$'), '').trim();

  String? _extractId(String url, String kind) {
    final match = RegExp('/$kind/(\\d+)').firstMatch(url);
    return match?.group(1);
  }

  List<_Entity> _dedup(List<_Entity> items) {
    final seen = <String>{};
    final out = <_Entity>[];
    for (final item in items) {
      if (seen.add(item.id)) out.add(item);
    }
    out.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    return out;
  }

  Future<Document> _getDocument(String path) async {
    final body = await _getWithRetry(path);
    return html_parser.parse(body);
  }

  Future<String> _getWithRetry(String path, {int maxAttempts = 6}) async {
    Object? lastError;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _dio.get<String>(path);
        final body = response.data ?? '';
        if ((response.statusCode ?? 0) == 200) {
          _throwIfCloudflareChallenge(response.statusCode, body);
          return body;
        }
        _throwIfCloudflareChallenge(response.statusCode, body);
        throw HttpException('GET $path 返回 ${response.statusCode}');
      } on _CloudflareChallengeException {
        rethrow;
      } catch (error) {
        lastError = error;
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: 2 * attempt));
        }
      }
    }
    throw HttpException('GET $path 多次重试仍失败: $lastError');
  }

  void _throwIfCloudflareChallenge(int? statusCode, String body) {
    final normalized = body.toLowerCase();
    final isChallenge =
        statusCode == 403 &&
        (normalized.contains('just a moment') ||
            body.contains('请稍候') ||
            normalized.contains('cdn-cgi/challenge-platform'));
    if (!isChallenge) return;
    throw const _CloudflareChallengeException(
      'Cloudflare 拦截了请求（交互式人机验证）。\n'
      'oreno3d 对机房 IP 会强制验证。请挂一个日本住宅类代理后重试，例如：\n'
      '  dart run tool/data/oreno3d_tags/fetch_oreno3d_tags.dart --proxy 127.0.0.1:7890\n'
      '或在浏览器通过验证后，用 --cookie "cf_clearance=...; ..." 复用其 clearance。',
    );
  }

  void close() => _dio.close(force: true);
}

class _CloudflareChallengeException implements Exception {
  const _CloudflareChallengeException(this.message);
  final String message;
}

class _Entity {
  const _Entity({
    required this.id,
    required this.name,
    required this.url,
    this.workCount,
    this.origin,
    this.groupId,
    this.groupName,
  });

  final String id;
  final String name;
  final String url;
  final int? workCount;
  final String? origin; // 仅 characters
  final String? groupId; // 仅 tags
  final String? groupName; // 仅 tags

  _Entity copyWithGroup(String groupId, String groupName) => _Entity(
    id: id,
    name: name,
    url: url,
    workCount: workCount,
    origin: origin,
    groupId: groupId,
    groupName: groupName,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    if (workCount != null) 'workCount': workCount,
    if (origin != null) 'origin': origin,
    if (groupId != null) 'groupId': groupId,
    if (groupName != null) 'groupName': groupName,
  };
}

class _TagGroup {
  const _TagGroup({required this.id, required this.name});
  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class _TagResult {
  const _TagResult({required this.groups, required this.tags});
  final List<_TagGroup> groups;
  final List<_Entity> tags;
}

class _Snapshot {
  const _Snapshot({
    required this.source,
    required this.fetchedAt,
    required this.origins,
    required this.characters,
    required this.tagGroups,
    required this.tags,
  });

  final String source;
  final DateTime fetchedAt;
  final List<_Entity> origins;
  final List<_Entity> characters;
  final List<_TagGroup> tagGroups;
  final List<_Entity> tags;

  Map<String, dynamic> toJson() => {
    'version': 1,
    'source': source,
    'fetchedAt': fetchedAt.toIso8601String(),
    'counts': {
      'origins': origins.length,
      'characters': characters.length,
      'tags': tags.length,
      'tagGroups': tagGroups.length,
    },
    'origins': origins.map((e) => e.toJson()).toList(),
    'characters': characters.map((e) => e.toJson()).toList(),
    'tagGroups': tagGroups.map((e) => e.toJson()).toList(),
    'tags': tags.map((e) => e.toJson()).toList(),
  };
}
