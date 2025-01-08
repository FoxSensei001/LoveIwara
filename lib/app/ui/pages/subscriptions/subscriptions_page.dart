import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_image_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_post_list.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_select_list_widget.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/subscription_video_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../../../models/dto/user_dto.dart';
import '../../../services/app_service.dart';
import '../../widgets/top_padding_height_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/constants.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage>
    with TickerProviderStateMixin {
  final UserService userService = Get.find<UserService>();
  final UserPreferenceService userPreferenceService =
      Get.find<UserPreferenceService>();

  late TabController _tabController;
  String selectedId = '';

  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  late AnimationController _refreshIconController;
  
  // 为每个列表保存一个GlobalKey，用于调用刷新方法
  final Map<int, GlobalKey<State>> _listStateKeys = {
    0: GlobalKey<SubscriptionVideoListState>(),
    1: GlobalKey<SubscriptionImageListState>(),
    2: GlobalKey<SubscriptionPostListState>(),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _refreshIconController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  void _scrollListener() {
    bool shouldShow =
        _scrollController.hasClients && _scrollController.offset > 200;
    if (shouldShow != _showBackToTop) {
      setState(() {
        _showBackToTop = shouldShow;
      });
    }
  }

  void _onIdSelected(String id) {
    if (selectedId != id) {
      setState(() {
        selectedId = id;
        // 为所有列表生成新的key
        _listStateKeys[0] = GlobalKey<SubscriptionVideoListState>();
        _listStateKeys[1] = GlobalKey<SubscriptionImageListState>();
        _listStateKeys[2] = GlobalKey<SubscriptionPostListState>();
      });
    }
  }

  // 刷新当前列表
  Future<void> _refreshCurrentList() async {
    _refreshIconController.repeat();
    try {
      final currentKey = _listStateKeys[_tabController.index];
      if (currentKey?.currentState != null) {
        if (_tabController.index == 0) {
          await (currentKey!.currentState as SubscriptionVideoListState).refresh();
        } else if (_tabController.index == 1) {
          await (currentKey!.currentState as SubscriptionImageListState).refresh();
        } else {
          await (currentKey!.currentState as SubscriptionPostListState).refresh();
        }
      }
    } finally {
      _refreshIconController.stop();
      _refreshIconController.reset();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _refreshIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (userService.isLogin) {
        return _buildLoggedInView(context);
      } else {
        return _buildNotLoggedIn(context);
      }
    });
  }

  Widget _buildContent(BuildContext context) {
    final t = slang.Translations.of(context);
    return Column(
      children: [
        TopPaddingHeightWidget(),
        Row(
          children: [
            Obx(() {
              if (userService.isLogin) {
                return IconButton(
                  icon: AvatarWidget(
                    avatarUrl: userService.userAvatar,
                    radius: 14,
                    defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                    isPremium: userService.currentUser.value?.premium ?? false,
                    isAdmin: userService.currentUser.value?.isAdmin ?? false,
                  ),
                  onPressed: () {
                    AppService.switchGlobalDrawer();
                  },
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    AppService.switchGlobalDrawer();
                  },
                );
              }
            }),
            Expanded(
              child: Text(
                t.common.subscriptions,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Obx(() {
          RxSet<UserDTO> likedUsers = userPreferenceService.likedUsers;
          List<UserDTO> sortedUsers = likedUsers.toList()
            ..sort((a, b) => 
              (b.likedTime ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.likedTime ?? DateTime.fromMillisecondsSinceEpoch(0)));
          List<SubscriptionSelectItem> selectionList = sortedUsers
              .map((userDto) => SubscriptionSelectItem(
                    id: userDto.id,
                    label: userDto.name,
                    avatarUrl: userDto.avatarUrl,
                    onLongPress: () => NaviService.navigateToAuthorProfilePage(userDto.username),
                  ))
              .toList();
          return SubscriptionSelectList(
            selectionList: selectionList,
            selectedId: selectedId,
            onIdSelected: _onIdSelected,
          );
        }),
        Row(
          children: [
            Expanded(
              child: TabBar(
                isScrollable: true,
                physics: const NeverScrollableScrollPhysics(),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                controller: _tabController,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  Tab(text: t.common.video),
                  Tab(text: t.common.gallery),
                  Tab(text: t.common.post),
                ],
              ),
            ),
            RotationTransition(
              turns: _refreshIconController,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshCurrentList,
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SubscriptionVideoList(
                key: _listStateKeys[0],
                userId: selectedId,
              ),
              SubscriptionImageList(
                key: _listStateKeys[1],
                userId: selectedId,
              ),
              SubscriptionPostList(
                key: _listStateKeys[2],
                userId: selectedId,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    return Scaffold(
      body: _buildContent(context),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _showBackToTop ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          opacity: _showBackToTop ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton.small(
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            },
            child: const Icon(Icons.arrow_upward),
          ),
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopPaddingHeightWidget(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t.signIn.pleaseLoginFirst,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t.subscriptions.pleaseLoginFirstToViewYourSubscriptions,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => Get.toNamed(Routes.LOGIN),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          minimumSize: const Size(200, 0),
                        ),
                        child: Text(
                          t.auth.login,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
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
