import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:win32_registry/win32_registry.dart';

import 'package:i_iwara/app/services/desktop_external_player.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 一个待探测的播放器候选。
///
/// 同一个软件在不同机器上可能装在完全不同的地方，所以每条候选都同时给出**多条
/// 线索**，探测器把它们挨个试一遍，命中哪条算哪条。
@immutable
class PlayerCandidate {
  const PlayerCandidate({
    required this.id,
    required this.name,
    required this.executableNames,
    this.steamDirectory,
    this.metaDirectory,
    this.absolutePaths = const [],
    this.uninstallKeywords = const [],
    this.macAppNames = const [],
    this.flatpakIds = const [],
    this.vr = false,
  });

  final String id;
  final String name;

  /// 可执行文件名，按优先级排。一个软件可能有多个（PotPlayer 的 64/32 位、
  /// MPC-HC 的两档），命中第一个就停。
  final List<String> executableNames;

  /// Steam 安装目录名（`steamapps/common/<这里>`）。
  final String? steamDirectory;

  /// Meta / Oculus 商店的安装目录名（`<库>/Software/<这里>`）。
  final String? metaDirectory;

  /// 固定安装路径候选（可含 `%ENV%` 形式的环境变量）。
  final List<String> absolutePaths;

  /// 在「卸载项」里匹配 DisplayName 用的关键字（小写、子串匹配）。
  ///
  /// 这是覆盖面最大的一条线索：只要软件是正经装的，不管装到哪个盘、哪个自定义
  /// 目录，卸载项里都记着它的 InstallLocation。
  final List<String> uninstallKeywords;

  /// macOS 的 `.app` 包名（不含扩展名）。
  final List<String> macAppNames;

  /// Linux 的 flatpak 应用 id。
  final List<String> flatpakIds;

  /// 是不是 VR / 全景播放器。只用于给探测结果排序——这个功能的第一动机就是
  /// PCVR，探到 HereSphere 却把它排在 VLC 后面，用户在转交面板里第一眼看到的
  /// 就是错的那个。
  final bool vr;
}

/// 自动探测本机已装的常见 PCVR / 桌面播放器。
///
/// # 探测走哪几条线索
///
/// 上一版只查两处（Steam 的 `steamapps/common` + 几条写死的 `%ProgramFiles%`
/// 路径），于是**非 Steam 装的一律探不到**——而 HereSphere、DeoVR 都另有独立
/// 发行渠道，mpv / VLC 更是 winget、scoop、choco 装到哪儿的都有
/// （2026-08-30 用户报障：「自动探测也探测不到啥」）。现在按平台分头走：
///
/// - **Windows**：注册表 `App Paths`（含 32 位视图）→ 注册表卸载项的
///   `InstallLocation` → Steam 库 → Meta/Oculus 库 → 写死的固定路径 → `PATH`；
/// - **macOS**：`/Applications` 与 `~/Applications` 里的 `.app` 包 → 固定路径
///   → `PATH`（含 homebrew 的两个前缀）；
/// - **Linux**：`PATH` → flatpak 导出目录 → 固定路径。
///
/// ⚠️ 候选表仍是尽力而为：探测只把**磁盘上真实存在的文件**加进来，猜错的条目
/// 落地就是探不到，不会产生错误配置——所以手动添加永远是兜底的正路。
class DesktopPlayerProbe {
  /// Windows 候选。
  static const List<PlayerCandidate> _windowsCandidates = [
    PlayerCandidate(
      id: 'heresphere',
      name: 'HereSphere',
      executableNames: ['HereSphere.exe'],
      steamDirectory: 'HereSphere',
      uninstallKeywords: ['heresphere'],
      vr: true,
    ),
    PlayerCandidate(
      id: 'deovr',
      name: 'DeoVR',
      executableNames: ['DeoVR.exe', 'DeoVRPlayer.exe'],
      steamDirectory: 'DeoVR Video Player',
      metaDirectory: 'deovr-video-player',
      uninstallKeywords: ['deovr'],
      vr: true,
    ),
    PlayerCandidate(
      id: 'whirligig',
      name: 'Whirligig',
      executableNames: ['Whirligig.exe'],
      steamDirectory: 'Whirligig',
      uninstallKeywords: ['whirligig'],
      vr: true,
    ),
    PlayerCandidate(
      id: 'simple_vr',
      name: 'Simple VR Video Player',
      executableNames: [
        'Simple VR Video Player.exe',
        'SimpleVRVideoPlayer.exe',
      ],
      steamDirectory: 'Simple VR Video Player',
      uninstallKeywords: ['simple vr video player'],
      vr: true,
    ),
    PlayerCandidate(
      id: 'skybox_pc',
      name: 'SKYBOX VR',
      executableNames: ['SKYBOX.exe', 'SkyboxVRPlayer.exe'],
      steamDirectory: 'SKYBOX VR Video Player',
      metaDirectory: 'skybox-vr-video-player',
      uninstallKeywords: ['skybox'],
      vr: true,
    ),
    PlayerCandidate(
      id: 'pigasus',
      name: 'Pigasus VR Media Player',
      executableNames: ['Pigasus.exe'],
      steamDirectory: 'Pigasus VR Media Player',
      uninstallKeywords: ['pigasus'],
      vr: true,
    ),
    PlayerCandidate(
      id: 'potplayer',
      name: 'PotPlayer',
      // ⛔ 目录名是 `PotPlayer64`，老版本才是 `PotPlayer`。上一版只写了后者，
      // 于是绝大多数装了 PotPlayer 的机器都探不到。
      executableNames: ['PotPlayerMini64.exe', 'PotPlayerMini.exe'],
      uninstallKeywords: ['potplayer'],
      absolutePaths: [
        r'%ProgramFiles%\DAUM\PotPlayer64\PotPlayerMini64.exe',
        r'%ProgramFiles%\DAUM\PotPlayer\PotPlayerMini64.exe',
        r'%ProgramFiles(x86)%\DAUM\PotPlayer\PotPlayerMini.exe',
      ],
    ),
    PlayerCandidate(
      id: 'vlc',
      name: 'VLC',
      executableNames: ['vlc.exe'],
      uninstallKeywords: ['vlc media player'],
      absolutePaths: [
        r'%ProgramFiles%\VideoLAN\VLC\vlc.exe',
        r'%ProgramFiles(x86)%\VideoLAN\VLC\vlc.exe',
      ],
    ),
    PlayerCandidate(
      id: 'mpv',
      name: 'mpv',
      executableNames: ['mpv.exe'],
      uninstallKeywords: ['mpv'],
      absolutePaths: [
        r'%ProgramFiles%\mpv\mpv.exe',
        r'%LOCALAPPDATA%\Microsoft\WinGet\Links\mpv.exe',
        r'%USERPROFILE%\scoop\shims\mpv.exe',
        r'%ChocolateyInstall%\bin\mpv.exe',
      ],
    ),
    PlayerCandidate(
      id: 'mpvnet',
      name: 'mpv.net',
      executableNames: ['mpvnet.exe'],
      uninstallKeywords: ['mpv.net'],
      absolutePaths: [
        r'%ProgramFiles%\mpv.net\mpvnet.exe',
        r'%USERPROFILE%\scoop\shims\mpvnet.exe',
      ],
    ),
    PlayerCandidate(
      id: 'mpc_hc',
      name: 'MPC-HC',
      executableNames: ['mpc-hc64.exe', 'mpc-hc.exe'],
      uninstallKeywords: ['mpc-hc'],
      absolutePaths: [
        r'%ProgramFiles%\MPC-HC\mpc-hc64.exe',
        r'%ProgramFiles(x86)%\MPC-HC\mpc-hc.exe',
      ],
    ),
    PlayerCandidate(
      id: 'mpc_be',
      name: 'MPC-BE',
      executableNames: ['mpc-be64.exe', 'mpc-be.exe'],
      uninstallKeywords: ['mpc-be'],
      absolutePaths: [
        r'%ProgramFiles%\MPC-BE x64\mpc-be64.exe',
        r'%ProgramFiles(x86)%\MPC-BE\mpc-be.exe',
      ],
    ),
  ];

  static const List<PlayerCandidate> _macCandidates = [
    PlayerCandidate(
      id: 'iina',
      name: 'IINA',
      executableNames: ['IINA'],
      macAppNames: ['IINA'],
    ),
    PlayerCandidate(
      id: 'vlc',
      name: 'VLC',
      executableNames: ['VLC'],
      macAppNames: ['VLC'],
    ),
    PlayerCandidate(
      id: 'mpv',
      name: 'mpv',
      executableNames: ['mpv'],
      macAppNames: ['mpv'],
      absolutePaths: ['/opt/homebrew/bin/mpv', '/usr/local/bin/mpv'],
    ),
    PlayerCandidate(
      id: 'movist',
      name: 'Movist Pro',
      executableNames: ['Movist Pro', 'Movist'],
      macAppNames: ['Movist Pro', 'Movist'],
    ),
    PlayerCandidate(
      id: 'infuse',
      name: 'Infuse',
      executableNames: ['Infuse'],
      macAppNames: ['Infuse'],
    ),
  ];

  static const List<PlayerCandidate> _linuxCandidates = [
    PlayerCandidate(
      id: 'vlc',
      name: 'VLC',
      executableNames: ['vlc'],
      flatpakIds: ['org.videolan.VLC'],
      absolutePaths: ['/usr/bin/vlc', '/usr/local/bin/vlc'],
    ),
    PlayerCandidate(
      id: 'mpv',
      name: 'mpv',
      executableNames: ['mpv'],
      flatpakIds: ['io.mpv.Mpv'],
      absolutePaths: ['/usr/bin/mpv', '/usr/local/bin/mpv'],
    ),
    PlayerCandidate(
      id: 'celluloid',
      name: 'Celluloid',
      executableNames: ['celluloid'],
      flatpakIds: ['io.github.celluloid_player.Celluloid'],
      absolutePaths: ['/usr/bin/celluloid'],
    ),
    PlayerCandidate(
      id: 'haruna',
      name: 'Haruna',
      executableNames: ['haruna'],
      flatpakIds: ['org.kde.haruna'],
      absolutePaths: ['/usr/bin/haruna'],
    ),
  ];

  /// 当前平台的候选表。手动添加那条路要拿它列「常见播放器」的快捷入口。
  static List<PlayerCandidate> get candidatesForPlatform {
    if (!GetPlatform.isDesktop) return const [];
    if (Platform.isWindows) return _windowsCandidates;
    if (Platform.isMacOS) return _macCandidates;
    return _linuxCandidates;
  }

  // --------------------------------------------------------------- 对外入口

  /// 探测本机装了哪些候选播放器。[existing] 里已有的可执行文件不重复加。
  static Future<List<DesktopPlayerEntry>> detect({
    List<DesktopPlayerEntry> existing = const [],
  }) async {
    if (!GetPlatform.isDesktop) return const [];

    final candidates = candidatesForPlatform;
    // 每次探测只建一次的公共索引：Steam 库、卸载项表、Meta 库、PATH。
    final ctx = await _ProbeContext.build();

    // 已配置过的路径不重复加（Windows 上路径大小写不敏感）。
    final seen = <String>{
      for (final entry in existing) _canonical(entry.executablePath),
    };

    final found = <DesktopPlayerEntry>[];
    for (final candidate in candidates) {
      final hit = await _locate(candidate, ctx);
      if (hit == null) continue;
      if (!seen.add(_canonical(hit))) continue;
      found.add(
        DesktopPlayerEntry(
          id: '${candidate.id}_${found.length}_${hit.hashCode}',
          name: candidate.name,
          executablePath: hit,
          autoDetected: true,
        ),
      );
    }

    LogUtils.i('自动探测到 ${found.length} 个外部播放器', 'DesktopPlayer');
    return found;
  }

  /// 把一条候选在本机的位置找出来，找不到返回 null。
  static Future<String?> _locate(
    PlayerCandidate candidate,
    _ProbeContext ctx,
  ) async {
    final probes = <Future<String?> Function()>[
      () => _fromRegistryAppPaths(candidate),
      () => _fromUninstallEntries(candidate, ctx),
      () => _fromSteam(candidate, ctx),
      () => _fromMetaLibraries(candidate, ctx),
      () => _fromMacApplications(candidate),
      () => _fromFlatpak(candidate),
      () => _fromAbsolutePaths(candidate),
      () => _fromPathEnv(candidate, ctx),
    ];
    for (final probe in probes) {
      try {
        final hit = await probe();
        if (hit != null) return hit;
      } catch (e) {
        // 单条线索炸了不该让整次探测失败——注册表被组策略锁、目录没读权限都可能。
        LogUtils.w('探测 ${candidate.name} 的某条线索失败: $e', 'DesktopPlayer');
      }
    }
    return null;
  }

  // ------------------------------------------------------------ Windows 注册表

  /// `App Paths`：软件装好后向系统登记「我的可执行文件在这儿」的地方——
  /// `开始 → 运行 → vlc` 能拉起来靠的就是它，装到哪个盘都查得到。
  static Future<String?> _fromRegistryAppPaths(PlayerCandidate candidate) async {
    if (!Platform.isWindows) return null;
    const roots = [
      r'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths',
      // 32 位程序登记在这儿：本应用是 64 位进程，读不到对方的原生视图。
      r'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths',
    ];
    for (final exe in candidate.executableNames) {
      for (final hive in [RegistryHive.localMachine, RegistryHive.currentUser]) {
        for (final root in roots) {
          final resolved = _normalizeRegistryPath(
            _readRegistryString(hive, '$root\\$exe', ''),
          );
          if (resolved != null && await File(resolved).exists()) return resolved;
        }
      }
    }
    return null;
  }

  /// 卸载项里的 `InstallLocation`：覆盖面最大的一条——只要是正经安装的，
  /// 不管装在哪个自定义目录都躲不掉。
  static Future<String?> _fromUninstallEntries(
    PlayerCandidate candidate,
    _ProbeContext ctx,
  ) async {
    if (!Platform.isWindows || candidate.uninstallKeywords.isEmpty) return null;
    for (final entry in ctx.uninstallLocations.entries) {
      final matched = candidate.uninstallKeywords.any(
        (keyword) => entry.key.contains(keyword),
      );
      if (!matched) continue;
      final hit = await _findExecutableUnder(entry.value, candidate);
      if (hit != null) return hit;
    }
    return null;
  }

  /// 在一个安装目录里找可执行文件：先看根目录，再往下找一层——不少播放器把
  /// exe 放在 `bin\` 或版本号子目录里。
  static Future<String?> _findExecutableUnder(
    String directory,
    PlayerCandidate candidate,
  ) async {
    if (directory.isEmpty) return null;
    final dir = Directory(directory);
    if (!await dir.exists()) return null;

    for (final exe in candidate.executableNames) {
      final direct = p.join(directory, exe);
      if (await File(direct).exists()) return direct;
    }

    List<FileSystemEntity> children;
    try {
      // 只看一层、且封顶 64 个子目录：安装目录里塞几千个文件的软件是有的
      // （游戏引擎打包的资源目录），不封顶就是一次几秒的磁盘遍历。
      children = await dir.list(followLinks: false).take(64).toList();
    } catch (_) {
      return null;
    }
    for (final child in children.whereType<Directory>()) {
      for (final exe in candidate.executableNames) {
        final nested = p.join(child.path, exe);
        if (await File(nested).exists()) return nested;
      }
    }
    return null;
  }

  // ------------------------------------------------------------------ Steam

  static Future<String?> _fromSteam(
    PlayerCandidate candidate,
    _ProbeContext ctx,
  ) async {
    final dirName = candidate.steamDirectory;
    if (dirName == null) return null;
    for (final library in ctx.steamLibraries) {
      final hit = await _findExecutableUnder(
        p.join(library, 'steamapps', 'common', dirName),
        candidate,
      );
      if (hit != null) return hit;
    }
    return null;
  }

  // ----------------------------------------------------------- Meta / Oculus

  static Future<String?> _fromMetaLibraries(
    PlayerCandidate candidate,
    _ProbeContext ctx,
  ) async {
    final dirName = candidate.metaDirectory;
    if (dirName == null) return null;
    for (final library in ctx.metaLibraries) {
      final hit = await _findExecutableUnder(
        p.join(library, 'Software', dirName),
        candidate,
      );
      if (hit != null) return hit;
    }
    return null;
  }

  // ------------------------------------------------------------------ macOS

  static Future<String?> _fromMacApplications(PlayerCandidate candidate) async {
    if (!Platform.isMacOS || candidate.macAppNames.isEmpty) return null;
    final home = Platform.environment['HOME'];
    final roots = <String>[
      '/Applications',
      if (home != null && home.isNotEmpty) p.join(home, 'Applications'),
    ];
    for (final root in roots) {
      for (final appName in candidate.macAppNames) {
        final bundle = p.join(root, '$appName.app');
        if (!await Directory(bundle).exists()) continue;
        final macOsDir = p.join(bundle, 'Contents', 'MacOS');
        for (final exe in candidate.executableNames) {
          final path = p.join(macOsDir, exe);
          if (await File(path).exists()) return path;
        }
        // 可执行文件名与包名对不上（改过名的版本）时，目录里只有一个就用它。
        try {
          final entries = await Directory(
            macOsDir,
          ).list(followLinks: false).toList();
          final files = entries.whereType<File>().toList();
          if (files.length == 1) return files.first.path;
        } catch (_) {
          // 读不了就算了，后面还有固定路径和 PATH 两条线索。
        }
      }
    }
    return null;
  }

  // ------------------------------------------------------------------ Linux

  static Future<String?> _fromFlatpak(PlayerCandidate candidate) async {
    if (!Platform.isLinux || candidate.flatpakIds.isEmpty) return null;
    final home = Platform.environment['HOME'];
    final exportDirs = <String>[
      '/var/lib/flatpak/exports/bin',
      if (home != null && home.isNotEmpty)
        p.join(home, '.local', 'share', 'flatpak', 'exports', 'bin'),
    ];
    for (final dir in exportDirs) {
      for (final id in candidate.flatpakIds) {
        final path = p.join(dir, id);
        if (await File(path).exists()) return path;
      }
    }
    return null;
  }

  // ------------------------------------------------------- 固定路径 / PATH

  static Future<String?> _fromAbsolutePaths(PlayerCandidate candidate) async {
    for (final raw in candidate.absolutePaths) {
      final path = _expandWindowsEnv(raw);
      // 环境变量没展开成功（这台机器上没这个变量）就跳过，别拿字面量去 stat。
      if (Platform.isWindows && path.contains('%')) continue;
      if (await File(path).exists()) return path;
    }
    return null;
  }

  /// `PATH` 查找：winget / scoop / choco / homebrew / 各家包管理器装的东西位置
  /// 千奇百怪，但它们**一定**在 PATH 上——这条线索专收这一类。
  static Future<String?> _fromPathEnv(
    PlayerCandidate candidate,
    _ProbeContext ctx,
  ) async {
    for (final dir in ctx.pathDirectories) {
      for (final exe in candidate.executableNames) {
        final path = p.join(dir, exe);
        if (await File(path).exists()) return path;
      }
    }
    return null;
  }

  // ------------------------------------------------------------------ 工具

  /// 注册表里的路径经常带引号、带 `%ProgramFiles%`、或者写成
  /// `"C:\...\x.exe" --flag` 的命令行形式。统一收拾成一个裸路径。
  @visibleForTesting
  static String? normalizeRegistryPathForTest(String? raw) =>
      _normalizeRegistryPath(raw);

  static String? _normalizeRegistryPath(String? raw) {
    if (raw == null) return null;
    var value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('"')) {
      final closing = value.indexOf('"', 1);
      value = closing > 0 ? value.substring(1, closing) : value.substring(1);
    }
    value = _expandWindowsEnv(value).trim();
    if (value.isEmpty || (Platform.isWindows && value.contains('%'))) {
      return null;
    }
    return value;
  }

  static String _expandWindowsEnv(String path) {
    if (!Platform.isWindows) return path;
    return path.replaceAllMapped(RegExp(r'%([^%]+)%'), (match) {
      final name = match.group(1)!;
      final direct = Platform.environment[name];
      if (direct != null) return direct;
      // 环境变量名在 Windows 上大小写不敏感，而 Platform.environment 这个 Map
      // 是敏感的，所以自己再兜一层。
      for (final entry in Platform.environment.entries) {
        if (entry.key.toLowerCase() == name.toLowerCase()) return entry.value;
      }
      return match.group(0)!;
    });
  }

  static String _canonical(String path) =>
      Platform.isWindows ? path.toLowerCase().replaceAll('/', r'\') : path;

  /// 读一个注册表字符串值；键 / 值不存在时返回 null（而不是把异常抛出去）。
  static String? _readRegistryString(
    RegistryHive hive,
    String keyPath,
    String valueName,
  ) {
    if (!Platform.isWindows) return null;
    RegistryKey? key;
    try {
      key = Registry.openPath(hive, path: keyPath);
      return key.getStringValue(valueName, expandPaths: true);
    } catch (_) {
      return null;
    } finally {
      try {
        key?.close();
      } catch (_) {}
    }
  }

  @visibleForTesting
  static List<String> parseSteamLibraryPaths(String vdf) {
    final matches = RegExp(r'"path"\s*"((?:[^"\\]|\\.)*)"').allMatches(vdf);
    return matches
        .map((m) => m.group(1)!.replaceAll(r'\\', r'\'))
        .where((path) => path.isNotEmpty)
        .toList();
  }
}

/// 一次探测里所有候选**共用**的索引。
///
/// 卸载项有好几百条、Steam 库要读 vdf、PATH 要切分——每条候选各建一遍是十几倍
/// 的无谓开销。统一建一次，之后只是查表。
class _ProbeContext {
  _ProbeContext({
    required this.steamLibraries,
    required this.metaLibraries,
    required this.uninstallLocations,
    required this.pathDirectories,
  });

  final List<String> steamLibraries;
  final List<String> metaLibraries;

  /// 小写 DisplayName → InstallLocation。
  final Map<String, String> uninstallLocations;

  final List<String> pathDirectories;

  static Future<_ProbeContext> build() async {
    return _ProbeContext(
      steamLibraries: Platform.isWindows
          ? await _steamLibraries()
          : const <String>[],
      metaLibraries: Platform.isWindows ? _metaLibraries() : const <String>[],
      uninstallLocations: Platform.isWindows
          ? await _uninstallLocations()
          : const <String, String>{},
      pathDirectories: _pathDirectories(),
    );
  }

  static List<String> _pathDirectories() {
    final raw = Platform.environment['PATH'] ?? Platform.environment['Path'];
    if (raw == null || raw.isEmpty) return const [];
    return raw
        .split(Platform.isWindows ? ';' : ':')
        .map((dir) => dir.trim().replaceAll('"', ''))
        .where((dir) => dir.isNotEmpty)
        .toList();
  }

  static Future<List<String>> _steamLibraries() async {
    final roots = <String>{};
    // 注册表里的 Steam 安装路径最准（换过盘、装在非默认位置都认得），
    // Program Files 那两条只是兜底。
    for (final hive in [RegistryHive.currentUser, RegistryHive.localMachine]) {
      for (final keyPath in [
        r'SOFTWARE\Valve\Steam',
        r'SOFTWARE\WOW6432Node\Valve\Steam',
      ]) {
        final path =
            DesktopPlayerProbe._readRegistryString(hive, keyPath, 'SteamPath') ??
            DesktopPlayerProbe._readRegistryString(hive, keyPath, 'InstallPath');
        if (path != null && path.isNotEmpty) {
          roots.add(path.replaceAll('/', r'\'));
        }
      }
    }
    for (final base in [
      Platform.environment['ProgramFiles(x86)'],
      Platform.environment['ProgramFiles'],
    ]) {
      if (base == null || base.isEmpty) continue;
      final steamRoot = '$base\\Steam';
      if (await Directory(steamRoot).exists()) roots.add(steamRoot);
    }

    final libraries = <String>{...roots};
    for (final root in roots) {
      final vdf = File('$root\\steamapps\\libraryfolders.vdf');
      if (!await vdf.exists()) continue;
      try {
        libraries.addAll(
          DesktopPlayerProbe.parseSteamLibraryPaths(await vdf.readAsString()),
        );
      } catch (e) {
        LogUtils.w('读取 Steam 库列表失败: $e', 'DesktopPlayer');
      }
    }
    return libraries.toList();
  }

  /// Meta / Oculus 的软件库。多盘用户会把库挪到别的盘，注册表里记着全部。
  static List<String> _metaLibraries() {
    const librariesKey = r'SOFTWARE\Oculus VR, LLC\Oculus\Libraries';
    final libraries = <String>{};
    RegistryKey? root;
    try {
      root = Registry.openPath(RegistryHive.currentUser, path: librariesKey);
      for (final name in root.subkeyNames) {
        final path = DesktopPlayerProbe._readRegistryString(
          RegistryHive.currentUser,
          '$librariesKey\\$name',
          'OriginalPath',
        );
        if (path != null && path.isNotEmpty) libraries.add(path);
      }
    } catch (_) {
      // 没装 Oculus 软件就没这个键，是正常情况。
    } finally {
      try {
        root?.close();
      } catch (_) {}
    }

    final programFiles = Platform.environment['ProgramFiles'];
    if (programFiles != null && programFiles.isNotEmpty) {
      libraries.add('$programFiles\\Oculus');
    }
    return libraries.toList();
  }

  /// 扫一遍「程序和功能」的卸载项，建 DisplayName → InstallLocation 的表。
  ///
  /// 三个视图都要扫：64 位、32 位（WOW6432Node）、当前用户——免管理员安装的
  /// 软件只登记在 HKCU，DeoVR、mpv.net 这类都可能走那条。
  static Future<Map<String, String>> _uninstallLocations() async {
    const roots = <(RegistryHive, String)>[
      (
        RegistryHive.localMachine,
        r'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
      ),
      (
        RegistryHive.localMachine,
        r'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
      ),
      (
        RegistryHive.currentUser,
        r'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
      ),
    ];

    final result = <String, String>{};
    var scanned = 0;
    for (final (hive, rootPath) in roots) {
      RegistryKey? root;
      List<String> names;
      try {
        root = Registry.openPath(hive, path: rootPath);
        names = root.subkeyNames.toList();
      } catch (_) {
        continue;
      } finally {
        try {
          root?.close();
        } catch (_) {}
      }

      for (final name in names) {
        // ⛔ 这一趟是同步 FFI，几百条连着跑会把这一帧整个占住（弹窗上的转圈会
        // 僵住不动）。每 60 条让一次事件循环，代价是几微秒，换来转圈是转的。
        if (++scanned % 60 == 0) await Future<void>.delayed(Duration.zero);

        final keyPath = '$rootPath\\$name';
        final displayName = DesktopPlayerProbe._readRegistryString(
          hive,
          keyPath,
          'DisplayName',
        );
        if (displayName == null || displayName.isEmpty) continue;
        final location = DesktopPlayerProbe._readRegistryString(
          hive,
          keyPath,
          'InstallLocation',
        );
        if (location == null || location.trim().isEmpty) continue;
        result.putIfAbsent(displayName.toLowerCase(), () => location.trim());
      }
    }
    LogUtils.d('扫描到 ${result.length} 条带安装目录的卸载项', 'DesktopPlayer');
    return result;
  }
}
