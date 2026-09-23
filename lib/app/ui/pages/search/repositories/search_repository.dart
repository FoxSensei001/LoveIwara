import 'dart:async';

import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/search_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import '../iwara_search_syntax.dart';

/// 归并时每一路的游标：自己的查询串、自己的页码、自己还没吐完的缓冲。
class _MergeCursor<T> {
  _MergeCursor(this.route);

  final SearchRoute route;
  String get query => route.query;

  final List<T> buffer = [];
  int page = 0;
  bool exhausted = false;
  int count = 0;

  /// 这一路已经吐出去几条。排序键不可比时按它轮流取（名次小的先出）。
  int consumed = 0;

  /// 服务端给过多少条、核对后留下多少条。要核对的路按这个比例折算总数。
  int fetchedRaw = 0;
  int keptRaw = 0;

  /// 留下的里面，有几条是别的路还没拿到过的。它占 [keptRaw] 的比例就是这一路
  /// 剩下那些条目预计能给并集添多少（见 [SearchRepository._estimatedTotal]）。
  int novel = 0;

  /// 在途的那次补货。迟到的补路在后台接着跑，下一页直接接上它，不重复发请求。
  Future<String?>? inFlight;

  /// 每次重置自增；重置前发出去的请求回来时认出自己过期了，结果丢掉。
  int generation = 0;

  /// 估计的总数：要核对的路按「留下/拿到」折算（主路 `藿藿` 服务端报 24 条，
  /// 核对后只剩一半多）。
  int get estimatedCount {
    if (!route.needsVerify || fetchedRaw == 0) return count;
    return (count * keptRaw / fetchedRaw).round();
  }

  void reset() {
    buffer.clear();
    page = 0;
    exhausted = false;
    count = 0;
    consumed = 0;
    fetchedRaw = 0;
    keptRaw = 0;
    novel = 0;
    inFlight = null;
    generation++;
  }
}

/// 搜索仓库基类，处理搜索查询和分页
///
/// # 多路归并
///
/// ⭐ 用户说的那个东西，iwara 一条查询搜不全：自由文本只搜标题与简介、不搜标签，
/// 而且只搜引擎自己挑的那一种语言。所以一个关键词会拆成好几路（原话 / 标签 /
/// 日英中文名 / 标题补路），引擎又没有跨字段 OR，并集只能发多次请求在客户端
/// 归并——哪几路、为什么、实测数据都在 [planSearchRoutes] 上。
///
/// 这里的做法是**在关键词那一层分叉**：几路共用同一个 [fetchSearchResults]，
/// 只是喂进去的 query 串不同。所以八个搜索仓库一次性全部受益，谁都不用改签名；
/// 子类只要交出 [itemId]（以及排序键、标题、简介），再把
/// [supportsCrossLanguageMerge] 打开即可。
abstract class SearchRepository<T> extends ExtendedLoadingMoreBase<T> {
  final SearchService searchService = Get.find<SearchService>();
  final String query;
  final String segment;

  SearchRepository({required this.query, required this.segment});

  /// 每路一次拉多少。⛔ 50 是**引擎的硬上限**：传 200/1000 回来的
  /// `limit` 照样是 50。拉满能让补一次缓冲多服务几屏，摊薄归并的请求数。
  static const int _mergePageSize = 50;

  /// 本仓库能不能多路归并：要给得出稳定的 [itemId] 去重。
  bool get supportsCrossLanguageMerge => false;

  /// **当前这次排序**的键在几路之间可不可比（日期/播放/点赞可比）。
  ///
  /// ⛔ 相关度排序下引擎不返回分数，几路之间没有共同的尺子；这时不按键归并，
  /// 改成按各路自己的名次轮流取（每路第 1 名、每路第 2 名……），主路优先。
  bool get sortKeyComparable => false;

  /// 去重用的稳定 id。归并时同一条内容会从多路同时冒出来。
  String? itemId(T item) => null;

  /// 按**当前排序**取出的排序键，越大越靠前；日期取毫秒。null ＝这条排最后。
  ///
  /// ⛔ 归并的正确性全押在「每一路都按同一个键、同一个方向有序」上。
  num? itemSortKey(T item) => null;

  /// 标题与标签。要核对的补路（见 [SearchRoute.accepts]）靠它们判断结果
  /// 是不是真的是用户搜的那个东西；给不出的仓库，那一路会被整条放弃。
  String? itemTitle(T item) => null;
  Iterable<String> itemTagIds(T item) => const [];

  /// 一行能认出这条是什么的字（AI 试搜回给模型看前几条用）。
  ///
  /// ⛔ 与 [itemTitle] 分开：那个是核对用的，给出来就会参与「这条算不算」的判断，
  /// 而用户/论坛回复这些板块根本不归并、也不该被核对。
  String previewTitle(T item) => itemTitle(item) ?? '';

  /// 各路此刻的状态：哪一路、发的什么、估计多少条。第 0 页归并完才有意义。
  ///
  /// 只读，给 AI 试搜回报「这次按标签补搜了多少」——模型据此判断该不该改词，
  /// 而不是只盯着原话那一路的 0。
  List<({SearchRouteKind kind, String query, int count})> get routeStats => [
    for (final c in _cursors)
      (kind: c.route.kind, query: c.query, count: c.estimatedCount),
  ];

  /// 这次是不是真的走了多路归并（开关关着、板块不支持、只有一路时都不走）。
  bool get isMerging => _mergeEnabled && !_mergeAbandoned;

  /// 这次搜索往哪几路发。按标签补路只在能归并的仓库里、且用户没关掉时才做
  /// （[ConfigKey.SEARCH_TAG_EXPANSION]）。
  late final SearchPlan plan = planSearchRoutes(
    query,
    apiType: segment,
    resolveTag: supportsCrossLanguageMerge && _tagExpansionEnabled
        ? TagLocalizationService.matchName
        : null,
  );

  static bool get _tagExpansionEnabled =>
      !Get.isRegistered<ConfigService>() ||
      Get.find<ConfigService>()[ConfigKey.SEARCH_TAG_EXPANSION] != false;

  late final List<_MergeCursor<T>> _cursors = [
    for (final route in plan.routes) _MergeCursor<T>(route),
  ];

  /// 已经归并出来的页，按页码存着。
  ///
  /// ⭐ 分页模式靠它：游标只能顺序推进，所以跳到第 N 页时把中间的页依次归并
  /// 出来存下，往回翻直接取缓存。瀑布流只会顺序要下一页，同样适用。
  final List<List<T>> _mergedPages = [];
  final Set<String> _seenIds = <String>{};

  /// 各路**拿到过**的 id（不管吐没吐出去），只用来估并集大小。
  final Set<String> _knownIds = <String>{};

  /// 一次最多往前归并多少页。再远（典型：分页栏点「末页」）就放弃归并，改走
  /// 条数最多的那一路单路翻页。之后页码条改按那一路的 count 显示（比并集估计
  /// 略小，落点若超出它的末页会是空页，重新点一次末页即可）。
  static const int _maxPagesAhead = 30;

  /// 停用归并后改走的单路（见 [_maxPagesAhead]）；null ＝主路。
  String? _singleRouteQuery;

  /// 停用归并后就一直单路，不再摇摆（两种结果混在一张列表里会重复与缺漏）。
  bool _mergeAbandoned = false;

  /// 第 0 页引号搜出 0 条、退成裸词后，后续页都沿用它（见 [looseQueryOf]）。
  String? _looseFallbackQuery;

  /// ⚠️ 分页模式也归并（2026-09-23 起）。早先分页模式整个退回单路，而那正是
  /// 一部分用户的默认模式——按标签补路对他们等于没做。
  late final bool _mergeEnabled =
      _cursors.length > 1 && supportsCrossLanguageMerge;

  @override
  Map<String, dynamic> buildQueryParams(int page, int limit) {
    return {'query': query};
  }

  /// 归并状态（游标、页缓存）只能一个请求一个请求地动。
  ///
  /// ⛔ 瀑布流/分页切换时仓库是同一个，两条加载路径可能同时在跑：后来的第 0 页
  /// 请求会在前一个请求往前归并到一半时把游标清掉，前一个请求回来又把深处的页
  /// 写进清空后的缓存，第 0 页就成了别处的内容（2026-09-23 审查查出）。所以排队，
  /// 并用 [_mergeEpoch] 让过期的那个尽早收手。
  Future<void> _mergeQueue = Future<void>.value();

  /// 每次第 0 页（刷新/回到第一页）自增；排队中的旧请求发现它变了就作废。
  int _mergeEpoch = 0;

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) {
    if (!_mergeEnabled) return _fetchSingle(params, page, limit);
    final epoch = page == 0 ? ++_mergeEpoch : _mergeEpoch;
    final previous = _mergeQueue;
    final done = Completer<void>();
    _mergeQueue = done.future;
    return () async {
      try {
        await previous;
        if (epoch != _mergeEpoch) throw const StalePageLoadException();
        return await _fetchWithMerge(params, page, limit, epoch);
      } finally {
        done.complete();
      }
    }();
  }

  Future<Map<String, dynamic>> _fetchWithMerge(
    Map<String, dynamic> params,
    int page,
    int limit,
    int epoch,
  ) async {
    // 回到第 0 页（刷新 / 分页点回第一页）时重新评估：远跳页停用的归并、
    // 空结果退成的单路，都只作用到下一次回到第一页为止。
    if (page == 0) {
      _mergeAbandoned = false;
      _singleRouteQuery = null;
    }
    if (!_mergeAbandoned) {
      if (page == 0) {
        _resetCursors();
        // 每次搜索一条：出了问题时，「到底往哪几路发了」是第一个要问的。
        LogUtils.d(
          '跨语言归并($segment)：${_cursors.map((c) => c.query).join(' ⊕ ')}',
          'SearchRepository',
        );
      }
      if (page < _mergedPages.length) return _mergedResponse(page);

      if (page - _mergedPages.length <= _maxPagesAhead) {
        var hadFailure = false;
        while (_mergedPages.length <= page) {
          final merged = await _fetchMerged(limit);
          if (epoch != _mergeEpoch) throw const StalePageLoadException();
          hadFailure = hadFailure || merged.hadFailure;
          _mergedPages.add(merged.items);
          if (merged.items.isEmpty) break; // 并集翻完了
        }
        // 几路合起来一条都没有：退回单路，让下面的「引号 0 条就退裸词」接手。
        // ⛔ 只在每一路都**成功**回了空时才退：有一路是超时/报错导致的空，退了
        // 就再也回不来（仓库只随关键词重建，下拉刷新复用同一个实例）。
        final emptyFirstPage =
            page == 0 && _mergedPages.isNotEmpty && _mergedPages[0].isEmpty;
        if (!emptyFirstPage ||
            hadFailure ||
            looseQueryOf(plan.main.query) == null) {
          return _mergedResponse(page);
        }
        _mergeAbandoned = true;
      } else {
        _mergeAbandoned = true;
        // 要核对的路不能单独翻页（单路不走核对，垃圾会原样进列表）。
        final largest = _cursors
            .where((c) => !c.route.needsVerify)
            .reduce((a, b) => b.count > a.count ? b : a);
        if (!identical(largest, _cursors.first)) {
          _singleRouteQuery = largest.query;
        }
        LogUtils.d(
          '跳到第 $page 页太远，停用归并，改走单路：${largest.query}',
          'SearchRepository',
        );
      }
    }
    return _fetchSingle(params, page, limit);
  }

  /// 已归并好的第 [page] 页（翻过头了就是空页）。
  Map<String, dynamic> _mergedResponse(int page) => {
    'success': true,
    'merged': true,
    'items': page < _mergedPages.length ? _mergedPages[page] : <T>[],
    'count': _estimatedTotal(),
  };

  /// 并集大概有多大。分页栏按它算页数，所以宁可略高也不能偏低。
  ///
  /// ⛔ 早先取「最大那一路」当下界：真机 `藿藿` 报 76（标签路），可名字路、标题
  /// 路里还有几十条标签路没有的，分页栏停在 4/4，后面的永远点不到（2026-09-23）。
  /// 现在按各路**已拿到的部分里有多少是新的**折算它剩下的部分；全部翻完时就是
  /// 精确值。另外只要还有路没翻完，至少多报一条，保证页码条上有下一页。
  int _estimatedTotal() {
    var total = 0.0;
    var more = false;
    for (final c in _cursors) {
      total += c.novel;
      if (c.buffer.isNotEmpty) more = true;
      if (c.exhausted || c.keptRaw == 0) continue;
      final remaining = c.estimatedCount - c.keptRaw;
      if (remaining <= 0) continue;
      more = true;
      total += remaining * c.novel / c.keptRaw;
    }
    var merged = 0;
    for (final p in _mergedPages) {
      merged += p.length;
    }
    final lowerBound = merged + (more ? 1 : 0);
    final largest = _cursors.fold<int>(
      0,
      (m, c) => c.estimatedCount > m ? c.estimatedCount : m,
    );
    return [total.round(), lowerBound, largest].reduce((a, b) => a > b ? a : b);
  }

  void _resetCursors() {
    for (final c in _cursors) {
      c.reset();
    }
    _seenIds.clear();
    _knownIds.clear();
    _mergedPages.clear();
  }

  Future<Map<String, dynamic>> _fetchSingle(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    try {
      if (page == 0) _looseFallbackQuery = null;
      // 单路发的是规划里的主路，不是原串：主路把筛选挪到了文本后面（反过来
      // 文本会被静默丢掉），也带上了排除标签。
      ApiResult response = await fetchSearchResults(
        page,
        limit,
        _looseFallbackQuery ?? _singleRouteQuery ?? plan.main.query,
      );

      // 引号搜出 0 条就退一步用裸词再搜一次（理由见 [looseQueryOf]）。只在第 0 页
      // 判：翻到后面才空是「搜完了」，不是「引号太严」。
      final loose = page == 0 && _singleRouteQuery == null
          ? looseQueryOf(plan.main.query)
          : null;
      if (loose != null &&
          response.isSuccess &&
          response.data != null &&
          (response.data.results as List).isEmpty) {
        LogUtils.d('引号搜出 0 条，退成裸词：$loose', 'SearchRepository');
        final retry = await fetchSearchResults(page, limit, loose);
        if (retry.isSuccess && retry.data != null) {
          _looseFallbackQuery = loose;
          response = retry;
        }
      }

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
  Future<({List<T> items, bool hadFailure})> _fetchMerged(int limit) async {
    final items = <T>[];
    String? primaryError;
    String? anyError;

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

    // 本页没等到、留在后台接着跑的补路（见 [_optionalRouteBudget]）。
    final deferred = <_MergeCursor<T>>{};
    final clock = Stopwatch()..start();

    void settle(_MergeCursor<T> c, String? error) {
      if (error == null) return;
      // ⛔ 必须记一笔：不记的话这个 while 会对着同一条坏路无限重试。
      failedThisPage.add(c);
      anyError ??= error;
      if (identical(c, _cursors.first)) {
        // 主路失败要能冒泡成错误页；补路失败只是少几条，不该毁掉整次搜索。
        primaryError ??= error;
        LogUtils.w('跨语言主路本页失败，下一页会重试：${c.query} → $error', 'SearchRepository');
      } else {
        LogUtils.w('跨语言补路本页失败，下一页会重试：${c.query} → $error', 'SearchRepository');
      }
    }

    while (items.length < limit) {
      final hungry = _cursors
          .where(
            (c) =>
                c.buffer.isEmpty &&
                !c.exhausted &&
                !failedThisPage.contains(c) &&
                !deferred.contains(c),
          )
          .toList();
      if (hungry.isNotEmpty) {
        final results = <_MergeCursor<T>, String?>{};
        final futures = {
          for (final c in hungry)
            c: _startRefill(c).then((e) => results[c] = e),
        };
        // 主路与标签路硬等：它们是这一页的骨架（占结果八成）。
        await Future.wait([
          for (final c in hungry)
            if (_isRequired(c)) futures[c]!,
        ]);
        // 其余补路只等到预算用完；没回来的留在后台，下一页接上。
        final optional = [
          for (final c in hungry)
            if (!_isRequired(c)) futures[c]!,
        ];
        final remaining = _optionalRouteBudget - clock.elapsed;
        if (optional.isNotEmpty && remaining > Duration.zero) {
          await Future.wait(
            optional,
          ).timeout(remaining, onTimeout: () => const []);
        }
        for (final c in hungry) {
          if (results.containsKey(c)) {
            settle(c, results[c]);
          } else {
            deferred.add(c);
            LogUtils.d(
              '补路超过 ${_optionalRouteBudget.inMilliseconds}ms 未回，本页先不等：${c.query}',
              'SearchRepository',
            );
          }
        }
      }

      _MergeCursor<T>? best;
      for (final c in _cursors) {
        if (c.buffer.isEmpty) continue;
        if (best == null || _isAhead(c, best)) best = c;
      }
      if (best == null) {
        // 别的路都空了，只剩迟到的还在路上：它们回来前不能判「这一页没有了」，
        // 那会让瀑布流停住、分页缓存一个空页。这时就老老实实等它们。
        if (deferred.isEmpty) break;
        for (final c in deferred) {
          if (c.inFlight case final f?) settle(c, await f);
        }
        // 放回候选：已回来的有了缓冲；在后台失败过的会被重新叫一次，再失败就
        // 记进 failedThisPage，最终要么出料、要么报错，不会拼出一个假的空页。
        deferred.clear();
        continue;
      }

      final item = best.buffer.removeAt(0);
      best.consumed++;
      final id = itemId(item);
      if (id != null && !_seenIds.add(id)) continue;
      items.add(item);
    }

    // ⛔ 一条都没归并出来、而有路失败了：这是「这一页没拿到」，不是「翻完了」，
    // 必须报错让用户重试。主路现在常常是最小的那一路（`原神` 文本 17 条、标签
    // 300+），它先翻完后，标签路一次超时就会拼出空页——瀑布流据此判「没有更多」，
    // 分页模式还会把空页缓存下来，重试也永远是空（2026-09-23 审查查出）。
    final error = primaryError ?? anyError;
    if (items.isEmpty && error != null) {
      lastErrorMessage = error;
      throw Exception(error);
    }

    return (items: items, hadFailure: failedThisPage.isNotEmpty);
  }

  /// 首屏必须等到的路：主路（用户的原话）与标签路（结果的大头）。
  static bool _isRequired(_MergeCursor<dynamic> c) =>
      c.route.kind == SearchRouteKind.main ||
      c.route.kind == SearchRouteKind.tags;

  /// 名字路 / 标题补路最多陪等多久（从这一页开始归并算起）。
  ///
  /// ⭐ 原先一页要等**所有路**回来，首屏时间＝最慢那一路：真机 `藿藿` 四路里
  /// `"フォフォ"` 1 秒回、`"Huohuo"` 与标签路 4 秒才回（2026-09-23）。补路只贡献
  /// 一两成结果，不该拖住整页。超时的那一路不取消，回来后缓冲留给下一页。
  ///
  /// ⚠️ 代价：迟到那一路里本该排进这一页的几条会出现在下一页，时间顺序略错位。
  static const Duration _optionalRouteBudget = Duration(milliseconds: 1500);

  /// 发起一次补货；这一路已经有在途请求（上一页没等到的）就直接接上它。
  Future<String?> _startRefill(_MergeCursor<T> c) {
    final existing = c.inFlight;
    if (existing != null) return existing;
    final future = _refill(c);
    c.inFlight = future;
    future.then((_) {
      if (identical(c.inFlight, future)) c.inFlight = null;
    });
    return future;
  }

  /// [a] 这一路的下一条该不该排在 [b] 那一路的下一条前面。平手时不动（前面的路
  /// ——主路——优先）。
  bool _isAhead(_MergeCursor<T> a, _MergeCursor<T> b) {
    if (!sortKeyComparable) return a.consumed < b.consumed;
    final ka = itemSortKey(a.buffer.first);
    final kb = itemSortKey(b.buffer.first);
    if (ka == null) return false;
    if (kb == null) return true;
    return ka > kb;
  }

  /// 给一路补一页。返回 null ＝成功，否则是失败原因。
  ///
  /// ⛔ [_MergeCursor.exhausted] 的含义是「这一路**真的**没有更多了」，所以只在
  /// 服务端回了空表、或核对出这一路整条是垃圾时才置。请求失败一律不置——那是「这一次没拿到」，不是「以后
  /// 都没有」，判错了就等于让一次网络抖动把整条路永久删掉（见 [_fetchMerged]
  /// 里那段 `failedThisPage`）。失败时 [_MergeCursor.page] 也不前进，下次重试
  /// 拿的还是同一页，不会漏。
  Future<String?> _refill(_MergeCursor<T> cursor) async {
    final generation = cursor.generation;
    final clock = Stopwatch()..start();
    try {
      final res = await fetchSearchResults(
        cursor.page,
        _mergePageSize,
        cursor.query,
      );
      // 在途期间被重置了（刷新 / 回到第一页）：这是上一轮的结果，丢掉。
      if (generation != cursor.generation) return null;
      if (!res.isSuccess || res.data == null) {
        return res.message;
      }
      cursor.count = (res.data.count as int?) ?? cursor.count;
      cursor.page++;
      final list = (res.data.results as List).cast<T>();
      cursor.fetchedRaw += list.length;
      LogUtils.d(
        '归并取数 [${cursor.route.kind.name}] ${cursor.query} 第${cursor.page - 1}页：'
            'count=${cursor.count}，本页 ${list.length} 条，耗时 ${clock.elapsedMilliseconds}ms',
        'SearchRepository',
      );
      if (list.isEmpty) {
        cursor.exhausted = true;
        return null;
      }
      // 不满一页、且已拿够服务端报的条数：这就是最后一页。省掉一次只为确认
      // 「空了」的请求——真机 `藿藿` 六路翻到底时，每路都多发一次，末页因此
      // 多等 2 秒（2026-09-23）。两个条件都要：单看哪个都可能被服务端骗。
      if (list.length < _mergePageSize && cursor.fetchedRaw >= cursor.count) {
        cursor.exhausted = true;
      }
      final route = cursor.route;
      if (!route.needsVerify) {
        _keep(cursor, list);
        return null;
      }

      // ⛔ 这一路可能整条都是垃圾（ja 标题路见 _unreliableLocales；名字路的译名
      // 偶尔撞车、带怪符号的名字能让整条查询失效返回全站）。逐条核对只留真含
      // 关键词的；一页里过半是冒牌货就**整条放弃**——实测它要么 20/20 要么
      // 0/20，坏的那种能有几千条（`丝袜` 4846），只逐条筛的话归并会为了凑一页
      // 把它们全部翻完。
      final kept = list
          .where((it) => route.accepts(itemTitle(it), itemTagIds(it)))
          .toList();
      _keep(cursor, kept);
      // 主路永不整路放弃（那是用户的原话），但一整页一条都留不下就说明它往后
      // 全是简介里顺嘴一提的——别为了凑页把它翻到底。
      if (!route.droppable && kept.isEmpty) {
        cursor.exhausted = true;
        LogUtils.d('主路整页都只是简介提及，停止翻它：${cursor.query}', 'SearchRepository');
        return null;
      }
      if (route.droppable && kept.length * 2 < list.length) {
        cursor.exhausted = true;
        // 服务端报的是那堆垃圾的条数，拿去当总数下界会虚高（`萝莉` 会显示 229）。
        cursor.count = 0;
        LogUtils.d(
          '跨语言补路结果不可信，放弃：${cursor.query}（本页 ${kept.length}/${list.length} 条标题含关键词）',
          'SearchRepository',
        );
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void _keep(_MergeCursor<T> cursor, List<T> kept) {
    cursor.keptRaw += kept.length;
    for (final it in kept) {
      final id = itemId(it);
      if (id == null || _knownIds.add(id)) cursor.novel++;
    }
    cursor.buffer.addAll(kept);
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
