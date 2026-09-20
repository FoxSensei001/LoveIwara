import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/comment/controllers/comment_controller.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_section_widget.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 评论列表弹层（作者页 / 投稿详情 / 图库详情共用的那一张）。
///
/// 收口前这三页各抄了一份同样的
/// `GlassDraggableBottomSheet[标题 Row + Expanded(CommentSection)]`，连带把
/// 「发评论」那一套空文本校验 / 未登录拦截也各抄了一遍；标题行还是上下分家的
/// 老样式（投稿页自己补了条 Divider，另外两页连分界都没有）。现在壳与版式都
/// 走 [GlassFloatingHeaderSheet]：列表铺满整块，从玻璃标题行**背后**滚过去。
class CommentListBottomSheet extends StatelessWidget {
  const CommentListBottomSheet({
    super.key,
    required this.controller,
    this.authorUserId,
    this.onTimestampSeek,
  });

  final CommentController controller;

  /// 作者本人的 id，用来给列表里作者自己的评论打标。
  ///
  /// 取的是**打开弹层那一刻**的值：三个调用点的入口钮都长在「详情已加载」
  /// 之后的正文里，弹层活着的时候作者不会再变。
  final String? authorUserId;

  final void Function(Duration position)? onTimestampSeek;

  /// 发评论：空文本 / 未登录两道闸门原本在三个页面里各写一遍。
  void _showComposer(BuildContext context) {
    final t = slang.Translations.of(context);
    showGlassBottomSheet(
      context: context,
      builder: (context) => CommentInputBottomSheet(
        title: t.common.sendComment,
        submitText: t.common.send,
        onSubmit: (text) async {
          if (text.trim().isEmpty) {
            showAppToast(
              t.errors.commentCanNotBeEmpty,
              type: AppToastType.error,
              position: AppToastPosition.bottom,
            );
            return;
          }
          if (!Get.find<UserService>().isAuthenticated) {
            showAppToast(
              t.errors.pleaseLoginFirst,
              type: AppToastType.error,
              position: AppToastPosition.bottom,
            );
            LoginService.showLogin();
            return;
          }
          await controller.postComment(text);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassFloatingHeaderSheet(
      title: t.common.commentList,
      // 排序 / 发评论合成一只玻璃胶囊，关闭圆钮由壳自己摆在最右。
      actions: [
        GlassButtonGroup(
          children: [
            Obx(
              () => GlassIconButton(
                icon: Icon(
                  controller.sortOrder.value
                      ? Icons
                            .arrow_downward_rounded // 倒序
                      : Icons.arrow_upward_rounded, // 正序
                ),
                tooltip: controller.sortOrder.value
                    ? t.common.createTimeDesc
                    : t.common.createTimeAsc,
                onPressed: controller.toggleSortOrder,
              ),
            ),
            GlassIconButton(
              icon: const Icon(Icons.add_comment),
              tooltip: t.common.sendComment,
              onPressed: () => _showComposer(context),
            ),
          ],
        ),
      ],
      bodyBuilder: (context, scrollController, headerExtent) => CommentSection(
        controller: controller,
        authorUserId: authorUserId,
        topPadding: headerExtent,
        scrollController: scrollController,
        onTimestampSeek: onTimestampSeek,
      ),
    );
  }
}

/// 打开评论列表弹层。返回的 future 在弹层关闭时完成（调用方可以挂
/// `whenComplete` 收自己的状态）。
Future<void> showCommentListBottomSheet({
  required BuildContext context,
  required CommentController controller,
  String? authorUserId,
  void Function(Duration position)? onTimestampSeek,
}) {
  return showGlassDraggableBottomSheet<void>(
    context: context,
    builder: (context) => CommentListBottomSheet(
      controller: controller,
      authorUserId: authorUserId,
      onTimestampSeek: onTimestampSeek,
    ),
  );
}
