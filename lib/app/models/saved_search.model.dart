import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/common/enums/media_enums.dart';

/// 已保存的「搜索」。
///
/// 完整记录搜索结果页的全部条件，便于一键还原：
/// - [keyword]：搜索关键词
/// - [segment]：搜索分类（视频/图库/用户/帖子/论坛/播放列表/Oreno3D…）
/// - [sort]：排序方式
/// - [filters]：高级搜索筛选项（`{field op value}` 语法）
/// - [searchType] / [extData] / [singleTagName]：Oreno3D 单实体浏览态
///   （按原作/角色/标签 id 浏览时需要还原）
class SavedSearch {
  final String id;
  String name;
  final String keyword;
  final SearchSegment segment;
  final String sort;
  final List<Filter> filters;

  /// Oreno3D 搜索类型：'origin' / 'tag' / 'character'，空表示普通文本搜索。
  final String searchType;

  /// Oreno3D 扩展数据：{searchType, id, name}，普通搜索为空。
  final Map<String, dynamic>? extData;

  /// Oreno3D 单实体浏览时展示的标签名。
  final String singleTagName;

  SavedSearch({
    required this.id,
    required this.name,
    required this.keyword,
    required this.segment,
    required this.sort,
    required this.filters,
    this.searchType = '',
    this.extData,
    this.singleTagName = '',
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      keyword: json['keyword']?.toString() ?? '',
      segment: SearchSegment.values.firstWhere(
        (e) => e.name == json['segment'],
        orElse: () => SearchSegment.video,
      ),
      sort: json['sort']?.toString() ?? '',
      filters:
          (json['filters'] as List?)
              ?.map(
                (e) => Filter.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          <Filter>[],
      searchType: json['searchType']?.toString() ?? '',
      extData: json['extData'] is Map
          ? Map<String, dynamic>.from(json['extData'] as Map)
          : null,
      singleTagName: json['singleTagName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'keyword': keyword,
      'segment': segment.name,
      'sort': sort,
      'filters': filters.map((e) => e.toJson()).toList(),
      'searchType': searchType,
      'extData': extData,
      'singleTagName': singleTagName,
    };
  }

  SavedSearch copyWith({String? name}) {
    return SavedSearch(
      id: id,
      name: name ?? this.name,
      keyword: keyword,
      segment: segment,
      sort: sort,
      filters: filters,
      searchType: searchType,
      extData: extData,
      singleTagName: singleTagName,
    );
  }
}
