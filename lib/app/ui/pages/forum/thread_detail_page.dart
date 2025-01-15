import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_detail_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_reply_dialog.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'widgets/thread_comment_card_widget.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_edit_title_dialog.dart';

class ThreadDetailPage extends StatefulWidget {
  final String threadId;
  final String categoryId;

  const ThreadDetailPage({
    super.key,
    required this.threadId,
    required this.categoryId,
  });

  @override
  State<ThreadDetailPage> createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage> with SingleTickerProviderStateMixin {
  late ThreadDetailRepository listSourceRepository;
  final ScrollController _scrollController = ScrollController();
  final RxBool _showBackToTop = false.obs;
  final RxBool _enableFloatingButtons = true.obs;
  final Rx<ForumThreadModel?> _thread = Rx<ForumThreadModel?>(null);
  final UserService _userService = Get.find<UserService>();
  late AnimationController _floatingButtonController;

  @override
  void initState() {
    super.initState();
    _floatingButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    listSourceRepository = ThreadDetailRepository(
      categoryId: widget.categoryId,
      threadId: widget.threadId,
      updateThread: (thread) {
        _thread.value = thread;
      },
    );

    // 添加滚动监听
    _scrollController.addListener(() {
      if (_scrollController.offset >= 300) {
        _showBackToTop.value = true;
        if (_enableFloatingButtons.value) {
          _floatingButtonController.forward();
        }
      } else {
        _showBackToTop.value = false;
        _floatingButtonController.reverse();
      }
    });

    // 监听启用状态变化
    ever(_enableFloatingButtons, (bool enabled) {
      if (!enabled) {
        _floatingButtonController.reverse();
      } else if (_showBackToTop.value) {
        _floatingButtonController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    listSourceRepository.dispose();
    _floatingButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => _thread.value == null 
          ? Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              highlightColor: Theme.of(context).colorScheme.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _thread.value?.title ?? '',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                if (_thread.value != null)
                  Text(
                    '${t.common.publishedAt}: ${CommonUtils.formatFriendlyTimestamp(_thread.value?.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            )),
        actions: [
          Obx(() => IconButton(
            icon: Icon(_enableFloatingButtons.value ? Icons.vertical_align_top : Icons.vertical_align_top_outlined),
            onPressed: () {
              _enableFloatingButtons.value = !_enableFloatingButtons.value;

              showToastWidget(MDToastWidget(
                message: _enableFloatingButtons.value ? t.common.disabledFloatingButtons : t.common.enabledFloatingButtons,
                type: MDToastType.success
              ));
            },
            tooltip: _enableFloatingButtons.value ? t.common.disableFloatingButtons : t.common.enableFloatingButtons,
            style: IconButton.styleFrom(
              backgroundColor: !_enableFloatingButtons.value 
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                : null,
              foregroundColor: !_enableFloatingButtons.value 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => listSourceRepository.refresh(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWideScreen = constraints.maxWidth > 600;

          return LoadingMoreCustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              // 帖子内容区域
              SliverToBoxAdapter(
                child: Obx(() {
                  if (_thread.value == null) {
                    return _buildShimmerLoading(isWideScreen);
                  }

                  return Card(
                    margin: EdgeInsets.all(isWideScreen ? 16.0 : 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          // 作者信息
                          Row(
                            spacing: 12,
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    NaviService.navigateToAuthorProfilePage(
                                        _thread.value!.user.username);
                                  },
                                  child: AvatarWidget(
                                    avatarUrl:
                                        _thread.value!.user.avatar?.avatarUrl,
                                    radius: 20,
                                    headers: const {
                                      'referer': CommonConstants.iwaraBaseUrl
                                    },
                                    defaultAvatarUrl:
                                        CommonConstants.defaultAvatarUrl,
                                    isPremium: _thread.value!.user.premium,
                                    isAdmin: _thread.value!.user.isAdmin,
                                    role: _thread.value!.user.role,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          NaviService.navigateToAuthorProfilePage(
                                              _thread.value!.user.username);
                                        },
                                        child: _buildUserName(_thread.value!.user),
                                      ),
                                    ),
                                    Row(
                                      spacing: 8,
                                      children: [
                                        Expanded(
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(text: _thread.value!.user.username));
                                                showToastWidget(MDToastWidget(
                                                  message: slang.t.forum.copySuccessForMessage(str: _thread.value!.user.username),
                                                  type: MDToastType.success
                                                ));
                                              },
                                              child: Text(
                                                '@${_thread.value!.user.username}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.schedule, size: 14),
                                        Text(
                                          CommonUtils.formatFriendlyTimestamp(
                                              _thread.value!.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // 标签
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Wrap(
                                        spacing: 8,
                                        children: [
                                          if (_thread.value!.user.role == 'officer' || _thread.value!.user.role == 'moderator' || _thread.value!.user.role == 'admin')
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.tertiaryContainer,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.verified_user_outlined,
                                                    size: 12,
                                                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _thread.value!.user.role,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (_thread.value!.user.premium)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primaryContainer,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.workspace_premium,
                                                    size: 12,
                                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Premium',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (_userService.currentUser.value?.id == _thread.value!.user.id)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primaryContainer,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.person_outline,
                                                    size: 12,
                                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    slang.t.common.me,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.tertiaryContainer,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.stars_outlined,
                                                  size: 12,
                                                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  slang.t.common.author,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // 标题和状态
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  if (_thread.value!.sticky)
                                    Icon(
                                      Icons.push_pin,
                                      size: 18,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  if (_thread.value!.locked)
                                    Icon(
                                      Icons.lock,
                                      size: 18,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _thread.value!.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.translate),
                                    onPressed: () {
                                      Get.dialog(
                                        TranslationDialog(
                                          text: _thread.value!.title,
                                        ),
                                      );
                                    },
                                    tooltip: t.common.translate,
                                  ),
                                  if (_userService.currentUser.value?.id == _thread.value!.user.id)
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Get.dialog(
                                          ForumEditTitleDialog(
                                            postId: _thread.value!.id,
                                            initialTitle: _thread.value!.title,
                                            repository: listSourceRepository,
                                            onSubmit: () {
                                              listSourceRepository.refresh();
                                            },
                                          ),
                                        );
                                      },
                                      tooltip: t.forum.editTitle,
                                    ),
                                ],
                              ),
                            ],
                          ),
                          // 统计信息和更新时间
                          Row(
                            spacing: 16,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 12,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 4,
                                      children: [
                                        Icon(
                                          Icons.remove_red_eye,
                                          size: 16,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color,
                                        ),
                                        Text(
                                          CommonUtils.formatFriendlyNumber(
                                              _thread.value!.numViews),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 4,
                                      children: [
                                        Icon(
                                          Icons.comment,
                                          size: 16,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color,
                                        ),
                                        Text(
                                          CommonUtils.formatFriendlyNumber(
                                              _thread.value!.numPosts),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${t.common.updatedAt}: ${CommonUtils.formatFriendlyTimestamp(_thread.value!.updatedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              // 评论列表
              LoadingMoreSliverList<ThreadCommentModel>(
                SliverListConfig<ThreadCommentModel>(
                  itemBuilder: (context, comment, index) =>
                      buildCommentItem(context, comment, isWideScreen),
                  sourceList: listSourceRepository,
                  padding: EdgeInsets.only(
                    left: isWideScreen ? 16.0 : 8.0,
                    right: isWideScreen ? 16.0 : 8.0,
                    bottom: Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0,
                  ),
                  indicatorBuilder: (context, status) => myLoadingMoreIndicator(
                    context,
                    status,
                    isSliver: true,
                    loadingMoreBase: listSourceRepository,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Obx(() => _enableFloatingButtons.value ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 发帖按钮
            if (_thread.value != null)
              FloatingActionButton(
                onPressed: _thread.value!.locked ? () {
                  showToastWidget(MDToastWidget(
                    message: slang.t.forum.errors.threadLocked,
                    type: MDToastType.warning
                  ));
                } : () {
                  UserService userService = Get.find<UserService>();
                  if (!userService.isLogin) {
                    showToastWidget(MDToastWidget(
                      message: slang.t.errors.pleaseLoginFirst,
                      type: MDToastType.warning
                    ));
                    return;
                  }
                  Get.dialog(ForumReplyDialog(threadId: _thread.value!.id, onSubmit: () {
                    listSourceRepository.refresh();
                  }));
                },
                backgroundColor: _thread.value!.locked 
                    ? Theme.of(context).colorScheme.surfaceContainerHighest 
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: _thread.value!.locked 
                    ? Theme.of(context).colorScheme.onSurfaceVariant 
                    : Theme.of(context).colorScheme.onPrimary,
                child: Icon(
                  _thread.value!.locked ? Icons.lock : Icons.reply,
                  size: 20,
                ),
              ).paddingOnly(bottom: 8),
            // 回到顶部按钮
            if (_showBackToTop.value)
              ScaleTransition(
                scale: _floatingButtonController,
                child: FloatingActionButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(Icons.arrow_upward),
                ),
              ),
            const SafeArea(child: SizedBox()),
          ],
        ).paddingBottom(Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0) : const SizedBox()),
    );
  }

  Widget buildCommentItem(
      BuildContext context, ThreadCommentModel comment, bool isWideScreen) {
    return ThreadCommentCardWidget(
      comment: comment,
      threadAuthorId: _thread.value?.user.id ?? '',
      threadId: widget.threadId,
      lockedThread: _thread.value?.locked ?? false,
      listSourceRepository: listSourceRepository,
    );
  }

  Widget _buildUserName(User user) {
    // 根据用户角色设置颜色
    Color? nameColor;
    if (user.role == 'officer' || user.role == 'moderator' || user.role == 'admin') {
      nameColor = Colors.green.shade400;
    } else if (user.role == 'limited') {
      nameColor = Colors.grey.shade400;
    } else {
      nameColor = user.isAdmin ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant;
    }

    // 如果是高级用户,使用渐变效果
    if (user.premium) {
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Colors.purple.shade300,
            Colors.blue.shade300,
            Colors.pink.shade300,
          ],
        ).createShader(bounds),
        child: Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // 普通用户名显示
    return Text(
      user.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: nameColor,
      ),
    );
  }

  Widget _buildShimmerLoading(bool isWideScreen) {
    return Card(
      margin: EdgeInsets.all(isWideScreen ? 16.0 : 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          highlightColor: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              // 作者信息
              Row(
                spacing: 12,
                children: [
                  // 头像
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        // 用户名
                        Container(
                          width: 100,
                          height: 14,
                          color: Colors.white,
                        ),
                        // 时间
                        Container(
                          width: 80,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 标题
              Container(
                width: double.infinity,
                height: 20,
                color: Colors.white,
              ),
              // 统计信息
              Row(
                spacing: 16,
                children: [
                  Container(
                    width: 60,
                    height: 14,
                    color: Colors.white,
                  ),
                  Container(
                    width: 60,
                    height: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 