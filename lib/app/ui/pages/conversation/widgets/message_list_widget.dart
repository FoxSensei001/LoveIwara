import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/message_and_conversation.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/conversation/widgets/conversation_message_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/comment_actions_sheet.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

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

  User get _otherParticipant => widget.conversation.participants.firstWhere(
        (user) => user.id != _userService.currentUser.value?.id,
        orElse: () => widget.conversation.participants.first,
      );

  void _showMessageComposer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConversationMessageBottomSheet(
        conversationId: widget.conversation.id,
        onSubmit: () {
          _messageListRepository.refresh(true);
        },
      ),
    );
  }

  /// 中间标题胶囊：对方昵称，长按/点按可看完整昵称 + @用户名。
  Widget _buildTitlePill(BuildContext context) {
    final otherParticipant = _otherParticipant;
    final String displayName = otherParticipant.name.isNotEmpty
        ? otherParticipant.name
        : otherParticipant.username;
    return GlassTitlePill(
      title: displayName,
      subtitle: '@${otherParticipant.username}',
    );
  }

  /// 右侧动作胶囊：仅刷新（忙碌时图标交叉过渡成沙漏）。
  Widget _buildActionGroup(BuildContext context) {
    return StreamBuilder<Iterable<MessageModel>>(
      stream: _messageListRepository.rebuild,
      builder: (context, snapshot) {
        final bool isLoading =
            _messageListRepository.isLoading && _messageListRepository.isEmpty;
        return GlassButtonGroup(
          children: [
            GlassIconButton(
              icon: const Icon(Icons.refresh),
              loading: isLoading,
              tooltip: t.common.refresh,
              onPressed: () => _messageListRepository.refresh(true),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageItem(BuildContext context, MessageModel message) {
    final bool isMe = message.user.id == _userService.currentUser.value?.id;
    final ConversationService conversationService =
        Get.find<ConversationService>();

    void showMessageTranslationDialog() {
      showTranslationDialog(
        context,
        text: message.body,
        barrierDismissible: true,
      );
    }

    Future<void> deleteMessage() async {
      final result = await conversationService.deleteMessage(message.id);
      if (result.isSuccess) {
        _messageListRepository.refresh(true);
      } else {
        showGlassToast(result.message, type: GlassToastType.error);
      }
    }

    Future<void> showDeleteConfirmation() async {
      await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) {
          final colorScheme = Theme.of(sheetContext).colorScheme;
          return Padding(
            padding: EdgeInsets.only(
              top: 8,
              bottom: computeSheetBottomInset(sheetContext) + 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: colorScheme.error),
                  title: Text(
                    t.conversation.deleteThisMessage,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  subtitle: Text(t.conversation.deleteThisMessageSubtitle),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    deleteMessage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(t.common.cancel),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          );
        },
      );
    }

    /// 长按消息正文：复制 / 选择复制 / 翻译 / 删除（仅自己发的消息）。
    void showActionsSheet() {
      showCommentActionsSheet(
        context: context,
        text: message.body,
        onTranslate: showMessageTranslationDialog,
        onDelete: isMe ? showDeleteConfirmation : null,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => NaviService.navigateToAuthorProfilePage(
                  message.user.username,
                ),
                child: _buildAvatar(message.user),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 第一行显示用户名
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                NaviService.navigateToAuthorProfilePage(
                                  message.user.username,
                                ),
                            child: buildUserName(
                              context,
                              message.user,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // 第二行只显示时间——翻译/删除移进长按操作菜单
                      Text(
                        CommonUtils.formatFriendlyTimestamp(
                          message.createdAt,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      // 带小尾巴的对话气泡：尾巴从气泡顶角伸出、指向发送者
                      // （对方消息在左角、自己的消息在右角，正好指着两侧头像）。
                      // 轮廓（含尾巴）由 _MessageBubblePainter 一笔画成，
                      // 描边不会从尾巴根部穿过去。
                      child: CustomPaint(
                        painter: _MessageBubblePainter(
                          fill: isMe
                              ? Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1)
                              : Theme.of(context).cardColor,
                          stroke: isMe
                              ? Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.28)
                              : Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.5),
                          tailOnRight: isMe,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            _MessageBubblePainter.tailHeight + 12,
                            12,
                            12,
                          ),
                          child: CustomMarkdownBody(
                            data: message.body,
                            originalData: message.body,
                            initialShowUnprocessedText: false,
                            clickInternalLinkByUrlLaunch: false,
                            onLongPress: showActionsSheet,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isMe)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => NaviService.navigateToAuthorProfilePage(
                  message.user.username,
                ),
                child: _buildAvatar(message.user),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User user) {
    return AvatarWidget(user: user, size: 40);
  }

  Widget _buildBottomBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      // 底部安全区交给 SafeArea 就够了。原先这里又手动加了一次
      // MediaQuery.padding.bottom，而这个 context 是 State.context、
      // 取自 SafeArea「之上」，拿到的是尚未被消费的原始值 —— 等于算了两遍。
      // 之前看不出来，是因为 Shell 的 Scaffold 把 padding.bottom 抹成了 0；
      // 现在底栏隐藏时 bottomNavigationBar 真的为 null，这里就会露出双倍间距。
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
        child: SizedBox(
          width: double.infinity,
          child: GlassSurface(
            height: GlassTokens.pillHeight,
            onTap: _showMessageComposer,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.conversation.writeMessageHere,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final double listTopPadding = headerExtent + 8;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GlassHeaderOverlay(
              headerExtent: headerExtent,
              headerTop: statusBarHeight,
              solidExtent: statusBarHeight,
              body: RefreshIndicator(
                // 指示器从 header 下方弹出
                displacement: headerExtent,
                onRefresh: () => _messageListRepository.refresh(true),
                child: LoadingMoreCustomScrollView(
                  controller: _scrollController,
                  reverse: true,
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    LoadingMoreSliverList<MessageModel>(
                      SliverListConfig<MessageModel>(
                        sourceList: _messageListRepository,
                        itemBuilder: (context, message, index) {
                          return _buildMessageItem(context, message);
                        },
                        indicatorBuilder: (context, status) =>
                            myLoadingMoreIndicator(
                          context,
                          status,
                          isSliver: true,
                          loadingMoreBase: _messageListRepository,
                        ),
                        padding: EdgeInsets.fromLTRB(
                          12.0,
                          listTopPadding,
                          12.0,
                          8.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // header 行：左 返回圆钮（窄屏才有）/ 中 标题胶囊 / 右 动作胶囊
              header: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (widget.fromNarrowScreen) ...[
                      GlassIconButton(
                        standalone: true,
                        icon: const Icon(Icons.arrow_back),
                        tooltip: t.common.back,
                        onPressed: () => AppService.tryPop(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(child: _buildTitlePill(context)),
                    const SizedBox(width: 8),
                    _buildActionGroup(context),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }
}

class MessageListRepository extends LoadingMoreBase<MessageModel>
    with LoadingMoreRefreshGuard<MessageModel> {
  final String conversationId;
  final ConversationService _conversationService =
      Get.find<ConversationService>();
  String? _lastMessageTime;
  bool _hasMoreMessages = true;

  MessageListRepository(this.conversationId);

  @override
  bool get hasMore => _hasMoreMessages;

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    // 代际 + 游标快照必须在 await 之前取：本仓库用 before 时间游标而非页码，
    // await 期间若发生 refresh()（把游标打回 null），回来的这一段旧消息会被
    // 追加进已经重新开始的列表里，游标也跟着错位。
    final int generation = currentGeneration;
    try {
      // 第一次加载使用当前时间,之后使用上一次结果的last时间
      final before = isLoadMoreAction
          ? _lastMessageTime
          : DateTime.now().toIso8601String();

      final result = await _conversationService.getMessages(
        conversationId,
        before: before,
        limit: 100,
      );

      // await 期间已被 refresh() 作废 → 丢弃本次结果。必须返回 true：
      // 返回 false 会被 loading_more_list 映射成一个假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }

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
      if (isStaleGeneration(generation)) {
        return true;
      }
      LogUtils.e('加载消息失败', tag: 'MessageListRepository', error: e);
      return false;
    }
  }

  @override
  void resetPagingState() {
    super.resetPagingState(); // 代际自增，作废在途回写
    _lastMessageTime = null;
    _hasMoreMessages = true;
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    return runGuardedRefresh(() => super.refresh(notifyStateChanged));
  }

  @override
  void dispose() {
    super.dispose();
    clear();
  }
}

/// 消息气泡背景：圆角矩形 + 从顶角伸出的小尾巴。
///
/// 尾巴位置由 [tailOnRight] 决定：自己的消息尾巴在右上角（指向右侧头像），
/// 对方的消息尾巴在左上角（指向左侧头像）。整个轮廓（含尾巴）是一条闭合
/// 路径，填充与描边共用，避免「描边从尾巴根部横穿过去」的破相。
///
/// 画布布局：顶部 [tailHeight] 高的条带留给尾巴，气泡主体从 y = tailHeight
/// 开始；外层内容的 Padding 因此要多让出 [tailHeight]。
class _MessageBubblePainter extends CustomPainter {
  _MessageBubblePainter({
    required this.fill,
    required this.stroke,
    required this.tailOnRight,
  });

  final Color fill;
  final Color stroke;
  final bool tailOnRight;

  /// 气泡圆角。
  static const double radius = 16;

  /// 尾巴根部的宽度。
  static const double tailWidth = 11;

  /// 尾巴伸出的高度（也是画布顶部预留条带的高度）。
  static const double tailHeight = 8;

  /// 尾巴根部离气泡近端边缘的距离。
  static const double tailInset = 14;

  /// 尾巴尖端相对根部中心的水平偏移：往发送者一侧偏一点，
  /// 让尾巴读起来是「指向头像」而不是竖直地杵着。
  static const double tailLean = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final double bodyTop = tailHeight;
    final double w = size.width;
    final double h = size.height;

    final Path path = Path();
    // 从左上圆角起点开始顺时针走一圈
    path.moveTo(radius, bodyTop);

    // 顶边：走到尾巴处，伸出尾巴再回来
    if (tailOnRight) {
      final double baseRight = w - tailInset;
      path.lineTo(baseRight - tailWidth, bodyTop);
      path.lineTo(baseRight - tailWidth / 2 + tailLean, bodyTop - tailHeight);
      path.lineTo(baseRight, bodyTop);
    } else {
      final double baseLeft = tailInset;
      path.lineTo(baseLeft, bodyTop);
      path.lineTo(baseLeft + tailWidth / 2 - tailLean, bodyTop - tailHeight);
      path.lineTo(baseLeft + tailWidth, bodyTop);
    }

    path.lineTo(w - radius, bodyTop);
    path.arcToPoint(
      Offset(w, bodyTop + radius),
      radius: const Radius.circular(radius),
    );
    path.lineTo(w, h - radius);
    path.arcToPoint(
      Offset(w - radius, h),
      radius: const Radius.circular(radius),
    );
    path.lineTo(radius, h);
    path.arcToPoint(
      Offset(0, h - radius),
      radius: const Radius.circular(radius),
    );
    path.lineTo(0, bodyTop + radius);
    path.arcToPoint(
      Offset(radius, bodyTop),
      radius: const Radius.circular(radius),
    );
    path.close();

    final Paint fillPaint = Paint()..color = fill;
    canvas.drawPath(path, fillPaint);

    final Paint strokePaint =
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _MessageBubblePainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.stroke != stroke ||
        oldDelegate.tailOnRight != tailOnRight;
  }
}
