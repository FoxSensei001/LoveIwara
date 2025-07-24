import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/search/repositories/search_repositories.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';

import 'base_search_list.dart';

/// 视频搜索列表
class VideoSearchList extends BaseSearchList<Video, VideoSearchRepository> {
  final String? sortType;
  
  const VideoSearchList({
    super.key,
    required super.query,
    super.isPaginated = false,
    this.sortType,
  });
  
  @override
  State<VideoSearchList> createState() => VideoSearchListState();
}

class VideoSearchListState extends BaseSearchListState<Video, VideoSearchRepository, VideoSearchList> {
  @override
  VideoSearchRepository createRepository() {
    return VideoSearchRepository(
      query: widget.query,
      sortType: widget.sortType,
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
  final String? sortType;
  
  const ImageSearchList({
    super.key,
    required super.query,
    super.isPaginated = false,
    this.sortType,
  });
  
  @override
  State<ImageSearchList> createState() => ImageSearchListState();
}

class ImageSearchListState extends BaseSearchListState<ImageModel, ImageSearchRepository, ImageSearchList> {
  @override
  ImageSearchRepository createRepository() {
    return ImageSearchRepository(
      query: widget.query,
      sortType: widget.sortType,
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