import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/common_utils.dart';

class DeepLinkService extends GetxService {
  final _appLinks = AppLinks();
  bool _isReady = false;
  Uri? _pendingInitialLink;

  // macOS 文件处理 MethodChannel
  static const MethodChannel _fileHandlerChannel = MethodChannel(
    'com.example.i_iwara/file_handler',
  );

  /// 判断一个URI是否可以被应用内处理
  static bool canHandleInternally(Uri uri) {
    if (uri.pathSegments.isEmpty) return false;

    final pathSegments = uri.pathSegments;
    switch (pathSegments[0]) {
      case 'video':
      case 'playlist':
      case 'image':
      case 'post':
        // 这些类型只需要第一个 pathSegment 就可以判断
        return pathSegments.length > 1;

      case 'profile':
        // profile 可以是 /profile/userName 或者 /profile/userName/playlists
        return pathSegments.length > 1;

      case 'forum':
        // forum 可以是 /forum/categoryId 或者 /forum/categoryId/threadId
        return pathSegments.length > 1;

      default:
        return false;
    }
  }

  /// 判断一个链接字符串是否可以被应用内处理
  static bool canHandleLink(String link) {
    try {
      final uri = Uri.parse(link);
      // 检查是否是iwara链接
      if (!uri.host.contains("iwara")) return false;

      return canHandleInternally(uri);
    } catch (e) {
      return false;
    }
  }

  /// 如果需要添加更多链接 请在 {@link AndroidManifest.xml} 中也做配置
  Future<void> init() async {
    LogUtils.i('DeepLinkService 初始化开始', 'DeepLinkService');

    // 设置文件处理 MethodChannel 监听器（所有桌面和移动平台）
    if (!GetPlatform.isWeb) {
      _fileHandlerChannel.setMethodCallHandler((call) async {
        if (call.method == 'onFileOpened') {
          final String fileUrlString = call.arguments as String;
          final platformName = CommonUtils.getPlatformName();
          LogUtils.i(
            '收到 $platformName 文件打开事件: $fileUrlString',
            'DeepLinkService',
          );

          try {
            final Uri fileUri = Uri.parse(fileUrlString);
            _handleLink(fileUri);
          } catch (e) {
            LogUtils.e('解析文件 URL 失败: $e', tag: 'DeepLinkService', error: e);
          }
        }
        return null; // Return null for unhandled calls or void methods
      });
      final platformName = CommonUtils.getPlatformName();
      LogUtils.i('已设置 $platformName 文件处理监听器', 'DeepLinkService');
    }

    // 监听所有链接事件
    _appLinks.uriLinkStream.listen((Uri? uri) {
      LogUtils.i('收到 URI 链接流事件: $uri', 'DeepLinkService');
      if (uri != null) {
        _handleLink(uri);
      }
    });

    // 保存初始链接，但不立即处理
    _pendingInitialLink = await _appLinks.getInitialLink();
    LogUtils.i('获取到初始链接: $_pendingInitialLink', 'DeepLinkService');
  }

  // 标记服务已准备就绪
  void markReady() {
    LogUtils.i('DeepLinkService 标记为已准备就绪', 'DeepLinkService');
    _isReady = true;

    // 通知原生端 Flutter 已准备好（macOS）
    if (GetPlatform.isMacOS) {
      _fileHandlerChannel.invokeMethod('ready').then((_) {
        LogUtils.d('已通知 macOS 端 Flutter 准备就绪', 'DeepLinkService');
      }).catchError((e) {
        LogUtils.w('通知 macOS 端时出错: $e', 'DeepLinkService');
      });
    }

    // 处理待处理的初始链接
    if (_pendingInitialLink != null) {
      LogUtils.i('准备处理待处理的初始链接: $_pendingInitialLink', 'DeepLinkService');
      // 使用Future.delayed确保在下一个Frame处理，给予足够时间初始化路由系统
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_pendingInitialLink != null) {
          LogUtils.i('延迟后开始处理初始链接: $_pendingInitialLink', 'DeepLinkService');
          _handleLink(_pendingInitialLink!);
          _pendingInitialLink = null;
        }
      });
    } else {
      LogUtils.d('没有待处理的初始链接', 'DeepLinkService');
    }
  }

  void _handleLink(Uri uri) {
    LogUtils.i('_handleLink 被调用，URI: $uri', 'DeepLinkService');

    // 如果服务还未准备就绪，保存链接等待处理
    if (!_isReady) {
      LogUtils.d('服务未准备好，保存链接等待处理', 'DeepLinkService');
      _pendingInitialLink = uri;
      return;
    }

    // 确保在主UI线程中执行导航操作
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LogUtils.d('在 PostFrameCallback 中处理链接', 'DeepLinkService');
      processLink(uri);
    });
  }

  void processLink(Uri uri) {
    LogUtils.i('processLink 开始处理 URI: $uri', 'DeepLinkService');
    LogUtils.i(
      'URI scheme: ${uri.scheme}, path: ${uri.path}',
      'DeepLinkService',
    );

    // 处理不同类型的链接
    final pathSegments = uri.pathSegments;

    // 处理本地文件 URI (file:// 或 content://)
    if (uri.scheme == 'file' || uri.scheme == 'content') {
      LogUtils.i('识别为本地文件 URI，调用 _handleFileUri', 'DeepLinkService');
      _handleFileUri(uri);
      return;
    }

    if (pathSegments.isEmpty) {
      LogUtils.w('URI pathSegments 为空，无法处理', 'DeepLinkService');
      return;
    }

    // 确保路由系统已经准备就绪
    if (!Get.isRegistered<AppService>()) {
      LogUtils.d('AppService 未注册，延迟500ms后重试', 'DeepLinkService');
      Future.delayed(const Duration(milliseconds: 500), () => processLink(uri));
      return;
    }

    LogUtils.d('处理在线链接，第一个路径段: ${pathSegments[0]}', 'DeepLinkService');

    switch (pathSegments[0]) {
      case 'video':
        // 视频详情页 目前url可以识别 iwara.tv/video/id 和 iwara.tv/video/id/subId 两种路径
        if (pathSegments.length > 1) {
          final videoId = pathSegments[1];
          NaviService.navigateToVideoDetailPage(videoId);
        }
        break;

      case 'profile':
        // 用户主页 目前url可以识别 iwara.tv/profile/userName 和 iwara.tv/profile/userName/playlists 两种路径
        if (pathSegments.length > 1) {
          final userName = pathSegments[1];
          if (pathSegments.length > 2 && pathSegments[2] == 'playlists') {
            NaviService.navigateToPlayListPage(userName);
          } else {
            NaviService.navigateToAuthorProfilePage(userName);
          }
        }
        break;

      case 'playlist':
        // 播放列表详情页 目前url可以识别 iwara.tv/playlist/id 和 iwara.tv/playlist/id/subId 两种路径
        if (pathSegments.length > 1) {
          final playlistId = pathSegments[1];
          NaviService.navigateToPlayListDetail(playlistId, isMine: false);
        }
        break;

      case 'image':
        // 图片详情页 目前url可以识别 iwara.tv/image/id 和 iwara.tv/image/id/subId 两种路径
        if (pathSegments.length > 1) {
          final imageId = pathSegments[1];
          NaviService.navigateToGalleryDetailPage(imageId);
        }
        break;

      case 'forum':
        // 论坛详情页 目前url可以识别 iwara.tv/forum/categoryId/threadId 和 iwara.tv/forum/categoryId 两种路径
        // https://www.iwara.tv/forum/announcements/895468a8-bdd9-401d-a8d1-2fd4d2d68c7d/2025-q1-small-updateoror-rule-changes-recent-issues-and-other-topics
        if (pathSegments.length > 1) {
          final categoryId = pathSegments[1];
          if (pathSegments.length > 2) {
            final threadId = pathSegments[2];
            NaviService.navigateToForumThreadDetailPage(categoryId, threadId);
          } else {
            NaviService.navigateToForumThreadListPage(categoryId);
          }
        }
        break;

      case 'post':
        // 帖子详情页 目前url可以识别 iwara.tv/post/id 和 iwara.tv/post/id/subId 两种路径
        if (pathSegments.length > 1) {
          final postId = pathSegments[1];
          NaviService.navigateToPostDetailPage(postId, null);
        }
        break;
    }
  }

  /// 处理文件 URI，用于本地视频播放
  void _handleFileUri(Uri uri) {
    LogUtils.i('收到文件 URI: $uri', 'DeepLinkService');
    LogUtils.i('URI scheme: ${uri.scheme}', 'DeepLinkService');
    LogUtils.i('URI path: ${uri.path}', 'DeepLinkService');

    // 确保路由系统已经准备就绪
    if (!Get.isRegistered<AppService>()) {
      LogUtils.d('AppService 未准备好，延迟500ms后重试', 'DeepLinkService');
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _handleFileUri(uri),
      );
      return;
    }

    String? filePath;

    if (uri.scheme == 'file') {
      // file:// URI，直接获取路径
      filePath = uri.toFilePath();
      LogUtils.i('file:// URI 转换为路径: $filePath', 'DeepLinkService');
    } else if (uri.scheme == 'content') {
      // content:// URI (Android)，需要将 URI 字符串传递给播放器
      // media_kit 可以直接处理 content:// URI
      filePath = uri.toString();
      LogUtils.i('content:// URI: $filePath', 'DeepLinkService');
    }

    if (filePath != null && filePath.isNotEmpty) {
      // 检查是否是视频文件（通过扩展名）
      // 对于 content:// URI，需要先解码 URL 编码再检查扩展名
      String pathForExtCheck = filePath;
      if (uri.scheme == 'content') {
        pathForExtCheck = Uri.decodeFull(filePath);
      }
      final ext = pathForExtCheck.toLowerCase().split('.').lastOrNull ?? '';
      LogUtils.i('文件扩展名: $ext', 'DeepLinkService');

      final videoExtensions = [
        'mp4',
        'mkv',
        'avi',
        'mov',
        'wmv',
        'flv',
        'webm',
        'm4v',
        '3gp',
        'ts',
      ];

      if (videoExtensions.contains(ext) || uri.scheme == 'content') {
        LogUtils.i('识别为视频文件，准备导航到播放页面: $filePath', 'DeepLinkService');
        NaviService.navigateToLocalVideoPlayerPageFromPath(filePath);
      } else {
        LogUtils.w('不是支持的视频文件格式: $ext', 'DeepLinkService');
      }
    } else {
      LogUtils.w('文件路径为空', 'DeepLinkService');
    }
  }
}
