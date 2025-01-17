import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/dto/forum_thread_section_dto.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

// 分类名称映射
final Map<String, String> groupNames = {
  'administration': slang.t.forum.groups.administration,
  'global': slang.t.forum.groups.global,
  'chinese': slang.t.forum.groups.chinese,
  'japanese': slang.t.forum.groups.japanese,
};

// 叶子的id名称映射
final Map<String, String> idNames = {
  'announcements': slang.t.forum.leafNames.announcements,
  'feedback': slang.t.forum.leafNames.feedback,
  'support': slang.t.forum.leafNames.support,
  'general': slang.t.forum.leafNames.general,
  'guides': slang.t.forum.leafNames.guides,
  'questions': slang.t.forum.leafNames.questions,
  'requests': slang.t.forum.leafNames.requests,
  'sharing': slang.t.forum.leafNames.sharing,
  'general_zh': slang.t.forum.leafNames.general,
  'questions_zh': slang.t.forum.leafNames.questions,
  'requests_zh': slang.t.forum.leafNames.requests,
  'support_zh': slang.t.forum.leafNames.support,
  'general_ja': slang.t.forum.leafNames.general,
  'questions_ja': slang.t.forum.leafNames.questions,
  'requests_ja': slang.t.forum.leafNames.requests,
  'support_ja': slang.t.forum.leafNames.support,
  'korean': slang.t.forum.leafNames.korean,
  'other': slang.t.forum.leafNames.other,
};

// 叶子的描述映射
final Map<String, String> idDescriptions = {
  'announcements': slang.t.forum.leafDescriptions.announcements,
  'feedback': slang.t.forum.leafDescriptions.feedback,
  'support': slang.t.forum.leafDescriptions.support,
  'general': slang.t.forum.leafDescriptions.general,
  'guides': slang.t.forum.leafDescriptions.guides,
  'questions': slang.t.forum.leafDescriptions.questions,
  'requests': slang.t.forum.leafDescriptions.requests,
  'sharing': slang.t.forum.leafDescriptions.sharing,
  'general_zh': slang.t.forum.leafDescriptions.general_zh,
  'questions_zh': slang.t.forum.leafDescriptions.questions_zh,
  'requests_zh': slang.t.forum.leafDescriptions.requests_zh,
  'support_zh': slang.t.forum.leafDescriptions.support_zh,
  'general_ja': slang.t.forum.leafDescriptions.general_ja,
  'questions_ja': slang.t.forum.leafDescriptions.questions_ja,
  'requests_ja': slang.t.forum.leafDescriptions.requests_ja,
  'support_ja': slang.t.forum.leafDescriptions.support_ja,
  'korean': slang.t.forum.leafDescriptions.korean,
  'other': slang.t.forum.leafDescriptions.other,
};

class ForumService extends GetxService {
  final ApiService _apiService = Get.find();

  /// 编辑帖子标题
  /// 参数很离谱，是把请求的body改了改title字段，然后发过来了，
  /// 所以调用这个接口前，最好
  /// /forum/:id
  Future<ApiResult<void>> editThreadTitle(String categoryId, String threadId, String title) async {
    late Map<String, dynamic> jsonBody;

    try {
      // 获取帖子详情
      var response = await _apiService.get(ApiConstants.forumThreadDetail(categoryId, threadId));
      jsonBody = response.data;

      // 修改title
      jsonBody['title'] = title;
    } catch (e) {
      LogUtils.e('在编辑帖子标题时，获取帖子详情失败', tag: 'ForumService', error: e);
      return ApiResult.fail(slang.t.errors.failedToFetchData);
    }

    try {
      await _apiService.put(ApiConstants.forumThreads(threadId), data: jsonBody);
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('在编辑帖子标题时，编辑帖子标题失败', tag: 'ForumService', error: e);
      return ApiResult.fail(slang.t.errors.failedToOperate);
    }
  }

  /// 编辑帖子回复
  /// /forum/post/:postId
  /// 这个也是一样的，不过不能偷懒了，必须参数里接一下 转换成Map<String, dynamic>了
  Future<ApiResult<void>> editPost(String postId, Map<String, dynamic> jsonBody) async {
    try {
      await _apiService.put(ApiConstants.forumPosts(postId), data: jsonBody);
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('在编辑帖子回复时，编辑帖子回复失败', tag: 'ForumService', error: e);
      return ApiResult.fail(slang.t.errors.failedToOperate);
    }
  }

  /// 回复帖子
  /// /forum/:threadId/reply
  /// @params body
  Future<ApiResult<void>> postReply(String threadId, String body) async {
    try {
      await _apiService.post(ApiConstants.forumThreadReply(threadId), data: {
        'body': body,
        'rulesAgreement': true,
      });
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('回复帖子失败', tag: 'ForumService', error: e);
      return ApiResult.fail(slang.t.errors.failedToOperate);
    }
  }

  /// 获取帖子详情
  ///  /forum/:categoryId/:threadId
  /// @params page
  /// @params limit
  Future<ApiResult<Map<String, dynamic>>> fetchForumThread(
      String categoryId, String threadId, {int page = 0, int limit = 20}) async {
    try {
      var response = await _apiService.get(ApiConstants.forumThreadDetail(categoryId, threadId), queryParameters: {
        'page': page,
        'limit': limit,
      });

      final ForumThreadModel thread = ForumThreadModel.fromJson(response.data['thread']);
      final List<ThreadCommentModel> posts = (response.data['results'] as List)
          .map((post) => ThreadCommentModel.fromJson(post))
          .toList();
      return ApiResult.success(data: {
        'thread': thread,
        'posts': posts,
        'page': response.data['page'],
        'limit': response.data['limit'],
        'count': response.data['count'],
      });
    } catch (e) {
      LogUtils.e('获取帖子详情失败', tag: 'ForumService', error: e);
      return ApiResult.fail(slang.t.errors.failedToFetchData);
    }
  }

  /// 获取论坛帖子列表
  Future<ApiResult<Map<String, dynamic>>> fetchForumThreads(
      String categoryId,
      {int page = 0,
      int limit = 20}) async {
    try {
      var response = await _apiService
          .get(ApiConstants.forumThreads(categoryId), queryParameters: {
        'page': page,
        'limit': limit,
      });
      final List<ForumThreadModel> threads = (response.data['threads'] as List)
          .map((thread) => ForumThreadModel.fromJson(thread))
          .toList();
      final ForumThreadSectionDto section = ForumThreadSectionDto.fromJson(response.data['section']);
      // 根据id获取分类名称和描述
      final String categoryName = idNames[categoryId.replaceAll('-', '_')] ?? categoryId;
      final String categoryDescription = idDescriptions[categoryId.replaceAll('-', '_')] ?? '';
      section.name = categoryName;
      section.description = categoryDescription;
      final Map<String, dynamic> pageData = {
        'page': response.data['page'],
        'limit': response.data['limit'],
        'count': response.data['count'],
        'results': threads,
        'section': section,
      };
      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取论坛帖子列表失败', tag: 'ForumService', error: e);
      return ApiResult.fail(slang.t.errors.failedToFetchData);
    }
  }

  /// 获取发帖冷却时间
  Future<ApiResult<PostCooldownModel>> fetchPostCollingInfo() async {
    try {
      var response = await _apiService.get(ApiConstants.forumThreadCooldown());
      return ApiResult.success(data: PostCooldownModel.fromJson(response.data));
    } catch (e) {
      LogUtils.e('获取冷却时间失败', tag: 'PostService', error: e);
      return ApiResult.fail(slang.t.errors.failedToFetchData);
    }
  }

  /// 获取论坛总表
  /// /forum
  Future<ApiResult<List<ForumCategoryModel>>> fetchForumList() async {
    try {
      var response = await _apiService.get(ApiConstants.forum());
      return ApiResult.success(
          data: (response.data as List)
              .map((e) => ForumCategoryModel.fromJson(e))
              .toList());
    } catch (e) {
      LogUtils.e('获取论坛总表失败', tag: 'ForumService', error: e);
      return ApiResult.fail(slang.t.errors.failedToFetchData);
    }
  }

  /// 获取论坛分类树
  /// 将扁平的论坛分类列表转换为树形结构
  Future<ApiResult<List<ForumCategoryTreeModel>>> getForumCategoryTree() async {
    try {
      final result = await fetchForumList();
      if (!result.isSuccess) {
        return ApiResult.fail(result.message);
      }

      final categories = result.data;
      if (categories == null) {
        return ApiResult.fail(slang.t.errors.failedToFetchData);
      }

      // 按照group对分类进行分组，并转换名称
      final Map<String, List<ForumCategoryModel>> groupedCategories = {};
      for (var category in categories) {
        // 创建新的分类对象，使用映射的名称
        var newCategory = ForumCategoryModel(
          id: category.id,
          group: category.group, // 保持原始group用于分组
          label: idNames[category.id.replaceAll('-', '_')] ??
              category.id, // 使用映射的标签名，如果没有映射则使用id
          description: idDescriptions[category.id.replaceAll('-', '_')] ??
              '', // 使用映射的描述，如果没有映射则使用空字符串
          locked: category.locked,
          numPosts: category.numPosts,
          numThreads: category.numThreads,
          lastThread: category.lastThread,
        );

        if (!groupedCategories.containsKey(category.group)) {
          groupedCategories[category.group] = [];
        }
        groupedCategories[category.group]!.add(newCategory);
      }

      // 按照预定义的顺序创建树形结构
      final orderedGroups = ['administration', 'global', 'chinese', 'japanese'];
      final List<ForumCategoryTreeModel> tree = [];

      for (var group in orderedGroups) {
        if (groupedCategories.containsKey(group)) {
          // 对每个组内的分类按照id进行排序
          var groupCategories = groupedCategories[group]!;
          groupCategories.sort((a, b) {
            // 获取叶子节点名称的显示顺序
            var aName = idNames[a.id.replaceAll('-', '_')] ?? a.id;
            var bName = idNames[b.id.replaceAll('-', '_')] ?? b.id;
            return aName.compareTo(bName);
          });

          // 创建树节点
          tree.add(ForumCategoryTreeModel(
            name: groupNames[group] ?? group,
            children: groupCategories,
          ));
        }
      }

      return ApiResult.success(data: tree);
    } catch (e) {
      LogUtils.e('获取论坛分类树失败', tag: 'ForumService', error: e);
      return ApiResult.fail(slang.t.errors.failedToFetchData);
    }
  }

  /// 发布帖子
  Future<ApiResult<ForumThreadModel>> postThread(
      String forumCategoryId, String title, String body) async {
    try {
      var response = await _apiService
          .post(ApiConstants.forumThread(forumCategoryId), data: {
        'title': title,
        'body': body,
      });
      return ApiResult.success(data: ForumThreadModel.fromJson(response.data));
    } catch (e) {
      LogUtils.e('发布帖子失败', tag: 'ForumService', error: e);
      return ApiResult.fail(slang.t.errors.failedToOperate);
    }
  }

}
