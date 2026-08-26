import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
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

  /// 产物构建时间（UTC）。**[rev] 是内容指纹、不带先后关系**，
  /// 要回答「缓存那份和打包那份谁更新」只能靠它。
  /// 本字段之前的产物没有它。
  final DateTime? builtAt;

  const DictionarySnapshot({
    required this.version,
    required this.rev,
    required this.count,
    this.builtAt,
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
      builtAt: DateTime.tryParse('${decoded['builtAt'] ?? ''}')?.toUtc(),
    );
  } catch (_) {
    return null;
  }
}

/// 远端这份是不是**确定地更旧**——旧到既不该顶掉内存里那份，也不该落盘。
///
/// 判据只有 `builtAt`：`rev` 是内容指纹，只答「一不一样」，答不了先后。
/// 缺 `builtAt` 的产物必定早于这个字段本身（与 [assetBeatsCache] 同一条推理），
/// 所以「本地有 `builtAt`、远端没有」也算确定更旧——jsDelivr 的 @master
/// 缓存会滞后十几个小时到几天，这段窗口里远端就是上一版的产物。
bool isStaleIncoming(DictionarySnapshot? loaded, DictionarySnapshot incoming) {
  final loadedAt = loaded?.builtAt;
  if (loadedAt == null) return false;
  final incomingAt = incoming.builtAt;
  if (incomingAt == null) return true;
  return incomingAt.isBefore(loadedAt);
}

/// 远端这份要不要顶掉内存里那份。
///
/// 先挡确定更旧的那份（见 [isStaleIncoming]），否则「远端有 rev、没 builtAt」
/// 会直接走到指纹分支，把用户包里更新的词库降级回 CDN 那份旧的。
/// 剩下的情况：两边都有 `rev` 时按指纹判——这是唯一能发现「只改了译名」的方式；
/// 任意一边缺 `rev`（旧产物或旧缓存）时退回旧的条目数判据，保持向后兼容。
bool shouldRebuild(DictionarySnapshot? loaded, DictionarySnapshot incoming) {
  if (loaded == null) return true;
  if (isStaleIncoming(loaded, incoming)) return false;
  final a = loaded.rev;
  final b = incoming.rev;
  if (a != null && b != null) return a != b;
  return loaded.count != incoming.count;
}

/// 冷启动时「缓存那份」和「打包那份」谁该赢。
///
/// 老实现是缓存无条件优先，代价是：发版带了更新的词库，只要用户本地还留着
/// 上一版的 CDN 缓存就一直用旧的——他若连不上 jsDelivr（国内常见），
/// 新译名**永远**到不了他手里。
///
/// 判据是 `builtAt`：
/// - 两边都有 → 新的赢；
/// - 缓存没有、打包有 → 打包赢（没有 `builtAt` 的缓存必定早于这个字段本身）；
/// - 其余（都没有 / 只有缓存有）→ 缓存赢，保持老行为。
///
/// 返回 true 表示该用打包资源。
bool assetBeatsCache(DictionarySnapshot? cache, DictionarySnapshot? asset) {
  if (cache == null) return true;
  if (asset == null) return false;
  final a = asset.builtAt;
  final c = cache.builtAt;
  if (a == null) return false;
  if (c == null) return true;
  return a.isAfter(c);
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

  /// 冷启动读词库：在「CDN 缓存」与「打包资源」之间取 `builtAt` 更新的那份。
  ///
  /// 收口在这里而不是各服务自己写一遍，是因为这段逻辑此前就是两份同构拷贝，
  /// 而这类重复的代价是修一处漏一处。判据见 [assetBeatsCache]。
  Future<String?> readFreshest({
    required String assetKey,
    required int Function(Map<String, dynamic> decoded) countEntries,
  }) async {
    final cache = await readCache();
    String? asset;
    try {
      asset = await rootBundle.loadString(assetKey);
    } catch (e) {
      LogUtils.e('加载打包词库失败', tag: logTag, error: e);
    }
    if (cache == null) return asset;
    if (asset == null) return cache;

    final useAsset = assetBeatsCache(
      peekSnapshot(cache, countEntries),
      peekSnapshot(asset, countEntries),
    );
    if (useAsset) {
      LogUtils.i('打包词库比 CDN 缓存新，本次用打包那份', logTag);
    }
    return useAsset ? asset : cache;
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
