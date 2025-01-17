class PageData<T> {
  final int count;
  final int page;
  final int limit;
  List<T> results = <T>[];
  Map<String, dynamic>? extras;

  PageData({
    required this.count,
    required this.page,
    required this.limit,
    required this.results,
    this.extras,
  });

  PageData.fromJson(Map<String, dynamic> data)
      : count = data['count'],
        page = data['page'],
        limit = data['limit'],
        results = [],
        extras = Map<String, dynamic>.from(data)
          ..removeWhere((key, value) =>
              ['count', 'page', 'limit', 'results'].contains(key));

  /// 工厂构造函数，用于处理泛型类型的转换
  static PageData<T> fromJsonWithConverter<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PageData<T>(
      count: data['count'],
      page: data['page'],
      limit: data['limit'],
      results: (data['results'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      extras: Map<String, dynamic>.from(data)
        ..removeWhere(
            (key, value) => ['count', 'page', 'limit', 'results'].contains(key)),
    );
  }
}
