import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../../../../common/constants.dart';
import '../../../../models/comment.model.dart';
import '../../../../services/comment_service.dart';

enum CommentType {
  post,
  video,
  profile,
  image,
  ;

  const CommentType();

  // 获取完整的API路径
  String getApiEndpoint(String id) => ApiConstants.comments(name, id);
}

class CommentController<T extends CommentType> extends GetxController {
  final String id;
  final T type;

  var comments = <Comment>[].obs;
  var isLoading = false.obs;
  var doneFirstTime = false.obs;
  var errorMessage = ''.obs;
  var currentPage = 0;
  final int pageSize = 20;
  var totalComments = 0.obs;
  var hasMore = true.obs;
  var pendingCount = 0.obs;

  // 排序方式：true为倒序，false为正序
  var sortOrder = true.obs;

  // 已加载的顶级评论数量（用于楼号计算）
  var loadedTopLevelComments = 0;

  // API 服务实例
  final CommentService _commentService = Get.find<CommentService>();
  final ConfigService _configService = Get.find<ConfigService>();

  CommentController({
    required this.id,
    required this.type,
  });

  @override
  void onInit() {
    super.onInit();
    LogUtils.d('初始化', 'CommentController<${type.toString()}>');
    // 从配置中获取排序方式
    sortOrder.value = _configService.settings[ConfigKey.COMMENT_SORT_ORDER]!.value;
    fetchComments(refresh: true);
  }

  // 从 API 获取评论
  Future<void> fetchComments({bool refresh = false}) async {
    LogUtils.d('获取评论', 'CommentController<${type.toString()}>');

    if (refresh) {
      doneFirstTime.value = false;
      currentPage = 0;
      comments.clear();
      errorMessage.value = '';
      hasMore.value = true;
      loadedTopLevelComments = 0; // 重置顶级评论计数
    }

    if (!hasMore.value || isLoading.value) return;

    isLoading.value = true;

    try {
      int apiPage = currentPage;

      // 如果是倒序，需要先获取总数来计算实际的API页码
      if (sortOrder.value && currentPage == 0) {
        // 第一次加载时，先获取第一页来获取总数
        final firstPageResult = await _commentService.getComments(
          type: type.name,
          id: id,
          page: 0,
          limit: pageSize,
        );

        if (firstPageResult.isSuccess) {
          totalComments.value = firstPageResult.data!.count;
          pendingCount.value = firstPageResult.data!.extras?['pendingCount'] ?? 0;
        }
      }

      // 计算倒序时的API页码
      if (sortOrder.value) {
        final totalPages = (totalComments.value + pageSize - 1) ~/ pageSize;
        apiPage = totalPages - currentPage - 1;

        // 如果计算出的页码小于0，说明没有更多数据
        if (apiPage < 0) {
          hasMore.value = false;
          isLoading.value = false;
          doneFirstTime.value = true;
          return;
        }
      }

      final result = await _commentService.getComments(
        type: type.name,
        id: id,
        page: apiPage,
        limit: pageSize,
      );

      if (result.isSuccess) {
        final pageData = result.data!;
        totalComments.value = pageData.count;
        pendingCount.value = pageData.extras?['pendingCount'] ?? 0;
        var fetchedComments = pageData.results;

        if (fetchedComments.isEmpty) {
          hasMore.value = false;
        } else {
          // 如果是倒序，需要反转当前页的评论顺序
          if (sortOrder.value) {
            fetchedComments = fetchedComments.reversed.toList();
          }

          // 为评论计算楼号
          final commentsWithFloorNumber = <Comment>[];
          int topLevelCommentIndex = 0; // 当前页面中顶级评论的索引

          for (int i = 0; i < fetchedComments.length; i++) {
            final comment = fetchedComments[i];
            // 只为顶级评论计算楼号
            if (comment.parent == null) {
              int floorNumber;
              if (sortOrder.value) {
                // 倒序：从总数开始递减
                // 使用已加载的顶级评论数量来计算
                floorNumber = totalComments.value - loadedTopLevelComments - topLevelCommentIndex;
              } else {
                // 正序：从1开始递增
                // 使用已加载的顶级评论数量来计算
                floorNumber = loadedTopLevelComments + topLevelCommentIndex + 1;
              }
              commentsWithFloorNumber.add(comment.copyWith(floorNumber: floorNumber));
              topLevelCommentIndex++; // 顶级评论索引递增
            } else {
              commentsWithFloorNumber.add(comment);
            }
          }

          // 更新已加载的顶级评论数量
          loadedTopLevelComments += topLevelCommentIndex;

          comments.addAll(commentsWithFloorNumber);
          currentPage += 1;

          // 检查是否还有更多数据
          if (sortOrder.value) {
            final totalPages = (totalComments.value + pageSize - 1) ~/ pageSize;
            hasMore.value = currentPage < totalPages;
          } else {
            hasMore.value = fetchedComments.length >= pageSize;
          }
        }

        errorMessage.value = '';
      } else {
        errorMessage.value = result.message;
      }
    } catch (e) {
      LogUtils.e('获取评论时出错',
          tag: 'CommentController<${type.toString()}>', error: e);
      errorMessage.value = CommonUtils.parseExceptionMessage(e);
    } finally {
      isLoading.value = false;
      doneFirstTime.value = true;
    }
  }

  // 刷新评论的方法
  Future<void> refreshComments() async {
    await fetchComments(refresh: true);
  }

  // 加载更多评论的方法
  Future<void> loadMoreComments() async {
    if (!isLoading.value && hasMore.value) {
      await fetchComments();
    }
  }

  // 切换排序方式
  Future<void> toggleSortOrder() async {
    sortOrder.value = !sortOrder.value;
    await refreshComments();
  }



  // 发表评论
  Future<ApiResult<Comment>> postComment(String body, {String? parentId}) async {
    final result = await _commentService.postComment(
      type: type.name,
      id: id,
      body: body,
      parentId: parentId,
    );

    if (result.isSuccess && result.data != null) {
      if (parentId != null) {
        final parentComment = comments.firstWhere((c) => c.id == parentId);
        final index = comments.indexOf(parentComment);
        comments[index] = parentComment.copyWith(
          numReplies: parentComment.numReplies + 1
        );
      } else {
        comments.insert(0, result.data!);
      }
      totalComments.value++;
      showToastWidget(MDToastWidget(message: t.common.commentPostedSuccessfully, type: MDToastType.success));
      AppService.tryPop();
    } else {
      showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error), position: ToastPosition.bottom);
    }
    
    return result;
  }

  // 删除评论
  Future<void> deleteComment(String commentId) async {
    final result = await _commentService.deleteComment(commentId);
    if (result.isSuccess) {
      comments.removeWhere((comment) => comment.id == commentId);
      totalComments.value--;
      showToastWidget(MDToastWidget(message: t.common.commentDeletedSuccessfully, type: MDToastType.success));
    } else {
      showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error), position: ToastPosition.bottom);
    }
  }

  // 编辑评论
  Future<void> editComment(String commentId, String newBody) async {
    final result = await _commentService.editComment(commentId, newBody);
    if (result.isSuccess) {
      final index = comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        comments[index] = comments[index].copyWith(
          body: newBody,
          updatedAt: DateTime.now(),
        );
        showToastWidget(MDToastWidget(message: t.common.commentUpdatedSuccessfully, type: MDToastType.success));
        AppService.tryPop();
      }
    } else {
      showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error), position: ToastPosition.bottom);
    }
  }

  // 创建 LoadingMoreList 数据源
  CommentListSource createListSource() {
    return CommentListSource(this);
  }
}

/// LoadingMoreList 数据源类，用于管理评论列表的分页加载
class CommentListSource extends LoadingMoreBase<Comment> {
  final CommentController controller;

  CommentListSource(this.controller) {
    // 监听控制器状态变化
    controller.comments.listen((_) => setState());
    controller.isLoading.listen((_) => setState());
    controller.hasMore.listen((_) => setState());
    controller.errorMessage.listen((_) => setState());
  }

  @override
  bool get hasMore => controller.hasMore.value;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    super.refresh(notifyStateChanged);
    await controller.refreshComments();
    return controller.errorMessage.value.isEmpty;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    try {
      if (isloadMoreAction) {
        await controller.loadMoreComments();
      } else {
        await controller.fetchComments(refresh: true);
      }
      return controller.errorMessage.value.isEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  int get length => controller.comments.length;

  @override
  Comment operator [](int index) => controller.comments[index];
}
