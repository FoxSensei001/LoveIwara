import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

/// PROPFIND（Depth: 1）列出来的一条。
class DavEntry {
  const DavEntry({
    required this.serverPath,
    required this.isDirectory,
    this.size,
    this.modifiedMs,
  });

  /// 服务端绝对路径，**已解码**、`/` 开头、目录不带结尾 `/`。
  final String serverPath;
  final bool isDirectory;
  final int? size;
  final int? modifiedMs;

  String get name => p.posix.basename(serverPath);

  @override
  String toString() =>
      'DavEntry($serverPath, dir=$isDirectory, size=$size, mtime=$modifiedMs)';
}

const String _davNs = 'DAV:';

/// 解析一次 `PROPFIND Depth: 1` 的 207 响应，返回 [requestServerPath] 的
/// **直接子项**（不含它自己）。
///
/// 实现上的几条硬约束（都是真实服务器的差异，不是假想）：
/// - ⛔ **按命名空间认元素**，不按前缀：wsgidav 写 `ns0:`，常见实现写 `D:`/`d:`，
///   也有写默认命名空间不带前缀的。
/// - `href` 可能是**绝对 URL**（`http://host/a/b`）也可能是**路径**（`/a/b`），
///   都只取路径部分再**逐段**百分号解码（`+` 在路径里不是空格，不能用 query 解码）。
/// - 自身那一条要跳过；比较时去掉结尾 `/`（有的服务器目录 href 带、有的不带）。
/// - 只收直接子项：防御性地过滤掉父目录不是请求目录的条目。
/// - 一条 response 可能有多个 propstat（200 的和 404 的分开），只读 200 那个。
List<DavEntry> parsePropfind(
  String body, {
  required String requestServerPath,
}) => parsePropfindListing(body, requestServerPath: requestServerPath).entries;

/// 同 [parsePropfind]，并告诉调用方响应里**有没有请求的目录自身**那一条。
///
/// ⛔ 没有自身那一条 = 响应描述的不是我们以为的那个目录（重定向到了大小写 /
/// 前缀不同的路径等）。这时所有条目都会被「父目录不对」滤掉，得到一个**成功的
/// 空列表**——当真的话，整个目录会被收敛成 missing。调用方必须按错误处理。
({List<DavEntry> entries, bool containsSelf}) parsePropfindListing(
  String body, {
  required String requestServerPath,
}) {
  final document = XmlDocument.parse(body);
  final self = _normalize(requestServerPath);
  final entries = <DavEntry>[];
  var containsSelf = false;
  for (final response in document.findAllElements(
    'response',
    namespace: _davNs,
  )) {
    final href = response
        .findElements('href', namespace: _davNs)
        .firstOrNull
        ?.innerText
        .trim();
    if (href == null || href.isEmpty) continue;
    final serverPath = _normalize(_decodeHrefPath(href));
    if (serverPath == self) {
      containsSelf = true;
      continue;
    }
    if (p.posix.dirname(serverPath) != self) continue;

    var isDirectory = false;
    int? size;
    int? modifiedMs;
    for (final propstat in response.findElements(
      'propstat',
      namespace: _davNs,
    )) {
      final status = propstat
          .findElements('status', namespace: _davNs)
          .firstOrNull
          ?.innerText;
      if (status != null && !status.contains(' 200')) continue;
      final prop = propstat.findElements('prop', namespace: _davNs).firstOrNull;
      if (prop == null) continue;
      final resourceType = prop
          .findElements('resourcetype', namespace: _davNs)
          .firstOrNull;
      if (resourceType != null &&
          resourceType
              .findElements('collection', namespace: _davNs)
              .isNotEmpty) {
        isDirectory = true;
      }
      size ??= int.tryParse(
        prop
                .findElements('getcontentlength', namespace: _davNs)
                .firstOrNull
                ?.innerText
                .trim() ??
            '',
      );
      modifiedMs ??= _parseHttpDate(
        prop
            .findElements('getlastmodified', namespace: _davNs)
            .firstOrNull
            ?.innerText
            .trim(),
      );
    }
    entries.add(
      DavEntry(
        serverPath: serverPath,
        isDirectory: isDirectory,
        size: isDirectory ? null : size,
        modifiedMs: modifiedMs,
      ),
    );
  }
  return (entries: entries, containsSelf: containsSelf);
}

String _decodeHrefPath(String href) {
  var path = href;
  if (href.startsWith('http://') || href.startsWith('https://')) {
    // 只取路径，保留原始编码（Uri.path 已经是编码态）。
    path = Uri.parse(href).path;
  } else {
    final cut = path.indexOf('?');
    if (cut >= 0) path = path.substring(0, cut);
  }
  return path.split('/').map(_decodeSegment).join('/');
}

String _decodeSegment(String segment) {
  try {
    return Uri.decodeComponent(segment);
  } on ArgumentError {
    // 非法的 `%` 序列：有服务器会把文件名里的 `%` 原样吐出来。保留原文。
    return segment;
  }
}

String _normalize(String serverPath) {
  final normalized = p.posix.normalize(
    serverPath.startsWith('/') ? serverPath : '/$serverPath',
  );
  return normalized;
}

int? _parseHttpDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return HttpDate.parse(raw).millisecondsSinceEpoch;
  } on HttpException {
    return DateTime.tryParse(raw)?.millisecondsSinceEpoch;
  } on FormatException {
    return DateTime.tryParse(raw)?.millisecondsSinceEpoch;
  }
}
