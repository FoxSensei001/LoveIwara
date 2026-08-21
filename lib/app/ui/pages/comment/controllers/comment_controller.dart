import 'dart:async';

import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';

import '../../../../../common/constants.dart';
import '../../../../models/comment.model.dart';
import '../../../../services/comment_service.dart';

enum CommentType {
  post,
  video,
  profile,
  image;

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

  CommentController({required this.id, required this.type});

  @override
  void onInit() {
    super.onInit();
    LogUtils.d('初始化', 'CommentController<${type.toString()}>');
    // 从配置中获取排序方式
    sortOrder.value =
        _configService.settings[ConfigKey.COMMENT_SORT_ORDER]!.value;
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
          pendingCount.value =
              firstPageResult.data!.extras?['pendingCount'] ?? 0;
        } else {
          // 如果获取总数失败，直接抛出异常，让外层catch处理
          throw Exception(firstPageResult.message);
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
                floorNumber =
                    totalComments.value -
                    loadedTopLevelComments -
                    topLevelCommentIndex;
              } else {
                // 正序：从1开始递增
                // 使用已加载的顶级评论数量来计算
                floorNumber = loadedTopLevelComments + topLevelCommentIndex + 1;
              }
              commentsWithFloorNumber.add(
                comment.copyWith(floorNumber: floorNumber),
              );
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
      LogUtils.e(
        '获取评论时出错',
        tag: 'CommentController<${type.toString()}>',
        error: e,
      );
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
  Future<ApiResult<Comment>> postComment(
    String body, {
    String? parentId,
  }) async {
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
          numReplies: parentComment.numReplies + 1,
        );
      } else {
        comments.insert(0, result.data!);
      }
      totalComments.value++;
      showGlassToast(
        t.common.commentPostedSuccessfully,
        type: GlassToastType.success,
      );
      AppService.tryPop();
    } else {
      showGlassToast(
        result.message,
        type: GlassToastType.error,
        position: GlassToastPosition.bottom,
      );
    }

    return result;
  }

  // 删除评论
  Future<void> deleteComment(String commentId) async {
    final result = await _commentService.deleteComment(commentId);
    if (result.isSuccess) {
      comments.removeWhere((comment) => comment.id == commentId);
      totalComments.value--;
      showGlassToast(
        t.common.commentDeletedSuccessfully,
        type: GlassToastType.success,
      );
    } else {
      showGlassToast(
        result.message,
        type: GlassToastType.error,
        position: GlassToastPosition.bottom,
      );
    }
  }

  /// 子回复被删除后，同步主列表中对应顶级评论的 numReplies（仅本地状态）。
  /// 与 postComment 里 parentId 分支的 +1 互为镜像。
  void onReplyDeleted(String parentId) {
    final index = comments.indexWhere((c) => c.id == parentId);
    if (index == -1) return;
    final parent = comments[index];
    if (parent.numReplies <= 0) return;
    comments[index] = parent.copyWith(numReplies: parent.numReplies - 1);
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
        showGlassToast(
          t.common.commentUpdatedSuccessfully,
          type: GlassToastType.success,
        );
        AppService.tryPop();
      }
    } else {
      showGlassToast(
        result.message,
        type: GlassToastType.error,
        position: GlassToastPosition.bottom,
      );
    }
  }

  // 创建 LoadingMoreList 数据源
  CommentListSource createListSource() {
    return CommentListSource(this);
  }
}

/// LoadingMoreList 数据源类，用于管理评论列表的分页加载
class CommentListSource extends LoadingMoreBase<Comment>
    with LoadingMoreRefreshGuard<Comment> {
  final CommentController controller;

  // 持有订阅以便在 dispose 时取消，避免泄漏（每个详情页都会创建评论数据源）
  final List<StreamSubscription> _subscriptions = [];

  CommentListSource(this.controller) {
    // 监听控制器状态变化
    _subscriptions.add(controller.comments.listen((_) => setState()));
    _subscriptions.add(controller.isLoading.listen((_) => setState()));
    _subscriptions.add(controller.hasMore.listen((_) => setState()));
    _subscriptions.add(controller.errorMessage.listen((_) => setState()));
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }

  @override
  bool get hasMore => controller.hasMore.value;

  @override
  void resetPagingState() {
    super.resetPagingState(); // 代际自增，作废在途回写
    // 本数据源自己不持有分页字段：currentPage / loadedTopLevelComments /
    // comments 都在 controller 里，由 fetchComments(refresh: true) 重置。
    // 这里只需提前把 hasMore 打回 true —— 否则列表已加载到底时，
    // super.refresh() 会被框架的 `if (isLoading || !hasMore)` 闸门
    // 在发出请求之前拦掉（还会谎报成功）。
    controller.hasMore.value = true;
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    return runGuardedRefresh(() async {
      final int generation = currentGeneration;
      // 只走 super.refresh()：它会经 loadData 调到
      // controller.fetchComments(refresh: true)，不会重复发起刷新。
      final bool result = await super.refresh(notifyStateChanged);
      return isStaleGeneration(generation) ? true : result;
    });
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    // 代际快照必须在 await 之前取：await 期间可能发生 refresh()。
    final int generation = currentGeneration;
    try {
      if (isloadMoreAction) {
        await controller.loadMoreComments();
      } else {
        await controller.fetchComments(refresh: true);
      }
      // await 期间已被 refresh() 作废 → 丢弃本次结果。必须返回 true：
      // 返回 false 会被 loading_more_list 映射成一个假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }
      return controller.errorMessage.value.isEmpty;
    } catch (e, stack) {
      if (isStaleGeneration(generation)) {
        return true;
      }
      LogUtils.e(
        '加载评论列表失败',
        tag: 'CommentListSource<${controller.type.toString()}>',
        error: e,
        stack: stack,
      );
      return false;
    }
  }

  @override
  int get length => controller.comments.length;

  @override
  Comment operator [](int index) => controller.comments[index];
}
