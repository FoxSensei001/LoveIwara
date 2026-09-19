import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:file_selector/file_selector.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/author_folder_cache_service.dart';
import 'package:i_iwara/app/services/download_location.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/common/constants.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

export 'package:i_iwara/app/services/download_location.dart';
export 'package:i_iwara/app/services/permission_service.dart'
    show StorageAccessNeed;

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

/// 「更改位置」里的一个快捷选项。
class DownloadLocationOption {
  const DownloadLocationOption({required this.location, required this.role});

  final DownloadLocation location;
  final DownloadLocationOptionRole role;

  String get path => location.path;
}

enum DownloadLocationOptionRole {
  /// 推荐位置（Android 的「下载 › LoveIwara」、桌面的系统下载文件夹）。
  recommended,

  /// App 专属空间：不用权限，但卸载即删、相册看不到。
  appPrivate,

  /// 已挂载的 SD 卡 / U 盘：要「所有文件访问」。
  removable,
}

/// 下载路径服务
/// 统一管理下载路径和文件命名逻辑
class DownloadPathService extends GetxService {
  static DownloadPathService get to => Get.find();

  /// 原生文件处理通道（与 MainActivity 中的 FILE_HANDLER_CHANNEL 对应）
  static const MethodChannel _fileHandlerChannel = MethodChannel(
    CommonConstants.fileHandlerChannelName,
  );

  /// 公共目录下我们自己那一层子目录的名字（`Download/LoveIwara`、
  /// `~/Downloads/LoveIwara`）。
  ///
  /// 不用 [CommonConstants.applicationNickname]（`Love Iwara`，带空格）：文件夹名
  /// 里的空格在命令行 / 部分文件管理器里要转义，和通知栏的 appName 也对不上。
  static const String publicFolderName = 'LoveIwara';

  /// 剩余空间低于这个值就把状态标成「空间不足」。一个 1080p 视频常常几百 MB。
  static const int lowSpaceThresholdBytes = 500 * 1024 * 1024;

  final ConfigService _configService = Get.find<ConfigService>();
  late FilenameTemplateService _filenameTemplateService;

  // ---------- 可观测状态（供 UI 直接订阅） ----------
  final Rxn<PathStatusInfo> _pathStatus = Rxn<PathStatusInfo>();
  final RxBool _pathStatusLoading = false.obs;

  final RxBool _storagePermissionGranted = false.obs;
  final RxBool _storagePermissionLoading = false.obs;

  final RxString _defaultDownloadPath = ''.obs;

  // 对外只读暴露
  PathStatusInfo? get pathStatus => _pathStatus.value;

  /// 供页面订阅「下载目录变了」：每次改目录后都会刷新一遍路径状态。
  Rxn<PathStatusInfo> get pathStatusRx => _pathStatus;
  bool get isPathStatusLoading => _pathStatusLoading.value;

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

  PermissionService get _permissionService => Get.find<PermissionService>();

  @override
  void onInit() {
    super.onInit();
    // 确保文件命名模板服务已初始化
    if (!Get.isRegistered<FilenameTemplateService>()) {
      Get.put(FilenameTemplateService());
    }
    _filenameTemplateService = Get.find<FilenameTemplateService>();

    // 作者首见名缓存（%authorcache 的存储后端）同样在此收口：
    // 路径解析只会经由本服务触达它，注册顺序跟着本服务走最稳。
    if (!Get.isRegistered<AuthorFolderCacheService>()) {
      Get.put(AuthorFolderCacheService());
    }

    // 初始化异步状态
    Future.microtask(() async {
      await _refreshResolvedPackageName();
      await _refreshPermissionStatus();
      _defaultDownloadPath.value = await getDefaultDownloadPath();
      await refreshPathStatus();
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
      // 生成多段路径（文件夹段 + 文件名段）
      final template =
          _configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String;
      LogUtils.d('使用文件命名模板: $template', 'DownloadPathService');

      final segments = _filenameTemplateService.generateVideoPathSegments(
        template: template,
        video: video,
        quality: quality,
        originalFilename: downloadUrl != null
            ? _extractFilenameFromUrl(downloadUrl)
            : null,
      );
      LogUtils.d('生成的路径段: $segments', 'DownloadPathService');

      final isCustomPathEnabled =
          _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
      final customPath =
          _configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;
      LogUtils.d(
        '自定义路径启用状态: $isCustomPathEnabled, 自定义路径: $customPath',
        'DownloadPathService',
      );

      if (GetPlatform.isDesktop && !isCustomPathEnabled) {
        // 桌面平台且未启用自定义路径：让用户选择保存位置。
        // 只把模板末段（文件名）作为系统对话框的建议名——「每次询问」模式下
        // 没有固定基目录可挂子文件夹，用户在对话框里的选择优先（07 边界表）。
        final result = await getSaveLocation(
          suggestedName: segments.last,
          acceptedTypeGroups: [
            const XTypeGroup(label: 'MP4 Video', extensions: ['mp4']),
          ],
        );
        return result?.path;
      } else {
        // 移动平台或桌面端启用自定义路径：使用配置的路径
        final basePath = await _getBasePath('');
        return safeJoinUnderBase(basePath, segments);
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
      // 生成多段路径（文件夹段 + 文件名段）
      final template =
          _configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String;
      LogUtils.d('批量下载使用文件命名模板: $template', 'DownloadPathService');

      final segments = _filenameTemplateService.generateVideoPathSegments(
        template: template,
        video: video,
        quality: quality,
        originalFilename: downloadUrl != null
            ? _extractFilenameFromUrl(downloadUrl)
            : null,
      );
      LogUtils.d('批量下载生成的路径段: $segments', 'DownloadPathService');

      // 批量下载始终使用默认路径，不弹出对话框
      final basePath = await _getBasePath('');
      return safeJoinUnderBase(basePath, segments);
    } catch (e) {
      LogUtils.e('获取视频批量下载路径失败', tag: 'DownloadPathService', error: e);
      return null;
    }
  }

  /// 获取图库下载路径
  Future<String?> getGalleryDownloadPath({required ImageModel gallery}) async {
    return _resolveGalleryPath(gallery: gallery);
  }

  /// 获取图库批量下载路径（不弹出对话框，模板全量生效）。
  ///
  /// 批量场景与视频批量同一条规矩：绝不逐个弹框——桌面「每次询问」模式下
  /// 以前会漏进来弹（图库批量复用了单册的路径函数），这里收口。
  Future<String?> getGalleryDownloadPathForBatch({
    required ImageModel gallery,
  }) async {
    return _resolveGalleryPath(gallery: gallery, forBatch: true);
  }

  Future<String?> _resolveGalleryPath({
    required ImageModel gallery,
    bool forBatch = false,
  }) async {
    try {
      // 生成多段文件夹路径
      final template =
          _configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] as String;
      final segments = _filenameTemplateService.generateGalleryPathSegments(
        template: template,
        gallery: gallery,
      );
      LogUtils.d(
        '${forBatch ? '批量下载' : ''}生成的图库路径段: $segments',
        'DownloadPathService',
      );

      final isCustomPathEnabled =
          _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;

      if (GetPlatform.isDesktop && !isCustomPathEnabled && !forBatch) {
        // 桌面平台且未启用自定义路径（单册下载）：让用户选择保存位置
        final result = await getSaveLocation(
          suggestedName: segments.last,
          acceptedTypeGroups: [
            const XTypeGroup(label: 'folders', extensions: ['']),
          ],
        );
        return result?.path;
      } else {
        // 移动平台、桌面端启用自定义路径，或批量下载：使用配置的路径
        final basePath = await _getBasePath('');
        return safeJoinUnderBase(basePath, segments);
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
    String? authorId,
    required String? id,
    String? originalFilename,
  }) async {
    try {
      final template =
          _configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] as String;
      final basePath = await _getBasePath('');

      final List<String> segments;
      if (template.contains('/')) {
        // 新式模板：结构写在模板里（如 %authorcache/%title/%filename），
        // 整条按模板逐段渲染。
        segments = _filenameTemplateService.generateImagePathSegments(
          template: template,
          title: title,
          authorName: authorName,
          authorUsername: authorUsername,
          authorId: authorId,
          id: id,
          originalFilename: originalFilename,
        );
      } else {
        // 存量平铺模板：历史上硬编码的「标题」子文件夹层继续保留，
        // 保证升级用户落盘路径逐字节不变（收编进模板首段是选择新预设之后的事）。
        final filename = _filenameTemplateService.generateImageFilename(
          template: template,
          title: title,
          authorName: authorName,
          authorUsername: authorUsername,
          authorId: authorId,
          id: id,
          originalFilename: originalFilename,
        );
        final sanitizedTitle = FilenameTemplateService.sanitizePathSegment(
          title,
          fallback: 'images',
        );
        segments = [sanitizedTitle, filename];
      }
      return safeJoinUnderBase(basePath, segments);
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

  /// 只读预览：视频下载将落下的相对路径段（下载弹窗「将保存到」用）。
  ///
  /// 与真实落盘共用同一套模板渲染和清洗规则，但**不写作者首见名缓存**、
  /// 不碰文件系统、不弹对话框——预览不该有副作用（缓存的首见名应由真实
  /// 下载时刻落笔）。
  List<String> previewVideoRelativePath({
    required Video video,
    required String quality,
    String? downloadUrl,
  }) {
    final template =
        _configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String;
    return _filenameTemplateService.generateVideoPathSegments(
      template: template,
      video: video,
      quality: quality,
      originalFilename: downloadUrl != null
          ? _extractFilenameFromUrl(downloadUrl)
          : null,
      writeAuthorCache: false,
    );
  }

  /// 只读预览：图库下载将落下的相对路径段（图库确认弹窗用），无副作用。
  List<String> previewGalleryRelativeSegments({required ImageModel gallery}) {
    final template =
        _configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] as String;
    return _filenameTemplateService.generateGalleryPathSegments(
      template: template,
      gallery: gallery,
      writeAuthorCache: false,
    );
  }

  /// 当前是否处于「目标下载目录不可用、临时退回 App 专属空间」的回退态。
  ///
  /// 非空 = 目标目录与原因，完成回执要用它把静默偏差显式化（「已保存到应用
  /// 目录 — 无法写入 …」）；null = 正常落盘。
  ({String target, DownloadFallbackReason reason})? get runtimeFallbackState {
    final fallback = _runtimeFallback;
    return fallback == null
        ? null
        : (target: fallback.target, reason: fallback.reason);
  }

  /// 算一个落盘路径相对下载根目录的「目录部分」，完成回执用。
  ///
  /// [isDirectory]：savePath 是否指向文件夹（图库任务的 savePath 是文件夹
  /// 本身，调用方由 `mediaType == 'gallery'` 判定；文件任务传 false）。
  /// - 文件任务取父目录（`…/LoveIwara/花火師さん/x.mp4` → `花火師さん/`）；
  /// - 图库任务整段保留（`…/LoveIwara/花火師さん/标题_id/`）；
  /// - 路径不在当前目标目录之下（桌面另存为选到别处、自定义目录刚改过等）
  ///   返回 null，回执退回与目录无关的原文案；
  /// - 落在权限回退的 App 专属目录里时照样能算出相对目录，`fellBack` 为 true，
  ///   回执据此切换到警示态。
  Future<({String relativeDir, bool fellBack})?> describeRelativeDir(
    String savePath, {
    bool isDirectory = false,
  }) async {
    try {
      final normalized = path.normalize(savePath);
      final directory =
          isDirectory ||
          FileSystemEntity.typeSync(normalized) ==
              FileSystemEntityType.directory;

      ({String base, bool fellBack})? baseState;

      final target = await targetDownloadDirectory();
      if (isPathInsideBase(target, normalized)) {
        baseState = (base: target, fellBack: false);
      } else {
        // 不在目标目录下：看是不是权限回退（临时落在 App 专属空间）。
        final fallback = _runtimeFallback;
        if (fallback != null) {
          final appDir = await CommonUtils.getAppDirectory(
            pathSuffix: 'downloads',
          );
          if (isPathInsideBase(appDir.path, normalized)) {
            baseState = (base: appDir.path, fellBack: true);
          }
        }
      }
      if (baseState == null) return null;

      final inBase = directory ? normalized : path.dirname(normalized);
      var relative = path.relative(inBase, from: baseState.base);
      if (relative == '.' || relative.isEmpty) {
        if (!baseState.fellBack) return null; // 平铺：没有目录信息可报
        relative = '';
      }
      final relativeDir = relative == '' ? '' : '$relative/';
      return (relativeDir: relativeDir, fellBack: baseState.fellBack);
    } catch (e) {
      LogUtils.e('计算相对目录失败', tag: 'DownloadPathService', error: e);
      return null;
    }
  }


  /// 新下载有没有一个固定的落脚目录。桌面端没开自定义路径时每次都弹「另存为」，
  /// 没有「当前下载目录」可言——「把已下载内容移到当前目录」在那里无从谈起。
  bool get hasFixedDownloadDirectory =>
      !GetPlatform.isDesktop ||
      (_configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool);

  /// 桌面端「每次询问保存位置」（= 没开自定义路径）。
  bool get asksEveryTime => !hasFixedDownloadDirectory;

  /// 新下载实际会落到的目录（已按权限 / 可写性回落过，目录保证存在）。
  Future<String> currentDownloadDirectory() => _getBasePath('');

  /// 「把已下载内容搬到当前目录」的目标：用户**想要**的那个目录，且此刻真能用。
  ///
  /// 与 [currentDownloadDirectory] 的区别有两条，都是为了别把东西搬错地方：
  ///   - 回退中（SD 卡拔了、权限被收回）答 null。那时 [currentDownloadDirectory]
  ///     给的是 App 专属空间，照着它搬等于把全部下载搬进卸载即删的地方。
  ///   - 只读：不建目录、不写探针（只有 [probe] 会动磁盘）。目录还没建出来时，
  ///     上一级在就算可用——搬家自己会建。
  /// 用户对「旧目录里还有 N 项」说过「不搬」的那个目标目录。目标目录换了，
  /// 这句回答就不再算数——横幅会重新问。
  bool isOutsideDismissedFor(String directory) {
    final dismissed =
        _configService[ConfigKey.DOWNLOADS_OUTSIDE_DISMISSED_DIR] as String;
    return dismissed.isNotEmpty && path.equals(dismissed, directory);
  }

  void dismissOutsideFor(String directory) {
    _configService[ConfigKey.DOWNLOADS_OUTSIDE_DISMISSED_DIR] = directory;
  }

  Future<String?> migrationTargetDirectory() async {
    if (!hasFixedDownloadDirectory) return null;
    if (_pathStatus.value?.isFallback ?? false) return null;
    final target = await targetDownloadDirectory();
    if (await Directory(target).exists()) return target;
    if (await Directory(path.dirname(target)).exists()) return target;
    return null;
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

  /// 用户（或默认规则）**想要**的下载目录——还没按权限 / 可写性回落。
  ///
  /// 开了自定义路径且非空 → 那条路径；否则 → [getDefaultDownloadPath]。
  /// 与 [_getBasePath]、[refreshPathStatus]、[hasFixedDownloadDirectory] 用的是
  /// 同一个判据：桌面端没开自定义路径时，单个下载弹「另存为」，批量下载与单图
  /// 落到这里。
  Future<String> targetDownloadDirectory() async {
    final enabled =
        _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = await _currentCustomPath();
    if (enabled && customPath.isNotEmpty) return customPath;
    return getDefaultDownloadPath();
  }

  /// 所有「可能装着我们下载内容」的根目录：App 专属目录、当前默认目录、
  /// 自定义目录。给删除图库文件夹前的安全校验用。
  Future<List<String>> knownDownloadRoots() async {
    final roots = <String>{};
    try {
      roots.add(await _appPrivateDownloadDirectory());
    } catch (e) {
      LogUtils.w('获取 App 专属下载目录失败: $e', 'DownloadPathService');
    }
    try {
      roots.add(await getDefaultDownloadPath());
    } catch (e) {
      LogUtils.w('获取默认下载目录失败: $e', 'DownloadPathService');
    }
    final enabled =
        _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = _configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;
    if (enabled && customPath.trim().isNotEmpty) roots.add(customPath);
    return roots.toList();
  }

  /// 下载时发生过的回退（建目录失败之类状态刷新看不出来的），按目标目录记。
  _RuntimeFallback? _runtimeFallback;

  void _recordRuntimeFallback(String target, DownloadFallbackReason? reason) {
    final previous = _runtimeFallback;
    if (reason == null) {
      if (previous == null || previous.target != target) return;
      _runtimeFallback = null;
    } else {
      if (previous != null &&
          previous.target == target &&
          previous.reason == reason) {
        return;
      }
      _runtimeFallback = _RuntimeFallback(target, reason);
    }
    // 回退状态变了：让设置页的「已临时回退」标签跟上。
    unawaited(refreshPathStatus());
  }

  /// 获取基础下载路径
  ///
  /// 目标目录不能用时退回 App 专属空间，并把**原因**记下来挂到
  /// [pathStatusRx] 上——以前是悄悄回落，用户只会觉得「文件不见了」。
  Future<String> _getBasePath(String subPath) async {
    final target = await targetDownloadDirectory();
    final finalPath = subPath.isEmpty ? target : path.join(target, subPath);

    LogUtils.d(
      '_getBasePath - 子路径: $subPath, 目标目录: $target',
      'DownloadPathService',
    );

    final reason = await _checkDirectory(finalPath, create: true);
    if (reason == null) {
      _recordRuntimeFallback(target, null);
      return finalPath;
    }

    LogUtils.w(
      '下载目录不可用($reason)，临时改用应用专用目录: $finalPath',
      'DownloadPathService',
    );
    _recordRuntimeFallback(target, reason);
    final appDir = await CommonUtils.getAppDirectory(
      pathSuffix: subPath.isEmpty
          ? 'downloads'
          : path.join('downloads', subPath),
    );
    return appDir.path;
  }

  /// 检查 [dirPath] 能不能当下载目录用，能用返回 null。
  ///
  /// [create] 为 false 时**绝不建目录**（设置页刷新状态走这条）：目录还不存在
  /// 就只看卷在不在、权限够不够，其余等真正下载 / probe 时再说。
  Future<DownloadFallbackReason?> _checkDirectory(
    String dirPath, {
    required bool create,
  }) async {
    if (await _isVolumeMissing(dirPath)) {
      return DownloadFallbackReason.volumeMissing;
    }
    final need = await storageAccessNeedOf(dirPath);
    if (need != StorageAccessNeed.none &&
        !await _permissionService.hasStorageAccess(need)) {
      return DownloadFallbackReason.needsPermission;
    }
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      if (!create) return null;
      try {
        await dir.create(recursive: true);
        LogUtils.d('创建下载目录: $dirPath', 'DownloadPathService');
      } catch (e) {
        LogUtils.e('创建下载目录失败: $dirPath', tag: 'DownloadPathService', error: e);
        return DownloadFallbackReason.cannotCreate;
      }
    }
    if (!await _isDirectoryWritable(dirPath)) {
      return DownloadFallbackReason.notWritable;
    }
    return null;
  }

  /// App 专属空间里的下载目录（永远可写的兜底）。
  Future<String> _appPrivateDownloadDirectory() async {
    final dir = await CommonUtils.getAppDirectory(pathSuffix: 'downloads');
    return dir.path;
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
  static RegExp _internalAppDirPattern(String packageName) =>
      RegExp('^/data/(data|user/\\d+)/${RegExp.escape(packageName)}(/|\$)');

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

  /// 写 [dirPath] 要先拿到哪一档存储权限（见 [StorageAccessNeed]）。
  ///
  /// 同步版：API level 取 [PermissionService] 已缓存的值（它 onInit 就暖了），
  /// 没暖上按 30 算。要准确结果的流程用 [storageAccessNeedOf]。
  StorageAccessNeed storageAccessNeed(String dirPath) {
    if (!GetPlatform.isAndroid) return StorageAccessNeed.none;
    final sdkInt = Get.isRegistered<PermissionService>()
        ? _permissionService.cachedAndroidSdkInt ?? 30
        : 30;
    return _androidAccessNeed(dirPath, sdkInt);
  }

  /// [storageAccessNeed] 的异步版：先把 API level 读准。
  Future<StorageAccessNeed> storageAccessNeedOf(String dirPath) async {
    if (!GetPlatform.isAndroid) return StorageAccessNeed.none;
    final sdkInt = await _permissionService.androidSdkInt();
    return _androidAccessNeed(dirPath, sdkInt);
  }

  StorageAccessNeed _androidAccessNeed(String dirPath, int sdkInt) {
    return DownloadLocation.androidAccessNeedFor(
      dirPath,
      sdkInt: sdkInt,
      isAppPrivate: isAndroidAppPrivatePath(dirPath, _resolvedPackageName),
      volumeRoot: storageVolumeRootOf(dirPath),
    );
  }

  /// 写这个目录要不要**任何**存储权限（Android 专用；其余平台恒为 false）。
  ///
  /// ⛔ 语义在 2026-09 变过：以前是「在共享存储上」（于是 Android 11+ 的
  /// `Download/LoveIwara` 也被当成要「所有文件访问」），现在是
  /// `storageAccessNeed(path) != none`。调用点（缺文件诊断的「没权限」分支）
  /// 要的本来就是后者。
  bool isPublicDirectory(String dirPath) =>
      storageAccessNeed(dirPath) != StorageAccessNeed.none;

  /// 把一个目录描述成 [DownloadLocation]（友好名、类别、要哪档权限）。
  Future<DownloadLocation> describeLocation(String dirPath) async {
    if (GetPlatform.isAndroid) {
      final sdkInt = await _permissionService.androidSdkInt();
      return DownloadLocation.describeAndroid(
        dirPath,
        sdkInt: sdkInt,
        isAppPrivate: isAndroidAppPrivatePath(dirPath, _resolvedPackageName),
        volumeRoot: storageVolumeRootOf(dirPath),
      );
    }
    if (GetPlatform.isDesktop) {
      final appDir = await _appPrivateDownloadDirectory();
      if (isPathInsideBase(path.dirname(appDir), dirPath)) {
        return DownloadLocation(
          path: dirPath,
          kind: DownloadLocationKind.appPrivate,
          volume: DownloadVolumeKind.appSpace,
          segments: const [],
        );
      }
      return DownloadLocation.describeDesktop(
        dirPath,
        context: path.context,
        downloadsDir: await _systemDownloadsDirectory(),
        isMacOS: GetPlatform.isMacOS,
        isLinux: GetPlatform.isLinux,
        isWindows: GetPlatform.isWindows,
      );
    }
    // iOS：只能写自己的沙盒。
    return DownloadLocation(
      path: dirPath,
      kind: DownloadLocationKind.appPrivate,
      volume: DownloadVolumeKind.appSpace,
      segments: const [],
    );
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

  /// 检查目录是否可写（目录必须已存在；只写一个临时文件，不建目录）。
  Future<bool> _isDirectoryWritable(String dirPath) async {
    try {
      final testFile = File(
        path.join(
          dirPath,
          // 带扩展名：Android 11+ 的公共 Download/ 下有机型拒写无扩展名文件，
          // 与 [probe] 的探针同一口径，免得 probe 说能写、下载时却静默回退。
          '.test_write_${DateTime.now().millisecondsSinceEpoch}.txt',
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

  /// 目录所在的卷不在了（SD 卡拔了、外置盘没接）。
  Future<bool> _isVolumeMissing(String dirPath) async {
    try {
      String? root;
      if (GetPlatform.isAndroid) {
        root = storageVolumeRootOf(dirPath);
        // 主存储永远在；它「不在」只能是权限问题。
        if (root != null && DownloadLocation.isPrimaryVolumeRoot(root)) {
          return false;
        }
      } else if (GetPlatform.isWindows) {
        root = path.rootPrefix(dirPath);
      } else if (GetPlatform.isDesktop) {
        root = DownloadLocation.desktopExternalVolumeRoot(
          dirPath,
          context: path.context,
          isMacOS: GetPlatform.isMacOS,
          isLinux: GetPlatform.isLinux,
        );
      }
      if (root == null || root.isEmpty) return false;
      return !await Directory(root).exists();
    } catch (_) {
      return false;
    }
  }

  static bool _isPermissionDenied(Object error) {
    if (error is FileSystemException) {
      final code = error.osError?.errorCode;
      // EPERM(1) / EACCES(13)；Windows 的 ERROR_ACCESS_DENIED(5)。
      return code == 13 || code == 1 || (Platform.isWindows && code == 5);
    }
    return false;
  }

  /// 实地检查一个目录能不能当下载目录：建目录 → 写一个带扩展名的探针文件 →
  /// 改名 → 删除 → 读可用空间。
  ///
  /// ⭐ 全服务**只有这里**会为了检查而建目录（设置页刷新状态、[validatePath]
  /// 一律不建）。检查失败时把自己建出来的空目录删回去，不给用户留一个空壳。
  ///
  /// 探针带扩展名：Android 11+ 的 `Download/` 由 MediaStore 接管，没有扩展名的
  /// 文件在部分机型上会被拒；`.txt` 在 Downloads 集合里任何机型都收。
  Future<DownloadProbeResult> probe(String dirPath) async {
    final access = await storageAccessNeedOf(dirPath);
    if (await _isVolumeMissing(dirPath)) {
      return DownloadProbeResult(
        path: dirPath,
        outcome: DownloadProbeOutcome.volumeMissing,
        access: access,
      );
    }
    if (access != StorageAccessNeed.none &&
        !await _permissionService.hasStorageAccess(access)) {
      return DownloadProbeResult(
        path: dirPath,
        outcome: DownloadProbeOutcome.needsPermission,
        access: access,
      );
    }

    // 记下哪一层是我们建的：失败时只删这些（从深到浅、只删空的）。
    final created = <String>[];
    Future<void> rollback() async {
      for (final dir in created.reversed) {
        try {
          await Directory(dir).delete();
        } catch (_) {
          break;
        }
      }
    }

    final stamp = DateTime.now().microsecondsSinceEpoch;
    final probeFile = File(path.join(dirPath, '.iwara_probe_$stamp.txt'));
    final renamed = path.join(dirPath, '.iwara_probe_${stamp}_ok.txt');
    try {
      var missing = dirPath;
      final toCreate = <String>[];
      while (!await Directory(missing).exists()) {
        toCreate.add(missing);
        final parent = path.dirname(missing);
        if (parent == missing) break;
        missing = parent;
      }
      for (final dir in toCreate.reversed) {
        await Directory(dir).create();
        created.add(dir);
      }
      await probeFile.writeAsString('iwara download location probe');
      final moved = await probeFile.rename(renamed);
      await moved.delete();
    } catch (e) {
      LogUtils.w('下载目录探测失败: $dirPath ($e)', 'DownloadPathService');
      // 探针文件可能已经写出来了，尽力收掉。
      for (final leftover in [probeFile.path, renamed]) {
        try {
          final f = File(leftover);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
      await rollback();
      return DownloadProbeResult(
        path: dirPath,
        outcome: access != StorageAccessNeed.none && _isPermissionDenied(e)
            ? DownloadProbeOutcome.needsPermission
            : DownloadProbeOutcome.notWritable,
        access: access,
        error: e,
      );
    }

    return DownloadProbeResult(
      path: dirPath,
      outcome: DownloadProbeOutcome.ok,
      access: access,
      freeBytes: await freeSpaceOf(dirPath),
      createdDirectories: List.unmodifiable(created),
    );
  }

  /// 撤回一次成功的探测：把它新建的目录从深到浅删掉，只删空的——探测之后
  /// 谁往里放了东西，就留着。
  Future<void> discardProbe(DownloadProbeResult result) async {
    for (final dir in result.createdDirectories.reversed) {
      try {
        await Directory(dir).delete();
      } catch (_) {
        break;
      }
    }
  }

  /// 目录所在卷的可用空间（字节）；拿不到返回 null。
  ///
  /// dart:io 没有 statvfs，这里借系统自带的 `df`（Android 的 toybox 也有）/
  /// Windows 的 PowerShell 读一次。目录还没建出来就往上找第一个存在的祖先。
  Future<int?> freeSpaceOf(String dirPath) async {
    try {
      var existing = dirPath;
      while (!await Directory(existing).exists()) {
        final parent = path.dirname(existing);
        if (parent == existing) return null;
        existing = parent;
      }
      if (Platform.isWindows) {
        final drive = path
            .rootPrefix(existing)
            .replaceAll(RegExp(r'[:\\/]+$'), '');
        if (drive.length != 1) return null;
        final result = await Process.run('powershell', [
          '-NoProfile',
          '-NonInteractive',
          '-Command',
          '(Get-PSDrive -Name $drive).Free',
        ]).timeout(const Duration(seconds: 5));
        return int.tryParse((result.stdout as String).trim());
      }
      if (Platform.isIOS) return null;
      final result = await Process.run('df', [
        '-Pk',
        existing,
      ]).timeout(const Duration(seconds: 3));
      if (result.exitCode != 0) return null;
      return parseDfAvailableBytes(result.stdout as String);
    } catch (e) {
      LogUtils.d('读取可用空间失败: $dirPath ($e)', 'DownloadPathService');
      return null;
    }
  }

  /// 解析 `df -Pk` 的输出，返回可用字节数（第二行第四列，单位 KB）。
  static int? parseDfAvailableBytes(String output) {
    final lines = output
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.length < 2) return null;
    // 挂载点名里可能有空格，但前几列不会：按空白切，第 4 列就是 Available。
    final cols = lines[1].split(RegExp(r'\s+'));
    if (cols.length < 4) return null;
    final kb = int.tryParse(cols[3]);
    return kb == null ? null : kb * 1024;
  }

  /// 桌面端的系统「下载」文件夹（Linux 按 XDG 取本地化名、Windows 认 Known
  /// Folder——不再手拼 `$HOME/Downloads`）。拿不到返回 null。
  Future<String?> _systemDownloadsDirectory() async {
    if (!GetPlatform.isDesktop) return null;
    try {
      return (await path_provider.getDownloadsDirectory())?.path;
    } catch (e) {
      LogUtils.w('获取系统下载目录失败: $e', 'DownloadPathService');
      return null;
    }
  }

  /// Android 主存储根（`/storage/emulated/<用户>`）。不写死 0：工作资料、
  /// 多用户下是别的数字。从 App 外部专属目录反推卷根。
  Future<String?> _androidPrimaryStorageRoot() async {
    try {
      final dir = await path_provider.getExternalStorageDirectory();
      if (dir == null) return null;
      return storageVolumeRootOf(dir.path);
    } catch (e) {
      LogUtils.w('获取主存储根失败: $e', 'DownloadPathService');
      return null;
    }
  }

  /// Android 已挂载的可移除卷根（SD 卡 / U 盘），同样从各卷上的 App 专属目录反推。
  Future<List<String>> _androidRemovableVolumeRoots() async {
    try {
      final dirs = await path_provider.getExternalStorageDirectories() ?? [];
      final roots = <String>{};
      for (final dir in dirs) {
        final root = storageVolumeRootOf(dir.path);
        if (root != null && !DownloadLocation.isPrimaryVolumeRoot(root)) {
          roots.add(root);
        }
      }
      return roots.toList();
    } catch (e) {
      LogUtils.w('获取可移除存储卷失败: $e', 'DownloadPathService');
      return const [];
    }
  }

  /// 「更改位置」里列出来的快捷选项（不含「选择其他文件夹…」和桌面的「每次询问」）。
  Future<List<DownloadLocationOption>> quickLocationOptions() async {
    final options = <DownloadLocationOption>[];
    Future<void> add(String dirPath, DownloadLocationOptionRole role) async {
      if (options.any((o) => path.equals(o.path, dirPath))) return;
      options.add(
        DownloadLocationOption(
          location: await describeLocation(dirPath),
          role: role,
        ),
      );
    }

    if (GetPlatform.isAndroid) {
      final publicDefault = await _androidPublicDownloadDirectory();
      if (publicDefault != null) {
        await add(publicDefault, DownloadLocationOptionRole.recommended);
      }
      await add(
        await _appPrivateDownloadDirectory(),
        DownloadLocationOptionRole.appPrivate,
      );
      // 分区存储之前 File API 写不进 SD 卡（只能走 SAF），列出来也用不了。
      if (await _permissionService.androidSdkInt() >= 30) {
        for (final root in await _androidRemovableVolumeRoots()) {
          await add(
            path.posix.join(root, publicFolderName),
            DownloadLocationOptionRole.removable,
          );
        }
      }
    } else if (GetPlatform.isDesktop) {
      final downloads = await _systemDownloadsDirectory();
      if (downloads != null) {
        await add(
          path.join(downloads, publicFolderName),
          DownloadLocationOptionRole.recommended,
        );
      }
    } else {
      await add(
        await _appPrivateDownloadDirectory(),
        DownloadLocationOptionRole.recommended,
      );
    }
    return options;
  }

  /// Android 的「下载 › LoveIwara」。拿不到主存储根返回 null。
  Future<String?> _androidPublicDownloadDirectory() async {
    final root = await _androidPrimaryStorageRoot();
    if (root == null) return null;
    return path.posix.join(root, 'Download', publicFolderName);
  }

  /// 格式化字节数为可读字符串
  static String formatBytes(int bytes) {
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

  /// 验证路径是否有效。
  ///
  /// ⛔ 不建目录：以前这里 `create(recursive: true)`，设置页每刷新一次状态就把
  /// 用户手输的错路径真的建出来。要实地检查请用 [probe]。
  Future<PathValidationResult> validatePath(String pathStr) async {
    try {
      final reason = await _checkDirectory(pathStr, create: false);
      switch (reason) {
        case DownloadFallbackReason.needsPermission:
          return PathValidationResult(
            isValid: false,
            reason: PathValidationReason.noPermission,
            message: _t.lackStoragePermission,
            canFix: true,
          );
        case DownloadFallbackReason.volumeMissing:
        case DownloadFallbackReason.cannotCreate:
          return PathValidationResult(
            isValid: false,
            reason: PathValidationReason.cannotCreate,
            message: _t.cannotCreateDirectory,
            canFix: false,
          );
        case DownloadFallbackReason.notWritable:
          return PathValidationResult(
            isValid: false,
            reason: PathValidationReason.notWritable,
            message: _t.directoryNotWritable,
            canFix: false,
          );
        case null:
          break;
      }

      final freeSpace = await freeSpaceOf(pathStr);
      if (freeSpace != null && freeSpace < lowSpaceThresholdBytes) {
        return PathValidationResult(
          isValid: true,
          reason: PathValidationReason.lowSpace,
          message: '${_t.insufficientSpace} (${formatBytes(freeSpace)})',
          canFix: false,
          availableSpace: freeSpace,
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

  /// 没开自定义路径时的下载目录（「默认位置」）。
  ///
  ///   - Android 11+：`/storage/emulated/<用户>/Download/LoveIwara`——不用任何
  ///     权限、卸载不删、系统文件管理器与相册都看得到；
  ///   - Android 10 及以下：仍是 App 专属空间（公共目录要先要存储权限，默认值
  ///     不该一装上就弹权限）；
  ///   - 桌面：系统「下载」文件夹下的 LoveIwara（批量下载 / 单图用；单个下载
  ///     在没开自定义路径时照旧每次弹「另存为」）；
  ///   - iOS：App 专属空间（本阶段不变）。
  ///
  /// 取不到对应目录时一律退回 App 专属空间。
  ///
  /// ⚠️ 只影响「没开自定义路径」的用户；已经设过 CUSTOM_DOWNLOAD_PATH 的不变。
  /// 老的 Android 11+ 用户（没开自定义路径）默认目录会从 App 专属空间变过来，
  /// 之前的下载留在原处照常能播，设置页的 DownloadsOutsideFolderCard 会提示搬。
  Future<String> getDefaultDownloadPath() async {
    try {
      if (GetPlatform.isAndroid) {
        if (await _permissionService.androidSdkInt() >= 30) {
          final publicDir = await _androidPublicDownloadDirectory();
          if (publicDir != null) return publicDir;
        }
      } else if (GetPlatform.isDesktop) {
        final downloads = await _systemDownloadsDirectory();
        if (downloads != null) return path.join(downloads, publicFolderName);
      }
    } catch (e) {
      LogUtils.w('计算默认下载目录失败，改用应用专用目录: $e', 'DownloadPathService');
    }
    return _appPrivateDownloadDirectory();
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
    // 出厂默认 = 「按作者」预设（与 ConfigKey.defaultValue 保持一致；
    // 首跑冻结机制保证这只影响显式点了重置/新装的用户，存量值不动）。
    await _configService.setSetting(
      ConfigKey.VIDEO_FILENAME_TEMPLATE,
      '%authorcache/%title_%quality',
    );
    await _configService.setSetting(
      ConfigKey.GALLERY_FILENAME_TEMPLATE,
      '%authorcache/%title_%id',
    );
    await _configService.setSetting(
      ConfigKey.IMAGE_FILENAME_TEMPLATE,
      '%authorcache/%title/%filename',
    );
  }

  /// 获取路径状态信息（同步占位版：只看配置，不做 I/O）。
  PathStatusInfo getPathStatusInfo() {
    final isCustomPathEnabled =
        _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = _configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;

    if (!isCustomPathEnabled || customPath.isEmpty) {
      return PathStatusInfo(
        currentPath: _defaultDownloadPath.value,
        isCustomPath: false,
        isValid: true,
        validationResult: PathValidationResult(
          isValid: true,
          reason: PathValidationReason.valid,
          message: _t.usingDefaultAppDirectory,
          canFix: false,
        ),
        askEveryTime: asksEveryTime,
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

  /// 获取路径状态信息（异步版本，含验证；不建目录）。
  Future<PathStatusInfo> getPathStatusInfoAsync() => _computePathStatus();

  Future<PathStatusInfo> _computePathStatus() async {
    final isCustomPathEnabled =
        _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = await _currentCustomPath();
    final isCustom = isCustomPathEnabled && customPath.isNotEmpty;
    final target = isCustom ? customPath : await getDefaultDownloadPath();

    var reason = await _checkDirectory(target, create: false);
    // 目录还没建出来时，状态刷新看不出「建不出来」——那要靠下载时记下的。
    final runtime = _runtimeFallback;
    if (reason == null &&
        runtime != null &&
        path.equals(runtime.target, target) &&
        !await Directory(target).exists()) {
      reason = runtime.reason;
    }

    final location = await describeLocation(target);
    final fallbackPath = reason == null
        ? null
        : await _appPrivateDownloadDirectory();
    final freeBytes = await freeSpaceOf(fallbackPath ?? target);
    final access = await storageAccessNeedOf(target);

    final PathValidationResult validation;
    switch (reason) {
      case DownloadFallbackReason.needsPermission:
        validation = PathValidationResult(
          isValid: false,
          reason: PathValidationReason.noPermission,
          message: _t.lackStoragePermission,
          canFix: true,
        );
      case DownloadFallbackReason.volumeMissing:
      case DownloadFallbackReason.cannotCreate:
        validation = PathValidationResult(
          isValid: false,
          reason: PathValidationReason.cannotCreate,
          message: _t.cannotCreateDirectory,
          canFix: false,
        );
      case DownloadFallbackReason.notWritable:
        validation = PathValidationResult(
          isValid: false,
          reason: PathValidationReason.notWritable,
          message: _t.directoryNotWritable,
          canFix: false,
        );
      case null:
        final low = freeBytes != null && freeBytes < lowSpaceThresholdBytes;
        validation = PathValidationResult(
          isValid: true,
          reason: low
              ? PathValidationReason.lowSpace
              : PathValidationReason.valid,
          message: low
              ? '${_t.insufficientSpace} (${formatBytes(freeBytes)})'
              : (isCustom ? _t.pathValid : _t.usingDefaultAppDirectory),
          canFix: false,
          availableSpace: freeBytes,
        );
    }

    return PathStatusInfo(
      currentPath: fallbackPath ?? target,
      isCustomPath: isCustom && reason == null,
      isValid: reason == null,
      validationResult: validation,
      selectedPath: isCustom ? customPath : null,
      targetPath: target,
      location: location,
      fallbackReason: reason,
      freeBytes: freeBytes,
      accessNeed: access,
      askEveryTime: asksEveryTime,
    );
  }

  // ---------- 改位置（设置页「更改位置」流程的落点） ----------

  /// 把下载目录改成 [dirPath]。**调用方必须先 [probe] 过**——这里只写配置。
  Future<void> commitDownloadLocation(String dirPath) async {
    await _configService.setSetting(ConfigKey.CUSTOM_DOWNLOAD_PATH, dirPath);
    await _configService.setSetting(
      ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH,
      true,
    );
    _runtimeFallback = null;
    await refreshPathStatus();
  }

  /// 桌面端「每次询问保存位置」（沿用 ENABLE_CUSTOM_DOWNLOAD_PATH=false 的老含义，
  /// 不新增配置；自定义路径原样留着，下次切回来还在）。
  Future<void> setAskEveryTime() async {
    await _configService.setSetting(
      ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH,
      false,
    );
    _runtimeFallback = null;
    await refreshPathStatus();
  }

  /// 恢复默认下载位置（关自定义路径并清空；桌面端即回到「每次询问」）。
  Future<void> restoreDefaultLocation() async {
    await _configService.setSetting(
      ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH,
      false,
    );
    await _configService.setSetting(ConfigKey.CUSTOM_DOWNLOAD_PATH, '');
    _runtimeFallback = null;
    await refreshPathStatus();
  }

  /// 申请写 [dirPath] 所需的那一档存储权限，回来后刷新状态。返回最终有没有。
  Future<bool> requestAccessFor(String dirPath) async {
    final need = await storageAccessNeedOf(dirPath);
    final granted = await _permissionService.requestStorageAccess(need);
    await refreshPermissionAndRelated();
    return granted;
  }

  // ---------- 响应式刷新方法供 UI 调用 ----------

  /// 刷新存储权限状态
  Future<void> _refreshPermissionStatus() async {
    try {
      _storagePermissionLoading.value = true;
      final granted = await _permissionService.hasStoragePermission();
      _storagePermissionGranted.value = granted;
    } finally {
      _storagePermissionLoading.value = false;
    }
  }

  /// 供外部调用：刷新存储权限与路径状态（从系统设置页回来时调）。
  Future<void> refreshPermissionAndRelated() async {
    await _refreshPermissionStatus();
    await refreshPathStatus();
  }

  bool _refreshQueued = false;
  Future<void>? _refreshing;

  /// 刷新当前路径状态（含验证；不建目录）。
  ///
  /// 并发调用合并：正在刷的时候再来一次，只在当前这次结束后补刷一次。
  Future<void> refreshPathStatus() async {
    if (_refreshing != null) {
      _refreshQueued = true;
      return _refreshing;
    }
    final completer = Completer<void>();
    _refreshing = completer.future;
    try {
      _pathStatusLoading.value = true;
      do {
        _refreshQueued = false;
        try {
          _defaultDownloadPath.value = await getDefaultDownloadPath();
          _pathStatus.value = await _computePathStatus();
        } catch (e) {
          LogUtils.e('刷新路径状态失败', tag: 'DownloadPathService', error: e);
        }
      } while (_refreshQueued);
    } finally {
      _pathStatusLoading.value = false;
      _refreshing = null;
      completer.complete();
    }
  }
}

class _RuntimeFallback {
  const _RuntimeFallback(this.target, this.reason);
  final String target;
  final DownloadFallbackReason reason;
}

/// 路径状态信息
class PathStatusInfo {
  final String currentPath; // 当前实际使用的路径（回退时是 App 专属空间）
  final bool isCustomPath; // 是否为自定义路径
  final bool isValid; // 路径是否有效
  final PathValidationResult validationResult;
  final String? selectedPath; // 用户选择的路径（可能与实际路径不同）

  /// 想要的目录（自定义路径或默认位置），不管能不能用。
  final String? targetPath;

  /// [targetPath] 的结构化描述（友好名、类别）。
  final DownloadLocation? location;

  /// 非空 = [targetPath] 暂时不能用，下载临时落在 [currentPath]（App 专属空间）。
  final DownloadFallbackReason? fallbackReason;

  /// 实际落脚目录所在卷的可用空间；拿不到为 null。
  final int? freeBytes;

  /// 写 [targetPath] 要哪一档存储权限。
  final StorageAccessNeed accessNeed;

  /// 桌面端「每次询问保存位置」。
  final bool askEveryTime;

  const PathStatusInfo({
    required this.currentPath,
    required this.isCustomPath,
    required this.isValid,
    required this.validationResult,
    this.selectedPath,
    this.targetPath,
    this.location,
    this.fallbackReason,
    this.freeBytes,
    this.accessNeed = StorageAccessNeed.none,
    this.askEveryTime = false,
  });

  bool get isFallback => fallbackReason != null;

  bool get isLowSpace =>
      !isFallback &&
      freeBytes != null &&
      freeBytes! < DownloadPathService.lowSpaceThresholdBytes;
}
