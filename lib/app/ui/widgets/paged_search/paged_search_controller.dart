import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/user.model.dart';

typedef PagedFetcher<T> =
    Future<PageData<T>> Function(int page, int limit, CancelToken cancelToken);

/// Match a local record by free-text fields (title, author name, handle…).
/// Every whitespace-separated word must hit at least one field; a leading `@`
/// is ignored so `@handle` also works.
bool matchesTextSearch(String query, Iterable<String?> fields) {
  final haystacks = [
    for (final field in fields)
      if (field != null && field.isNotEmpty) field.toLowerCase(),
  ];
  for (final word in query.trim().toLowerCase().split(RegExp(r'\s+'))) {
    final needle = word.startsWith('@') ? word.substring(1) : word;
    if (needle.isEmpty) continue;
    if (!haystacks.any((haystack) => haystack.contains(needle))) return false;
  }
  return true;
}

/// Match media by title or author. Every whitespace-separated word must hit
/// the title, the author's display name or the author's handle (`@` allowed).
bool matchesMediaSearch(String query, String? title, User? author) {
  final words = query.trim().toLowerCase().split(RegExp(r'\s+'));
  final haystackTitle = (title ?? '').toLowerCase();
  final name = (author?.name ?? '').toLowerCase();
  final username = (author?.username ?? '').toLowerCase();
  for (final word in words) {
    if (word.isEmpty) continue;
    final handle = word.startsWith('@') ? word.substring(1) : word;
    if (!haystackTitle.contains(word) &&
        !name.contains(word) &&
        !username.contains(handle)) {
      return false;
    }
  }
  return true;
}

/// Search over a server-paged list.
///
/// Search has its own snapshot; it must never change the browsing page cursor.
/// Only explicit pagination validation errors are used to discover limits.
class PagedSearchController<T> extends ChangeNotifier {
  PagedSearchController({
    required this.fetchPage,
    required this.idOf,
    required this.matches,
  });

  final PagedFetcher<T> fetchPage;

  /// Stable identity used to merge pages and browsing results.
  final String Function(T item) idOf;

  /// Whether [item] matches the current query.
  final bool Function(String query, T item) matches;

  // Bound the response size even if the server accepts an unlimited limit.
  static const maxProbeLimit = 10000;
  final Map<String, T> _loaded = {};
  final Map<String, T> _all = {};
  String query = '';
  bool searchAll = false;
  bool loading = false;
  bool probing = false;
  bool awaitingConfirmation = false;
  bool complete = false;
  bool cancelled = false;
  Object? error;
  int? totalCount;
  int? pageSize;
  int completedRequests = 0;
  int _nextPage = 1;
  int _generation = 0;
  bool _disposed = false;
  CancelToken? _cancelToken;
  Timer? _timer;
  final Stopwatch _requestWatch = Stopwatch();
  double _averageRequestMs = 1000;
  bool _loadedWholePage = false;
  int? _loadedPageSize;

  /// The user already accepted the long-wait warning for this full search.
  /// A rescan after the list refreshes keeps that answer instead of asking again.
  bool _scanConfirmed = false;

  int get loadedCount => _loaded.length;
  int get scannedCount => _all.length;
  bool get showingResults => query.trim().isNotEmpty || searchAll;
  // Until the full snapshot is complete, include all data already available
  // from browsing as well as successful scan requests.
  List<T> get results => (searchAll && complete ? _all : _loaded).values
      .where((item) => matches(query, item))
      .toList(growable: false);
  int get remainingRequests => pageSize == null || totalCount == null
      ? 0
      : math.max(0, (totalCount! / pageSize!).ceil() - _nextPage);
  int get estimatedRequests => completedRequests + remainingRequests;
  Duration get estimatedRemaining {
    if (complete) return Duration.zero;
    // The active request's elapsed time raises the estimate when it slows down.
    final measured = math.max(
      _averageRequestMs,
      _requestWatch.elapsedMilliseconds.toDouble(),
    );
    return Duration(
      milliseconds: (remainingRequests * (measured * 1.5 + 250)).ceil(),
    );
  }

  bool get needsLongWaitWarning =>
      (pageSize != null &&
          totalCount != null &&
          (totalCount! / pageSize!).ceil() >= 20) ||
      estimatedRemaining.inSeconds >= 30;

  void setQuery(String value) {
    query = value;
    _notify();
  }

  void recordLoaded(PageData<T> page) {
    // Browsing requests may finish while the independent scan is running.
    // They must not change that scan's termination count or page estimate.
    if (!loading && !awaitingConfirmation) {
      if (complete && totalCount != page.count) {
        complete = false;
        pageSize = null;
      }
      totalCount = page.count;
    }
    if (page.page == 0 && page.count == page.results.length) {
      _loadedWholePage = true;
      _loadedPageSize = page.limit;
    } else if (_loadedWholePage && page.count != _loaded.length) {
      _loadedWholePage = false;
    }
    for (final item in page.results) {
      final id = idOf(item);
      if (id.isNotEmpty) _loaded[id] = item;
    }
    _notify();
  }

  void useLoaded() {
    cancel();
    searchAll = false;
    _scanConfirmed = false;
    _notify();
  }

  Future<void> startAll({bool confirmed = false}) async {
    if (_disposed || loading) return;
    searchAll = true;
    cancelled = false;
    error = null;
    if (!complete && _loadedWholePage && totalCount == _loaded.length) {
      _all
        ..clear()
        ..addAll(_loaded);
      pageSize = _loadedPageSize;
      complete = true;
    }
    if (complete) {
      _notify();
      return;
    }
    if (awaitingConfirmation && !confirmed) {
      _notify();
      return;
    }
    awaitingConfirmation = false;
    if (confirmed) _scanConfirmed = true;
    loading = true;
    final generation = ++_generation;
    final token = _cancelToken = CancelToken();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _notify());
    _notify();
    try {
      if (pageSize == null) {
        probing = true;
        final first = await _probe(generation, token);
        _check(generation, token);
        pageSize = first.limit;
        _all.clear();
        _accept(first);
        _nextPage = 1;
        probing = false;
        _notify();
      }
      if (_all.length >= (totalCount ?? 0)) {
        complete = true;
        return;
      }
      if (!confirmed && needsLongWaitWarning) {
        awaitingConfirmation = true;
        return;
      }
      while (remainingRequests > 0) {
        final page = await _request(_nextPage, pageSize!, generation, token);
        _check(generation, token);
        if (page.limit != pageSize ||
            page.page != _nextPage ||
            page.count != totalCount) {
          pageSize = null;
          throw StateError('Pagination changed during full search');
        }
        _accept(page);
        _nextPage++;
        _notify();
        if (_all.length >= page.count) break;
        if (page.results.isEmpty) break;
      }
      complete = _all.length >= (totalCount ?? 0);
      if (!complete) {
        // A moving list, repeated pages or an early empty page is not "no match".
        // Retrying re-probes from page zero, rather than skipping missing items.
        pageSize = null;
        throw StateError('The list changed or returned incomplete pages');
      }
    } catch (e) {
      if (generation == _generation && !token.isCancelled) error = e;
    } finally {
      if (generation == _generation && !_disposed) {
        loading = false;
        probing = false;
        _requestWatch.stop();
        _requestWatch.reset();
        _timer?.cancel();
        _notify();
      }
    }
  }

  Future<PageData<T>> _probe(int generation, CancelToken token) async {
    int? rejected;
    PageData<T>? accepted;
    for (final limit in [maxProbeLimit, 1000, 100, 20, 1]) {
      try {
        accepted = await _request(0, limit, generation, token);
        // Servers usually clamp and report their maximum in response.limit.
        if (accepted.limit < limit ||
            accepted.count <= accepted.results.length) {
          return await _normalizeFirst(accepted, generation, token);
        }
        break;
      } on DioException catch (e) {
        if (!_isLimitRejection(e)) rethrow;
        rejected = limit;
      }
    }
    if (accepted == null) throw StateError('No supported pagination limit');
    if (rejected != null) {
      var low = accepted.limit;
      var high = rejected;
      // Find the largest accepted integer limit, not an arbitrary fallback.
      while (high - low > 1) {
        final middle = (low + high) ~/ 2;
        try {
          final candidate = await _request(0, middle, generation, token);
          if (candidate.limit < middle) {
            return await _normalizeFirst(candidate, generation, token);
          }
          accepted = candidate;
          low = middle;
        } on DioException catch (e) {
          if (!_isLimitRejection(e)) rethrow;
          high = middle;
        }
      }
    }
    return _normalizeFirst(accepted!, generation, token);
  }

  Future<PageData<T>> _normalizeFirst(
    PageData<T> page,
    int generation,
    CancelToken token,
  ) async {
    // Some servers echo limit but silently truncate results. Re-request with the
    // observed size so page offsets are based on the size actually returned.
    if (page.count > page.results.length &&
        page.results.isNotEmpty &&
        page.results.length < page.limit) {
      page = await _request(0, page.results.length, generation, token);
    }
    if (page.count < 0 ||
        page.limit <= 0 ||
        page.limit > maxProbeLimit ||
        page.page != 0 ||
        (page.count > 0 && page.results.isEmpty) ||
        (page.count > page.results.length &&
            page.results.length < page.limit)) {
      throw StateError('Invalid pagination response');
    }
    return page;
  }

  bool _isLimitRejection(DioException error) {
    final status = error.response?.statusCode;
    final body = '${error.response?.data}'.toLowerCase();
    return (status == 400 || status == 422) &&
        (body.contains('limit') || body.contains('page size'));
  }

  Future<PageData<T>> _request(
    int page,
    int limit,
    int generation,
    CancelToken token,
  ) async {
    _check(generation, token);
    _requestWatch
      ..reset()
      ..start();
    try {
      final result = await fetchPage(page, limit, token);
      _check(generation, token);
      // Even successful probe responses remain usable if probing is cancelled
      // before its final page size has been chosen.
      if (probing && page == 0) {
        _all.clear();
        _accept(result);
        _notify();
      }
      return result;
    } finally {
      if (generation == _generation) {
        completedRequests++;
        _requestWatch.stop();
        final elapsed = math
            .max(1, _requestWatch.elapsedMilliseconds)
            .toDouble();
        _averageRequestMs = completedRequests <= 1
            ? elapsed
            : _averageRequestMs * .65 + elapsed * .35;
        _requestWatch.reset();
      }
    }
  }

  void _accept(PageData<T> page) {
    totalCount = page.count;
    for (final item in page.results) {
      final id = idOf(item);
      if (id.isNotEmpty) {
        _all[id] = item;
        _loaded[id] = item;
      }
    }
  }

  void _check(int generation, CancelToken token) {
    if (_disposed || generation != _generation || token.isCancelled) {
      throw StateError('Search cancelled');
    }
  }

  void cancel() {
    ++_generation;
    _cancelToken?.cancel('paged search cancelled');
    _timer?.cancel();
    _requestWatch
      ..stop()
      ..reset();
    cancelled = loading || awaitingConfirmation;
    loading = false;
    probing = false;
    awaitingConfirmation = false;
    _notify();
  }

  /// The browsing list was refreshed (pull to refresh, reload after a delete):
  /// every snapshot is stale, but the scope the user picked is not.
  ///
  /// A full search that was running or had finished rescans the new data. One
  /// that was waiting for confirmation, cancelled or failed stays on "whole
  /// list" as cancelled, so the user decides whether to start it again.
  void reset() {
    final keepAll = searchAll;
    final rescan = searchAll && (loading || complete);
    final confirmed = _scanConfirmed;
    cancel();
    _loaded.clear();
    _all.clear();
    totalCount = null;
    pageSize = null;
    _loadedWholePage = false;
    _loadedPageSize = null;
    completedRequests = 0;
    _nextPage = 1;
    complete = false;
    cancelled = keepAll && !rescan;
    error = null;
    searchAll = keepAll;
    _scanConfirmed = rescan && confirmed;
    _notify();
    if (rescan) unawaited(startAll(confirmed: confirmed));
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    cancel();
    super.dispose();
  }
}
