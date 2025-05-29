import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/popular_media_list_base_page.dart';
import 'controllers/popular_video_controller.dart';
import 'controllers/popular_video_repository.dart';

// 继承基类，并指定泛型参数
class PopularVideoListPage extends PopularMediaListPageBase<Video, PopularVideoController, PopularVideoRepository> {

  const PopularVideoListPage({super.key})
      : super(
          controllerTag: 'video',
          searchSegment: SearchSegment.video,
          emptyIcon: Icons.video_library_outlined,
        );

  // 实现创建 Controller 的方法
  @override
  PopularVideoController createSpecificController(String sortIdName) {
    return Get.put(PopularVideoController(sortId: sortIdName), tag: sortIdName);
  }

  // 实现获取 Repository 的方法
  @override
  PopularVideoRepository getSpecificRepository(PopularVideoController controller) {
    // 假设 Controller 有一个 repository 属性
    return controller.repository as PopularVideoRepository;
  }

  // 实现必要的createState方法
  @override
  State<PopularVideoListPage> createState() => PopularMediaListPageBaseState<Video, PopularVideoController, PopularVideoRepository, PopularVideoListPage>();

  // 全局key，用于访问State
  static final GlobalKey<PopularMediaListPageBaseState> globalKey = GlobalKey<PopularMediaListPageBaseState>();

  @override
  void refreshCurrent() {
    refreshCurrentImpl();
  }
}
