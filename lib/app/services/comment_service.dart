import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/comment.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/rules.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class CommentService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// 获取评论
  /// [type]: 评论类型
  /// [id]: 评论对象的ID
  /// [parentId]: 父评论ID
  /// [page]: 页码
  /// [limit]: 每页数量
  /// return: 评论列表、分页数据、pendingCount我未审核通过的评论数量
  Future<ApiResult<PageData<Comment>>> getComments({
    required String type,
    required String id,
    String? parentId,
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.comments(type, id),
        queryParameters: {
          'page': page,
          'limit': limit,
          if (parentId != null) 'parent': parentId,
        },
      );

      final PageData<Comment> pageData = PageData.fromJsonWithConverter(
        response.data,
        Comment.fromJson,
      );

      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取评论失败', tag: 'CommentService', error: e);
      return ApiResult.fail(t.errors.failedToFetchComments);
    }
  }

  /// 删除评论
  Future<ApiResult<void>> deleteComment(String id) async {
    try {
      await _apiService.delete(ApiConstants.comment(id));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('删除评论失败', tag: 'CommentService', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  /// 编辑评论
  Future<ApiResult<void>> editComment(String id, String body) async {
    try {
      await _apiService.put(ApiConstants.comment(id), data: {'body': body});
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('编辑评论失败', tag: 'CommentService', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  /// 发表评论
  Future<ApiResult<Comment>> postComment({
    required String type,
    required String id,
    required String body,
    String? parentId,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.comments(type, id),
        data: {
          'body': body,
          'rulesAgreement': true,
          if (parentId != null) 'parentId': parentId,
        },
      );

      return ApiResult.success(data: Comment.fromJson(response.data));
    } catch (e) {
      LogUtils.e('发表评论失败', tag: 'CommentService', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  /// 获取规则
  Future<ApiResult<PageData<RulesModel>>> getRules() async {
    try {
      final response = await _apiService.get(ApiConstants.rules);
      final List<RulesModel> results = (response.data['results'] as List)
          .map((rule) {
            if (rule['body'] is! Map) {
              LogUtils.e('规则 body 字段格式错误: ${rule['body']}', tag: 'CommentService');
              return null;
            }
            try {
              return RulesModel.fromJson(rule);
            } catch (e) {
              LogUtils.e('解析规则失败', tag: 'CommentService', error: e);
              return null;
            }
          })
          .where((rule) => rule != null)
          .cast<RulesModel>()
          .toList();

      final PageData<RulesModel> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );
      return ApiResult.success(data: pageData);
    } catch (e) { 
      LogUtils.e('获取规则失败', tag: 'CommentService', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }
}
