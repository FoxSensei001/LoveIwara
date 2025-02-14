import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/author_profile/controllers/userz_post_list_repository.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_tile_list_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/pages/author_profile/widgets/post_input_dialog.dart';

class ProfilePostTabListWidget extends StatefulWidget {
  final String userId;
  final String tabKey;
  final TabController tc;
  final Function({int? count})? onFetchFinished;
  final GlobalKey<State<StatefulWidget>>? widgetKey;

  const ProfilePostTabListWidget({
    super.key,
    required this.userId,
    required this.tabKey,
    required this.tc,
    this.onFetchFinished,
    this.widgetKey,
  });

  void refresh() {
    if (widgetKey?.currentState != null) {
      (widgetKey!.currentState as _ProfilePostTabListWidgetState)
          .listSourceRepository
          .refresh();
    }
  }

  @override
  State<ProfilePostTabListWidget> createState() =>
      _ProfilePostTabListWidgetState();
}

class _ProfilePostTabListWidgetState extends State<ProfilePostTabListWidget>
    with AutomaticKeepAliveClientMixin {
  late UserzPostListRepository listSourceRepository;
  final ScrollController _scrollController = ScrollController();
  final RxBool _showBackToTop = false.obs;
  final UserService _userService = Get.find<UserService>();
  final PostService _postService = Get.find<PostService>();

  @override
  void initState() {
    super.initState();
    listSourceRepository = UserzPostListRepository(userId: widget.userId);

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

  void _showCreatePostDialog() {
    final t = slang.Translations.of(context);
    Get.dialog(
      PostInputDialog(
        onSubmit: (title, body) async {
          final result = await _postService.postPost(title, body);
          if (result.isSuccess) {
            showToastWidget(
              MDToastWidget(
                message: t.common.success,
                type: MDToastType.success,
              ),
            );
            AppService.tryPop();
            listSourceRepository.refresh();
          } else if (result.message == t.errors.tooManyRequests) {
            // 如果是请求过于频繁，则获取冷却时间
            final cooldownResult = await _postService.fetchPostCollingInfo();
            if (cooldownResult.isSuccess && cooldownResult.data != null) {
              final cooldown = cooldownResult.data!;
              if (cooldown.limited) {
                // 计算剩余时间，小数点后二位
                final remaining = cooldown.remaining; // 秒
                final hours = remaining ~/ 3600;
                final minutes = (remaining % 3600) ~/ 60;
                final seconds = remaining % 60;

                String timeStr =
                    '${t.errors.tooManyRequestsPleaseTryAgainLaterText} ';
                if (hours > 0) {
                  timeStr += '${t.errors.remainingHours(num: hours)} ';
                }
                if (minutes > 0) {
                  timeStr += '${t.errors.remainingMinutes(num: minutes)} ';
                }
                if (seconds > 0) {
                  timeStr += t.errors.remainingSeconds(num: seconds);
                }

                showToastWidget(
                  MDToastWidget(
                    message: timeStr.trim(),
                    type: MDToastType.error,
                  ),
                );
              }
            }
          } else {
            showToastWidget(
              MDToastWidget(
                message: result.message,
                type: MDToastType.error,
              ),
            );
          }
        },
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await listSourceRepository.refresh(true);
          },
          child: LoadingMoreCustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              LoadingMoreSliverList<PostModel>(
                SliverListConfig<PostModel>(
                  itemBuilder: buildItem,
                  sourceList: listSourceRepository,
                  padding: const EdgeInsets.all(8.0),
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
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 发表帖子按钮
              Obx(() {
                if (_userService.currentUser.value?.id == widget.userId) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: FloatingActionButton(
                      heroTag: 'createPost',
                      onPressed: _showCreatePostDialog,
                      child: const Icon(Icons.add),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              // 返回顶部按钮
              Obx(() => _showBackToTop.value
                  ? FloatingActionButton(
                      heroTag: 'backToTop',
                      onPressed: () {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Icon(Icons.arrow_upward),
                    ).paddingBottom(Get.context != null
                      ? MediaQuery.of(Get.context!).padding.bottom
                      : 0)
                  : const SizedBox()),
            ],
          ),
        ),
      ],
    ).paddingOnly(bottom: Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0);
  }

  Widget buildItem(BuildContext context, PostModel post, int index) {
    return PostTileListItemWidget(post: post);
  }

  @override
  bool get wantKeepAlive => true;
}
