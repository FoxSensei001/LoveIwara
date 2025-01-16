import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';

class DeepLinkService extends GetxService {
  final _appLinks = AppLinks();
  
  /// 如果需要添加更多链接 请在 {@link AndroidManifest.xml} 中也做配置
  Future<void> init() async {
    // 监听所有链接事件
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleLink(uri);
      }
    });
    
    // 检查初始链接（从外部打开应用时）
    final uri = await _appLinks.getInitialLink();
    if (uri != null) {
      _handleLink(uri);
    }
  }

  void _handleLink(Uri uri) {
    // 处理不同类型的链接
    final pathSegments = uri.pathSegments;
    
    if (pathSegments.isEmpty) return;

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
