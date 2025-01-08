import 'dart:convert';

import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_dto.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/repositories/commons_repository.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/models/search_record.model.dart';

class UserPreferenceService extends GetxService {
  final String _TAG = 'UserPreferenceService';

  // 视频搜索历史
  final RxList<SearchRecord> videoSearchHistory = <SearchRecord>[].obs;

  // 视频搜索标签
  final RxList<Tag> videoSearchTagHistory = <Tag>[].obs;

  // 喜欢的作者
  final RxSet<UserDTO> likedUsers = <UserDTO>{}.obs;

  final int maxSearchRecordCount = 50;

  final String _videoSearchHistoryKey = 'videoSearchHistory';
  final String _videoSearchTagHistoryKey = 'videoSearchTagHistory';
  final String _likedUsers = 'likedUsers';

  final RxBool searchRecordEnabled = true.obs;
  final String _searchRecordEnabledKey = 'searchRecordEnabled';

  Future<UserPreferenceService> init() async {
    await _loadUserPreferences();
    LogUtils.i('用户偏好服务初始化完成', _TAG);
    return this;
  }

  bool isUserSearchTagObject(Tag? tag) {
    if (tag == null) {
      return false;
    }
    String id = tag.id;
    return isUserSearchTagId(id);
  }

  bool isUserSearchTagId(String? tagId) {
    if (tagId == null) {
      return false;
    }
    return videoSearchTagHistory.any((element) => element.id == tagId);
  }

  Future<void> _loadUserPreferences() async {
    await _loadSearchRecordEnabled();
    await _loadUserLikeUsernames();
    await _loadVideoSearchHistory();
    await _loadVideoSearchTagHistory();
  }

  // 加载搜索记录开关状态
  Future<void> _loadSearchRecordEnabled() async {
    try {
      final String? data = 
          await CommonsRepository.instance.getData(_searchRecordEnabledKey);
      if (data != null) {
        searchRecordEnabled.value = data == 'true';
      }
    } catch (e) {
      LogUtils.e('加载搜索记录开关状态失败', tag: _TAG, error: e);
    }
  }

  // 设置搜索记录开关
  Future<void> setSearchRecordEnabled(bool enabled) async {
    searchRecordEnabled.value = enabled;
    try {
      await CommonsRepository.instance.setData(
        _searchRecordEnabledKey,
        enabled.toString(),
      );
    } catch (e) {
      LogUtils.e('保存搜索记录开关状态失败', tag: _TAG, error: e);
    }
  }

  // 加载喜欢的用户
  Future<void> _loadUserLikeUsernames() async {
    try {
      final String? data =
          await CommonsRepository.instance.getData(_likedUsers);
      if (data != null && data.isNotEmpty) {
        List<dynamic> list = jsonDecode(data);
        likedUsers.addAll(
            list.map((e) => UserDTO.fromJson(e as Map<String, dynamic>)));
      }
    } catch (e) {
      LogUtils.e('加载喜欢的用户失败', tag: _TAG, error: e);
      await CommonsRepository.instance.deleteData(_likedUsers);
    }
  }

  // 加载视频搜索历史
  Future<void> _loadVideoSearchHistory() async {
    try {
      final String? data =
          await CommonsRepository.instance.getData(_videoSearchHistoryKey);
      if (data != null && data.isNotEmpty) {
        List<dynamic> list = jsonDecode(data);
        videoSearchHistory.addAll(
            list.map((e) => SearchRecord.fromJson(e as Map<String, dynamic>)));
      }
    } catch (e) {
      LogUtils.e('加载视频搜索历史失败', tag: _TAG, error: e);
      await CommonsRepository.instance.deleteData(_videoSearchHistoryKey);
    }
  }

  // 加载视频搜索标签
  Future<void> _loadVideoSearchTagHistory() async {
    try {
      final String? data =
          await CommonsRepository.instance.getData(_videoSearchTagHistoryKey);
      if (data != null && data.isNotEmpty) {
        List<dynamic> list = jsonDecode(data);
        List<Tag> tags =
            list.map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList();
        videoSearchTagHistory.addAll(tags);
      }
    } catch (e) {
      LogUtils.e('加载视频搜索标签失败', tag: _TAG, error: e);
      await CommonsRepository.instance.deleteData(_videoSearchTagHistoryKey);
    }
  }

  // 添加视频搜索历史
  Future<void> addVideoSearchHistory(String keyword) async {
    var existingRecord = videoSearchHistory
        .firstWhereOrNull((element) => element.keyword == keyword);
    
    if (existingRecord != null) {
      existingRecord.usedTimes++;
      videoSearchHistory.remove(existingRecord);
      videoSearchHistory.insert(0, existingRecord);
    } else {
      videoSearchHistory.insert(
        0,
        SearchRecord(
          keyword: keyword,
          lastUsedAt: DateTime.now(),
        ),
      );
    }

    if (videoSearchHistory.length > maxSearchRecordCount) {
      videoSearchHistory.removeLast();
    }

    try {
      await CommonsRepository.instance.setData(
        _videoSearchHistoryKey,
        jsonEncode(videoSearchHistory.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      LogUtils.e('保存视频搜索历史失败', tag: _TAG, error: e);
    }
  }

  // 删除视频搜索历史
  Future<void> removeVideoSearchHistory(String keyword) async {
    videoSearchHistory.removeWhere((element) => element.keyword == keyword);
    try {
      await CommonsRepository.instance.setData(
        _videoSearchHistoryKey,
        jsonEncode(videoSearchHistory.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      LogUtils.e('删除视频搜索历史失败', tag: _TAG, error: e);
    }
  }

  // 清空视频搜索历史
  Future<void> clearVideoSearchHistory() async {
    videoSearchHistory.clear();
    try {
      await CommonsRepository.instance.deleteData(_videoSearchHistoryKey);
    } catch (e) {
      LogUtils.e('清空视频搜索历史失败', tag: _TAG, error: e);
    }
  }

  // 添加视频搜索标签
  Future<void> addVideoSearchTag(Tag tag) async {
    String id = tag.id;
    if (videoSearchTagHistory.any((element) => element.id == id)) {
      videoSearchTagHistory.removeWhere((element) => element.id == id);
    }
    videoSearchTagHistory.insert(0, tag);
    try {
      List<Map<String, dynamic>> tagList =
          videoSearchTagHistory.map((e) => e.toJson()).toList();
      await CommonsRepository.instance.setData(
        _videoSearchTagHistoryKey,
        jsonEncode(tagList),
      );
    } catch (e) {
      LogUtils.e('保存视频搜索标签失败', tag: _TAG, error: e);
    }
  }

  // 删除视频搜索标签
  Future<void> removeVideoSearchTag(Tag tag) async {
    String id = tag.id;
    videoSearchTagHistory.removeWhere((element) => element.id == id);
    await _saveVideoSearchTagHistory();
  }

  // 通过ID删除视频搜索标签
  Future<void> removeVideoSearchTagById(String id) async {
    videoSearchTagHistory.removeWhere((element) => element.id == id);
    await _saveVideoSearchTagHistory();
  }

  // 保存视频搜索标签到数据库
  Future<void> _saveVideoSearchTagHistory() async {
    try {
      List<Map<String, dynamic>> tagList =
          videoSearchTagHistory.map((e) => e.toJson()).toList();
      await CommonsRepository.instance.setData(
        _videoSearchTagHistoryKey,
        jsonEncode(tagList),
      );
    } catch (e) {
      LogUtils.e('保存视频搜索标签失败', tag: _TAG, error: e);
    }
  }

  // 清空视频搜索标签
  Future<void> clearVideoSearchTags() async {
    videoSearchTagHistory.clear();
    try {
      await CommonsRepository.instance.deleteData(_videoSearchTagHistoryKey);
    } catch (e) {
      LogUtils.e('清空视频搜索标签失败', tag: _TAG, error: e);
    }
  }

  // 添加喜欢的用户
  Future<void> addLikedUser(UserDTO user) async {
    // 通过id搜索
    if (!likedUsers.any((element) => element.id == user.id)) {
      // 创建新的UserDTO实例，包含likedTime
      final userWithTime = UserDTO(
        id: user.id,
        name: user.name,
        username: user.username,
        avatarUrl: user.avatarUrl,
        likedTime: DateTime.now(),
      );
      likedUsers.add(userWithTime);
      try {
        await CommonsRepository.instance.setData(
          _likedUsers,
          jsonEncode(likedUsers.toList()),
        );
      } catch (e) {
        LogUtils.e('保存喜欢的用户失败', tag: _TAG, error: e);
      }
    }
  }

  // 更新喜欢的用户
  Future<void> updateLikedUser(UserDTO user) async {
    if (likedUsers.any((element) => element.id == user.id)) {
      likedUsers.removeWhere((element) => element.id == user.id);
      likedUsers.add(user);
      try {
        await CommonsRepository.instance.setData(
          _likedUsers,
          jsonEncode(likedUsers.toList()),
        );
      } catch (e) {
        LogUtils.e('更新喜欢的用户失败', tag: _TAG, error: e);
      }
    }
  }

  // 移除喜欢的用户
  Future<void> removeLikedUser(UserDTO user) async {
    if (likedUsers.any((element) => element.id == user.id)) {
      likedUsers.removeWhere((element) => element.id == user.id);
      try {
        await CommonsRepository.instance.setData(
          _likedUsers,
          jsonEncode(likedUsers.toList()),
        );
      } catch (e) {
        LogUtils.e('删除喜欢的用户失败', tag: _TAG, error: e);
      }
    }
  }

  // 清空所有喜欢的用户
  Future<void> clearLikedUser() async {
    likedUsers.clear();
    try {
      await CommonsRepository.instance.deleteData(_likedUsers);
    } catch (e) {
      LogUtils.e('清空喜欢的用户失败', tag: _TAG, error: e);
    }
  }

  // 获取喜欢的用户
  UserDTO? getLikedUser(String id) {
    try {
      return likedUsers.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

}
