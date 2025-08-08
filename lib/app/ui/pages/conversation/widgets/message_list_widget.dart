import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/message_and_conversation.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/conversation/widgets/conversation_message_dialog.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:shimmer/shimmer.dart';

class MessageListWidget extends StatefulWidget {
  final ConversationModel conversation;
  final bool fromNarrowScreen;

  const MessageListWidget({
    super.key,
    required this.conversation,
    required this.fromNarrowScreen,
  });

  @override
  State<MessageListWidget> createState() => _MessageListWidgetState();
}

class _MessageListWidgetState extends State<MessageListWidget> {
  late MessageListRepository _messageListRepository;
  final ScrollController _scrollController = ScrollController();
  final UserService _userService = Get.find<UserService>();

  @override
  void initState() {
    super.initState();
    _messageListRepository = MessageListRepository(widget.conversation.id);
  }

  @override
  void dispose() {
    _messageListRepository.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: LoadingMoreCustomScrollView(
              controller: _scrollController,
              reverse: true,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                LoadingMoreSliverList<MessageModel>(
                  SliverListConfig<MessageModel>(
                    sourceList: _messageListRepository,
                    itemBuilder: (context, message, index) {
                      return _buildMessageItem(context, message);
                    },
                    indicatorBuilder: _buildIndicator,
                    padding: const EdgeInsets.all(8.0),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    final otherParticipant = widget.conversation.participants.firstWhere(
      (user) => user.id != _userService.currentUser.value?.id,
      orElse: () => widget.conversation.participants.first,
    );

    return AppBar(
      // 窄屏来的要显示返回按钮
      leading: widget.fromNarrowScreen ? IconButton(
        onPressed: () => AppService.tryPop(),
        icon: const Icon(Icons.arrow_back),
      ) : const SizedBox.shrink(),
      centerTitle: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildUserName(context, otherParticipant, fontSize: 16),
          Text(
            '@${otherParticipant.username}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
      actions: [
        StreamBuilder<Iterable<MessageModel>>(
          stream: _messageListRepository.rebuild,
          builder: (context, snapshot) {
            final isLoading = _messageListRepository.isLoading && _messageListRepository.isEmpty;
            return IconButton(
              onPressed: isLoading ? null : () => _messageListRepository.refresh(true),
              icon: isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: const Icon(Icons.refresh),
                  )
                : const Icon(Icons.refresh),
            );
          }
        ),
      ],
    );
  }

  Widget? _buildIndicator(BuildContext context, IndicatorStatus status) {
    Widget? widget;
    
    switch (status) {
      case IndicatorStatus.none:
        return null;
      case IndicatorStatus.loadingMoreBusying:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: _buildShimmerItem(),
          ),
        );
      case IndicatorStatus.fullScreenBusying:
        widget = Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: List.generate(3, (index) => _buildShimmerItem()),
          ),
        );
        return SliverFillRemaining(child: widget);
      case IndicatorStatus.error:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.errorContainer,
            child: InkWell(
              onTap: () => _messageListRepository.errorRefresh(),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.conversation.errors.loadFailedClickToRetry,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      case IndicatorStatus.fullScreenError:
        widget = Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.errorContainer,
          child: InkWell(
            onTap: () => _messageListRepository.errorRefresh(),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.conversation.errors.loadFailed,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.conversation.errors.clickToRetry,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget,
            ),
          ),
        );
      case IndicatorStatus.noMoreLoad:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              t.conversation.errors.noMoreConversations,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        );
      case IndicatorStatus.empty:
        widget = Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 16),
              Text(
                t.conversation.tmpNoConversions,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: widget),
        );
    }
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 50,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, MessageModel message) {
    final bool isMe = message.user.id == _userService.currentUser.value?.id;
    final ConversationService conversationService = Get.find<ConversationService>();

    Future<void> showDeleteConfirmation() async {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(t.conversation.deleteThisMessage),
                  subtitle: Text(t.conversation.deleteThisMessageSubtitle),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await conversationService.deleteMessage(message.id);
                    if (result.isSuccess) {
                      _messageListRepository.refresh(true);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(t.common.cancel),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    }

    void showTranslationDialog() {
      Get.dialog(
        TranslationDialog(text: message.body),
        barrierDismissible: true,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => NaviService.navigateToAuthorProfilePage(message.user.username),
              child: _buildAvatar(message.user),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 第一行显示用户名
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => NaviService.navigateToAuthorProfilePage(message.user.username),
                            child: buildUserName(context, message.user, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // 第二行显示时间及操作按钮
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            CommonUtils.formatFriendlyTimestamp(message.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          if (!isMe) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.translate,
                                size: 18,
                                color: Theme.of(context).hintColor,
                              ),
                              onPressed: showTranslationDialog,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          ],
                          if (isMe) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Theme.of(context).hintColor,
                              ),
                              onPressed: showDeleteConfirmation,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.translate,
                                size: 18,
                                color: Theme.of(context).hintColor,
                              ),
                              onPressed: showTranslationDialog,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: !isMe ? Border.all(
                            color: Theme.of(context).dividerColor.withOpacity(0.5),
                            width: 0.5,
                          ) : null,
                        ),
                        child: CustomMarkdownBody(
                          data: message.body,
                          originalData: message.body,
                          initialShowUnprocessedText: false,
                          clickInternalLinkByUrlLaunch: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => NaviService.navigateToAuthorProfilePage(message.user.username),
              child: _buildAvatar(message.user),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User user) {
    return AvatarWidget(
      user: user,
      size: 40,
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          8.0,
          4.0,
          8.0,
          4.0 + (Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConversationMessageDialog(
                      conversationId: widget.conversation.id,
                      onSubmit: () {
                        _messageListRepository.refresh(true);
                      },
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                  t.conversation.writeMessageHere,
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageListRepository extends LoadingMoreBase<MessageModel> {
  final String conversationId;
  final ConversationService _conversationService = Get.find<ConversationService>();
  String? _lastMessageTime;
  bool _hasMoreMessages = true;
  
  MessageListRepository(this.conversationId);

  @override
  bool get hasMore => _hasMoreMessages;

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    try {
      // 第一次加载使用当前时间,之后使用上一次结果的last时间
      final before = isLoadMoreAction ? _lastMessageTime : DateTime.now().toIso8601String();
      
      final result = await _conversationService.getMessages(
        conversationId,
        before: before,
        limit: 100,
      );

      if (result.isSuccess && result.data != null) {
        final data = result.data!;
        
        if (data.results.isEmpty) {
          _hasMoreMessages = false;
          return true;
        }

        // 记录最后一条消息的时间，用于下次加载
        _lastMessageTime = data.last.toIso8601String();
        
        // API返回的消息是从旧到新排序，但我们需要新消息在前面
        // 所以每次都需要反转消息顺序
        final reversedMessages = data.results.reversed.toList();
        
        // 第一次加载时，直接添加到列表前面
        // 加载更多时，添加到列表后面
        if (isLoadMoreAction) {
          addAll(reversedMessages);
        } else {
          addAll(reversedMessages);
        }

        // 如果返回的消息数量小于请求的数量，说明没有更多消息了
        _hasMoreMessages = data.results.length >= 2;
        
        return true;
      }
      return false;
    } catch (e) {
      LogUtils.e('加载消息失败', tag: 'MessageListRepository', error: e);
      return false;
    }
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _lastMessageTime = null;
    _hasMoreMessages = true;
    return super.refresh(notifyStateChanged);
  }

  @override
  void dispose() {
    super.dispose();
    clear();
  }
} 