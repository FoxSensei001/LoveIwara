import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';

/// 目录浏览页的地址口径，**只此一份**。
///
/// # ⛔ 相对路径走 query 不走 path 段
///
/// 目录的相对路径里天然带 `/`（`番剧/进击的巨人/第一季`），塞进 path 段会被
/// go_router 当成多级路由拆开、匹配不上。放进 query 由 [Uri] 统一转义，
/// 读回来时 go_router 已经解好码，拿到的就是原样的 `a/b/c`。
///
/// 源根这一层的 `relPath` 是空字符串，此时干脆不带 `path=`——地址短一截，
/// 也免得出现 `?path=` 这种空值尾巴。
class LocalFolderRoute {
  const LocalFolderRoute._();

  static const String path = '/local/browse';
  static const String name = 'local_folder_browse';

  static const String sourceParam = 'source';
  static const String pathParam = 'path';

  static String location({required String sourceId, String relPath = ''}) {
    return Uri(
      path: path,
      queryParameters: <String, String>{
        sourceParam: sourceId,
        if (relPath.isNotEmpty) pathParam: relPath,
      },
    ).toString();
  }

  static String locationForFolder(LocalMediaFolder folder) =>
      location(sourceId: folder.sourceId, relPath: folder.relPath);

  /// 从 go_router 的 query 里读回 `(sourceId, relPath)`；没有 `source` 时返回 null。
  static ({String sourceId, String relPath})? parse(
    Map<String, String> queryParameters,
  ) {
    final sourceId = queryParameters[sourceParam];
    if (sourceId == null || sourceId.isEmpty) return null;
    final raw = queryParameters[pathParam] ?? '';
    // 首尾斜杠一律削掉：口径必须与 local_media_folders.rel_path 逐字一致，
    // 否则 `/番剧` 与 `番剧` 会查成两个不同的目录（前者查不到，页面空白）。
    final relPath = raw.replaceAll(RegExp(r'^/+|/+$'), '');
    return (sourceId: sourceId, relPath: relPath);
  }
}
