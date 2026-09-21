import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/search_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/common/constants.dart' show CommonConstants;
import 'package:i_iwara/utils/logger_utils.dart';

import '../iwara_search_syntax.dart';

/// 归并时每一路的游标：自己的查询串、自己的页码、自己还没吐完的缓冲。
class _MergeCursor<T> {
  _MergeCursor(this.query);

  final String query;
  final List<T> buffer = [];
  int page = 0;
  bool exhausted = false;
  int count = 0;

  void reset() {
    buffer.clear();
    page = 0;
    exhausted = false;
    count = 0;
  }
}

/// 搜索仓库基类，处理搜索查询和分页
///
/// # 跨语言归并
///
/// ⭐ iwara 的自由文本查询**只搜一种语言的那一对字段**，选哪种由引擎自己判、
/// 用户无从干预，于是中文标题的内容大面积搜不到（`碧蓝航线` 自由文本 100 条，
/// `{title_zh:"碧蓝航线"}` 有 403 条）。引擎又没有跨字段 OR，并集只能发多次
/// 请求在客户端归并——理由与实测数据写在 [crossLanguageVariants] 上。
///
/// 这里的做法是**在关键词那一层分叉**：几路共用同一个 [fetchSearchResults]，
/// 只是喂进去的 query 串不同。所以八个搜索仓库一次性全部受益，谁都不用改签名；
/// 子类只要交出 [itemId] 与 [itemSortKey]，再把
/// [supportsCrossLanguageMerge] 打开即可。
abstract class SearchRepository<T> extends ExtendedLoadingMoreBase<T> {
  final SearchService searchService = Get.find<SearchService>();
  final String query;
  final String segment;

  SearchRepository({required this.query, required this.segment});

  /// 每路一次拉多少。⛔ 50 是**引擎的硬上限**：传 200/1000 回来的
  /// `limit` 照样是 50。拉满能让补一次缓冲多服务几屏，摊薄归并的请求数。
  static const int _mergePageSize = 50;

  /// 本仓库能不能参与跨语言归并。
  ///
  /// ⛔ 要求两件事：给得出稳定 [itemId]，以及**当前这次排序**的键是可比的。
  /// 相关度排序下引擎不返回分数，几路之间没有共同的尺子，子类必须在那种排序下
  /// 返回 false，否则归并会按一个不存在的顺序乱插。
  bool get supportsCrossLanguageMerge => false;

  /// 去重用的稳定 id。归并时同一条内容会从多路同时冒出来。
  String? itemId(T item) => null;

  /// 按**当前排序**取出的排序键，越大越靠前；日期取毫秒。null ＝这条排最后。
  ///
  /// ⛔ 归并的正确性全押在「每一路都按同一个键、同一个方向有序」上。
  num? itemSortKey(T item) => null;

  late final List<_MergeCursor<T>> _cursors = [
    _MergeCursor<T>(query),
    for (final q in crossLanguageVariants(
      query,
      crossLanguageFieldFor(segment),
    ))
      _MergeCursor<T>(q),
  ];

  /// 归并已经吐出过几页。用来认出「这次要的是下一页」——见
  /// [fetchDataFromSource] 里那道顺序闸门。
  int _emittedPages = 0;
  final Set<String> _seenIds = <String>{};

  /// 出现过跳页就永久停用归并（理由见 [fetchDataFromSource]）。
  bool _mergeAbandoned = false;

  /// ⛔ **分页模式下不归并**：归并游标只能顺序推进，跳到第 30 页就得把前 29 页
  /// 全部拉完。那种模式下页码必须是准的，宁可维持单路。
  late final bool _mergeEnabled =
      _cursors.length > 1 &&
      supportsCrossLanguageMerge &&
      !CommonConstants.isPaginated;

  @override
  Map<String, dynamic> buildQueryParams(int page, int limit) {
    return {'query': query};
  }

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    if (_mergeEnabled && !_mergeAbandoned) {
      if (page == 0) {
        _resetCursors();
        // 每次搜索一条：出了问题时，「到底往哪几路发了」是第一个要问的。
        LogUtils.d(
          '跨语言归并($segment)：${_cursors.map((c) => c.query).join(' ⊕ ')}',
          'SearchRepository',
        );
      }
      // 只服务顺序推进的请求。
      if (page == _emittedPages) return _fetchMerged(limit);
      // ⛔ 有人跳页了（分页组件直接调 loadPageData）。归并游标跟不上跳页，而
      // 两种结果混在一张列表里会出现重复与缺漏——从此彻底退回单路，别再摇摆。
      // 注意闸门不能只看 CommonConstants.isPaginated：那只是全局默认，单个页面
      // 仍可能自己是分页的。
      _mergeAbandoned = true;
      LogUtils.d('搜索发生跳页，本数据源停用跨语言归并', 'SearchRepository');
    }
    return _fetchSingle(params, page, limit);
  }

  void _resetCursors() {
    for (final c in _cursors) {
      c.reset();
    }
    _seenIds.clear();
    _emittedPages = 0;
  }

  Future<Map<String, dynamic>> _fetchSingle(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    try {
      ApiResult response = await fetchSearchResults(
        page,
        limit,
        params['query'],
      );

      if (response.isSuccess && response.data != null) {
        return {'success': true, 'data': response.data};
      } else {
        // 存储错误消息到当前实例
        lastErrorMessage = response.message;
        throw Exception(response.message);
      }
    } catch (e) {
      // 存储错误消息到当前实例
      lastErrorMessage = e.toString();
      rethrow; // 重新抛出异常以便被ExtendedLoadingMoreBase捕获
    }
  }

  /// 归并一页：缺料的几路并发补，然后反复取排序键最大的那一条。
  Future<Map<String, dynamic>> _fetchMerged(int limit) async {
    final items = <T>[];
    String? primaryError;

    // ⛔ 请求失败**只影响这一页**，不判这条路死刑。
    //
    // 早先失败是直接置 `exhausted`（那是「这一路真的没有更多了」的意思），而
    // 游标只在第 0 页重置——于是滚到第四页时的一次超时，会让那一路在**这次
    // 搜索剩下的全部翻页里**都不再出现。主路中招时更隐蔽：只要补路还有缓冲，
    // 下面那道 `items.isEmpty` 闸门就不成立，错误既不冒泡也不重试，用户安静地
    // 只拿到了 title_zh / title_ja 那一小撮（2026-09-21 审查查出）。
    //
    // 现在失败的那一路只是本页不出料（它的 page 没有前进，缓冲也没动），下一页
    // 照样会再叫它一次。
    //
    // ⚠️ 代价是顺序会有个小瑕疵：补上来的那批东西本该排在前面，却因为迟到一页
    // 而插在后面。这比整条路静默消失好得多，而且只在真出错时才发生。
    final failedThisPage = <_MergeCursor<T>>{};

    while (items.length < limit) {
      final hungry = _cursors
          .where(
            (c) =>
                c.buffer.isEmpty && !c.exhausted && !failedThisPage.contains(c),
          )
          .toList();
      if (hungry.isNotEmpty) {
        final errors = await Future.wait(hungry.map(_refill));
        for (var i = 0; i < hungry.length; i++) {
          if (errors[i] == null) continue;
          // ⛔ 必须记一笔：不记的话这个 while 会对着同一条坏路无限重试。
          failedThisPage.add(hungry[i]);
          if (identical(hungry[i], _cursors.first)) {
            // 主路失败要能冒泡成错误页；补路失败只是少几条，不该毁掉整次搜索。
            primaryError ??= errors[i];
            LogUtils.w(
              '跨语言主路本页失败，下一页会重试：${hungry[i].query} → ${errors[i]}',
              'SearchRepository',
            );
          } else {
            LogUtils.w(
              '跨语言补路本页失败，下一页会重试：${hungry[i].query} → ${errors[i]}',
              'SearchRepository',
            );
          }
        }
      }

      _MergeCursor<T>? best;
      for (final c in _cursors) {
        if (c.buffer.isEmpty) continue;
        if (best == null || _isAhead(c.buffer.first, best.buffer.first)) {
          best = c;
        }
      }
      if (best == null) break;

      final item = best.buffer.removeAt(0);
      final id = itemId(item);
      if (id != null && !_seenIds.add(id)) continue;
      items.add(item);
    }

    if (items.isEmpty && primaryError != null) {
      lastErrorMessage = primaryError;
      throw Exception(primaryError);
    }

    _emittedPages++;
    return {
      'success': true,
      'merged': true,
      'items': items,
      // ⛔ 并集的真实大小算不出来（各路重叠多少服务端不告诉我们）。取最大的那一路
      // 当下界，好过把几路相加报出一个虚高的数。
      'count': _cursors.fold<int>(0, (m, c) => c.count > m ? c.count : m),
    };
  }

  bool _isAhead(T a, T b) {
    final ka = itemSortKey(a);
    final kb = itemSortKey(b);
    if (ka == null) return false;
    if (kb == null) return true;
    return ka > kb;
  }

  /// 给一路补一页。返回 null ＝成功，否则是失败原因。
  ///
  /// ⛔ [_MergeCursor.exhausted] 的含义是「这一路**真的**没有更多了」，所以只在
  /// 服务端回了空表时才置。请求失败一律不置——那是「这一次没拿到」，不是「以后
  /// 都没有」，判错了就等于让一次网络抖动把整条路永久删掉（见 [_fetchMerged]
  /// 里那段 `failedThisPage`）。失败时 [_MergeCursor.page] 也不前进，下次重试
  /// 拿的还是同一页，不会漏。
  Future<String?> _refill(_MergeCursor<T> cursor) async {
    try {
      final res = await fetchSearchResults(
        cursor.page,
        _mergePageSize,
        cursor.query,
      );
      if (!res.isSuccess || res.data == null) {
        return res.message;
      }
      cursor.count = (res.data.count as int?) ?? cursor.count;
      cursor.page++;
      final list = (res.data.results as List).cast<T>();
      if (list.isEmpty) {
        cursor.exhausted = true;
      } else {
        cursor.buffer.addAll(list);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// 根据搜索类型获取搜索结果
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword);

  @override
  List<T> extractDataList(Map<String, dynamic> response) {
    if (response['merged'] == true) return response['items'] as List<T>;
    // 由于我们在 fetchDataFromSource 中已经处理了错误情况
    // 这里只会收到成功的响应
    return response['data'].results as List<T>;
  }

  @override
  int extractTotalCount(Map<String, dynamic> response) {
    if (response['merged'] == true) return response['count'] as int;
    return response['data'].count as int;
  }

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(
      'SearchRepository($segment): $message',
      error: error,
      stack: stackTrace,
      tag: 'SearchRepository',
    );
  }
}
