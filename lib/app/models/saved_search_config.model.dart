import 'package:i_iwara/app/models/tag.model.dart';

/// 已保存的「快速筛选配置」。
///
/// 对应热门视频/图库筛选项配置弹窗里的三个维度：
/// - [tags]：选中的标签
/// - [date]：日期字符串，空 / `YYYY` / `YYYY-MM`
/// - [rating]：内容评级（[MediaRating.value]，空表示全部）
class SavedSearchConfig {
  final String id;
  String name;
  final List<Tag> tags;
  final String date;
  final String rating;

  SavedSearchConfig({
    required this.id,
    required this.name,
    required this.tags,
    required this.date,
    required this.rating,
  });

  factory SavedSearchConfig.fromJson(Map<String, dynamic> json) {
    return SavedSearchConfig(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tags:
          (json['tags'] as List?)
              ?.map((e) => Tag.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          <Tag>[],
      date: json['date']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tags': tags.map((e) => e.toJson()).toList(),
      'date': date,
      'rating': rating,
    };
  }

  SavedSearchConfig copyWith({String? name}) {
    return SavedSearchConfig(
      id: id,
      name: name ?? this.name,
      tags: tags,
      date: date,
      rating: rating,
    );
  }
}
