import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/popular_media_search_config_widget.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/widgets/common_header.dart';

import '../../../models/sort.model.dart';
import '../../../models/tag.model.dart';
import '../../widgets/top_padding_height_widget.dart';
import 'controllers/popular_gallery_controller.dart';
import 'controllers/popular_gallery_repository.dart';
import 'widgets/media_tab_view.dart';

class PopularGalleryListPage extends StatefulWidget {
  final List<Sort> sorts = CommonConstants.mediaSorts;

  PopularGalleryListPage({super.key});

  @override
  _PopularGalleryListPageState createState() => _PopularGalleryListPageState();
}

class _PopularGalleryListPageState extends State<PopularGalleryListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _tabBarScrollController;
  final List<GlobalKey> _tabKeys = [];

  final UserService userService = Get.find<UserService>();

  final Map<SortId, PopularGalleryRepository> _repositories = {};
  final Map<SortId, PopularGalleryController> _controllers = {};

  // 查询参数
  List<Tag> tags = [];
  String year = '';
  String rating = '';

  @override
  void initState() {
    super.initState();
    for (var sort in widget.sorts) {
      _tabKeys.add(GlobalKey());
      final controller = Get.put(PopularGalleryController(sortId: sort.id.name), tag: sort.id.name);
      _controllers[sort.id] = controller;
      _repositories[sort.id] = controller.repository as PopularGalleryRepository;
    }
    _tabController = TabController(length: widget.sorts.length, vsync: this);
    _tabBarScrollController = ScrollController();

    _tabController.addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _tabBarScrollController.dispose();
    for (var controller in _controllers.values) {
      Get.delete<PopularGalleryController>(tag: controller.sortId);
    }
    _controllers.clear();
    _repositories.clear();
    super.dispose();
  }

  // 设置查询参数
  void setParams(
      {List<Tag> tags = const [], String year = '', String rating = ''}) {
    this.tags = tags;
    this.year = year;
    this.rating = rating;

    LogUtils.d('设置查询参数: tags: $tags, year: $year, rating: $rating', 'PopularGalleryListPage');

    // 设置每个controller的查询参数并重置数据
    for (var sort in widget.sorts) {
      var controller = _controllers[sort.id]!;
      controller.updateSearchParams(
        searchTagIds: tags.map((e) => e.id).toList(),
        searchDate: year,
        searchRating: rating,
      );
    }
  }

  void _onTabChange() {
    _scrollToSelectedTab();
  }

  void _scrollToSelectedTab() {
    final GlobalKey currentTabKey = _tabKeys[_tabController.index];
    final RenderBox? renderBox =
        currentTabKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final screenWidth = MediaQuery.of(context).size.width;
      final tabWidth = renderBox.size.width;

      final targetScroll = _tabBarScrollController.offset +
          position.dx -
          (screenWidth / 2) +
          (tabWidth / 2);

      final double finalScroll = targetScroll.clamp(
        0.0,
        _tabBarScrollController.position.maxScrollExtent,
      );

      _tabBarScrollController.animateTo(
        finalScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleScroll(double delta) {
    if (_tabBarScrollController.hasClients) {
      final double newOffset = _tabBarScrollController.offset + delta;
      if (newOffset < 0) {
        _tabBarScrollController.jumpTo(0);
      } else if (newOffset > _tabBarScrollController.position.maxScrollExtent) {
        _tabBarScrollController
            .jumpTo(_tabBarScrollController.position.maxScrollExtent);
      } else {
        _tabBarScrollController.jumpTo(newOffset);
      }
    }
  }

  // 打开搜索配置弹窗
  void _openParamsModal() {
    Get.dialog(PopularMediaSearchConfig(
      searchTags: tags,
      searchYear: year,
      searchRating: rating,
      onConfirm: (tags, year, rating) {
        setParams(tags: tags, year: year, rating: rating);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopPaddingHeightWidget(),
          const CommonHeader(
            searchSegment: SearchSegment.image,
            avatarRadius: 20,
          ),
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  child: Listener(
                    onPointerSignal: (pointerSignal) {
                      if (pointerSignal is PointerScrollEvent) {
                        _handleScroll(pointerSignal.scrollDelta.dy);
                      }
                    },
                    child: SingleChildScrollView(
                      controller: _tabBarScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: TabBar(
                        isScrollable: true,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        controller: _tabController,
                        tabs: widget.sorts.asMap().entries.map((entry) {
                          int index = entry.key;
                          Sort sort = entry.value;
                          return Container(
                            key: _tabKeys[index],
                            child: Tab(
                              child: Row(
                                children: [
                                  sort.icon ?? const SizedBox(),
                                  const SizedBox(width: 4),
                                  Text(sort.label),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  var sortId = widget.sorts[_tabController.index].id;
                  var repository = _repositories[sortId]!;
                  repository.refresh(true);
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _openParamsModal,
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.sorts.map((sort) {
                return MediaTabView<ImageModel>(
                  repository: _repositories[sort.id]!,
                  emptyIcon: Icons.image_outlined,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
