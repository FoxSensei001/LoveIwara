import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:file_selector/file_selector.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/common/constants.dart';
import 'package:path/path.dart' as path;

/// 路径验证原因枚举
enum PathValidationReason {
  valid, // 路径有效
  noPermission, // 缺少权限
  noPublicDirectoryAccess, // 无公共目录访问权限
  cannotCreate, // 无法创建目录
  notWritable, // 不可写
  lowSpace, // 空间不足
  unknown, // 未知错误
}

/// 路径验证结果
class PathValidationResult {
  final bool isValid;
  final PathValidationReason reason;
  final String message;
  final bool canFix;
  final int? availableSpace;

  const PathValidationResult({
    required this.isValid,
    required this.reason,
    required this.message,
    required this.canFix,
    this.availableSpace,
  });

  /// 是否为警告（路径可用但有问题）
  bool get isWarning => isValid && reason != PathValidationReason.valid;
}

/// 下载路径服务
/// 统一管理下载路径和文件命名逻辑
class DownloadPathService extends GetxService {
  static DownloadPathService get to => Get.find();

  /// 原生文件处理通道（与 MainActivity 中的 FILE_HANDLER_CHANNEL 对应）
  static const MethodChannel _fileHandlerChannel = MethodChannel(
    CommonConstants.fileHandlerChannelName,
  );

  final ConfigService _configService = Get.find<ConfigService>();
  late FilenameTemplateService _filenameTemplateService;

  // ---------- 可观测状态（供 UI 直接订阅） ----------
  final Rxn<PathStatusInfo> _pathStatus = Rxn<PathStatusInfo>();
  final RxBool _pathStatusLoading = false.obs;

  final RxList<RecommendedPath> _recommendedPaths = <RecommendedPath>[].obs;
  final RxBool _recommendedPathsLoading = false.obs;

  final RxBool _storagePermissionGranted = false.obs;
  final RxBool _storagePermissionLoading = false.obs;

  final RxString _defaultDownloadPath = ''.obs;

  // 对外只读暴露
  PathStatusInfo? get pathStatus => _pathStatus.value;
  bool get isPathStatusLoading => _pathStatusLoading.value;

  List<RecommendedPath> get recommendedPaths => _recommendedPaths;
  bool get isRecommendedPathsLoading => _recommendedPathsLoading.value;

  bool get storagePermissionGranted => _storagePermissionGranted.value;
  bool get isStoragePermissionLoading => _storagePermissionLoading.value;

  String get defaultDownloadPath => _defaultDownloadPath.value;

  /// 获取翻译实例
  /// 注意：这里不依赖 BuildContext，以避免在应用初始化阶段（UI 树尚未就绪）
  /// 触发诸如 "GetRoot is not part of the tree" 之类的异常。
  slang.TranslationsSettingsDownloadSettingsEn get _t {
    // 直接使用全局的 t（Method A），与当前 LocaleSettings 同步，
    // 不需要依赖 Get.context 或任何 Widget 树。
    return slang.t.settings.downloadSettings;
  }

  @override
  void onInit() {
    super.onInit();
    // 确保文件命名模板服务已初始化
    if (!Get.isRegistered<FilenameTemplateService>()) {
      Get.put(FilenameTemplateService());
    }
    _filenameTemplateService = Get.find<FilenameTemplateService>();

    // 初始化异步状态
    Future.microtask(() async {
      await _refreshResolvedPackageName();
      await _refreshPermissionStatus();
      _defaultDownloadPath.value = await getDefaultDownloadPath();
      await refreshPathStatus();
      await loadRecommendedPathsReactive();
    });
  }

  static String _comparisonPath(String rawPath) {
    final normalized = path.normalize(path.absolute(rawPath));
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }

  static bool isPathInsideBase(String basePath, String candidatePath) {
    final base = _comparisonPath(basePath);
    final candidate = _comparisonPath(candidatePath);
    if (candidate == base) return true;

    final baseWithSeparator = base.endsWith(path.separator)
        ? base
        : '$base${path.separator}';
    return candidate.startsWith(baseWithSeparator);
  }

  static String safeJoinUnderBase(String basePath, List<String> pathSegments) {
    final candidate = path.normalize(path.joinAll([basePath, ...pathSegments]));
    if (!isPathInsideBase(basePath, candidate)) {
      throw ArgumentError.value(candidate, 'pathSegments', '下载路径不能位于基础下载目录之外');
    }
    return candidate;
  }

  static String _appendNumericSuffix(
    String originalPath,
    int suffix, {
    required bool isDirectory,
  }) {
    final directory = path.dirname(originalPath);
    final basename = path.basename(originalPath);

    if (isDirectory) {
      return path.join(directory, '$basename ($suffix)');
    }

    final extension = path.extension(basename);
    final nameWithoutExtension = path.basenameWithoutExtension(basename);
    return path.join(directory, '$nameWithoutExtension ($suffix)$extension');
  }

  /// 返回一个没有被文件系统或下载任务占用的路径。
  ///
  /// [isReserved] 用于把数据库中尚未落盘的任务也纳入冲突检测。
  static Future<String> resolveAvailablePath(
    String desiredPath, {
    required bool isDirectory,
    FutureOr<bool> Function(String candidate)? isReserved,
    int maxAttempts = 100,
  }) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final candidate = attempt == 0
          ? desiredPath
          : _appendNumericSuffix(
              desiredPath,
              attempt,
              isDirectory: isDirectory,
            );

      final fileSystemType = await FileSystemEntity.type(candidate);
      final existsOnDisk = fileSystemType != FileSystemEntityType.notFound;
      final reserved = await (isReserved?.call(candidate) ?? false);
      if (!existsOnDisk && !reserved) {
        return candidate;
      }
    }

    throw StateError('无法生成未占用的下载路径: $desiredPath');
  }

  /// 获取视频下载路径
  Future<String?> getVideoDownloadPath({
    required Video video,
    required String quality,
    String? downloadUrl,
  }) async {
    try {
      // 生成文件名
      final template =
          _configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String;
      LogUtils.d('使用文件命名模板: $template', 'DownloadPathService');

      final filename = _filenameTemplateService.generateVideoFilename(
        template: template,
        video: video,
        quality: quality,
        originalFilename: downloadUrl != null
            ? _extractFilenameFromUrl(downloadUrl)
            : null,
      );
      LogUtils.d('生成的文件名: $filename', 'DownloadPathService');

      final isCustomPathEnabled =
          _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
      final customPath =
          _configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;
      LogUtils.d(
        '自定义路径启用状态: $isCustomPathEnabled, 自定义路径: $customPath',
        'DownloadPathService',
      );

      if (GetPlatform.isDesktop && !isCustomPathEnabled) {
        // 桌面平台且未启用自定义路径：让用户选择保存位置
        final result = await getSaveLocation(
          suggestedName: filename,
          acceptedTypeGroups: [
            const XTypeGroup(label: 'MP4 Video', extensions: ['mp4']),
          ],
        );
        return result?.path;
      } else {
        // 移动平台或桌面端启用自定义路径：使用配置的路径
        final basePath = await _getBasePath('');
        return safeJoinUnderBase(basePath, [filename]);
      }
    } catch (e) {
      LogUtils.e('获取视频下载路径失败', tag: 'DownloadPathService', error: e);
      return null;
    }
  }

  /// 获取视频批量下载路径（不弹出对话框，直接使用默认路径）
  /// 用于批量下载场景，避免每个视频都弹出保存对话框
  Future<String?> getVideoDownloadPathForBatch({
    required Video video,
    required String quality,
    String? downloadUrl,
  }) async {
    try {
      // 生成文件名
      final template =
          _configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String;
      LogUtils.d('批量下载使用文件命名模板: $template', 'DownloadPathService');

      final filename = _filenameTemplateService.generateVideoFilename(
        template: template,
        video: video,
        quality: quality,
        originalFilename: downloadUrl != null
            ? _extractFilenameFromUrl(downloadUrl)
            : null,
      );
      LogUtils.d('批量下载生成的文件名: $filename', 'DownloadPathService');

      // 批量下载始终使用默认路径，不弹出对话框
      final basePath = await _getBasePath('');
      return safeJoinUnderBase(basePath, [filename]);
    } catch (e) {
      LogUtils.e('获取视频批量下载路径失败', tag: 'DownloadPathService', error: e);
      return null;
    }
  }

  /// 获取图库下载路径
  Future<String?> getGalleryDownloadPath({required ImageModel gallery}) async {
    try {
      // 生成文件夹名
      final template =
          _configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] as String;
      final foldername = _filenameTemplateService.generateGalleryFoldername(
        template: template,
        gallery: gallery,
      );

      final isCustomPathEnabled =
          _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;

      if (GetPlatform.isDesktop && !isCustomPathEnabled) {
        // 桌面平台且未启用自定义路径：让用户选择保存位置
        final result = await getSaveLocation(
          suggestedName: foldername,
          acceptedTypeGroups: [
            const XTypeGroup(label: 'folders', extensions: ['']),
          ],
        );
        return result?.path;
      } else {
        // 移动平台或桌面端启用自定义路径：使用配置的路径
        final basePath = await _getBasePath('');
        return safeJoinUnderBase(basePath, [foldername]);
      }
    } catch (e) {
      LogUtils.e('获取图库下载路径失败', tag: 'DownloadPathService', error: e);
      return null;
    }
  }

  /// 获取单张图片下载路径
  Future<String> getImageDownloadPath({
    required String title,
    required String? authorName,
    required String? authorUsername,
    required String? id,
    String? originalFilename,
  }) async {
    try {
      // 生成文件名
      final template =
          _configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] as String;
      final filename = _filenameTemplateService.generateImageFilename(
        template: template,
        title: title,
        authorName: authorName,
        authorUsername: authorUsername,
        id: id,
        originalFilename: originalFilename,
      );

      // 移动平台：使用配置的路径（单张图片下载通常在移动端）
      final basePath = await _getBasePath('');
      final sanitizedTitle = FilenameTemplateService.sanitizePathSegment(
        title,
        fallback: 'images',
      );
      return safeJoinUnderBase(basePath, [sanitizedTitle, filename]);
    } catch (e) {
      LogUtils.e('获取图片下载路径失败', tag: 'DownloadPathService', error: e);
      // 返回默认路径
      final basePath = await _getBasePath('');
      final filename = FilenameTemplateService.sanitizePathSegment(
        originalFilename ?? 'image.jpg',
        fallback: 'image.jpg',
      );
      return safeJoinUnderBase(basePath, [filename]);
    }
  }

  /// 读取当前生效的自定义路径，顺带修掉 iOS/macOS 换容器后失效的老路径。
  Future<String> _currentCustomPath() async {
    final raw = _configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;
    if (raw.isEmpty) return raw;
    // 没启用自定义路径就别去 stat 它，更别因此回写配置。
    final enabled =
        _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    if (!enabled) return raw;
    return _repairStaleSandboxPath(raw);
  }

  /// 获取基础下载路径
  Future<String> _getBasePath(String subPath) async {
    final isCustomPathEnabled =
        _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = await _currentCustomPath();

    LogUtils.d(
      '_getBasePath - 子路径: $subPath, 启用自定义: $isCustomPathEnabled, 自定义路径: $customPath',
      'DownloadPathService',
    );

    if (isCustomPathEnabled && customPath.isNotEmpty) {
      final permissionService = Get.find<PermissionService>();

      // 检查权限（应用专用目录无需权限，非Android平台通常无需权限）
      if (GetPlatform.isAndroid && !_isAppPrivateDirectory(customPath)) {
        final hasPermission = await permissionService.hasStoragePermission();

        if (!hasPermission) {
          LogUtils.w('无存储权限，使用应用专用目录', 'DownloadPathService');
          final appDir = await CommonUtils.getAppDirectory(
            pathSuffix: subPath.isEmpty
                ? 'downloads'
                : path.join('downloads', subPath),
          );
          return appDir.path;
        }
      }

      // 使用自定义路径
      String finalPath;

      if (GetPlatform.isAndroid) {
        // Android平台：检查路径是否为公共目录
        if (isPublicDirectory(customPath)) {
          // 检查是否有访问公共目录的权限
          final canAccessPublic = await permissionService
              .canAccessPublicDirectories();
          if (!canAccessPublic) {
            LogUtils.w(
              '无公共目录访问权限，使用应用专用目录替代: $customPath',
              'DownloadPathService',
            );
            final appDir = await CommonUtils.getAppDirectory(
              pathSuffix: subPath.isEmpty
                  ? 'downloads'
                  : path.join('downloads', subPath),
            );
            finalPath = appDir.path;
          } else {
            finalPath = subPath.isEmpty
                ? customPath
                : path.join(customPath, subPath);
          }
        } else {
          finalPath = subPath.isEmpty
              ? customPath
              : path.join(customPath, subPath);
        }
      } else {
        // 其他平台直接使用自定义路径
        finalPath = subPath.isEmpty
            ? customPath
            : path.join(customPath, subPath);
      }

      final customDir = Directory(finalPath);
      if (!await customDir.exists()) {
        try {
          await customDir.create(recursive: true);
          LogUtils.d('创建自定义目录: ${customDir.path}', 'DownloadPathService');
        } catch (e) {
          LogUtils.e(
            '创建自定义目录失败，使用应用专用目录',
            tag: 'DownloadPathService',
            error: e,
          );
          final appDir = await CommonUtils.getAppDirectory(
            pathSuffix: subPath.isEmpty
                ? 'downloads'
                : path.join('downloads', subPath),
          );
          return appDir.path;
        }
      }

      // 验证目录是否可写
      if (await _isDirectoryWritable(customDir.path)) {
        LogUtils.d('使用自定义路径: ${customDir.path}', 'DownloadPathService');
        return customDir.path;
      } else {
        LogUtils.w('自定义目录不可写，使用应用专用目录', 'DownloadPathService');
        final appDir = await CommonUtils.getAppDirectory(
          pathSuffix: subPath.isEmpty
              ? 'downloads'
              : path.join('downloads', subPath),
        );
        return appDir.path;
      }
    } else {
      // 使用默认应用路径
      final dir = await CommonUtils.getAppDirectory(
        pathSuffix: subPath.isEmpty
            ? 'downloads'
            : path.join('downloads', subPath),
      );
      LogUtils.d('使用默认路径: ${dir.path}', 'DownloadPathService');
      return dir.path;
    }
  }

  /// 存储卷根目录的形状：主存储的三种别名 + 任意外置卷（SD/TF 卡、U 盘）。
  ///
  /// 这些判定全部用 [path.posix]，不跟着宿主平台的分隔符走——它们描述的是
  /// Android 设备上的路径，在 Windows 上跑单测时也必须是同一个结果。
  static final RegExp _storageVolumeRootPattern = RegExp(
    // 末项的 catch-all 要排掉 /storage/emulated 和 /storage/self 本身：它们只是
    // 中间层，不是卷。否则 /storage/emulated/etc 这类畸形路径会认出一个假卷根。
    r'^(/storage/emulated/\d+|/storage/self/primary|/sdcard'
    r'|/storage/(?!emulated$|self$)[^/]+)$',
  );

  /// 内部应用专用目录：`/data/data/<包名>` 与 `/data/user/<n>/<包名>`
  /// （`<n>` 是用户/工作资料 id，不止 0）。
  static RegExp _internalAppDirPattern(String packageName) => RegExp(
    '^/data/(data|user/\\d+)/${RegExp.escape(packageName)}(/|\$)',
  );

  /// 找出路径所属的存储卷根；不在任何卷上返回 null。
  ///
  /// 逐级向上比对**完整片段**，绝不用 startsWith 拼字符串——那样
  /// `/storage/emulated/0/Downloads_old` 会被当成 `.../Download` 的子目录。
  static String? storageVolumeRootOf(String dirPath) {
    if (dirPath.isEmpty) return null;
    var current = path.posix.normalize(dirPath);
    while (true) {
      if (_storageVolumeRootPattern.hasMatch(current)) return current;
      final parent = path.posix.dirname(current);
      if (parent == current) return null;
      current = parent;
    }
  }

  /// Android 应用专用目录（内部 + 任意存储卷上的外部）。
  ///
  /// ⛔ 旧的外部目录正则写成 `^(/storage/[^/]+|/sdcard)/Android/...`，
  /// 匹配不到主存储的 `/storage/emulated/0/Android/data/<包名>`：
  /// `/storage/[^/]+` 只吃到 `/storage/emulated`，下一段是 `/0` 不是 `/Android`。
  /// 于是**推荐路径本身**会被判成「非应用私有」，设置页据此报缺权限。
  static bool isAndroidAppPrivatePath(String dirPath, String packageName) {
    if (dirPath.isEmpty) return false;
    final normalized = path.posix.normalize(dirPath);
    if (_internalAppDirPattern(packageName).hasMatch(normalized)) return true;

    final volume = storageVolumeRootOf(normalized);
    if (volume == null) return false;
    for (final kind in const ['data', 'obb', 'media']) {
      final base = path.posix.join(volume, 'Android', kind, packageName);
      if (normalized == base || normalized.startsWith('$base/')) return true;
    }
    return false;
  }

  /// 路径是否落在 Android 的**共享存储**上（写它需要「所有文件访问」权限）。
  ///
  /// ⛔ 旧实现是 12 条硬编码公共目录前缀的 startsWith，两头都错：
  ///   - 漏判：外置 SD 卡的 `/storage/XXXX-XXXX/Download`、以及用户自建的
  ///     `/storage/emulated/0/Iwara` 一律不算「公共」，于是设置页不提示缺权限、
  ///     下载静默回落应用私有目录，用户只看到「文件不见了」；
  ///   - 误判：`/storage/emulated/0/Downloads_old` 被当成 Download。
  /// 现在按「在某个存储卷上，且不是我们自己的应用私有目录」判定——这正好就是
  /// 需要授权的那一类，不再依赖目录叫什么名字。
  static bool isAndroidSharedStoragePath(String dirPath, String packageName) {
    if (dirPath.isEmpty) return false;
    final normalized = path.posix.normalize(dirPath);
    if (isAndroidAppPrivatePath(normalized, packageName)) return false;
    return storageVolumeRootOf(normalized) != null;
  }

  /// 检查是否为需要「所有文件访问」权限的共享存储目录（Android 专用）。
  bool isPublicDirectory(String dirPath) {
    if (!GetPlatform.isAndroid) return false;
    return isAndroidSharedStoragePath(dirPath, _resolvedPackageName);
  }

  /// 运行时真实的 applicationId。
  ///
  /// ⛔ 不能直接用 [CommonConstants.packageName]：那是写死的常量，而 debug /
  /// profile 构建带 `applicationIdSuffix`（见 android/app/build.gradle），本机
  /// 跑出来的包实际是 `m.c.g.a.i_iwara.debug`。拿常量去比对，**App 自己的**
  /// 外部私有目录会被判成共享存储——也就是这轮刚修掉的「推荐路径报缺权限」，
  /// 会在真机验证时原样复现，让人以为修复没生效。
  String _resolvedPackageName = CommonConstants.packageName;

  /// 从 path_provider 给的容器目录里反解出真实包名。
  static final RegExp _packageFromAppDirPattern = RegExp(
    r'/Android/(?:data|obb|media)/([^/]+)/'
    r'|^/data/(?:data|user/\d+)/([^/]+)/',
  );

  Future<void> _refreshResolvedPackageName() async {
    if (!GetPlatform.isAndroid) return;
    try {
      final dir = '${(await CommonUtils.getAppDirectory()).path}/';
      final match = _packageFromAppDirPattern.firstMatch(dir);
      final resolved = match?.group(1) ?? match?.group(2);
      if (resolved != null && resolved.isNotEmpty) {
        _resolvedPackageName = resolved;
      }
    } catch (e) {
      LogUtils.w('反解运行时包名失败，沿用常量: $e', 'DownloadPathService');
    }
  }

  /// 检查是否为应用专用目录（内部或外部）。
  ///
  /// 只有 Android 需要这个判断——它唯一的用途是决定「这个路径要不要先要权限」，
  /// 而只有 Android 才有共享存储这回事。所有调用点都已经用
  /// `GetPlatform.isAndroid` 守过；非 Android 一律按「不需要权限」处理。
  /// （旧实现在非 Android 分支用 `dirPath.contains(应用名)` 猜，
  /// `C:\Users\LoveIwara\...` 会把整台机器判成应用私有目录。）
  bool _isAppPrivateDirectory(String dirPath) {
    if (!GetPlatform.isAndroid) return true;
    return isAndroidAppPrivatePath(dirPath, _resolvedPackageName);
  }

  /// 检查目录是否可写
  Future<bool> _isDirectoryWritable(String dirPath) async {
    try {
      final testFile = File(
        path.join(
          dirPath,
          '.test_write_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      LogUtils.w('目录写入测试失败: $dirPath', 'DownloadPathService');
      return false;
    }
  }

  /// 获取目录可用空间（字节）
  Future<int?> _getAvailableSpace(String dirPath) async {
    try {
      if (GetPlatform.isAndroid || GetPlatform.isIOS) {
        // 移动平台暂时返回null，可以后续通过platform channel实现
        return null;
      } else {
        // 桌面平台可以通过dart:io获取
        final dir = Directory(dirPath);
        await dir.stat();
        // 这里简化处理，实际需要通过系统调用获取可用空间
        return null;
      }
    } catch (e) {
      LogUtils.w('获取可用空间失败: $dirPath', 'DownloadPathService');
      return null;
    }
  }

  /// 格式化字节数为可读字符串
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// 从URL中提取文件名
  String? _extractFilenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['filename'] ?? path.basename(uri.path);
    } catch (e) {
      LogUtils.w('从URL提取文件名失败: $url', 'DownloadPathService');
      return null;
    }
  }

  /// 验证路径是否有效
  Future<PathValidationResult> validatePath(String pathStr) async {
    try {
      final dir = Directory(pathStr);

      // 1. 检查权限（应用专用目录无需权限，非Android平台通常无需权限）
      if (GetPlatform.isAndroid && !_isAppPrivateDirectory(pathStr)) {
        final permissionService = Get.find<PermissionService>();
        final hasPermission = await permissionService.hasStoragePermission();

        if (!hasPermission) {
          return PathValidationResult(
            isValid: false,
            reason: PathValidationReason.noPermission,
            message: _t.lackStoragePermission,
            canFix: true,
          );
        }

        // 2. 检查是否为公共目录且无相应权限
        if (isPublicDirectory(pathStr)) {
          final canAccessPublic = await permissionService
              .canAccessPublicDirectories();
          if (!canAccessPublic) {
            return PathValidationResult(
              isValid: false,
              reason: PathValidationReason.noPublicDirectoryAccess,
              message: _t.cannotAccessPublicDirectory,
              canFix: true,
            );
          }
        }
      }

      // 3. 检查路径是否存在
      if (!await dir.exists()) {
        try {
          await dir.create(recursive: true);
        } catch (e) {
          return PathValidationResult(
            isValid: false,
            reason: PathValidationReason.cannotCreate,
            message: '${_t.cannotCreateDirectory}: ${e.toString()}',
            canFix: false,
          );
        }
      }

      // 4. 检查是否有写权限
      if (!await _isDirectoryWritable(pathStr)) {
        return PathValidationResult(
          isValid: false,
          reason: PathValidationReason.notWritable,
          message: _t.directoryNotWritable,
          canFix: false,
        );
      }

      // 5. 检查可用空间
      final freeSpace = await _getAvailableSpace(pathStr);
      if (freeSpace != null && freeSpace < 100 * 1024 * 1024) {
        // 小于100MB
        return PathValidationResult(
          isValid: true,
          reason: PathValidationReason.lowSpace,
          message: '${_t.insufficientSpace} (${_formatBytes(freeSpace)})',
          canFix: false,
        );
      }

      return PathValidationResult(
        isValid: true,
        reason: PathValidationReason.valid,
        message: _t.pathValid,
        canFix: false,
        availableSpace: freeSpace,
      );
    } catch (e) {
      LogUtils.e('路径验证失败: $pathStr', tag: 'DownloadPathService', error: e);
      return PathValidationResult(
        isValid: false,
        reason: PathValidationReason.unknown,
        message: '${_t.validationFailed}: ${e.toString()}',
        canFix: false,
      );
    }
  }

  /// 获取默认下载路径
  Future<String> getDefaultDownloadPath() async {
    final dir = await CommonUtils.getAppDirectory(pathSuffix: 'downloads');
    return dir.path;
  }

  /// 获取推荐的下载路径（Android专用）
  Future<String> getRecommendedDownloadPath() async {
    if (GetPlatform.isAndroid) {
      // Android平台推荐使用外部应用专用目录
      final dir = await CommonUtils.getAppDirectory(pathSuffix: 'downloads');
      return dir.path;
    } else {
      // 其他平台使用默认路径
      return await getDefaultDownloadPath();
    }
  }

  /// 本平台有没有目录选择器。
  ///
  /// ⛔ iOS 没有：`file_selector_ios` 根本没实现 `getDirectoryPath`，
  /// platform interface 的默认实现直接 `throw UnimplementedError`。以前设置页
  /// 无条件显示「选择文件夹」，iOS 上点下去必然是一句 UnimplementedError 的
  /// 报错 toast。iOS 沙盒外的路径本来也写不进去，只能在容器内挑目录，
  /// 所以这里直接不提供选择器，由「推荐路径」承担。
  bool get supportsDirectoryPicker => !GetPlatform.isIOS;

  /// 弹出目录选择器并返回所选目录的绝对路径，取消时返回 null
  /// Android 走原生 SAF 选择器并自行解析路径（file_selector 的
  /// getDirectoryPath 不支持外置 SD/TF 卡卷，会抛 UnsupportedOperationException），
  /// 其余平台沿用 file_selector
  Future<String?> pickDirectoryPath() async {
    if (!supportsDirectoryPicker) {
      // ⛔ 不能抛带中文 message 的异常：设置页的通用 catch 会把 `$e` 原样吐成
      // toast。给错误码，文案由 Dart 侧按码取（认不出的码退回通用那句）。
      throw PlatformException(
        code: 'UNSUPPORTED_PLATFORM',
        message: 'directory picker is unavailable on this platform',
      );
    }
    if (GetPlatform.isAndroid) {
      return await _fileHandlerChannel.invokeMethod<String>('pickDirectory');
    }
    return await getDirectoryPath();
  }

  /// iOS / macOS 沙盒容器路径里带一段随机 UUID，**每次 App 更新都会换新的**。
  /// 把绝对路径存进配置，下次更新后那条路径就指向一个不存在的旧容器：下载静默
  /// 回落到默认目录，设置页却还理直气壮地显示着那条老路径。
  ///
  /// 匹配 `.../Containers/Data/Application/<UUID>` 这一段，返回把容器换成当前
  /// 容器之后的路径；不是容器路径、或本来就在当前容器里，返回 null。
  static final RegExp _sandboxContainerPattern = RegExp(
    r'^(.*/Containers/Data/Application/[^/]+)(/.*)?$',
  );

  static String? rebaseSandboxPath(
    String storedPath,
    String anchorPathInCurrentContainer,
  ) {
    if (storedPath.isEmpty || anchorPathInCurrentContainer.isEmpty) return null;
    final stored = _sandboxContainerPattern.firstMatch(
      path.posix.normalize(storedPath),
    );
    final current = _sandboxContainerPattern.firstMatch(
      path.posix.normalize(anchorPathInCurrentContainer),
    );
    if (stored == null || current == null) return null;
    if (stored.group(1) == current.group(1)) return null;
    return '${current.group(1)}${stored.group(2) ?? ''}';
  }

  /// 自定义路径指向旧沙盒容器时，就地搬到当前容器并写回配置。
  ///
  /// 只管 iOS：macOS 的沙盒容器是 `~/Library/Containers/<bundle-id>/Data/…`，
  /// 形状对不上 [_sandboxContainerPattern]，写上 isMacOS 只是让人以为它管了。
  Future<String> _repairStaleSandboxPath(String customPath) async {
    if (!GetPlatform.isIOS) return customPath;

    try {
      if (await Directory(customPath).exists()) return customPath;
      final anchor = (await CommonUtils.getAppDirectory()).path;
      final rebased = rebaseSandboxPath(customPath, anchor);
      if (rebased == null) return customPath;

      LogUtils.i(
        '自定义下载路径指向旧沙盒容器，已重定位: $customPath -> $rebased',
        'DownloadPathService',
      );
      await _configService.setSetting(ConfigKey.CUSTOM_DOWNLOAD_PATH, rebased);
      return rebased;
    } catch (e) {
      LogUtils.w('重定位沙盒下载路径失败: $e', 'DownloadPathService');
      return customPath;
    }
  }

  /// 获取当前配置的下载路径信息
  Map<String, dynamic> getDownloadPathInfo() {
    final isCustomPathEnabled =
        _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = _configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;

    return {
      'isCustomPathEnabled': isCustomPathEnabled,
      'customPath': customPath,
      'videoTemplate':
          _configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String,
      'galleryTemplate':
          _configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] as String,
      'imageTemplate':
          _configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] as String,
    };
  }

  /// 重置为默认配置
  Future<void> resetToDefault() async {
    await _configService.setSetting(
      ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH,
      false,
    );
    await _configService.setSetting(ConfigKey.CUSTOM_DOWNLOAD_PATH, '');
    await _configService.setSetting(
      ConfigKey.VIDEO_FILENAME_TEMPLATE,
      '%title_%quality',
    );
    await _configService.setSetting(
      ConfigKey.GALLERY_FILENAME_TEMPLATE,
      '%title_%id',
    );
    await _configService.setSetting(
      ConfigKey.IMAGE_FILENAME_TEMPLATE,
      '%title_%filename',
    );
  }

  /// 获取路径状态信息
  PathStatusInfo getPathStatusInfo() {
    final isCustomPathEnabled =
        _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = _configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;

    if (!isCustomPathEnabled || customPath.isEmpty) {
      return PathStatusInfo(
        currentPath: '', // Will be resolved asynchronously
        isCustomPath: false,
        isValid: true,
        validationResult: PathValidationResult(
          isValid: true,
          reason: PathValidationReason.valid,
          message: _t.usingDefaultAppDirectory,
          canFix: false,
        ),
      );
    }

    return PathStatusInfo(
      currentPath: customPath,
      isCustomPath: true,
      isValid: false, // Will be validated asynchronously
      validationResult: PathValidationResult(
        isValid: false,
        reason: PathValidationReason.unknown,
        message: _t.checkingPathStatus,
        canFix: false,
      ),
      selectedPath: customPath,
    );
  }

  /// 获取路径状态信息（异步版本，用于详细验证）
  Future<PathStatusInfo> getPathStatusInfoAsync() async {
    final isCustomPathEnabled =
        _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = await _currentCustomPath();

    if (!isCustomPathEnabled || customPath.isEmpty) {
      final defaultPath = await getDefaultDownloadPath();
      return PathStatusInfo(
        currentPath: defaultPath,
        isCustomPath: false,
        isValid: true,
        validationResult: PathValidationResult(
          isValid: true,
          reason: PathValidationReason.valid,
          message: _t.usingDefaultAppDirectory,
          canFix: false,
        ),
      );
    }

    final validationResult = await validatePath(customPath);
    final actualPath = validationResult.isValid
        ? customPath
        : await getDefaultDownloadPath();

    return PathStatusInfo(
      currentPath: actualPath,
      isCustomPath: validationResult.isValid,
      isValid: validationResult.isValid,
      validationResult: validationResult,
      selectedPath: customPath,
    );
  }

  /// 获取推荐路径列表
  Future<List<RecommendedPath>> getRecommendedPaths() async {
    final List<RecommendedPath> paths = [];

    // 1. 外部应用专用目录（默认推荐）
    final appDir = await CommonUtils.getAppDirectory(pathSuffix: 'downloads');
    paths.add(
      RecommendedPath(
        path: appDir.path,
        name: _t.externalAppPrivateDirectory,
        description: _t.externalAppPrivateDirectoryDesc,
        type: RecommendedPathType.appPrivate,
        isRecommended: true,
      ),
    );

    // 2. 内部应用专用目录（备选推荐）
    final internalAppDir = await CommonUtils.getInternalAppDirectory(
      pathSuffix: 'downloads',
    );
    paths.add(
      RecommendedPath(
        path: internalAppDir.path,
        name: _t.internalAppPrivateDirectory,
        description: _t.internalAppPrivateDirectoryDesc,
        type: RecommendedPathType.appPrivate,
        isRecommended: false,
      ),
    );

    if (GetPlatform.isAndroid) {
      final permissionService = Get.find<PermissionService>();
      final hasPermission = await permissionService
          .canAccessPublicDirectories();

      if (hasPermission) {
        // 3. 下载目录
        paths.add(
          RecommendedPath(
            path: '/storage/emulated/0/Download',
            name: _t.downloadDirectory,
            description: _t.downloadDirectoryDesc,
            type: RecommendedPathType.publicDownload,
            isRecommended: true,
          ),
        );

        // 4. 影片目录
        paths.add(
          RecommendedPath(
            path: '/storage/emulated/0/Movies',
            name: _t.moviesDirectory,
            description: _t.moviesDirectoryDesc,
            type: RecommendedPathType.publicMovies,
            isRecommended: false,
          ),
        );
      } else {
        // 无权限时显示但标记为不可用
        paths.add(
          RecommendedPath(
            path: '/storage/emulated/0/Download',
            name: _t.downloadDirectory,
            description: _t.requiresStoragePermission,
            type: RecommendedPathType.publicDownload,
            isRecommended: false,
            requiresPermission: true,
          ),
        );
      }
    } else if (GetPlatform.isIOS) {
      // iOS推荐路径
      try {
        final documentsDir = await CommonUtils.getAppDirectory();
        paths.add(
          RecommendedPath(
            path: documentsDir.path,
            name: _t.documentsDirectory,
            description: _t.documentsDirectoryDesc,
            type: RecommendedPathType.appPrivate,
            isRecommended: true,
          ),
        );
      } catch (e) {
        LogUtils.e('获取iOS文档目录失败', tag: 'DownloadPathService', error: e);
      }
    } else if (GetPlatform.isDesktop) {
      // 桌面平台（Windows、macOS、Linux）推荐路径
      try {
        // 应用文档目录
        final documentsDir = await CommonUtils.getAppDirectory();
        paths.add(
          RecommendedPath(
            path: documentsDir.path,
            name: _t.appDocumentsDirectory,
            description: _t.appDocumentsDirectoryDesc,
            type: RecommendedPathType.appPrivate,
            isRecommended: true,
          ),
        );

        // 系统下载目录（如果可以获取）
        try {
          if (GetPlatform.isWindows) {
            // Windows: 用户下载文件夹
            final userHome = Platform.environment['USERPROFILE'];
            if (userHome != null) {
              final downloadsPath = path.join(userHome, 'Downloads');
              if (await Directory(downloadsPath).exists()) {
                paths.add(
                  RecommendedPath(
                    path: downloadsPath,
                    name: _t.downloadsFolder,
                    description: _t.downloadsFolderDesc,
                    type: RecommendedPathType.publicDownload,
                    isRecommended: false,
                  ),
                );
              }
            }
          } else if (GetPlatform.isMacOS || GetPlatform.isLinux) {
            // macOS/Linux: 用户下载文件夹
            final userHome = Platform.environment['HOME'];
            if (userHome != null) {
              final downloadsPath = path.join(userHome, 'Downloads');
              if (await Directory(downloadsPath).exists()) {
                paths.add(
                  RecommendedPath(
                    path: downloadsPath,
                    name: _t.downloadsFolder,
                    description: _t.downloadsFolderDesc,
                    type: RecommendedPathType.publicDownload,
                    isRecommended: false,
                  ),
                );
              }
            }
          }
        } catch (e) {
          LogUtils.w('获取系统下载目录失败', 'DownloadPathService');
        }
      } catch (e) {
        LogUtils.e('获取桌面平台推荐路径失败', tag: 'DownloadPathService', error: e);
      }
    }

    // 去重：保留相同 path 的第一个对象
    final Map<String, RecommendedPath> uniquePaths = {};
    for (final pathItem in paths) {
      if (!uniquePaths.containsKey(pathItem.path)) {
        uniquePaths[pathItem.path] = pathItem;
      }
    }

    return uniquePaths.values.toList();
  }

  /// 修复路径问题
  Future<bool> fixPathIssue(PathValidationReason reason) async {
    switch (reason) {
      case PathValidationReason.noPermission:
      case PathValidationReason.noPublicDirectoryAccess:
        final permissionService = Get.find<PermissionService>();
        return await permissionService.requestStoragePermission();

      case PathValidationReason.cannotCreate:
      case PathValidationReason.notWritable:
        // 这些问题无法自动修复，需要用户选择其他路径
        return false;

      default:
        return false;
    }
  }

  // ---------- 新增：响应式刷新方法供 UI 调用 ----------

  /// 刷新存储权限状态
  Future<void> _refreshPermissionStatus() async {
    try {
      _storagePermissionLoading.value = true;
      final permissionService = Get.find<PermissionService>();
      final granted = await permissionService.hasStoragePermission();
      _storagePermissionGranted.value = granted;
    } finally {
      _storagePermissionLoading.value = false;
    }
  }

  /// 供外部调用：刷新存储权限并更新推荐路径
  Future<void> refreshPermissionAndRelated() async {
    await _refreshPermissionStatus();
    await loadRecommendedPathsReactive();
  }

  /// 刷新当前路径状态（含验证）
  Future<void> refreshPathStatus() async {
    try {
      _pathStatusLoading.value = true;

      final isCustomPathEnabled =
          _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
      final customPath = await _currentCustomPath();

      if (!isCustomPathEnabled || customPath.isEmpty) {
        final defaultPath = await getDefaultDownloadPath();
        _pathStatus.value = PathStatusInfo(
          currentPath: defaultPath,
          isCustomPath: false,
          isValid: true,
          validationResult: PathValidationResult(
            isValid: true,
            reason: PathValidationReason.valid,
            message: _t.usingDefaultAppDirectory,
            canFix: false,
          ),
        );
        return;
      }

      final validationResult = await validatePath(customPath);
      final actualPath = validationResult.isValid
          ? customPath
          : await getDefaultDownloadPath();
      _pathStatus.value = PathStatusInfo(
        currentPath: actualPath,
        isCustomPath: validationResult.isValid,
        isValid: validationResult.isValid,
        validationResult: validationResult,
        selectedPath: customPath,
      );
    } catch (e) {
      LogUtils.e('刷新路径状态失败', tag: 'DownloadPathService', error: e);
    } finally {
      _pathStatusLoading.value = false;
    }
  }

  /// 加载推荐路径供 UI 展示
  Future<void> loadRecommendedPathsReactive() async {
    try {
      _recommendedPathsLoading.value = true;
      final list = await getRecommendedPaths();
      _recommendedPaths.assignAll(list);
    } catch (e) {
      LogUtils.e('加载推荐路径失败', tag: 'DownloadPathService', error: e);
      _recommendedPaths.clear();
    } finally {
      _recommendedPathsLoading.value = false;
    }
  }
}

/// 路径状态信息
class PathStatusInfo {
  final String currentPath; // 当前实际使用的路径
  final bool isCustomPath; // 是否为自定义路径
  final bool isValid; // 路径是否有效
  final PathValidationResult validationResult;
  final String? selectedPath; // 用户选择的路径（可能与实际路径不同）

  const PathStatusInfo({
    required this.currentPath,
    required this.isCustomPath,
    required this.isValid,
    required this.validationResult,
    this.selectedPath,
  });
}

/// 推荐路径类型
enum RecommendedPathType {
  appPrivate, // 应用专用目录
  publicDownload, // 公共下载目录
  publicMovies, // 公共影片目录
  custom, // 自定义目录
}

/// 推荐路径
class RecommendedPath {
  final String path;
  final String name;
  final String description;
  final RecommendedPathType type;
  final bool isRecommended;
  final bool requiresPermission;

  const RecommendedPath({
    required this.path,
    required this.name,
    required this.description,
    required this.type,
    required this.isRecommended,
    this.requiresPermission = false,
  });
}
