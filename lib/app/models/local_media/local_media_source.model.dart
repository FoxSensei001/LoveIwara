/// 一个「媒体源」：用户授权过、我们会去扫的一处来源。
///
/// 源的种类决定了**怎么拿到文件**，而不只是"路径长什么样"：
///
/// - [LocalMediaSourceKind.directory]：一条绝对路径（桌面、Quest、以及 Android 上
///   由 SAF 解析出真实路径的那一支）。P0 只做这一种。
/// - [LocalMediaSourceKind.mediastore]：不扫盘，查 Android 系统媒体索引。
/// - [LocalMediaSourceKind.bookmark]：iOS 的书签（沙盒外目录只能这么长期持有）。
/// - [LocalMediaSourceKind.downloads]：应用自己的下载目录。它是**真实源**不是虚拟源
///   ——下载来的文件和拷进来的文件在同一张表里排序分页，卡片才可能同构。
enum LocalMediaSourceKind { directory, mediastore, bookmark, downloads }

/// 这个源要扫什么。
enum LocalMediaKinds { video, image, both }

/// 源的扫描状态。
///
/// [interrupted] 是**被杀/切后台留下的**：下次进来要从 `scanCursor` 续扫，
/// 而不是从头再扫一遍（大目录重扫一次的代价用户能感觉到）。
enum LocalMediaScanState { idle, scanning, interrupted }

class LocalMediaSource {
  const LocalMediaSource({
    required this.id,
    required this.kind,
    required this.displayName,
    this.path,
    this.uri,
    this.mediaKinds = LocalMediaKinds.video,
    this.recursive = true,
    this.autoRescan = true,
    this.sortOrder = 0,
    this.scanState = LocalMediaScanState.idle,
    this.scanCursor,
    this.offline = false,
    this.lastScanAt,
    this.itemCount = 0,
    required this.createdAt,
  });

  final String id;
  final LocalMediaSourceKind kind;
  final String displayName;
  final String? path;
  final String? uri;
  final LocalMediaKinds mediaKinds;
  final bool recursive;
  final bool autoRescan;
  final int sortOrder;
  final LocalMediaScanState scanState;

  /// 续扫游标：上次扫到哪个子目录。语义由扫描器定义，本模型只负责存取。
  final String? scanCursor;

  /// 整卷不可达（U 盘拔了、外置存储没挂上、权限被撤销）。
  ///
  /// ⛔ 这是**整源**级别的标记，不是把条目逐条标 `missing`：挂载点整个消失时逐条标记
  /// 会让重新插上之后必须全库回扫，而且 UI 上会先闪一下"全没了"。
  final bool offline;

  final int? lastScanAt;
  final int itemCount;
  final int createdAt;

  LocalMediaSource copyWith({
    String? displayName,
    LocalMediaScanState? scanState,
    Object? scanCursor = _unset,
    bool? offline,
    int? lastScanAt,
    int? itemCount,
    int? sortOrder,
    bool? autoRescan,
  }) {
    return LocalMediaSource(
      id: id,
      kind: kind,
      displayName: displayName ?? this.displayName,
      path: path,
      uri: uri,
      mediaKinds: mediaKinds,
      recursive: recursive,
      autoRescan: autoRescan ?? this.autoRescan,
      sortOrder: sortOrder ?? this.sortOrder,
      scanState: scanState ?? this.scanState,
      scanCursor: scanCursor == _unset ? this.scanCursor : scanCursor as String?,
      offline: offline ?? this.offline,
      lastScanAt: lastScanAt ?? this.lastScanAt,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toRow() => <String, Object?>{
    'id': id,
    'kind': kind.name,
    'display_name': displayName,
    'path': path,
    'uri': uri,
    'media_kinds': mediaKinds.name,
    'recursive': recursive ? 1 : 0,
    'auto_rescan': autoRescan ? 1 : 0,
    'sort_order': sortOrder,
    'scan_state': scanState.name,
    'scan_cursor': scanCursor,
    'offline': offline ? 1 : 0,
    'last_scan_at': lastScanAt,
    'item_count': itemCount,
    'created_at': createdAt,
  };

  /// 从库里读回来。
  ///
  /// ⛔ 枚举一律**容错解析**：认不出的值退回安全缺省，而不是抛。库里的值可能来自
  /// 更新版本的 App（用户降级）或一次写坏的迁移，为一行脏数据让整个列表打不开
  /// 是不划算的。
  factory LocalMediaSource.fromRow(Map<String, Object?> row) {
    return LocalMediaSource(
      id: row['id'] as String,
      kind: _parseEnum(
        LocalMediaSourceKind.values,
        row['kind'],
        LocalMediaSourceKind.directory,
      ),
      displayName: (row['display_name'] as String?) ?? '',
      path: row['path'] as String?,
      uri: row['uri'] as String?,
      mediaKinds: _parseEnum(
        LocalMediaKinds.values,
        row['media_kinds'],
        LocalMediaKinds.video,
      ),
      recursive: (row['recursive'] as int? ?? 1) != 0,
      autoRescan: (row['auto_rescan'] as int? ?? 1) != 0,
      sortOrder: row['sort_order'] as int? ?? 0,
      scanState: _parseEnum(
        LocalMediaScanState.values,
        row['scan_state'],
        LocalMediaScanState.idle,
      ),
      scanCursor: row['scan_cursor'] as String?,
      offline: (row['offline'] as int? ?? 0) != 0,
      lastScanAt: row['last_scan_at'] as int?,
      itemCount: row['item_count'] as int? ?? 0,
      createdAt: row['created_at'] as int? ?? 0,
    );
  }
}

const Object _unset = Object();

T _parseEnum<T extends Enum>(List<T> values, Object? raw, T fallback) {
  if (raw is! String) return fallback;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return fallback;
}
