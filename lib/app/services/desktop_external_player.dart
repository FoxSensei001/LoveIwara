import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 桌面端配置的一个外部播放器。
///
/// PCVR 的播放器（HereSphere、DeoVR 桌面版、Whirligig、SKYBOX PC 等）几乎都不是
/// 系统默认关联程序，「用系统默认播放器打开」对这些用户等于没用；而它们全都支持
/// 从命令行接一个文件路径或 URL。所以桌面端的转交走「指定可执行文件 + 参数模板」。
@immutable
class DesktopPlayerEntry {
  const DesktopPlayerEntry({
    required this.id,
    required this.name,
    required this.executablePath,
    this.argumentTemplate = defaultArgumentTemplate,
    this.autoDetected = false,
  });

  /// 参数模板里代表「要播的东西」的占位符；[argumentTemplate] 默认就是它本身，
  /// 即「把路径/URL 当唯一参数传过去」——绝大多数播放器都是这个用法。
  static const String inputPlaceholder = '{input}';
  static const String defaultArgumentTemplate = inputPlaceholder;

  final String id;
  final String name;
  final String executablePath;
  final String argumentTemplate;

  /// 是否由自动探测填进来的（用户手动加的为 false）。仅用于 UI 标注。
  final bool autoDetected;

  DesktopPlayerEntry copyWith({
    String? name,
    String? executablePath,
    String? argumentTemplate,
  }) {
    return DesktopPlayerEntry(
      id: id,
      name: name ?? this.name,
      executablePath: executablePath ?? this.executablePath,
      argumentTemplate: argumentTemplate ?? this.argumentTemplate,
      autoDetected: autoDetected,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'executablePath': executablePath,
    'argumentTemplate': argumentTemplate,
    'autoDetected': autoDetected,
  };

  static DesktopPlayerEntry? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final executablePath = json['executablePath'];
    if (id is! String || id.isEmpty) return null;
    if (name is! String || name.isEmpty) return null;
    if (executablePath is! String || executablePath.isEmpty) return null;
    final template = json['argumentTemplate'];
    return DesktopPlayerEntry(
      id: id,
      name: name,
      executablePath: executablePath,
      argumentTemplate: template is String && template.isNotEmpty
          ? template
          : defaultArgumentTemplate,
      autoDetected: json['autoDetected'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DesktopPlayerEntry &&
          other.id == id &&
          other.name == name &&
          other.executablePath == executablePath &&
          other.argumentTemplate == argumentTemplate;

  @override
  int get hashCode => Object.hash(id, name, executablePath, argumentTemplate);
}

/// 外部播放器列表的持久化（存在 [ConfigKey.EXTERNAL_PLAYERS_JSON] 里的 JSON 数组）。
class DesktopPlayerStore {
  /// 解析一份 JSON 文本；坏数据一律当成空列表，不让配置损坏把设置页整块打挂。
  ///
  /// 公开是因为设置页要在 `Obx` 里直接吃配置项的 Rx 原文算数量——走 [load]
  /// 拿不到响应式更新。
  static List<DesktopPlayerEntry> decode(String raw) {
    if (raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => DesktopPlayerEntry.fromJson(e.cast<String, dynamic>()))
          .whereType<DesktopPlayerEntry>()
          .toList();
    } catch (e) {
      LogUtils.w('外部播放器配置解析失败，按空列表处理: $e', 'DesktopPlayer');
      return const [];
    }
  }

  @visibleForTesting
  static String encode(List<DesktopPlayerEntry> entries) =>
      jsonEncode(entries.map((e) => e.toJson()).toList());

  static List<DesktopPlayerEntry> load() {
    try {
      final configService = Get.find<ConfigService>();
      return decode(configService[ConfigKey.EXTERNAL_PLAYERS_JSON] as String);
    } catch (e) {
      LogUtils.w('读取外部播放器配置失败: $e', 'DesktopPlayer');
      return const [];
    }
  }

  static Future<void> save(List<DesktopPlayerEntry> entries) async {
    final configService = Get.find<ConfigService>();
    configService[ConfigKey.EXTERNAL_PLAYERS_JSON] = encode(entries);
  }
}

/// 按参数模板拉起外部播放器。
class DesktopPlayerLauncher {
  /// 把参数模板展开成实参列表。
  ///
  /// 按空白切分，双引号内的空白不切（`--title "My Video"` 是两个参数）；
  /// 占位符可以嵌在参数里（`--url={input}` 展开成一个参数）。模板里没写占位符
  /// 时把输入补在最后——用户少写一个 `{input}` 不该导致播放器空手启动。
  @visibleForTesting
  static List<String> buildArguments(String template, String input) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    var hasToken = false;

    void flush() {
      if (hasToken) {
        tokens.add(buffer.toString());
        buffer.clear();
        hasToken = false;
      }
    }

    for (final rune in template.runes) {
      final char = String.fromCharCode(rune);
      if (char == '"') {
        inQuotes = !inQuotes;
        hasToken = true;
        continue;
      }
      if (!inQuotes && (char == ' ' || char == '\t')) {
        flush();
        continue;
      }
      buffer.write(char);
      hasToken = true;
    }
    flush();

    final substituted = tokens
        .map(
          (token) => token.replaceAll(DesktopPlayerEntry.inputPlaceholder, input),
        )
        .toList();

    if (!template.contains(DesktopPlayerEntry.inputPlaceholder)) {
      substituted.add(input);
    }
    return substituted;
  }

  /// 空手拉起播放器，只用来验证「这个可执行文件能不能跑起来」。
  static Future<bool> launchBare(DesktopPlayerEntry entry) async {
    if (!await File(entry.executablePath).exists()) return false;
    try {
      await Process.start(
        entry.executablePath,
        const [],
        mode: ProcessStartMode.detached,
      );
      return true;
    } catch (e, s) {
      LogUtils.e('测试启动外部播放器失败', tag: 'DesktopPlayer', error: e, stackTrace: s);
      return false;
    }
  }

  /// 拉起播放器。[input] 是本地文件绝对路径或在线直链。
  static Future<bool> launch(DesktopPlayerEntry entry, String input) async {
    if (!await File(entry.executablePath).exists()) {
      LogUtils.w('外部播放器不存在: ${entry.executablePath}', 'DesktopPlayer');
      return false;
    }
    try {
      final args = buildArguments(entry.argumentTemplate, input);
      // runInShell=false：路径里的空格/中文由 Process 自己转义，走 shell 反而会被
      // 二次解析。detached 让播放器脱离本进程，关掉 App 不会连带杀掉播放器。
      await Process.start(
        entry.executablePath,
        args,
        mode: ProcessStartMode.detached,
      );
      return true;
    } catch (e, s) {
      LogUtils.e('拉起外部播放器失败', tag: 'DesktopPlayer', error: e, stackTrace: s);
      return false;
    }
  }
}

/// 一个待探测的播放器候选。
@immutable
class _PlayerCandidate {
  const _PlayerCandidate({
    required this.id,
    required this.name,
    required this.steamDirectory,
    required this.executableName,
    this.absolutePaths = const [],
  });

  final String id;
  final String name;

  /// Steam 安装目录名（`steamapps/common/<这里>`）；非 Steam 程序传 null。
  final String? steamDirectory;
  final String executableName;

  /// 不走 Steam 的固定安装路径候选（可含 `%ENV%` 形式的环境变量）。
  final List<String> absolutePaths;
}

/// 自动探测本机已装的常见 PCVR / 桌面播放器。
///
/// ⚠️ 候选表是尽力而为：安装目录名和可执行文件名来自这些软件的常见安装形态，
/// 没法在开发机上逐个验证。探测只会「把磁盘上真实存在的文件」加进来，猜错的条目
/// 落地就是探不到，不会产生错误配置——所以手动添加永远是兜底的正路。
class DesktopPlayerProbe {
  static const List<_PlayerCandidate> _windowsCandidates = [
    _PlayerCandidate(
      id: 'heresphere',
      name: 'HereSphere',
      steamDirectory: 'HereSphere',
      executableName: 'HereSphere.exe',
    ),
    _PlayerCandidate(
      id: 'deovr',
      name: 'DeoVR',
      steamDirectory: 'DeoVR Video Player',
      executableName: 'DeoVR.exe',
    ),
    _PlayerCandidate(
      id: 'whirligig',
      name: 'Whirligig',
      steamDirectory: 'Whirligig',
      executableName: 'Whirligig.exe',
    ),
    _PlayerCandidate(
      id: 'simple_vr',
      name: 'Simple VR Video Player',
      steamDirectory: 'Simple VR Video Player',
      executableName: 'Simple VR Video Player.exe',
    ),
    _PlayerCandidate(
      id: 'skybox_pc',
      name: 'SKYBOX VR',
      steamDirectory: 'SKYBOX VR Video Player',
      executableName: 'SKYBOX.exe',
    ),
    _PlayerCandidate(
      id: 'potplayer',
      name: 'PotPlayer',
      steamDirectory: null,
      executableName: 'PotPlayerMini64.exe',
      absolutePaths: [
        r'%ProgramFiles%\DAUM\PotPlayer\PotPlayerMini64.exe',
        r'%ProgramFiles(x86)%\DAUM\PotPlayer\PotPlayerMini.exe',
      ],
    ),
    _PlayerCandidate(
      id: 'vlc',
      name: 'VLC',
      steamDirectory: null,
      executableName: 'vlc.exe',
      absolutePaths: [
        r'%ProgramFiles%\VideoLAN\VLC\vlc.exe',
        r'%ProgramFiles(x86)%\VideoLAN\VLC\vlc.exe',
      ],
    ),
    _PlayerCandidate(
      id: 'mpv',
      name: 'mpv',
      steamDirectory: null,
      executableName: 'mpv.exe',
      absolutePaths: [r'%ProgramFiles%\mpv\mpv.exe'],
    ),
  ];

  static const List<_PlayerCandidate> _macCandidates = [
    _PlayerCandidate(
      id: 'iina',
      name: 'IINA',
      steamDirectory: null,
      executableName: 'IINA',
      absolutePaths: ['/Applications/IINA.app/Contents/MacOS/IINA'],
    ),
    _PlayerCandidate(
      id: 'vlc',
      name: 'VLC',
      steamDirectory: null,
      executableName: 'VLC',
      absolutePaths: ['/Applications/VLC.app/Contents/MacOS/VLC'],
    ),
    _PlayerCandidate(
      id: 'mpv',
      name: 'mpv',
      steamDirectory: null,
      executableName: 'mpv',
      absolutePaths: [
        '/Applications/mpv.app/Contents/MacOS/mpv',
        '/opt/homebrew/bin/mpv',
        '/usr/local/bin/mpv',
      ],
    ),
  ];

  static const List<_PlayerCandidate> _linuxCandidates = [
    _PlayerCandidate(
      id: 'vlc',
      name: 'VLC',
      steamDirectory: null,
      executableName: 'vlc',
      absolutePaths: ['/usr/bin/vlc', '/usr/local/bin/vlc'],
    ),
    _PlayerCandidate(
      id: 'mpv',
      name: 'mpv',
      steamDirectory: null,
      executableName: 'mpv',
      absolutePaths: ['/usr/bin/mpv', '/usr/local/bin/mpv'],
    ),
    _PlayerCandidate(
      id: 'celluloid',
      name: 'Celluloid',
      steamDirectory: null,
      executableName: 'celluloid',
      absolutePaths: ['/usr/bin/celluloid'],
    ),
  ];

  /// 从 `libraryfolders.vdf` 里抠出所有 Steam 库根目录。
  ///
  /// 游戏不一定装在 Steam 主目录：多盘用户的库在 D:/E: 是常态，只认
  /// `Program Files (x86)\Steam` 会把他们全漏掉。
  @visibleForTesting
  static List<String> parseSteamLibraryPaths(String vdf) {
    final matches = RegExp(
      r'"path"\s*"((?:[^"\\]|\\.)*)"',
    ).allMatches(vdf);
    return matches
        .map((m) => m.group(1)!.replaceAll(r'\\', r'\'))
        .where((p) => p.isNotEmpty)
        .toList();
  }

  static String _expandWindowsEnv(String path) {
    return path.replaceAllMapped(RegExp(r'%([^%]+)%'), (match) {
      final name = match.group(1)!;
      return Platform.environment[name] ?? match.group(0)!;
    });
  }

  static Future<List<String>> _steamLibraries() async {
    final roots = <String>[];
    final programFilesX86 = Platform.environment['ProgramFiles(x86)'];
    final programFiles = Platform.environment['ProgramFiles'];
    for (final base in [programFilesX86, programFiles]) {
      if (base == null || base.isEmpty) continue;
      final steamRoot = '$base\\Steam';
      if (await Directory(steamRoot).exists()) roots.add(steamRoot);
    }

    final libraries = <String>{...roots};
    for (final root in roots) {
      final vdf = File('$root\\steamapps\\libraryfolders.vdf');
      if (!await vdf.exists()) continue;
      try {
        libraries.addAll(parseSteamLibraryPaths(await vdf.readAsString()));
      } catch (e) {
        LogUtils.w('读取 Steam 库列表失败: $e', 'DesktopPlayer');
      }
    }
    return libraries.toList();
  }

  /// 探测本机装了哪些候选播放器。[existing] 里已有的可执行文件不重复加。
  static Future<List<DesktopPlayerEntry>> detect({
    List<DesktopPlayerEntry> existing = const [],
  }) async {
    if (!GetPlatform.isDesktop) return const [];

    final List<_PlayerCandidate> candidates;
    if (Platform.isWindows) {
      candidates = _windowsCandidates;
    } else if (Platform.isMacOS) {
      candidates = _macCandidates;
    } else {
      candidates = _linuxCandidates;
    }

    final steamLibraries = Platform.isWindows
        ? await _steamLibraries()
        : const <String>[];
    final known = existing
        .map((e) => e.executablePath.toLowerCase())
        .toSet();
    final found = <DesktopPlayerEntry>[];

    for (final candidate in candidates) {
      final paths = <String>[
        for (final library in steamLibraries)
          if (candidate.steamDirectory != null)
            '$library\\steamapps\\common\\${candidate.steamDirectory}\\${candidate.executableName}',
        for (final path in candidate.absolutePaths)
          Platform.isWindows ? _expandWindowsEnv(path) : path,
      ];

      for (final path in paths) {
        if (known.contains(path.toLowerCase())) break;
        if (!await File(path).exists()) continue;
        known.add(path.toLowerCase());
        found.add(
          DesktopPlayerEntry(
            id: '${candidate.id}_${found.length}',
            name: candidate.name,
            executablePath: path,
            autoDetected: true,
          ),
        );
        break;
      }
    }

    return found;
  }
}
