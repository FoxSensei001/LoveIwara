import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'search_repository.dart';

/// 视频搜索仓库
class VideoSearchRepository extends SearchRepository<Video> {
  VideoSearchRepository({required super.query})
      : super(segment: 'video');

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchVideoByQuery(
      page: page,
      limit: limit,
      query: keyword,
    );
  }
}

/// 图片搜索仓库
class ImageSearchRepository extends SearchRepository<ImageModel> {
  ImageSearchRepository({required super.query})
      : super(segment: 'image');

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchImageByQuery(
      page: page,
      limit: limit,
      query: keyword,
    );
  }
}

/// 用户搜索仓库
class UserSearchRepository extends SearchRepository<User> {
  UserSearchRepository({required super.query})
      : super(segment: 'user');

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchUserByQuery(
      page: page,
      limit: limit,
      query: keyword,
    );
  }
}

/// 帖子搜索仓库
class PostSearchRepository extends SearchRepository<PostModel> {
  PostSearchRepository({required super.query})
      : super(segment: 'post');

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchPostByQuery(
      page: page,
      limit: limit,
      query: keyword,
    );
  }
}

/// 论坛搜索仓库
class ForumSearchRepository extends SearchRepository<ForumThreadModel> {
  ForumSearchRepository({required super.query})
      : super(segment: 'forum');

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchForumByQuery(
      page: page,
      limit: limit,
      query: keyword,
    );
  }
} 