import 'dart:io';
import 'package:get/get.dart';
import 'package:file_selector/file_selector.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:path/path.dart' as path;

/// 路径验证原因枚举
enum PathValidationReason {
  valid,                    // 路径有效
  noPermission,            // 缺少权限
  noPublicDirectoryAccess, // 无公共目录访问权限
  cannotCreate,            // 无法创建目录
  notWritable,             // 不可写
  lowSpace,                // 空间不足
  unknown,                 // 未知错误
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

  final ConfigService _configService = Get.find<ConfigService>();
  late FilenameTemplateService _filenameTemplateService;

  @override
  void onInit() {
    super.onInit();
    // 确保文件命名模板服务已初始化
    if (!Get.isRegistered<FilenameTemplateService>()) {
      Get.put(FilenameTemplateService());
    }
    _filenameTemplateService = Get.find<FilenameTemplateService>();
  }

  /// 获取视频下载路径
  Future<String?> getVideoDownloadPath({
    required Video video,
    required String quality,
    String? downloadUrl,
  }) async {
    try {
      // 生成文件名
      final template = _configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String;
      LogUtils.d('使用文件命名模板: $template', 'DownloadPathService');

      final filename = _filenameTemplateService.generateVideoFilename(
        template: template,
        video: video,
        quality: quality,
        originalFilename: downloadUrl != null ? _extractFilenameFromUrl(downloadUrl) : null,
      );
      LogUtils.d('生成的文件名: $filename', 'DownloadPathService');

      final isCustomPathEnabled = _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
      final customPath = _configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;
      LogUtils.d('自定义路径启用状态: $isCustomPathEnabled, 自定义路径: $customPath', 'DownloadPathService');

      if (GetPlatform.isDesktop && !isCustomPathEnabled) {
        // 桌面平台且未启用自定义路径：让用户选择保存位置
        final result = await getSaveLocation(
          suggestedName: filename,
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'MP4 Video',
              extensions: ['mp4'],
            ),
          ],
        );
        return result?.path;
      } else {
        // 移动平台或桌面端启用自定义路径：使用配置的路径
        final basePath = await _getBasePath('videos');
        return path.join(basePath, filename);
      }
    } catch (e) {
      LogUtils.e('获取视频下载路径失败', tag: 'DownloadPathService', error: e);
      return null;
    }
  }

  /// 获取图库下载路径
  Future<String?> getGalleryDownloadPath({
    required ImageModel gallery,
  }) async {
    try {
      // 生成文件夹名
      final template = _configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] as String;
      final foldername = _filenameTemplateService.generateGalleryFoldername(
        template: template,
        gallery: gallery,
      );

      final isCustomPathEnabled = _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;

      if (GetPlatform.isDesktop && !isCustomPathEnabled) {
        // 桌面平台且未启用自定义路径：让用户选择保存位置
        final result = await getSaveLocation(
          suggestedName: foldername,
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'folders',
              extensions: [''],
            ),
          ],
        );
        return result?.path;
      } else {
        // 移动平台或桌面端启用自定义路径：使用配置的路径
        final basePath = await _getBasePath('galleries');
        return path.join(basePath, foldername);
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
      final template = _configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] as String;
      final filename = _filenameTemplateService.generateImageFilename(
        template: template,
        title: title,
        authorName: authorName,
        authorUsername: authorUsername,
        id: id,
        originalFilename: originalFilename,
      );

      // 移动平台：使用配置的路径（单张图片下载通常在移动端）
      final basePath = await _getBasePath('single');
      final sanitizedTitle = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      return path.join(basePath, sanitizedTitle, filename);
    } catch (e) {
      LogUtils.e('获取图片下载路径失败', tag: 'DownloadPathService', error: e);
      // 返回默认路径
      final basePath = await _getBasePath('single');
      return path.join(basePath, originalFilename ?? 'image.jpg');
    }
  }

  /// 获取基础下载路径
  Future<String> _getBasePath(String subPath) async {
    final isCustomPathEnabled = _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = _configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;

    LogUtils.d('_getBasePath - 子路径: $subPath, 启用自定义: $isCustomPathEnabled, 自定义路径: $customPath', 'DownloadPathService');

    if (isCustomPathEnabled && customPath.isNotEmpty) {
      // 检查权限
      final permissionService = Get.find<PermissionService>();
      final hasPermission = await permissionService.hasStoragePermission();

      if (!hasPermission) {
        LogUtils.w('无存储权限，使用应用专用目录', 'DownloadPathService');
        final appDir = await CommonUtils.getAppDirectory(pathSuffix: path.join('downloads', subPath));
        return appDir.path;
      }

      // 使用自定义路径
      String finalPath;

      if (GetPlatform.isAndroid) {
        // Android平台：检查路径是否为公共目录
        if (_isPublicDirectory(customPath)) {
          // 检查是否有访问公共目录的权限
          final canAccessPublic = await permissionService.canAccessPublicDirectories();
          if (!canAccessPublic) {
            LogUtils.w('无公共目录访问权限，使用应用专用目录替代: $customPath', 'DownloadPathService');
            final appDir = await CommonUtils.getAppDirectory(pathSuffix: path.join('downloads', subPath));
            finalPath = appDir.path;
          } else {
            finalPath = path.join(customPath, subPath);
          }
        } else {
          finalPath = path.join(customPath, subPath);
        }
      } else {
        // 其他平台直接使用自定义路径
        finalPath = path.join(customPath, subPath);
      }

      final customDir = Directory(finalPath);
      if (!await customDir.exists()) {
        try {
          await customDir.create(recursive: true);
          LogUtils.d('创建自定义目录: ${customDir.path}', 'DownloadPathService');
        } catch (e) {
          LogUtils.e('创建自定义目录失败，使用应用专用目录', tag: 'DownloadPathService', error: e);
          final appDir = await CommonUtils.getAppDirectory(pathSuffix: path.join('downloads', subPath));
          return appDir.path;
        }
      }

      // 验证目录是否可写
      if (await _isDirectoryWritable(customDir.path)) {
        LogUtils.d('使用自定义路径: ${customDir.path}', 'DownloadPathService');
        return customDir.path;
      } else {
        LogUtils.w('自定义目录不可写，使用应用专用目录', 'DownloadPathService');
        final appDir = await CommonUtils.getAppDirectory(pathSuffix: path.join('downloads', subPath));
        return appDir.path;
      }
    } else {
      // 使用默认应用路径
      final dir = await CommonUtils.getAppDirectory(pathSuffix: path.join('downloads', subPath));
      LogUtils.d('使用默认路径: ${dir.path}', 'DownloadPathService');
      return dir.path;
    }
  }

  /// 检查是否为Android公共目录
  bool _isPublicDirectory(String dirPath) {
    final publicPaths = [
      '/storage/emulated/0/Download',
      '/storage/emulated/0/下载',
      '/storage/emulated/0/Pictures',
      '/storage/emulated/0/Movies',
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Documents',
      '/sdcard/Download',
      '/sdcard/下载',
      '/sdcard/Pictures',
      '/sdcard/Movies',
      '/sdcard/Music',
      '/sdcard/Documents',
    ];

    return publicPaths.any((publicPath) => dirPath.startsWith(publicPath));
  }

  /// 检查目录是否可写
  Future<bool> _isDirectoryWritable(String dirPath) async {
    try {
      final testFile = File(path.join(dirPath, '.test_write_${DateTime.now().millisecondsSinceEpoch}'));
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
        final stat = await dir.stat();
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
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
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

      // 1. 检查权限
      final permissionService = Get.find<PermissionService>();
      final hasPermission = await permissionService.hasStoragePermission();

      if (!hasPermission) {
        return PathValidationResult(
          isValid: false,
          reason: PathValidationReason.noPermission,
          message: '缺少存储权限',
          canFix: true,
        );
      }

      // 2. 检查是否为公共目录且无相应权限
      if (GetPlatform.isAndroid && _isPublicDirectory(pathStr)) {
        final canAccessPublic = await permissionService.canAccessPublicDirectories();
        if (!canAccessPublic) {
          return PathValidationResult(
            isValid: false,
            reason: PathValidationReason.noPublicDirectoryAccess,
            message: '无法访问公共目录，需要"所有文件访问权限"',
            canFix: true,
          );
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
            message: '无法创建目录: ${e.toString()}',
            canFix: false,
          );
        }
      }

      // 4. 检查是否有写权限
      if (!await _isDirectoryWritable(pathStr)) {
        return PathValidationResult(
          isValid: false,
          reason: PathValidationReason.notWritable,
          message: '目录不可写',
          canFix: false,
        );
      }

      // 5. 检查可用空间
      final freeSpace = await _getAvailableSpace(pathStr);
      if (freeSpace != null && freeSpace < 100 * 1024 * 1024) { // 小于100MB
        return PathValidationResult(
          isValid: true,
          reason: PathValidationReason.lowSpace,
          message: '可用空间不足 (${_formatBytes(freeSpace)})',
          canFix: false,
        );
      }

      return PathValidationResult(
        isValid: true,
        reason: PathValidationReason.valid,
        message: '路径有效',
        canFix: false,
        availableSpace: freeSpace,
      );
    } catch (e) {
      LogUtils.e('路径验证失败: $pathStr', tag: 'DownloadPathService', error: e);
      return PathValidationResult(
        isValid: false,
        reason: PathValidationReason.unknown,
        message: '验证失败: ${e.toString()}',
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
      // Android平台推荐使用应用专用目录
      final dir = await CommonUtils.getAppDirectory(pathSuffix: 'downloads');
      return dir.path;
    } else {
      // 其他平台使用默认路径
      return await getDefaultDownloadPath();
    }
  }

  /// 选择下载文件夹（仅桌面平台）
  Future<String?> selectDownloadFolder() async {
    if (!GetPlatform.isDesktop) {
      return null;
    }

    try {
      return await getDirectoryPath();
    } catch (e) {
      LogUtils.e('选择下载文件夹失败', tag: 'DownloadPathService', error: e);
      return null;
    }
  }

  /// 获取当前配置的下载路径信息
  Map<String, dynamic> getDownloadPathInfo() {
    final isCustomPathEnabled = _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = _configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;
    
    return {
      'isCustomPathEnabled': isCustomPathEnabled,
      'customPath': customPath,
      'videoTemplate': _configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String,
      'galleryTemplate': _configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] as String,
      'imageTemplate': _configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] as String,
    };
  }

  /// 重置为默认配置
  Future<void> resetToDefault() async {
    await _configService.setSetting(ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH, false);
    await _configService.setSetting(ConfigKey.CUSTOM_DOWNLOAD_PATH, '');
    await _configService.setSetting(ConfigKey.VIDEO_FILENAME_TEMPLATE, '%title_%quality');
    await _configService.setSetting(ConfigKey.GALLERY_FILENAME_TEMPLATE, '%title_%id');
    await _configService.setSetting(ConfigKey.IMAGE_FILENAME_TEMPLATE, '%title_%filename');
  }

  /// 获取路径状态信息
  Future<PathStatusInfo> getPathStatusInfo() async {
    final isCustomPathEnabled = _configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = _configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;

    if (!isCustomPathEnabled || customPath.isEmpty) {
      final defaultPath = await getDefaultDownloadPath();
      return PathStatusInfo(
        currentPath: defaultPath,
        isCustomPath: false,
        isValid: true,
        validationResult: PathValidationResult(
          isValid: true,
          reason: PathValidationReason.valid,
          message: '使用默认应用目录',
          canFix: false,
        ),
      );
    }

    final validationResult = await validatePath(customPath);
    final actualPath = validationResult.isValid ? customPath : await getDefaultDownloadPath();

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

    // 1. 应用专用目录（总是推荐）
    final appDir = await CommonUtils.getAppDirectory(pathSuffix: 'downloads');
    paths.add(RecommendedPath(
      path: appDir.path,
      name: '应用专用目录',
      description: '安全可靠，无需额外权限',
      type: RecommendedPathType.appPrivate,
      isRecommended: true,
    ));

    if (GetPlatform.isAndroid) {
      final permissionService = Get.find<PermissionService>();
      final hasPermission = await permissionService.canAccessPublicDirectories();

      if (hasPermission) {
        // 2. 下载目录
        paths.add(RecommendedPath(
          path: '/storage/emulated/0/Download',
          name: '下载目录',
          description: '系统默认下载位置，便于管理',
          type: RecommendedPathType.publicDownload,
          isRecommended: true,
        ));

        // 3. 影片目录
        paths.add(RecommendedPath(
          path: '/storage/emulated/0/Movies',
          name: '影片目录',
          description: '系统影片目录，媒体应用可识别',
          type: RecommendedPathType.publicMovies,
          isRecommended: false,
        ));
      } else {
        // 无权限时显示但标记为不可用
        paths.add(RecommendedPath(
          path: '/storage/emulated/0/Download',
          name: '下载目录',
          description: '需要存储权限才能访问',
          type: RecommendedPathType.publicDownload,
          isRecommended: false,
          requiresPermission: true,
        ));
      }
    } else if (GetPlatform.isIOS) {
      // iOS推荐路径
      try {
        final documentsDir = await CommonUtils.getAppDirectory();
        paths.add(RecommendedPath(
          path: documentsDir.path,
          name: '文档目录',
          description: 'iOS应用文档目录',
          type: RecommendedPathType.appPrivate,
          isRecommended: true,
        ));
      } catch (e) {
        LogUtils.e('获取iOS文档目录失败', tag: 'DownloadPathService', error: e);
      }
    }

    return paths;
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
}

/// 路径状态信息
class PathStatusInfo {
  final String currentPath;      // 当前实际使用的路径
  final bool isCustomPath;       // 是否为自定义路径
  final bool isValid;           // 路径是否有效
  final PathValidationResult validationResult;
  final String? selectedPath;   // 用户选择的路径（可能与实际路径不同）

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
  appPrivate,      // 应用专用目录
  publicDownload,  // 公共下载目录
  publicMovies,    // 公共影片目录
  custom,          // 自定义目录
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
