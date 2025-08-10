import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/ui/pages/comment/controllers/comment_controller.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_section_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/grid_speed_dial.dart';
import 'package:oktoast/oktoast.dart';

import 'package:i_iwara/i18n/strings.g.dart' as slang;

class CommentsTabWidget extends StatefulWidget {
  final CommentController commentController;
  final MyVideoStateController videoController;

  const CommentsTabWidget({
    super.key,
    required this.commentController,
    required this.videoController,
  });

  @override
  State<CommentsTabWidget> createState() => _CommentsTabWidgetState();
}

class _CommentsTabWidgetState extends State<CommentsTabWidget> {
  // 浮动按钮相对右/下的距离，保持容器高度变化时位置稳定
  double? _distanceFromRight;
  double? _distanceFromBottom;
  static const double _fabSize = 56.0;
  static const double _edgePadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxW = constraints.maxWidth;
          final double maxH = constraints.maxHeight;
          // 初始贴右下角
          _distanceFromRight ??= _edgePadding;
          _distanceFromBottom ??= _edgePadding;

          // 将相对右/下的距离转换为左/上的像素定位
          final double left =
              (maxW - _fabSize - _distanceFromRight!)
                  .clamp(_edgePadding, maxW - _fabSize - _edgePadding)
                  .toDouble();
          final double top =
              (maxH - _fabSize - _distanceFromBottom!)
                  .clamp(_edgePadding, maxH - _fabSize - _edgePadding)
                  .toDouble();

          return Stack(
            children: [
              Positioned.fill(
                child: Obx(() => CommentSection(
                      controller: widget.commentController,
                      authorUserId:
                          widget.videoController.videoInfo.value?.user?.id,
                      topPadding: 0.0,
                    )),
              ),
              // 可拖拽浮动按钮
              Positioned(
                left: left,
                top: top,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    setState(() {
                      final double minX = _edgePadding;
                      final double minY = _edgePadding;
                      final double maxX = maxW - _fabSize - _edgePadding;
                      final double maxY = maxH - _fabSize - _edgePadding;

                      // 使用 state 中的相对右/下距离实时换算当前位置，避免使用构建时的旧值
                      final double currentLeft =
                          (maxW - _fabSize - _distanceFromRight!)
                              .clamp(minX, maxX)
                              .toDouble();
                      final double currentTop =
                          (maxH - _fabSize - _distanceFromBottom!)
                              .clamp(minY, maxY)
                              .toDouble();

                      // 基于当前实时位置增量移动
                      final double nextLeft = (currentLeft + details.delta.dx)
                          .clamp(minX, maxX)
                          .toDouble();
                      final double nextTop = (currentTop + details.delta.dy)
                          .clamp(minY, maxY)
                          .toDouble();

                      // 转换回相对右/下的距离，确保容器尺寸变化时视觉位置不漂移
                      _distanceFromRight = maxW - nextLeft - _fabSize;
                      _distanceFromBottom = maxH - nextTop - _fabSize;
                    });
                  },
                  child: Obx(() {
                    final commentCount =
                        widget.commentController.totalComments.value;
                    return GridSpeedDial(
                      activeIcon: Icons.close,
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                      spacing: 6,
                      spaceBetweenChildren: 4,
                      direction: SpeedDialDirection.up,
                      childPadding: const EdgeInsets.all(6),
                      childrens: [
                        [
                          // 第一列
                          SpeedDialChild(
                            child: const Icon(Icons.refresh_rounded),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            onTap: () {
                              widget.commentController.refreshComments();
                            },
                          ),
                          SpeedDialChild(
                            child: const Icon(Icons.edit_outlined),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            onTap: () => _showCommentDialog(context),
                          ),
                        ],
                      ],
                      child: commentCount > 0
                          ? Text(
                              commentCount > 99
                                  ? '99+'
                                  : commentCount.toString(),
                              textAlign: TextAlign.center,
                            )
                          : const Icon(Icons.comment_outlined),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    if (!Get.find<UserService>().isLogin) {
      showToastWidget(MDToastWidget(
          message: t.errors.pleaseLoginFirst, type: MDToastType.error));
      Get.toNamed(Routes.LOGIN);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentInputBottomSheet(
        title: t.common.sendComment,
        submitText: t.common.send,
        onSubmit: (text) async {
          if (text.trim().isNotEmpty) {
            await widget.commentController.postComment(text);
          } else {
            showToastWidget(MDToastWidget(
                message: t.errors.commentCanNotBeEmpty,
                type: MDToastType.error));
          }
        },
      ),
    );
  }
}
