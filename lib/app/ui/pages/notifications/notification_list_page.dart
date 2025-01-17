import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/notifications/controllers/notification_list_repository.dart';
import 'package:i_iwara/app/ui/pages/notifications/widgets/notification_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:url_launcher/url_launcher.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  late NotificationListRepository listSourceRepository;
  final ScrollController _scrollController = ScrollController();
  final RxBool _showBackToTop = false.obs;
  final RxBool _enableFloatingButton = true.obs;
  final UserService _userService = Get.find<UserService>();
  final RxBool _isMarkingAllAsRead = false.obs;
  final RxBool _isRefreshing = false.obs;

  @override
  void initState() {
    super.initState();
    listSourceRepository = NotificationListRepository();

    // 添加滚动监听
    _scrollController.addListener(() {
      if (_scrollController.offset >= 300) {
        _showBackToTop.value = true;
      } else {
        _showBackToTop.value = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    listSourceRepository.dispose();
    super.dispose();
  }

  // 标记所有通知为已读
  Future<void> _markAllAsRead() async {
    final translations = slang.Translations.of(context);
    try {
      _isMarkingAllAsRead.value = true;
      final result = await _userService.markAllNotificationAsRead();
      if (result.isSuccess) {
        _userService.refreshNotificationCount();
        showToastWidget(MDToastWidget(
          message: translations.notifications.markAllAsReadSuccess,
          type: MDToastType.success,
        ));
        // 刷新列表和计数
        await listSourceRepository.refresh();
      } else {
        showToastWidget(MDToastWidget(
          message: result.message,
          type: MDToastType.error,
        ));
      }
    } catch (e) {
      showToastWidget(MDToastWidget(
        message: '${translations.errors.failedToOperate}: $e',
        type: MDToastType.error,
      ));
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

  @override
  Widget build(BuildContext context) {
    final translations = slang.Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Text(translations.notifications.notifications),
            Obx(() {
              final count = _userService.notificationCount.value + _userService.friendRequestsCount.value + _userService.messagesCount.value;
              if (count > 0) {
                return Text('($count)');
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        actions: [
          Row(
            children: [
              // 全部标记已读按钮
              Obx(() {
                if (_isMarkingAllAsRead.value) {
                  return Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                    child: const IconButton(
                      icon: Icon(Icons.mark_email_read),
                      onPressed: null,
                    ),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.mark_email_read),
                  onPressed: _markAllAsRead,
                  tooltip: translations.notifications.markAllAsRead,
                );
              }),
              // 浮动按钮开关
              Obx(() => IconButton(
                icon: Icon(_enableFloatingButton.value
                    ? Icons.vertical_align_top
                    : Icons.vertical_align_top_outlined),
                onPressed: () {
                  _enableFloatingButton.value = !_enableFloatingButton.value;
                  showToastWidget(MDToastWidget(
                      message: _enableFloatingButton.value
                          ? translations.common.disabledFloatingButtons
                          : translations.common.enabledFloatingButtons,
                      type: MDToastType.success));
                },
                tooltip: _enableFloatingButton.value
                    ? translations.common.disableFloatingButtons
                    : translations.common.enableFloatingButtons,
                style: IconButton.styleFrom(
                  backgroundColor: !_enableFloatingButton.value
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.5)
                      : null,
                  foregroundColor: !_enableFloatingButton.value
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )),
              // 刷新按钮
              Obx(() {
                if (_isRefreshing.value) {
                  return Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                    child: const IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: null,
                    ),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshList,
                );
              }),
              // 帮助按钮
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  final ConfigService configService = Get.find<ConfigService>();
                  Get.dialog(
                    AlertDialog(
                      title: Text('ℹ️ ${slang.t.notifications.notificationTypeHelp}'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🔔 ${slang.t.notifications.dueToLackOfNotificationTypeDetails}'),
                          Text('🔔 ${slang.t.notifications.helpUsImproveNotificationTypeSupport}'),
                          const SizedBox(height: 8),
                          Text(slang.t.notifications.helpUsImproveNotificationTypeSupportLongText),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse(configService[ConfigService.REMOTE_REPO_URL]));
                          },
                          child: Text('🔗 ${slang.t.notifications.goToRepository}'),
                        ),
                        TextButton(
                          onPressed: () => AppService.tryPop(),
                          child: Text(slang.t.common.close),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: LoadingMoreCustomScrollView(
        controller: _scrollController,
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
                left: 5.0,
                right: 5.0,
                top: 5.0,
                bottom: Get.context != null
                    ? MediaQuery.of(Get.context!).padding.bottom
                    : 0,
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
      ),
      floatingActionButton: Obx(() =>
          (_showBackToTop.value && _enableFloatingButton.value)
              ? FloatingActionButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  backgroundColor: !_enableFloatingButton.value
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                      : null,
                  foregroundColor: !_enableFloatingButton.value
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  child: const Icon(Icons.arrow_upward),
                ).paddingBottom(Get.context != null
                  ? MediaQuery.of(Get.context!).padding.bottom
                  : 0)
              : const SizedBox()),
    );
  }
} 