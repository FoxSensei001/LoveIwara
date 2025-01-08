import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/error_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/proxy/proxy_util.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../utils/logger_utils.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/gallery_service.dart';

class PopularGalleryController extends GetxController {
  final String sortId; // 当前controller的排序
  final GalleryService _galleryService = Get.find<GalleryService>(); // 图片服务

  final RxList<ImageModel> images = <ImageModel>[].obs; // 图片列表
  final RxBool isLoading = false.obs; // 是否正在加载
  final RxBool hasMore = true.obs; // 是否还有更多数据
  final RxBool isInit = true.obs; // 是否是初始化状态
  final Rxn<Widget> errorWidget = Rxn<Widget>(); // 错误小部件
  List<String> searchTagIds = []; // 搜索标签
  String searchDate = ''; // 搜索日期 如2024、2023、
  String searchRating = ''; // 内容评级

  final int pageSize = 20; // 每页数据量
  int page = 0; // 当前页码

  PopularGalleryController({required this.sortId});

  /// 重置控制器状态
  void reset() {
    page = 0;
    hasMore.value = true;
    isInit.value = true;
    images.clear();
    errorWidget.value = null;
  }

  /// 获取图片列表
  /// [refresh] 是否刷新
  Future<void> fetchImageModels({bool refresh = false}) async {
    if (refresh) {
      // 刷新时重置所有状态
      reset();
    }
    
    if (!hasMore.value || isLoading.value) return;

    isLoading.value = true;

    LogUtils.d('当前的查询参数: tags: $searchTagIds, date: $searchDate, rating: $searchRating', 'PopularImageModelController');
    try {
      ApiResult<PageData<ImageModel>> result =
          await _galleryService.fetchImageModelsByParams(
        params: {
          'sort': sortId,
          'tags': searchTagIds.join(','),
          'date': searchDate,
          'rating': searchRating,
        },
        page: page,
        limit: pageSize,
      );

      if (result.isFail) {
        throw result.message;
      }

      List<ImageModel> newImageModels = result.data!.results;
      images.addAll(newImageModels);

      if (newImageModels.length < pageSize) {
        hasMore.value = false;
      }

      page++;
    } catch (e) {
      LogUtils.e('获取图片列表失败', tag: 'PopularImageModelController', error: e);
      showToastWidget(MDToastWidget(message: t.errors.errorWhileFetching, type: MDToastType.error));
      errorWidget.value = CommonErrorWidget(
        text: t.errors.errorWhileFetching,
        children: [
          if (ProxyUtil.isSupportedPlatform())
            ElevatedButton(
              onPressed: () => {Get.toNamed(Routes.PROXY_SETTINGS_PAGE)},
              child: Text(t.common.checkNetworkSettings),
            ).paddingRight(10),
          ElevatedButton(
            onPressed: () => fetchImageModels(refresh: true),
            child: Text(t.common.refresh),
          ),
        ],
      );
    } finally {
      isLoading.value = false;
      isInit.value = false;
    }
  }

}
