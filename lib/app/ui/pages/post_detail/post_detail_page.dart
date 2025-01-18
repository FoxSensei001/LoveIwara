import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_dialog.dart';
import 'package:i_iwara/app/ui/pages/post_detail/widgets/post_detail_content_widget.dart';
import 'package:i_iwara/app/ui/pages/post_detail/widgets/share_post_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import '../../widgets/error_widget.dart';
import '../../widgets/sliding_card_widget.dart';
import '../comment/controllers/comment_controller.dart';
import '../comment/widgets/comment_entry_area_widget.dart';
import '../comment/widgets/comment_section_widget.dart';
import 'controllers/post_detail_controller.dart';
import 'widgets/post_detail_shimmer.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  
  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late String postId;
  late PostDetailController detailController;
  late CommentController commentController;
  late String uniqueTag;

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    uniqueTag = UniqueKey().toString();

    if (postId.isEmpty) return;

    // 初始化控制器
    detailController = Get.put(
      PostDetailController(postId),
      tag: uniqueTag,
    );

    commentController = Get.put(
      CommentController(id: postId, type: CommentType.post),
      tag: uniqueTag,
    );
  }

  @override
  void dispose() {
    Get.delete<PostDetailController>(tag: uniqueTag);
    Get.delete<CommentController>(tag: uniqueTag);
    super.dispose();
  }

  void showCommentModal(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 600;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: isSmallScreen ? 0.9 : 0.8,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                  child: Row(
                    children: [
                      Text(
                        slang.t.common.commentList,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Get.dialog(
                            CommentInputDialog(
                              title: slang.t.common.sendComment,
                              submitText: slang.t.common.send,
                              onSubmit: (text) async {
                                if (text.trim().isEmpty) {
                                  showToastWidget(MDToastWidget(
                                    message: slang.t.errors.commentCanNotBeEmpty,
                                    type: MDToastType.error,
                                  ));
                                  return;
                                }
                                final UserService userService = Get.find();
                                if (!userService.isLogin) {
                                  showToastWidget(MDToastWidget(
                                    message: slang.t.errors.pleaseLoginFirst,
                                    type: MDToastType.error,
                                  ));
                                  Get.toNamed(Routes.LOGIN);
                                  return;
                                }
                                await commentController.postComment(text);
                              },
                            ),
                            barrierDismissible: true,
                          );
                        },
                        icon: Icon(
                          Icons.add_comment,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        label: Text(
                          slang.t.common.sendComment,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: isSmallScreen ? 20 : 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() => CommentSection(
                    controller: commentController,
                    authorUserId: detailController.postInfo.value?.user.id,
                  )),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 600;
    
    if (postId.isEmpty) {
      return CommonErrorWidget(
        text: t.errors.invalidPostId,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.back),
          ),
        ],
      );
    }

    double paddingTop = MediaQuery.paddingOf(context).top;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (detailController.isCommentSheetVisible.value) {
            detailController.isCommentSheetVisible.toggle();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: Obx(() {
          if (detailController.errorMessage.value != null) {
            return CommonErrorWidget(
              text: detailController.errorMessage.value ?? t.errors.errorWhileLoadingPost,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.common.back),
                ),
              ],
            );
          }

          if (detailController.isPostInfoLoading.value) {
            return const PostDetailShimmer();
          }

          if (detailController.postInfo.value == null) {
            return const MyEmptyWidget();
          }

          return PopScope(
            canPop: !detailController.isCommentSheetVisible.value,
            onPopInvokedWithResult: (bool didPop, dynamic result) {
              if (detailController.isCommentSheetVisible.value) {
                detailController.isCommentSheetVisible.toggle();
              }
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PostDetailContent(
                        controller: detailController,
                        paddingTop: paddingTop,
                        onShare: () {
                          showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => SharePostBottomSheet(
                              post: detailController.postInfo.value!,
                            ),
                            context: context,
                          );
                        },
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 8 : 16,
                        ),
                        child: CommentEntryAreaButtonWidget(
                          commentController: commentController,
                          onClickButton: () {
                            showCommentModal(context);
                          },
                        ),
                      ),
                      const SafeArea(child: SizedBox.shrink()),
                    ],
                  ),
                ),
                SlidingCard(
                  isVisible: detailController.isCommentSheetVisible.value,
                  onDismiss: () => detailController.isCommentSheetVisible.toggle(),
                  title: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                    ),
                    child: Row(
                      children: [
                        Text(
                          t.common.commentList,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            final UserService userService = Get.find();
                            if (!userService.isLogin) {
                              showToastWidget(MDToastWidget(
                                message: slang.t.errors.pleaseLoginFirst,
                                type: MDToastType.error,
                              ));
                              Get.toNamed(Routes.LOGIN);
                              return;
                            }
                            showCommentModal(context);
                          },
                          icon: Icon(
                            Icons.add_comment,
                            size: isSmallScreen ? 18 : 20,
                          ),
                          label: Text(
                            t.common.sendComment,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          onPressed: () =>
                              detailController.isCommentSheetVisible.toggle(),
                        ),
                      ],
                    ),
                  ),
                  child: CommentSection(
                    controller: commentController,
                    authorUserId: detailController.postInfo.value?.user.id,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
} 