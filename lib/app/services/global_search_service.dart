import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/search_record.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/search_service.dart';
import 'package:i_iwara/app/ui/widgets/error_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class GlobalSearchService extends GetxService {
  final SearchService searchService = Get.find<SearchService>();
  final Rx<String> searchPlaceholder = ''.obs;
  final RxString searchErrorText = ''.obs;

  /// 当前搜索关键词
  final Rx<String> currentSearch = ''.obs;

  /// {@link SearchSegment} 的枚举值
  final Rx<String> selectedSegment = 'video'.obs;

  /// 数据
  final RxList<Video> searchVideoResult = <Video>[].obs;
  final RxList<ImageModel> searchImageResult = <ImageModel>[].obs;
  final RxList<User> searchUserResult = <User>[].obs;
  final Rxn<Widget> errorWidget = Rxn<Widget>();

  final RxBool isLoading = false.obs;

  bool get isCurrentResultEmpty {
    String segment = selectedSegment.value;
    if (segment == 'video') {
      return searchVideoResult.isEmpty;
    } else if (segment == 'image') {
      return searchImageResult.isEmpty;
    } else if (segment == 'user') {
      return searchUserResult.isEmpty;
    }
    return true;
  }

  bool get isCurrentResultInitialized {
    String segment = selectedSegment.value;
    if (segment == 'video') {
      return videoPageInitialized;
    } else if (segment == 'image') {
      return imagePageInitialized;
    } else if (segment == 'user') {
      return userPageInitialized;
    }
    return false;
  }

  bool inSearchResultPage = false;
  int limit = 32;

  // Separate pagination states for each segment
  final _videoPage = 0.obs;
  bool videoPageInitialized = false;
  final _imagePage = 0.obs;
  bool imagePageInitialized = false;
  final _userPage = 0.obs;
  bool userPageInitialized = false;

  final _videoHasMore = true.obs;
  final _imageHasMore = true.obs;
  final _userHasMore = true.obs;

  // Helper getters for current segment's state
  int get currentPage {
    switch (selectedSegment.value) {
      case 'video':
        return _videoPage.value;
      case 'image':
        return _imagePage.value;
      case 'user':
        return _userPage.value;
      default:
        return 0;
    }
  }

  bool get hasMore {
    switch (selectedSegment.value) {
      case 'video':
        print('video has more: ${_videoHasMore.value}');
        return _videoHasMore.value;
      case 'image':
        print('image has more: ${_imageHasMore.value}');
        return _imageHasMore.value;
      case 'user':
        print('user has more: ${_userHasMore.value}');
        return _userHasMore.value;
      default:
        return false;
    }
  }

  void _updatePage(int newPage) {
    switch (selectedSegment.value) {
      case 'video':
        _videoPage.value = newPage;
        break;
      case 'image':
        _imagePage.value = newPage;
        break;
      case 'user':
        _userPage.value = newPage;
        break;
    }
  }

  void _updateHasMore(bool value) {
    switch (selectedSegment.value) {
      case 'video':
        _videoHasMore.value = value;
        break;
      case 'image':
        _imageHasMore.value = value;
        break;
      case 'user':
        _userHasMore.value = value;
        break;
    }
  }

  bool get isResultEmpty =>
      searchVideoResult.isEmpty && 
      searchImageResult.isEmpty && 
      searchUserResult.isEmpty;

  void clearOtherSearchResult() {
    String segment = selectedSegment.value;
    LogUtils.d('清除其他搜索结果: $segment', 'GlobalSearchService');
    if (segment == 'video') {
      searchImageResult.clear();
      searchUserResult.clear();
    } else if (segment == 'image') {
      searchVideoResult.clear();
      searchUserResult.clear();
    } else if (segment == 'user') {
      searchVideoResult.clear();
      searchImageResult.clear();
    }
  }

  void fetchSearchResult({bool refresh = false}) async {
    String keyword = currentSearch.value;
    String segment = selectedSegment.value;
    LogUtils.d(
        '搜索关键词: $keyword, 片段: $segment, 刷新: $refresh', 'GlobalSearchService');
    final tmpPage = refresh ? 0 : currentPage;
    if (!hasMore && !refresh) return;
    if (errorWidget.value != null) errorWidget.value = null;
    isLoading.value = true;

    try {
      ApiResult response;
      if (segment == 'video') {
        response = await searchService.fetchVideoByQuery(
            page: tmpPage, limit: limit, query: keyword);
      } else if (segment == 'image') {
        response = await searchService.fetchImageByQuery(
            page: tmpPage, limit: limit, query: keyword);
      } else if (segment == 'user') {
        response = await searchService.fetchUserByQuery(
            page: tmpPage, limit: limit, query: keyword);
      } else {
        response = ApiResult.fail('尚不支持的搜索类型: $segment');
      }

      if (!response.isSuccess) {
        errorWidget.value = CommonErrorWidget(
          text: response.message,
          children: [
            ElevatedButton(
              child: Text('重试'),
              onPressed: () {
                fetchSearchResult(refresh: refresh);
              },
            ),
          ],
        );
        return;
      }

      final results = response.data!.results;
      if (refresh) {
        if (segment == 'video') {
          searchVideoResult.clear();
        } else if (segment == 'image') {
          searchImageResult.clear();
        } else if (segment == 'user') {
          searchUserResult.clear();
        }
      }

      if (segment == 'video') {
        searchVideoResult.addAll(results as List<Video>);
        _videoHasMore.value = response.data!.count > searchVideoResult.length;
      } else if (segment == 'image') {
        searchImageResult.addAll(results as List<ImageModel>);
        _imageHasMore.value = response.data!.count > searchImageResult.length;
      } else if (segment == 'user') {
        searchUserResult.addAll(results as List<User>);
        _userHasMore.value = response.data!.count > searchUserResult.length;
      }

      _updatePage(tmpPage + 1);
    } finally {
      isLoading.value = false;
      if (segment == 'video') {
        videoPageInitialized = true;
      } else if (segment == 'image') {
        imagePageInitialized = true;
      } else if (segment == 'user') {
        userPageInitialized = true;
      }
    }
  }

  void setSearchError(String? error) {
    searchErrorText.value = error ?? '';
  }

  void clearSearchError() {
    searchErrorText.value = '';
  }

  void updateSearchPlaceholder(List<SearchRecord> history) {
    if (history.isEmpty) {
      searchPlaceholder.value = '';
      return;
    }

    // 计算最大使用次数，用于归一化
    final maxUsedTimes = history.map((e) => e.usedTimes).reduce(max);

    // 为每条记录计算权重分数
    final now = DateTime.now();
    List<(SearchRecord, double)> weightedRecords = history.map((record) {
      // 使用频率得分 (0-40分)
      double freqScore = (record.usedTimes / maxUsedTimes) * 40;

      // 时间衰减得分 (0-40分)
      double daysAgo = now.difference(record.lastUsedAt).inDays.toDouble();
      double timeScore = (1 - (daysAgo / 30)).clamp(0.0, 1.0) * 40;

      // 随机因素 (0-20分)
      double randomScore = Random().nextDouble() * 20;

      return (record, freqScore + timeScore + randomScore);
    }).toList();

    // 按总分排序
    weightedRecords.sort((a, b) => b.$2.compareTo(a.$2));

    // 从前3条中随机选择一条
    final topCount = min(3, weightedRecords.length);
    final selectedIndex = Random().nextInt(topCount);

    searchPlaceholder.value = weightedRecords[selectedIndex].$1.keyword;
  }

  void resetAll() {
    searchVideoResult.clear();
    searchImageResult.clear();
    searchUserResult.clear();
    searchErrorText.value = '';
    searchPlaceholder.value = '';
    currentSearch.value = '';
    selectedSegment.value = 'video';
    _videoPage.value = 0;
    videoPageInitialized = false;
    _imagePage.value = 0;
    imagePageInitialized = false;
    _userPage.value = 0;
    userPageInitialized = false;
    _videoHasMore.value = true;
    _imageHasMore.value = true;
    _userHasMore.value = true;
    isLoading.value = false;
    errorWidget.value = null;
  }
}
