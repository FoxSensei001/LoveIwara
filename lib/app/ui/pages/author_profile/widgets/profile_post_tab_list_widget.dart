import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/ui/pages/author_profile/controllers/userz_post_list_controller.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_tile_list_item_widget.dart';

class ProfilePostTabListWidget extends StatefulWidget {
  final String userId;
  final String tabKey;
  final TabController tc;
  final Function({int? count})? onFetchFinished;

  const ProfilePostTabListWidget({
    super.key,
    required this.userId,
    required this.tabKey,
    required this.tc,
    this.onFetchFinished,
  });

  @override
  State<ProfilePostTabListWidget> createState() => _ProfilePostTabListWidgetState();
}

class _ProfilePostTabListWidgetState extends State<ProfilePostTabListWidget>
    with AutomaticKeepAliveClientMixin {
  late UserzPostListRepository listSourceRepository;
  final ScrollController _scrollController = ScrollController();
  final RxBool _showBackToTop = false.obs;

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        LoadingMoreCustomScrollView(
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
        Positioned(
          right: 16,
          bottom: 16,
          child: Obx(() => _showBackToTop.value
              ? FloatingActionButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(Icons.arrow_upward),
                ).paddingBottom(Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0)
              : const SizedBox()),
        ),
      ],
    );
  }

  Widget buildItem(BuildContext context, PostModel post, int index) {
    return PostTileListItemWidget(post: post);
  }

  @override
  bool get wantKeepAlive => true;
} 