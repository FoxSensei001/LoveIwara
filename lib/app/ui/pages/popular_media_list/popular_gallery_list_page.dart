import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';

import 'controllers/popular_gallery_controller.dart';
import 'controllers/popular_gallery_repository.dart';
import 'popular_media_list_base_page.dart';

// 继承基类，并指定泛型参数
class PopularGalleryListPage extends PopularMediaListPageBase<ImageModel,
    PopularGalleryController, PopularGalleryRepository> {
  
  const PopularGalleryListPage({super.key})
      : super(
          controllerTag: 'gallery',
          searchSegment: SearchSegment.image,
          emptyIcon: Icons.image_outlined,
        );

  // 实现创建 Controller 的方法
  @override
  PopularGalleryController createSpecificController(String sortIdName) {
    return Get.put(PopularGalleryController(sortId: sortIdName),
        tag: sortIdName);
  }

  // 实现获取 Repository 的方法
  @override
  PopularGalleryRepository getSpecificRepository(
      PopularGalleryController controller) {
    return controller.repository as PopularGalleryRepository;
  }
  
  @override
  State<PopularGalleryListPage> createState() => PopularMediaListPageBaseState<ImageModel, PopularGalleryController, PopularGalleryRepository, PopularGalleryListPage>();

  // 全局key，用于访问State
  static final GlobalKey<PopularMediaListPageBaseState> globalKey = GlobalKey<PopularMediaListPageBaseState>();
  
  @override
  void refreshCurrent() {
    refreshCurrentImpl();
  }
}
