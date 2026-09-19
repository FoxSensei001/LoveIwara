/// 本机文件 / NAS 源「哪些子目录不进去」的唯一判据。
///
/// 以前这件事散在四处各写一份（本地扫描 worker、目录选择器、NAS 扫描器、NAS
/// 连接弹窗），规则悄悄分叉：选择器能看见 `Android`、浏览页里它却消失；NAS 那边
/// 从没排除过群晖的 `@eaDir`。现在四处都只问这里。
///
/// ⛔ 纯 Dart、无状态：本地扫描跑在独立 isolate 里，这里不许引 GetX / Flutter。
///
/// ⛔ 只判「子目录」，从不判扫描根自己：用户主动把一个 `.` 开头的目录、甚至
/// Android 10 上的 `Android/data/<包名>` 选成源，意图就是「给我看这里」，照扫。
abstract final class LocalDirectoryPolicy {
  /// 无论如何都不进去的目录（小写比较）：回收站、系统元数据、NAS 缩略图、版本库。
  ///
  /// `.` 开头的几项平时也被 [isDotEntry] 挡着，写在这里是给源打开了「扫描 `.`
  /// 开头的文件夹」时用的：开关打开也不该把 `.git` / `.thumbnails` 卷进来。
  static const Set<String> junkNames = <String>{
    // 回收站
    r'$recycle.bin',
    '.trash',
    '.trashed',
    '.trashes',
    '#recycle', // 群晖
    '@recycle', // 威联通
    // 系统元数据
    'lost.dir',
    'system volume information',
    '.spotlight-v100',
    '.fseventsd',
    '.documentrevisions-v100',
    '.temporaryitems',
    // 缩略图 / 缓存
    '.thumbnails',
    '.cache',
    '@eadir', // 群晖：每张图一份 SYNOPHOTO_THUMB_*.jpg
    '.@__thumb', // 威联通
    '#snapshot', // 群晖快照
    // 版本库
    '.git',
    '.svn',
  };

  static bool isDotEntry(String name) => name.startsWith('.');

  static bool isJunk(String name) => junkNames.contains(name.toLowerCase());

  /// 父目录名为 `Android` 的 `data` / `obb`（以及父目录名为 `Library` 的 macOS
  /// 应用容器）：别的应用的私有目录。
  ///
  /// 按「父目录名 + 自己的名字」判，**任意深度**都生效，不只卷根：手机备份到
  /// 电脑上的 `备份/Android/data` 同样是一堆应用缓存，挡掉正合适；要看它，把它
  /// 自己选成源根即可（源根不受这里管）。
  ///
  /// Android 11 起任何权限都读不到，列了也是白走一趟；Android 10 及以下读得到，
  /// 但那是所有应用的缓存，扫进来只会把库淹掉。所以自动递归时一律不进。
  ///
  /// ⭐ 以前是按名字挡整个 `Android`——任意深度的 `Games/Android` 被误伤，
  /// `Android/media`（WhatsApp / Telegram 在 11 之后的媒体）也一起丢了。
  /// 现在只挡 `data` / `obb` 这两个。
  static bool isOtherAppsPrivate({
    required String parentName,
    required String name,
  }) {
    final parent = parentName.toLowerCase();
    final lower = name.toLowerCase();
    if (parent == 'android') return lower == 'data' || lower == 'obb';
    // macOS 的 `~/Library/Containers`、`Group Containers`：别的应用的沙盒。
    // 用户把 `~` 选成源时会一头扎进去，macOS 15 起每碰一个别家容器就弹一次
    // 「想访问其他 App 的数据」，看起来像恶意软件。
    if (parent == 'library') {
      return lower == 'containers' || lower == 'group containers';
    }
    return false;
  }

  /// 绝对路径是否落在（或就是）别的应用的私有目录里。给「读不动」时判断该不该
  /// 换成那段系统限制的解释用——扫描递归不走这里。
  static bool isUnderOtherAppsPrivate(String absPath) {
    final segments = absPath
        .split(RegExp(r'[/\\]'))
        .where((s) => s.isNotEmpty)
        .toList();
    for (var i = 1; i < segments.length; i++) {
      if (isOtherAppsPrivate(parentName: segments[i - 1], name: segments[i])) {
        return true;
      }
    }
    return false;
  }

  /// 本地扫描递归时是否跳过这个子目录。
  ///
  /// [includeDot]：源的 `includeDotEntries`。只放开 `.` 开头这一条，垃圾目录
  /// 与别的应用的私有目录照挡。
  static bool skipLocalChild({
    required String parentName,
    required String name,
    bool includeDot = false,
  }) =>
      (!includeDot && isDotEntry(name)) ||
      isJunk(name) ||
      isOtherAppsPrivate(parentName: parentName, name: name);

  /// NAS 扫描 / 选择器列目录时是否跳过。
  ///
  /// 不带 [isOtherAppsPrivate]：NAS 上不存在「别的应用的私有目录」这回事；
  /// 本地选择器则要让 Android 10 的用户能手动选进 `Android/data`（11 起列不出来，
  /// 选择器自己会提示读不动）。
  static bool skipListedChild(String name, {bool includeDot = false}) =>
      (!includeDot && isDotEntry(name)) || isJunk(name);

  /// 相对源根的路径里有没有 `.` 开头的一段（`a/.b/c` → true）。给「关掉开关时
  /// 哪些库行该收敛」和「哪些隐藏目录不再豁免」用。两种分隔符都认。
  static bool relPathHasDotSegment(String relPath) =>
      relPath.split(RegExp(r'[/\\]')).any(isDotEntry);
}
