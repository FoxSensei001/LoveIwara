import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/notifications/controllers/notification_list_repository.dart';
import 'package:i_iwara/app/ui/pages/notifications/widgets/notification_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:loading_more_list/loading_more_list.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  late NotificationListRepository listSourceRepository;
  final ScrollController _scrollController = ScrollController();

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  final UserService _userService = Get.find<UserService>();
  final RxBool _isMarkingAllAsRead = false.obs;
  final RxBool _isRefreshing = false.obs;

  /// 未读总数：通知 + 好友申请 + 私信（与旧版标题里的计数口径一致）。
  int get _unreadCount =>
      _userService.notificationCount.value +
      _userService.friendRequestsCount.value +
      _userService.messagesCount.value;

  @override
  void initState() {
    super.initState();
    listSourceRepository = NotificationListRepository();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    listSourceRepository.dispose();
    _showBackToTop.dispose();
    super.dispose();
  }

  // 滚动到顶部方法
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 标记所有通知为已读
  Future<void> _markAllAsRead() async {
    try {
      _isMarkingAllAsRead.value = true;
      final result = await _userService.markAllNotificationAsRead();
      if (result.isSuccess) {
        _userService.refreshNotificationCount();
        showToastWidget(
          MDToastWidget(
            message: slang.t.notifications.markAllAsReadSuccess,
            type: MDToastType.success,
          ),
        );
        // 刷新列表和计数
        await listSourceRepository.refresh();
      } else {
        showToastWidget(
          MDToastWidget(
            message: result.message,
            type: MDToastType.error,
          ),
        );
      }
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: '${slang.t.errors.failedToOperate}: $e',
          type: MDToastType.error,
        ),
      );
    } finally {
      _isMarkingAllAsRead.value = false;
    }
  }

  // 刷新列表
  Future<void> _refreshList() async {
    try {
      _isRefreshing.value = true;
      await listSourceRepository.refresh();
    } finally {
      _isRefreshing.value = false;
    }
  }

  // 通知类型帮助弹窗
  void _showHelpDialog() {
    final configService = Get.find<ConfigService>();
    final colorScheme = Theme.of(context).colorScheme;
    showAppDialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行：图标 + 标题 + 关闭玻璃圆钮
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 22,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          slang.t.notifications.notificationTypeHelp,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      GlassIconButton(
                        standalone: true,
                        icon: const Icon(Icons.close),
                        tooltip: slang.t.common.close,
                        onPressed: () => AppService.tryPop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slang.t.notifications.dueToLackOfNotificationTypeDetails,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slang
                            .t.notifications.helpUsImproveNotificationTypeSupport,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slang.t.notifications
                            .helpUsImproveNotificationTypeSupportLongText,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => launchUrl(
                        Uri.parse(configService[ConfigKey.REMOTE_REPO_URL]),
                      ),
                      icon: const Icon(Icons.open_in_new),
                      label: Text(slang.t.notifications.goToRepository),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 右侧动作胶囊：全部已读（带未读小红点）· 刷新 · 帮助。
  Widget _buildActionGroup(BuildContext context) {
    return Obx(
      () {
        final bool marking = _isMarkingAllAsRead.value;
        final bool refreshing = _isRefreshing.value;
        final int unread = _unreadCount;
        return GlassButtonGroup(
          children: [
            GlassIconButton(
              // 忙碌时图标经 GlassAnimatedIcon 交叉过渡成沙漏，而不是整钮换 Shimmer
              icon: Icon(
                marking ? Icons.hourglass_top : Icons.mark_email_read,
              ),
              tooltip: slang.t.notifications.markAllAsRead,
              // 未读小红点：有未读时弹跳出现，全部已读后收缩消失
              showBadge: unread > 0 && !marking,
              onPressed: marking ? null : _markAllAsRead,
            ),
            GlassIconButton(
              icon: Icon(refreshing ? Icons.hourglass_top : Icons.refresh),
              tooltip: slang.t.common.refresh,
              onPressed: refreshing ? null : _refreshList,
            ),
            GlassIconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: slang.t.notifications.notificationTypeHelp,
              onPressed: _showHelpDialog,
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
                tooltip: slang.t.common.scrollToTop,
                onPressed: _scrollToTop,
              ),
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
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
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
            onRefresh: _refreshList,
            child: LoadingMoreCustomScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: <Widget>[
                LoadingMoreSliverList<Map<String, dynamic>>(
                  SliverListConfig<Map<String, dynamic>>(
                    itemBuilder: (context, notification, index) {
                      return NotificationListItemWidget(
                        notification: notification,
                      );
                    },
                    sourceList: listSourceRepository,
                    padding: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: listTopPadding,
                      bottom: MediaQuery.of(context).padding.bottom,
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
                tooltip: slang.t.common.back,
                onPressed: () => AppService.tryPop(),
              ),
              const SizedBox(width: 8),
              // 标题胶囊：未读数并入标题，点按/长按可弹完整标题
              Expanded(
                child: Obx(
                  () {
                    final int count = _unreadCount;
                    return GlassTitlePill(
                      title: count > 0
                          ? '${slang.t.notifications.notifications} ($count)'
                          : slang.t.notifications.notifications,
                    );
                  },
                ),
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
