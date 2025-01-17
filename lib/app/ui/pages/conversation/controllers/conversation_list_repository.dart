import 'package:get/get.dart';
import 'package:i_iwara/app/models/message_and_conversation.model.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';

class ConversationListRepository extends LoadingMoreBase<ConversationModel> {
  final ConversationService _conversationService = Get.find<ConversationService>();
  final UserService _userService = Get.find<UserService>();
  
  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;
  @override
  bool get hasMore => _hasMore || forceRefresh;
  final int maxLength;

  ConversationListRepository({this.maxLength = 300});

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 0;
    forceRefresh = !notifyStateChanged;
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      final userId = _userService.currentUser.value?.id;
      if (userId == null) {
        throw Exception(t.errors.pleaseLoginFirst);
      }

      final result = await _conversationService.getConversations(
        userId,
        page: _pageIndex,
        limit: 20,
      );

      if (!result.isSuccess) {
        throw Exception(result.message);
      }

      if (_pageIndex == 0) {
        clear();
      }

      final pageData = result.data!;
      for (final conversation in pageData.results) {
        add(conversation);
      }

      _hasMore = pageData.results.length >= 20;
      _pageIndex++;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      LogUtils.e('加载会话列表失败',
          error: exception, stack: stack, tag: 'ConversationListRepository');
    }
    return isSuccess;
  }
} 