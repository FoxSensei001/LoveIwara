import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart'; // 保留 SearchSegment 导入
import 'package:i_iwara/app/ui/pages/popular_media_list/popular_media_list_base_page.dart'; // 导入基类
import 'package:i_iwara/app/ui/pages/home_page.dart'; // 导入HomeWidgetInterface
import 'controllers/popular_video_controller.dart';
import 'controllers/popular_video_repository.dart';

// 继承基类，并指定泛型参数
class PopularVideoListPage extends PopularMediaListPageBase<Video, PopularVideoController, PopularVideoRepository> {
  // 提供 GlobalKey - 更新类型
  static final globalKey = GlobalKey<PopularMediaListPageBaseState<Video, PopularVideoController, PopularVideoRepository, PopularVideoListPage>>();
  
  // 增加静态方法实现HomeWidgetInterface的查找
  static PopularVideoListPage? _cachedInstance;
  
  static PopularVideoListPage getInstance() {
    if (_cachedInstance == null) {
      _cachedInstance = PopularVideoListPage(key: globalKey);
    }
    return _cachedInstance!;
  }

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

  // 实现获取 GlobalKey 的 getter - 更新类型
  @override
  GlobalKey<PopularMediaListPageBaseState<Video, PopularVideoController, PopularVideoRepository, PopularVideoListPage>> get pageGlobalKey => globalKey;
}
