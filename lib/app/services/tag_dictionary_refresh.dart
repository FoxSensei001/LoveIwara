import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../utils/logger_utils.dart';

/// 词库快照的身份标识——用来回答「本地这份和远端那份是不是同一份」。
///
/// 历史实现用的是「条目数变了才算更新」的启发式（两个本地化服务各写了一遍），
/// 纯译名修正条数不变，判不出来，修正要等下一次冷启动才生效。
/// 构建脚本现在会给产物写入内容指纹 `rev`，任何一个字变了它就变。
class DictionarySnapshot {
  /// 产物结构版本。
  final int version;

  /// 内容指纹。旧产物（version 1）没有这个字段。
  final String? rev;

  /// 条目数。仅在 [rev] 缺失时作为退化判据。
  final int count;

  const DictionarySnapshot({
    required this.version,
    required this.rev,
    required this.count,
  });

  bool get isEmpty => count == 0;

  @override
  String toString() => 'v$version${rev == null ? '' : '/$rev'} ($count 条)';
}

/// 从词库 JSON 里只探测身份信息，不构建完整映射。
///
/// [countEntries] 由调用方提供，因为两份词库的结构不同
/// （iwara 是平铺的 `tags`，oreno3d 分 origins/characters/tags 三类）。
DictionarySnapshot? peekSnapshot(
  String content,
  int Function(Map<String, dynamic> decoded) countEntries,
) {
  try {
    final decoded = jsonDecode(content) as Map<String, dynamic>;
    final count = countEntries(decoded);
    if (count <= 0) return null;
    return DictionarySnapshot(
      version: (decoded['version'] as num?)?.toInt() ?? 1,
      rev: decoded['rev'] as String?,
      count: count,
    );
  } catch (_) {
    return null;
  }
}

/// 远端这份要不要顶掉内存里那份。
///
/// 两边都有 `rev` 时按指纹判——这是唯一能发现「只改了译名」的方式。
/// 任意一边缺 `rev`（旧产物或旧缓存）时退回旧的条目数判据，保持向后兼容。
bool shouldRebuild(DictionarySnapshot? loaded, DictionarySnapshot incoming) {
  if (loaded == null) return true;
  final a = loaded.rev;
  final b = incoming.rev;
  if (a != null && b != null) return a != b;
  return loaded.count != incoming.count;
}

/// 两个本地化服务共用的 CDN 拉取 + 缓存落盘。
///
/// 抽出来是因为它们此前是逐行同构的两份拷贝，那个条目数启发式也就存在了两遍——
/// 这类重复的代价不是多几行代码，是修一处漏一处。
class TagDictionaryFetcher {
  TagDictionaryFetcher({
    required this.url,
    required this.cacheFileName,
    required this.logTag,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final String url;
  final String cacheFileName;
  final String logTag;
  final Dio _dio;

  Future<File> cacheFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, cacheFileName));
  }

  /// 拉取远端词库原文；失败返回 null（网络失败属正常情况，有兜底数据）。
  Future<String?> fetch() async {
    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
        ),
      );
      final content = response.data;
      if (content == null || content.isEmpty) return null;
      return content;
    } catch (e) {
      LogUtils.w('从 CDN 拉取词库失败: $e', logTag);
      return null;
    }
  }

  /// 写入缓存。即使本次没有重建内存也要写——下次冷启动会读到新的那份。
  Future<void> writeCache(String content) async {
    try {
      final file = await cacheFile();
      await file.writeAsString(content, flush: true);
    } catch (e) {
      LogUtils.w('写入词库缓存失败: $e', logTag);
    }
  }

  /// 读取缓存原文；不存在或为空返回 null。
  Future<String?> readCache() async {
    try {
      final file = await cacheFile();
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return content.isEmpty ? null : content;
    } catch (e) {
      LogUtils.w('读取词库缓存失败: $e', logTag);
      return null;
    }
  }
}
