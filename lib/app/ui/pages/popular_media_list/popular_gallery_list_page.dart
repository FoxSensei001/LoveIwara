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
  // 提供 GlobalKey - 更新类型
  static final globalKey = GlobalKey<
      PopularMediaListPageBaseState<ImageModel, PopularGalleryController,
          PopularGalleryRepository, PopularGalleryListPage>>();

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
    // 假设 Controller 有一个 repository 属性
    return controller.repository as PopularGalleryRepository;
  }

  // 实现获取 GlobalKey 的 getter - 更新类型
  @override
  GlobalKey<
      PopularMediaListPageBaseState<
          ImageModel,
          PopularGalleryController,
          PopularGalleryRepository,
          PopularGalleryListPage>> get pageGlobalKey => globalKey;
}
