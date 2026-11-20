import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/frame_interp/frame_interp_bindings.dart';
import 'package:i_iwara/app/services/frame_interp/system_vulkan_loader.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 补帧组件在这份安装里的状态。
enum FrameInterpComponentStatus {
  /// 这个平台没有补帧引擎，或这份安装里没带。功能入口应当整个不露。
  unsupported,

  /// 带着，能用。
  ready,

  /// 带着一份，但清单读不懂或和应用对不上——打包出了岔子才会这样。
  incompatible,
}

/// 加载引擎所需的全部路径。全是字符串，方便整个丢进后台 isolate。
class FrameInterpLibrarySpec {
  const FrameInterpLibrarySpec({
    required this.directory,
    required this.preload,
    required this.library,
    required this.modelDirectory,
  });

  final String directory;

  /// 依赖库的文件名，按依赖顺序（被依赖的在前）。
  final List<String> preload;
  final String library;
  final String modelDirectory;
}

/// 一次加载得到的引擎句柄。
class FrameInterpLibrary {
  FrameInterpLibrary._(this.bindings, this._handles);

  final FrameInterpBindings bindings;
  final List<DynamicLibrary> _handles;

  /// 按依赖顺序逐个加载。
  ///
  /// 组件放在应用目录下的一个子目录里，而 dart:ffi 打开一只动态库时，系统只在
  /// 应用目录本身和系统目录里找它的依赖，不会去「这只库自己所在的目录」找。
  /// 所以先把依赖一个个按完整路径加载进进程——已经在进程里的模块按名字就能
  /// 对上——最后再开引擎本体。
  ///
  /// 系统的 Vulkan 加载器也这样先装进来，道理相同、方向相反：要防的是 ncnn
  /// 按名字找到应用目录里那份旧的（见 [SystemVulkanLoader]）。
  factory FrameInterpLibrary.open(FrameInterpLibrarySpec spec) {
    final handles = <DynamicLibrary>[];
    try {
      final vulkan = SystemVulkanLoader.pin();
      if (vulkan != null) handles.add(vulkan);
      for (final name in spec.preload) {
        handles.add(DynamicLibrary.open(p.join(spec.directory, name)));
      }
      final engine = DynamicLibrary.open(p.join(spec.directory, spec.library));
      handles.add(engine);
      return FrameInterpLibrary._(FrameInterpBindings(engine), handles);
    } catch (_) {
      for (final handle in handles.reversed) {
        handle.close();
      }
      rethrow;
    }
  }

  void close() {
    for (final handle in _handles.reversed) {
      handle.close();
    }
    _handles.clear();
  }
}

class FrameInterpComponentException implements Exception {
  FrameInterpComponentException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 组件在一份安装里的摆法：清单在哪、库在哪、模型相对谁解析。
///
/// 桌面上三样都是同一个目录；安卓上库被系统拆进了原生库目录，模型得另找地方
/// 放；苹果上库是 framework，清单和模型在 framework 的资源目录里。清单的格式
/// 和校验规则三处一样，见 [FrameInterpComponent.readLayout]。
class FrameInterpComponentLayout {
  const FrameInterpComponentLayout({
    required this.manifest,
    required this.libraryDirectory,
    required this.modelRoot,
  });

  /// 桌面的摆法：组件目录里平铺着库、清单和 models/。
  FrameInterpComponentLayout.flat(Directory directory)
    : manifest = File(p.join(directory.path, 'manifest.json')),
      libraryDirectory = directory,
      modelRoot = directory;

  final File manifest;

  /// 清单里 library / preload 的文件都在这个目录下。
  final Directory libraryDirectory;

  /// 清单里的 model 相对它解析。
  final Directory modelRoot;
}

/// 补帧组件（引擎库 + 裁剪过的 FFmpeg + ncnn + 模型）的定位与加载。
///
/// 组件随安装包分发，各平台的打包脚本负责把它放到下面这些位置。这里只做两件
/// 事：认出它在不在、能不能用；以及按清单把它加载进来。
///
/// | 平台          | 位置                                                       |
/// |---------------|------------------------------------------------------------|
/// | Windows       | 可执行文件旁的 `frame_interp/`                             |
/// | Linux         | 可执行文件旁的 `lib/frame_interp/`                         |
/// | Android arm64 | APK 的原生库目录（清单、模型改名成 `libfi_*.so` 混在里面） |
/// | macOS / iOS   | 应用 Frameworks 里的 `FrameInterp.framework`               |
///
/// 之所以要单独隔开、带一份清单，而不是把那几只库直接平铺在应用目录里：
/// 引擎带着自己的一份 FFmpeg，播放器（libmpv）里也有一份，两份的文件名和
/// 导出符号都可能撞；隔开放、按完整路径加载，谁也碰不着谁。Windows 以外的平台
/// 上，我们这份 FFmpeg 的库名另外带了 `_fi` 后缀。
class FrameInterpComponent {
  static const String _tag = 'FrameInterpComponent';

  /// 组件在应用目录下的子目录名（Windows / Linux）。
  static const String bundleDirectoryName = 'frame_interp';

  /// 苹果平台上组件所在的 framework。
  static const String appleFrameworkName = 'FrameInterp';

  /// 安卓上清单和模型文件在 APK 里的名字。原生库目录只收 `lib*.so`，而只有
  /// 原生库能按 ABI 拆进各自的 APK——放进 assets 的话，32 位设备的安装包也得
  /// 背着这十几兆，可那上面补帧根本不露出来。
  static const String androidManifestName = 'libfi_manifest.so';
  static const Map<String, String> androidModelFiles = {
    'flownet.param': 'libfi_model_flownet_param.so',
    'flownet.bin': 'libfi_model_flownet_bin.so',
  };

  static const MethodChannel _androidChannel = MethodChannel(
    'i_iwara/frame_interp',
  );

  /// 调试用：直接指向一个组件目录（native/frame_interp 的 install 产物），
  /// 免得每改一次引擎都要重新走一遍应用的打包。用
  /// `--dart-define=FRAME_INTERP_COMPONENT_DIR=...` 或同名环境变量传。
  /// 只对桌面平台有意义。
  ///
  /// 只在 debug 构建里生效：别的构建不该能被一个环境变量指去加载任意目录里
  /// 的原生代码。
  static const String _debugDirectoryDefine = String.fromEnvironment(
    'FRAME_INTERP_COMPONENT_DIR',
  );

  static String? get debugDirectory {
    if (!kDebugMode) return null;
    if (_debugDirectoryDefine.isNotEmpty) return _debugDirectoryDefine;
    final fromEnv = Platform.environment['FRAME_INTERP_COMPONENT_DIR'];
    return fromEnv == null || fromEnv.isEmpty ? null : fromEnv;
  }

  /// 当前平台在组件清单里的名字；没有对应构建的平台返回 null，补帧入口整个
  /// 不露。
  ///
  /// 安卓只有 arm64-v8a 的构建：32 位设备（以及装了 32 位安装包的 64 位设备）
  /// 的显卡本来也跑不动。macOS 的 framework 是 arm64 + x86_64 的通用二进制。
  static String? get platformKey {
    final abi = Abi.current();
    if (Platform.isWindows && abi == Abi.windowsX64) return 'windows-x64';
    if (Platform.isLinux && abi == Abi.linuxX64) return 'linux-x64';
    if (Platform.isAndroid && abi == Abi.androidArm64) return 'android-arm64';
    if (Platform.isMacOS && (abi == Abi.macosArm64 || abi == Abi.macosX64)) {
      return 'macos';
    }
    if (Platform.isIOS && abi == Abi.iosArm64) return 'ios-arm64';
    return null;
  }

  /// 桌面平台上组件目录应当在的位置。
  static Directory get bundleDirectory {
    final debug = debugDirectory;
    if (debug != null) return Directory(debug);
    final executableDir = p.dirname(Platform.resolvedExecutable);
    if (Platform.isLinux) {
      return Directory(p.join(executableDir, 'lib', bundleDirectoryName));
    }
    return Directory(p.join(executableDir, bundleDirectoryName));
  }

  /// 苹果平台上 framework 的位置。
  static Directory get _appleFramework {
    final executableDir = p.dirname(Platform.resolvedExecutable);
    final frameworks = Platform.isMacOS
        ? p.join(p.dirname(executableDir), 'Frameworks')
        : p.join(executableDir, 'Frameworks');
    return Directory(p.join(frameworks, '$appleFrameworkName.framework'));
  }

  /// framework 的资源目录：清单在哪儿，资源目录就是哪儿。macOS 的 framework 带
  /// 版本目录，资源在 `Resources/`（指向 Versions/A/Resources 的链接）里；iOS 的
  /// 是扁平的，资源一般就在根上。
  static Future<Directory> _appleResources(Directory framework) async {
    final nested = Directory(p.join(framework.path, 'Resources'));
    if (await File(p.join(nested.path, 'manifest.json')).exists()) {
      return nested;
    }
    return framework;
  }

  final Rx<FrameInterpComponentStatus> status =
      FrameInterpComponentStatus.unsupported.obs;

  FrameInterpLibrarySpec? _spec;
  FrameInterpLibrary? _library;

  /// 可用时的加载参数；否则为 null。
  FrameInterpLibrarySpec? get spec => _spec;

  bool get isReady => status.value == FrameInterpComponentStatus.ready;

  /// 看一眼这份安装里带没带组件。应用启动时调一次。
  Future<void> refresh() async {
    if (platformKey == null) {
      _spec = null;
      status.value = FrameInterpComponentStatus.unsupported;
      return;
    }
    try {
      final layout = await _locate();
      final result = layout == null
          ? (status: FrameInterpComponentStatus.unsupported, spec: null)
          : await readLayout(layout);
      _spec = result.spec;
      status.value = result.status;
    } catch (e) {
      LogUtils.w('定位补帧组件失败: $e', _tag);
      _spec = null;
      status.value = FrameInterpComponentStatus.incompatible;
    }
  }

  /// 按平台找到组件的摆法。这份安装里没带组件时返回 null。
  static Future<FrameInterpComponentLayout?> _locate() async {
    if (Platform.isAndroid) return _locateAndroid();
    if (Platform.isMacOS || Platform.isIOS) {
      final framework = _appleFramework;
      if (!await framework.exists()) return null;
      final resources = await _appleResources(framework);
      // 从真正的二进制所在的目录打开（macOS 上是 Versions/A/，根上那个只是链接）。
      // 引擎按 @loader_path 往上数目录去找旁边的 FFmpeg framework，从链接打开的话
      // 能不能找到，就得看 dyld 会不会先把链接解开——不赌这个。
      final binary = File(p.join(framework.path, appleFrameworkName));
      final libraryDirectory = await binary.exists()
          ? Directory(p.dirname(await binary.resolveSymbolicLinks()))
          : framework;
      return FrameInterpComponentLayout(
        manifest: File(p.join(resources.path, 'manifest.json')),
        libraryDirectory: libraryDirectory,
        modelRoot: resources,
      );
    }
    return FrameInterpComponentLayout.flat(bundleDirectory);
  }

  /// 安卓：库在系统给的原生库目录里；模型也在那儿，只是改了名。
  ///
  /// 引擎按 `<模型目录>/flownet.param` 这样的固定名字读模型，所以在应用自己的
  /// 目录里按原名建一组指过去的符号链接（建不了就拷一份）。应用每次更新后原生
  /// 库目录的路径都会变，所以每次启动都核对一遍、对不上就重建。
  static Future<FrameInterpComponentLayout?> _locateAndroid() async {
    final libDirPath = await _androidChannel.invokeMethod<String>(
      'nativeLibraryDir',
    );
    if (libDirPath == null || libDirPath.isEmpty) return null;
    final libDir = Directory(libDirPath);
    final manifest = File(p.join(libDir.path, androidManifestName));
    if (!await manifest.exists()) return null;

    final decoded = jsonDecode(await manifest.readAsString());
    final model = decoded is Map ? decoded['model'] : null;
    final support = await getApplicationSupportDirectory();
    final modelRoot = Directory(p.join(support.path, bundleDirectoryName));
    if (model is String) {
      final modelDir = p.normalize(p.join(modelRoot.path, model));
      // 越界的清单交给 readLayout 判 incompatible，这里不往外面建东西。
      if (p.isWithin(modelRoot.path, modelDir)) {
        await _linkAndroidModel(libDir, Directory(modelDir));
      }
    }
    return FrameInterpComponentLayout(
      manifest: manifest,
      libraryDirectory: libDir,
      modelRoot: modelRoot,
    );
  }

  static Future<void> _linkAndroidModel(
    Directory libDir,
    Directory modelDir,
  ) async {
    await modelDir.create(recursive: true);
    for (final entry in androidModelFiles.entries) {
      final source = File(p.join(libDir.path, entry.value));
      if (!await source.exists()) continue;
      final targetPath = p.join(modelDir.path, entry.key);
      final type = await FileSystemEntity.type(targetPath, followLinks: false);
      if (type == FileSystemEntityType.link) {
        if (await Link(targetPath).target() == source.path) continue;
        await Link(targetPath).delete();
      } else if (type == FileSystemEntityType.file) {
        // 上次是拷过来的：大小一样就当是同一份。
        if (await File(targetPath).length() == await source.length()) continue;
        await File(targetPath).delete();
      }
      try {
        await Link(targetPath).create(source.path);
      } on FileSystemException {
        await source.copy(targetPath);
      }
    }
  }

  /// 读一个桌面组件目录的清单，判断它能不能用。
  @visibleForTesting
  static Future<
    ({FrameInterpComponentStatus status, FrameInterpLibrarySpec? spec})
  >
  readManifest(Directory directory) =>
      readLayout(FrameInterpComponentLayout.flat(directory));

  /// 读清单，按它核对组件里的文件，判断能不能用。
  @visibleForTesting
  static Future<
    ({FrameInterpComponentStatus status, FrameInterpLibrarySpec? spec})
  >
  readLayout(FrameInterpComponentLayout layout) async {
    const incompatible = (
      status: FrameInterpComponentStatus.incompatible,
      spec: null,
    );
    if (!await layout.manifest.exists()) {
      return (status: FrameInterpComponentStatus.unsupported, spec: null);
    }
    try {
      final manifest =
          jsonDecode(await layout.manifest.readAsString())
              as Map<String, dynamic>;
      if (manifest['abi'] != FrameInterpBindings.expectedAbi ||
          manifest['platform'] != platformKey) {
        return incompatible;
      }
      final library = manifest['library'] as String;
      final preload = (manifest['preload'] as List).cast<String>();
      final model = manifest['model'] as String;
      final libDir = layout.libraryDirectory.path;
      // 清单里的名字会被拼进路径再交给系统加载，只认平铺在库目录里的纯文件名。
      for (final name in [library, ...preload]) {
        if (name != p.basename(name) || name.startsWith('.')) {
          return incompatible;
        }
      }
      final modelDirectory = p.normalize(p.join(layout.modelRoot.path, model));
      if (!p.isWithin(layout.modelRoot.path, modelDirectory)) {
        return incompatible;
      }
      for (final name in [library, ...preload]) {
        if (!await File(p.join(libDir, name)).exists()) return incompatible;
      }
      if (!await File(p.join(modelDirectory, 'flownet.bin')).exists()) {
        return incompatible;
      }
      return (
        status: FrameInterpComponentStatus.ready,
        spec: FrameInterpLibrarySpec(
          directory: libDir,
          preload: preload,
          library: library,
          modelDirectory: modelDirectory,
        ),
      );
    } catch (e) {
      LogUtils.w('补帧组件清单读不懂: $e', _tag);
      return incompatible;
    }
  }

  /// 在主 isolate 上加载引擎（只加载一次，之后一直开着）。
  /// 失败时把状态改成 incompatible 并抛出。
  FrameInterpLibrary load() {
    final existing = _library;
    if (existing != null) return existing;
    final spec = _spec;
    if (spec == null) {
      throw FrameInterpComponentException('component not available');
    }
    try {
      final library = FrameInterpLibrary.open(spec);
      final abi = library.bindings.abiVersion();
      if (abi != FrameInterpBindings.expectedAbi) {
        library.close();
        throw FrameInterpComponentException('abi mismatch: $abi');
      }
      _library = library;
      return library;
    } catch (e) {
      LogUtils.e('加载补帧组件失败: $e', tag: _tag, error: e);
      status.value = FrameInterpComponentStatus.incompatible;
      rethrow;
    }
  }
}
