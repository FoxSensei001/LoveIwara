import 'dart:ui';
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
  // 浮动按钮当前位置（相对页面左上角）。首次构建时按右下角初始化
  Offset? _fabOffset;
  static const double _fabSize = 56.0;
  static const double _edgePadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxW = constraints.maxWidth;
          final double maxH = constraints.maxHeight;
          _fabOffset ??= Offset(
            maxW - _fabSize - _edgePadding,
            maxH - _fabSize - _edgePadding,
          );

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
                left: _fabOffset!.dx,
                top: _fabOffset!.dy,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    setState(() {
                      final double minX = _edgePadding;
                      final double minY = _edgePadding;
                      final double maxX = maxW - _fabSize - _edgePadding;
                      final double maxY = maxH - _fabSize - _edgePadding;

                      final double nextX = (_fabOffset!.dx + details.delta.dx)
                          .clamp(minX, maxX)
                          .toDouble();
                      final double nextY = (_fabOffset!.dy + details.delta.dy)
                          .clamp(minY, maxY)
                          .toDouble();
                      _fabOffset = Offset(nextX, nextY);
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
