import 'package:path/path.dart' as p;

/// NAS（WebDAV）源在库里的路径形状：`dav:/` + **解码后**的服务端绝对路径。
///
/// 例：服务端 `/video/%E5%89%A7%E9%9B%86/EP01.mp4` → 库里存 `dav:/video/剧集/EP01.mp4`。
/// 条目 `path`、`folder_path`、源 `path` 一律是这个形状。
///
/// # 为什么要前缀，而不是直接存 `/video/…`
///
/// 远端路径和 Unix 本地路径长得一模一样。本模块到处都有「拿 path 直接 `File()`」
/// 的代码，同形意味着它们会在本机磁盘上找同名东西——实际核实过的误伤：
/// - `findOverlappingSource`：NAS 根选 `/` 时，所有本地文件夹都「落在它里面」，
///   再也加不进来；
/// - 「文件没了、父目录还在」的判定：本机 `/` 永远在，NAS 根下的条目被标 missing；
/// - 已发布的旧版本读到这一行时把源当 `directory`，会去扫**本机根目录**。
///
/// 带上前缀后 `File('dav:/…')` 是相对路径、必然不存在，父目录也不存在；与本地路径
/// 永不重叠；旧版扫它第 0 层就列不出 → 整源 offline，不做 missing 收敛。
///
/// ⛔ 不用 `dav://`：`p.posix.normalize` 会把 `//` 折叠成 `/`，存进去的和算出来的
/// 就对不上了。
///
/// ⛔ 这类路径的一切运算只许走本类（内部固定 `p.posix`）。`package:path` 的默认
/// 上下文在 Windows 上是反斜杠，`p.dirname('dav:/a/b.mp4')` 会算出 `dav:\a`。
abstract final class DavPath {
  static const String prefix = 'dav:/';

  static final p.Context _posix = p.posix;

  /// 这条路径是不是 NAS 源的。**条目级的「能不能碰本机文件」一律问它**——
  /// 条目不带源的种类，但前缀本身就是判据，不必回库查源。
  static bool isDav(String? path) => path != null && path.startsWith(prefix);

  /// 服务端绝对路径（已解码，`/` 开头）→ 库里的形状。
  static String fromServerPath(String serverPath) {
    final normalized = _posix.normalize(
      serverPath.startsWith('/') ? serverPath : '/$serverPath',
    );
    // normalize('/') == '/'，拼出来就是 'dav:/'，正好是「服务端根」。
    return 'dav:$normalized';
  }

  /// 库里的形状 → 服务端绝对路径（已解码，`/` 开头）。
  static String toServerPath(String davPath) {
    assert(isDav(davPath), '不是 dav 路径：$davPath');
    return davPath.substring(prefix.length - 1);
  }

  /// 服务端路径按段拆开（不含空段），给 `Uri(pathSegments:)` 用。
  ///
  /// ⛔ 生成 URL 一律 `Uri(pathSegments: …)`，禁止字符串拼接——文件名里的
  /// `#`、`%`、`?`、空格拼进去会被当成 fragment/query/转义。
  static List<String> segments(String davPath) =>
      toServerPath(davPath).split('/').where((s) => s.isNotEmpty).toList();

  static String join(String davDir, String name) =>
      fromServerPath(_posix.join(toServerPath(davDir), name));

  static String dirname(String davPath) =>
      fromServerPath(_posix.dirname(toServerPath(davPath)));

  static String basename(String davPath) =>
      _posix.basename(toServerPath(davPath));

  /// [child] 是否在 [parent] 之下（不含相等）。
  static bool isWithin(String parent, String child) =>
      _posix.isWithin(toServerPath(parent), toServerPath(child));

  /// [child] 相对 [root] 的 rel_path（`/` 分隔，相等时为空串）——与扫描器
  /// `relPathOf` 同一口径。
  static String relative(String root, String child) {
    final rel = _posix.relative(toServerPath(child), from: toServerPath(root));
    return rel == '.' ? '' : rel;
  }
}
