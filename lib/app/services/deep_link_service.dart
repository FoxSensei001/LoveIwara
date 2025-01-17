import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';

class DeepLinkService extends GetxService {
  final _appLinks = AppLinks();
  bool _isReady = false;
  Uri? _pendingInitialLink;
  
  /// 如果需要添加更多链接 请在 {@link AndroidManifest.xml} 中也做配置
  Future<void> init() async {
    // 监听所有链接事件
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleLink(uri);
      }
    });
    
    // 保存初始链接，但不立即处理
    _pendingInitialLink = await _appLinks.getInitialLink();
  }

  // 标记服务已准备就绪
  void markReady() {
    _isReady = true;
    // 处理待处理的初始链接
    if (_pendingInitialLink != null) {
      // 使用Future.delayed确保在下一个Frame处理，给予足够时间初始化路由系统
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_pendingInitialLink != null) {
          _handleLink(_pendingInitialLink!);
          _pendingInitialLink = null;
        }
      });
    }
  }

  void _handleLink(Uri uri) {
    // 如果服务还未准备就绪，保存链接等待处理
    if (!_isReady) {
      _pendingInitialLink = uri;
      return;
    }

    // 确保在主UI线程中执行导航操作
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processLink(uri);
    });
  }

  void _processLink(Uri uri) {
    // 处理不同类型的链接
    final pathSegments = uri.pathSegments;
    
    if (pathSegments.isEmpty) return;

    // 确保路由系统已经准备就绪
    if (!Get.isRegistered<AppService>()) {
      Future.delayed(const Duration(milliseconds: 500), () => _processLink(uri));
      return;
    }

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
        if (pathSegments.length > 1) {
          final categoryId = pathSegments[1];
          if (pathSegments.length > 3) {
            final threadId = pathSegments[3];
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
}
