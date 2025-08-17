import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/oreno3d_video.model.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/search/repositories/search_repositories.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:i_iwara/app/ui/widgets/oreno3d_video_card.dart';
import 'package:i_iwara/app/ui/pages/play_list/widgets/playlist_item_widget.dart';

import 'base_search_list.dart';

/// 视频搜索列表
class VideoSearchList extends BaseSearchList<Video, VideoSearchRepository> {
  const VideoSearchList({
    super.key,
    required super.query,
    super.isPaginated = false,
  });
  
  @override
  State<VideoSearchList> createState() => VideoSearchListState();
}

class VideoSearchListState extends BaseSearchListState<Video, VideoSearchRepository, VideoSearchList> {
  @override
  VideoSearchRepository createRepository() {
    return VideoSearchRepository(
      query: widget.query,
    );
  }
  
  @override
  IconData get emptyIcon => Icons.video_library_outlined;
  
  @override
  Widget buildListItem(BuildContext context, Video video, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth <= 600 ? (screenWidth - 8) / 2 : (screenWidth - 24) / 3;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
        vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
      ),
      child: VideoCardListItemWidget(
        video: video,
        width: itemWidth,
      ),
    );
  }
}

/// 图片搜索列表
class ImageSearchList extends BaseSearchList<ImageModel, ImageSearchRepository> {
  const ImageSearchList({
    super.key,
    required super.query,
    super.isPaginated = false,
  });
  
  @override
  State<ImageSearchList> createState() => ImageSearchListState();
}

class ImageSearchListState extends BaseSearchListState<ImageModel, ImageSearchRepository, ImageSearchList> {
  @override
  ImageSearchRepository createRepository() {
    return ImageSearchRepository(
      query: widget.query,
    );
  }
  
  @override
  IconData get emptyIcon => Icons.image_outlined;
  
  @override
  Widget buildListItem(BuildContext context, ImageModel image, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth <= 600 ? (screenWidth - 8) / 2 : (screenWidth - 24) / 3;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
        vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
      ),
      child: ImageModelCardListItemWidget(
        imageModel: image,
        width: itemWidth,
      ),
    );
  }
}

/// 用户搜索列表
class UserSearchList extends BaseSearchList<User, UserSearchRepository> {
  const UserSearchList({
    super.key,
    required super.query,
    super.isPaginated = false,
  });
  
  @override
  State<UserSearchList> createState() => UserSearchListState();
}

class UserSearchListState extends BaseSearchListState<User, UserSearchRepository, UserSearchList> {
  @override
  UserSearchRepository createRepository() {
    return UserSearchRepository(query: widget.query);
  }
  
  @override
  IconData get emptyIcon => Icons.person_outline;
  
  @override
  Widget buildListItem(BuildContext context, User user, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
        vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
      ),
      child: UserCard(
        user: user,
      ),
    );
  }
}

/// 帖子搜索列表
class PostSearchList extends BaseSearchList<PostModel, PostSearchRepository> {
  const PostSearchList({
    super.key,
    required super.query,
    super.isPaginated = false,
  });
  
  @override
  State<PostSearchList> createState() => PostSearchListState();
}

class PostSearchListState extends BaseSearchListState<PostModel, PostSearchRepository, PostSearchList> {
  @override
  PostSearchRepository createRepository() {
    return PostSearchRepository(query: widget.query);
  }
  
  @override
  IconData get emptyIcon => Icons.article_outlined;
  
  @override
  Widget buildListItem(BuildContext context, PostModel post, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
        vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
      ),
      child: PostCardListItemWidget(
        post: post,
      ),
    );
  }
}

/// 论坛搜索列表
class ForumSearchList extends BaseSearchList<ForumThreadModel, ForumSearchRepository> {
  const ForumSearchList({
    super.key,
    required super.query,
    super.isPaginated = false,
  });

  @override
  State<ForumSearchList> createState() => ForumSearchListState();
}

class ForumSearchListState extends BaseSearchListState<ForumThreadModel, ForumSearchRepository, ForumSearchList> {
  @override
  ForumSearchRepository createRepository() {
    return ForumSearchRepository(query: widget.query);
  }

  @override
  IconData get emptyIcon => Icons.forum_outlined;

  @override
  Widget buildListItem(BuildContext context, ForumThreadModel forum, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
        vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
      ),
      child: ThreadListItemWidget(
        thread: forum,
        categoryId: forum.section,
      ),
    );
  }
}

/// Oreno3d视频搜索列表
class Oreno3dSearchList extends BaseSearchList<Oreno3dVideo, Oreno3dSearchRepository> {
  final String? sortType;
  final String? searchType; // 新增搜索类型参数
  final Map<String, dynamic>? extData; // 新增扩展数据参数

  const Oreno3dSearchList({
    super.key,
    required super.query,
    super.isPaginated = false,
    this.sortType,
    this.searchType,
    this.extData,
  });

  @override
  State<Oreno3dSearchList> createState() => Oreno3dSearchListState();
}

class Oreno3dSearchListState extends BaseSearchListState<Oreno3dVideo, Oreno3dSearchRepository, Oreno3dSearchList> {
  @override
  Oreno3dSearchRepository createRepository() {
    return Oreno3dSearchRepository(
      query: widget.query,
      sortType: widget.sortType,
      searchType: widget.searchType,
      extData: widget.extData,
    );
  }

  @override
  IconData get emptyIcon => Icons.view_in_ar_outlined;

  @override
  Widget buildListItem(BuildContext context, Oreno3dVideo video, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth <= 600 ? (screenWidth - 8) / 2 : (screenWidth - 24) / 3;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
        vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
      ),
      child: Oreno3dVideoCard(
        video: video,
        width: itemWidth,
      ),
    );
  }
}

/// 播放列表搜索列表
class PlaylistSearchList extends BaseSearchList<PlaylistModel, PlaylistSearchRepository> {
  const PlaylistSearchList({
    super.key,
    required super.query,
    super.isPaginated = false,
  });

  @override
  State<PlaylistSearchList> createState() => PlaylistSearchListState();
}

class PlaylistSearchListState extends BaseSearchListState<PlaylistModel, PlaylistSearchRepository, PlaylistSearchList> {
  @override
  PlaylistSearchRepository createRepository() {
    return PlaylistSearchRepository(
      query: widget.query,
    );
  }

  @override
  IconData get emptyIcon => Icons.playlist_play_outlined;

  @override
  Widget buildListItem(BuildContext context, PlaylistModel playlist, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth <= 600 ? (screenWidth - 8) / 2 : (screenWidth - 24) / 3;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
        vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
      ),
      child: SizedBox(
        width: itemWidth,
        child: PlaylistItemWidget(
          playlist: playlist,
        ),
      ),
    );
  }
}