import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/message_and_conversation.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/conversation/controllers/conversation_list_repository.dart';
import 'package:i_iwara/app/ui/pages/conversation/widgets/new_conversation_dialog.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class ConversationListWidget extends StatefulWidget {
  final Function(ConversationModel) onConversationSelected;

  const ConversationListWidget({
    super.key,
    required this.onConversationSelected,
  });

  @override
  State<ConversationListWidget> createState() =>
      _ConversationListWidgetState();
}

class _ConversationListWidgetState extends State<ConversationListWidget> {
  late ConversationListRepository listSourceRepository;
  final ScrollController _scrollController = ScrollController();
  final UserService userService = Get.find<UserService>();

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    listSourceRepository = ConversationListRepository();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    listSourceRepository.dispose();
    _showBackToTop.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _startConversation() {
    showAppDialog(
      NewConversationDialog(
        onSubmit: () {
          listSourceRepository.refresh(true);
        },
      ),
      barrierDismissible: true,
    );
  }

  /// 右侧动作胶囊：发起对话 · 刷新（忙碌时图标交叉过渡成沙漏）。
  Widget _buildActionGroup(BuildContext context) {
    return StreamBuilder<Iterable<ConversationModel>>(
      stream: listSourceRepository.rebuild,
      builder: (context, snapshot) {
        final bool isLoading =
            listSourceRepository.isLoading && listSourceRepository.isEmpty;
        return GlassButtonGroup(
          children: [
            GlassIconButton(
              icon: const Icon(Icons.add_comment),
              tooltip: t.conversation.startConversation,
              onPressed: _startConversation,
            ),
            GlassIconButton(
              icon: const Icon(Icons.refresh),
              loading: isLoading,
              tooltip: t.common.refresh,
              onPressed: () => listSourceRepository.refresh(true),
            ),
          ],
        );
      },
    );
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮。
  Widget _buildScrollToTopFab(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) => IgnorePointer(
          ignoring: !visible,
          child: AnimatedSlide(
            duration: GlassTokens.motionDuration,
            curve: GlassTokens.motionCurve,
            offset: visible ? Offset.zero : const Offset(0, 0.4),
            child: AnimatedOpacity(
              duration: GlassTokens.motionDuration,
              opacity: visible ? 1 : 0,
              child: GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.vertical_align_top),
                tooltip: t.common.scrollToTop,
                onPressed: _scrollToTop,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    ConversationModel conversation,
  ) {
    final otherParticipant = conversation.participants.firstWhere(
      (user) => user.id != userService.currentUser.value?.id,
      orElse: () => conversation.participants.first,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final bool unread = conversation.unread;
    // 最后一条是不是自己发的：是的话预览行前面带「我：」前缀
    final bool fromMe =
        conversation.lastMessage.user.id ==
        userService.currentUser.value?.id;

    // 未读会话铺一层极淡的主题色（与通知卡片同一套未读语言）
    final Color? cardColor = unread
        ? Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.06),
            colorScheme.surface,
          )
        : null;

    return UserCardShell(
      color: cardColor,
      onTap: () {
        widget.onConversationSelected(conversation);
        // 去除红点
        if (conversation.unread) {
          conversation.unread = false;
          if (userService.messagesCount.value > 0) {
            userService.messagesCount.value =
                userService.messagesCount.value - 1;
          }
          setState(() {});
        }
      },
      leading: GestureDetector(
        onTap: () =>
            NaviService.navigateToAuthorProfilePage(otherParticipant.username),
        // 未读时头像外圈加一圈主题色描边，让「谁有新消息」在缩略图上就能读出来
        child: unread
            ? Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
                child: AvatarWidget(user: otherParticipant, size: 44),
              )
            : AvatarWidget(user: otherParticipant, size: 44),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: buildUserName(
                  context,
                  otherParticipant,
                  fontSize: 15,
                  overflowLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CommonUtils.formatFriendlyTimestamp(
                  conversation.lastMessage.createdAt,
                ),
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '@${otherParticipant.username}',
            style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      if (fromMe)
                        TextSpan(
                          text: t.conversation.lastMessageFromMe,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      TextSpan(text: conversation.lastMessage.body),
                    ],
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: unread
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.error.withValues(alpha: 0.35),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final double listTopPadding = headerExtent + 8;

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        liquid: true,
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.axis == Axis.vertical &&
                notification.depth == 0) {
              _showBackToTop.value = notification.metrics.pixels >= 300;
            }
            return false;
          },
          child: RefreshIndicator(
            // 指示器从 header 下方弹出
            displacement: headerExtent,
            onRefresh: () => listSourceRepository.refresh(true),
            child: LoadingMoreCustomScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: <Widget>[
                LoadingMoreSliverList<ConversationModel>(
                  SliverListConfig<ConversationModel>(
                    itemBuilder: (context, conversation, index) =>
                        _buildConversationItem(context, conversation),
                    sourceList: listSourceRepository,
                    padding: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: listTopPadding,
                      bottom: MediaQuery.of(context).padding.bottom + 8.0,
                    ),
                    indicatorBuilder: (context, status) =>
                        myLoadingMoreIndicator(
                      context,
                      status,
                      isSliver: true,
                      loadingMoreBase: listSourceRepository,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // header 行：左 返回圆钮 / 中 标题胶囊 / 右 动作胶囊
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.arrow_back),
                tooltip: t.common.back,
                onPressed: () => AppService.tryPop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GlassTitlePill(title: t.conversation.conversation),
              ),
              const SizedBox(width: 8),
              _buildActionGroup(context),
            ],
          ),
        ),
        extra: [_buildScrollToTopFab(context)],
      ),
    );
  }
}
