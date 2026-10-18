import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_request_access.model.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/iwara_poll.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/auth_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

enum PollLoadStatus { loading, ready, notFound, error }

/// 一个投票在应用里的唯一一份状态。
///
/// 同一个投票可能同时出现在帖子正文和它下面的评论里，所以状态按 id 存在
/// [PollService] 里共享，卡片只订阅、不各自持有一份。这样投完一处，所有卡片
/// 一起变成结果视图。
class PollState {
  final PollLoadStatus status;
  final IwaraPoll? poll;

  /// [status] 为 error 时是整张卡的报错；为 ready 时是「后台重拉失败」，
  /// 卡片照旧显示 [poll]，另给一个重试入口。
  final String? errorMessage;

  /// 这份 [poll] 是不是带着登录态拉的。
  ///
  /// 只有带登录态拉回来的 `vote` 才可信：匿名读取时 `vote` 恒为 null，拿它
  /// 判断「还没投」会把已投过的人重新放进投票界面（后果见 [PollService.vote]）。
  final bool fetchedWithAuth;

  /// 正在提交的选项 id；null = 没有提交在进行。
  final int? votingOptionId;

  /// 本账号这次登录里已经交过票（成功，或结果不明）。
  ///
  /// 不能只靠服务端的 `vote` 判断「投过没有」：投票成功后的重拉可能失败或读到
  /// 旧数据（`vote` 仍是 null），那样表单会回来、第二次点击就成了改投。
  final bool voteLocked;

  /// 标题与选项的译文；null = 没译过。跟投票走、不跟卡片走：同一个投票出现在
  /// 几处（正文、正文译文、独立页），一处点了翻译，几处一起显示。
  final PollTranslation? translation;

  /// 当前是否显示译文（有 [translation] 才有意义）。
  final bool showTranslation;

  /// 正在翻译。
  final bool translating;

  const PollState({
    required this.status,
    this.poll,
    this.errorMessage,
    this.fetchedWithAuth = false,
    this.votingOptionId,
    this.voteLocked = false,
    this.translation,
    this.showTranslation = false,
    this.translating = false,
  });

  const PollState.loading() : this(status: PollLoadStatus.loading);

  /// 当前账号能不能对它投票：带登录态拉到的、服务端说还没投过、本地也没交过票。
  bool get canVote =>
      status == PollLoadStatus.ready &&
      poll != null &&
      fetchedWithAuth &&
      poll!.vote == null &&
      !voteLocked;

  PollState copyWith({
    PollLoadStatus? status,
    IwaraPoll? poll,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? fetchedWithAuth,
    int? votingOptionId,
    bool clearVotingOptionId = false,
    bool? voteLocked,
    PollTranslation? translation,
    bool? showTranslation,
    bool? translating,
  }) {
    return PollState(
      status: status ?? this.status,
      poll: poll ?? this.poll,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      fetchedWithAuth: fetchedWithAuth ?? this.fetchedWithAuth,
      votingOptionId: clearVotingOptionId
          ? null
          : (votingOptionId ?? this.votingOptionId),
      voteLocked: voteLocked ?? this.voteLocked,
      translation: translation ?? this.translation,
      showTranslation: showTranslation ?? this.showTranslation,
      translating: translating ?? this.translating,
    );
  }
}

/// 一次翻译的结果，记下目标语言：换了语言要重译，不能拿旧语言的译文顶。
class PollTranslation {
  final String language;
  final String title;

  /// 选项 id → 译文。
  final Map<int, String> options;

  const PollTranslation({
    required this.language,
    required this.title,
    required this.options,
  });
}

class PollService extends GetxService {
  static const String _tag = 'PollService';

  final ApiService _apiService = Get.find();
  final AuthService _authService = Get.find();

  final Map<String, Rx<PollState>> _states = {};
  final Map<String, Future<void>> _inflight = {};
  // 每个投票最近一次翻译请求的代号，旧请求的结果回来时据此丢弃。
  final Map<String, int> _translateSeq = {};
  StreamSubscription<bool>? _authSubscription;

  /// 登录状态每变一次加一。发请求时记下当时的值，结果回来对不上就丢掉：
  /// 否则旧账号的 `vote` 会被当成新账号的写进去。
  int _authGeneration = 0;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _authService.authStateStream.listen((_) {
      _authGeneration++;
      // 换了账号（或登出），`vote` 与本地的交票锁都不再属于当前账号：先把卡片
      // 退回结果视图（不可投），再全部重拉。
      for (final entry in _states.entries.toList()) {
        entry.value.value = entry.value.value.copyWith(
          fetchedWithAuth: false,
          voteLocked: false,
          clearVotingOptionId: true,
        );
        unawaited(_reload(entry.key));
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  /// 订阅某个投票的状态。第一次订阅时开始加载；加载失败过的再次订阅会重试。
  Rx<PollState> watch(String id) {
    final existing = _states[id];
    if (existing != null) {
      if (existing.value.status == PollLoadStatus.error) {
        unawaited(load(id));
      }
      return existing;
    }
    final created = Rx<PollState>(const PollState.loading());
    _states[id] = created;
    unawaited(load(id));
    return created;
  }

  /// 拉一次投票。同一个 id 同时只发一个请求，后来的调用共用前一个。
  Future<void> load(String id) {
    final inflight = _inflight[id];
    if (inflight != null) return inflight;
    // ⛔ 必须写成代码块：箭头写法会把 remove 返回的这个 Future 自己交还给
    // whenComplete，它就永远在等自己完成。
    final future = _fetch(id).whenComplete(() {
      _inflight.remove(id);
    });
    _inflight[id] = future;
    return future;
  }

  /// 等正在飞的那次结束后**再拉一次**。投票、切换账号之后用它：正在飞的那次
  /// 可能是在变化之前发出的，拿它的结果会读到旧的 `vote`。
  Future<void> _reload(String id) async {
    final inflight = _inflight[id];
    if (inflight != null) await inflight;
    await load(id);
  }

  Future<void> _fetch(String id) async {
    final state = _states.putIfAbsent(
      id,
      () => Rx<PollState>(const PollState.loading()),
    );
    if (state.value.poll == null) {
      state.value = state.value.copyWith(
        status: PollLoadStatus.loading,
        clearErrorMessage: true,
      );
    }

    // 已登录就强制带登录态（authRequired），不用 optionalAuthShortWait：
    // 后者在 token 刷新慢时会静默改成匿名请求，拿回来的 `vote` 是 null，
    // 卡片就会把已经投过的人当成没投。宁可报错让用户重试。
    final generation = _authGeneration;
    final withAuth = _authService.isAuthenticated;
    try {
      final response = await _apiService.get(
        ApiConstants.poll(id),
        requestAccess: withAuth
            ? ApiRequestAccess.authRequired
            : ApiRequestAccess.publicOnly,
      );
      if (generation != _authGeneration) return;
      final poll = IwaraPoll.fromJson(response.data as Map<String, dynamic>);
      final current = state.value;
      state.value = current.copyWith(
        status: PollLoadStatus.ready,
        // 交过票但服务端还读不到 `vote`（重拉读到旧数据）：保留本地记下的那一项。
        poll:
            poll.vote == null &&
                current.voteLocked &&
                current.poll?.vote != null
            ? poll.withVote(current.poll!.vote!)
            : poll,
        fetchedWithAuth: withAuth,
        clearErrorMessage: true,
      );
    } catch (e) {
      if (generation != _authGeneration) return;
      if (e is DioException && e.response?.statusCode == 404) {
        state.value = const PollState(status: PollLoadStatus.notFound);
        return;
      }
      LogUtils.e('获取投票失败: $id', tag: _tag, error: e);
      final message = CommonUtils.parseExceptionMessage(e);
      // 已经有内容的保留旧内容，不翻成错误页，只挂一条可重试的报错。
      state.value = state.value.poll != null
          ? state.value.copyWith(errorMessage: message)
          : state.value.copyWith(
              status: PollLoadStatus.error,
              errorMessage: message,
            );
    }
  }

  /// 投票。成功后重新拉取，以服务端为准，不在本地猜票数。
  ///
  /// ⛔ 已经投过的投票**绝不再发请求**：服务端接受改投、会改掉「你投了哪项」，
  /// 但各选项票数不跟着变（2026-10-18 实测），结果就是打勾在 B、票算在 A。
  /// 网页端没有改票入口所以碰不到；这里在入口处硬拦，UI 也不提供改票。
  /// 「投过」除了看服务端的 `vote`，还看本地的 [PollState.voteLocked]。
  Future<ApiResult<void>> vote(String pollId, int optionId) async {
    final t = slang.t;
    final state = _states[pollId];
    final current = state?.value;
    if (state == null || current == null || current.poll == null) {
      return ApiResult.fail(t.poll.voteFailed);
    }
    if (!_authService.isAuthenticated) {
      return ApiResult.fail(t.errors.pleaseLoginFirst);
    }
    if (current.votingOptionId != null) {
      return ApiResult.fail(t.poll.voteFailed);
    }
    if (!current.canVote) {
      LogUtils.w('拦下对已投投票的重复投票: $pollId', _tag);
      return ApiResult.fail(t.poll.alreadyVoted);
    }
    if (!current.poll!.options.any((o) => o.id == optionId)) {
      return ApiResult.fail(t.poll.voteFailed);
    }

    final generation = _authGeneration;
    state.value = current.copyWith(votingOptionId: optionId);
    try {
      await _apiService.post(ApiConstants.pollVote(pollId, optionId));
      if (generation == _authGeneration) {
        // 先在本地记下，重拉失败或读到旧数据也不会让表单回来。
        final latest = state.value;
        state.value = latest.copyWith(
          voteLocked: true,
          poll: latest.poll?.withVote(optionId),
        );
      }
      await _reload(pollId);
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('投票失败: $pollId/$optionId', tag: _tag, error: e);
      final status = e is DioException ? e.response?.statusCode : null;
      final definitelyRejected =
          status != null && status >= 400 && status < 500;
      if (!definitelyRejected && generation == _authGeneration) {
        // 超时、断线、5xx：票可能已经落库。先锁住，等带登录态的重拉说了算——
        // 重拉回来 `vote` 仍是 null 才说明真没投上（见下面的解锁）。
        state.value = state.value.copyWith(voteLocked: true);
        unawaited(_settleUncertainVote(pollId, generation));
      }
      return ApiResult.fail(CommonUtils.parseExceptionMessage(e), exception: e);
    } finally {
      state.value = state.value.copyWith(clearVotingOptionId: true);
    }
  }

  /// 结果不明的那次投票：重拉成功且服务端确认没投上，才解开交票锁。
  Future<void> _settleUncertainVote(String pollId, int generation) async {
    await _reload(pollId);
    final state = _states[pollId];
    if (state == null || generation != _authGeneration) return;
    final s = state.value;
    if (s.errorMessage == null && s.fetchedWithAuth && s.poll?.vote == null) {
      state.value = s.copyWith(voteLocked: false);
    }
  }

  // 翻译 ---------------------------

  /// 卡片上那枚翻译钮：正在显示译文就收起；已有当前语言的译文就直接显示；
  /// 否则去翻译。
  Future<ApiResult<void>> toggleTranslation(String pollId) async {
    final state = _states[pollId];
    final s = state?.value;
    if (state == null || s == null || s.poll == null) {
      return ApiResult.fail(slang.t.poll.translateFailed);
    }
    if (s.translating) return ApiResult.success();
    if (s.showTranslation) {
      state.value = s.copyWith(showTranslation: false);
      return ApiResult.success();
    }
    if (s.translation?.language == _targetLanguage) {
      state.value = s.copyWith(showTranslation: true);
      return ApiResult.success();
    }
    return translate(pollId);
  }

  /// 按当前目标语言翻译标题和全部选项，完成后显示译文。换了目标语言时也调它。
  ///
  /// 翻译中又换了语言：不等上一次，直接按新语言再发一次，上一次的结果回来后
  /// 按代号丢弃（不然最后显示的是旧语言，选择器上却是新语言）。
  Future<ApiResult<void>> translate(String pollId) async {
    final state = _states[pollId];
    final s = state?.value;
    final poll = s?.poll;
    if (state == null || s == null || poll == null) {
      return ApiResult.fail(slang.t.poll.translateFailed);
    }

    final language = _targetLanguage;
    if (!s.translating && s.translation?.language == language) {
      state.value = s.copyWith(showTranslation: true);
      return ApiResult.success();
    }

    final seq = (_translateSeq[pollId] ?? 0) + 1;
    _translateSeq[pollId] = seq;
    state.value = s.copyWith(translating: true);
    ApiResult<List<String>> result;
    try {
      result = await _translateTexts([
        poll.title,
        for (final option in poll.options) option.title,
      ], language);
    } catch (e) {
      LogUtils.e('投票翻译失败', tag: _tag, error: e);
      result = ApiResult.fail(slang.t.poll.translateFailed);
    }
    // 被更新的一次请求取代：转圈与结果都归那一次管。
    if (_translateSeq[pollId] != seq) return ApiResult.success();

    final texts = result.data;
    if (!result.isSuccess || texts == null) {
      state.value = state.value.copyWith(translating: false);
      return ApiResult.fail(
        result.message.isNotEmpty
            ? result.message
            : slang.t.poll.translateFailed,
      );
    }
    state.value = state.value.copyWith(
      translating: false,
      showTranslation: true,
      translation: PollTranslation(
        language: language,
        title: texts.first,
        options: {
          for (var i = 0; i < poll.options.length; i++)
            poll.options[i].id: texts[i + 1],
        },
      ),
    );
    return ApiResult.success();
  }

  String get _targetLanguage =>
      Get.find<ConfigService>().currentTranslationLanguage;

  /// 把几段短文本译完，结果与输入一一对应。
  ///
  /// 先一次请求译完（每段占一行），省得一个 11 项的投票连发 12 个请求；译文的
  /// 行数对不上（翻译服务合并或拆分了行）再逐段各译一次（每批 3 个）。
  ///
  /// 目标语言显式传下去：翻译服务不传就在发请求那一刻读配置，降级和重试都
  /// 发生在 await 之后，那时用户可能已经换了语言。
  Future<ApiResult<List<String>>> _translateTexts(
    List<String> texts,
    String language,
  ) async {
    final service = Get.find<TranslationService>();
    // 标题、选项在网页端都是单行输入，这里再把换行压平，保证「一段一行」。
    final cleaned = [
      for (final text in texts)
        text.replaceAll(RegExp(r'\s*\n\s*'), ' ').trim(),
    ];
    // 空段不进请求（否则合并请求必定少一行），结果按下标放回。
    final indexes = [
      for (var i = 0; i < cleaned.length; i++)
        if (cleaned[i].isNotEmpty) i,
    ];
    final output = List<String>.filled(cleaned.length, '');
    if (indexes.isEmpty) return ApiResult.success(data: output);

    final joined = await service.translate(
      indexes.map((i) => cleaned[i]).join('\n'),
      targetLanguage: language,
    );
    if (!joined.isSuccess || joined.data == null) {
      // 整个翻译服务不可用时，逐段再试只会连失败 N 次。
      return ApiResult.fail(joined.message);
    }
    final lines = joined.data!
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.length == indexes.length) {
      for (var k = 0; k < indexes.length; k++) {
        output[indexes[k]] = lines[k];
      }
      return ApiResult.success(data: output);
    }

    LogUtils.w('投票译文行数对不上（${lines.length}/${indexes.length}），改为逐段翻译', _tag);
    const batchSize = 3;
    for (var start = 0; start < indexes.length; start += batchSize) {
      final batch = indexes.skip(start).take(batchSize).toList();
      final results = await Future.wait([
        for (final i in batch)
          service.translate(cleaned[i], targetLanguage: language),
      ]);
      for (var k = 0; k < batch.length; k++) {
        final result = results[k];
        if (!result.isSuccess) return ApiResult.fail(result.message);
        output[batch[k]] = result.data?.trim() ?? '';
      }
    }
    return ApiResult.success(data: output);
  }
}
