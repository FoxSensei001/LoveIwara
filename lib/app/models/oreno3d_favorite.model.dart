/// 用户收藏的 Oreno3d 实体（原作 / 角色 / 标签），用于快速选择浏览。
///
/// [type] 取 `origin` / `character` / `tag`，与搜索 extData 的 `searchType` 一致；
/// [id] 为 oreno3d 的数字 id（用于 `/origins/:id` 等浏览接口）；
/// [name] 存日文原名作为稳定展示兜底（实际展示时优先经
/// `Oreno3dLocalizationService` 取当前语言译名）。
class Oreno3dFavorite {
  final String type;
  final String id;
  final String name;

  const Oreno3dFavorite({
    required this.type,
    required this.id,
    required this.name,
  });

  /// 去重 / 比较用的唯一键。
  String get key => '$type:$id';

  factory Oreno3dFavorite.fromJson(Map<String, dynamic> json) {
    return Oreno3dFavorite(
      type: json['type'] as String,
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'name': name,
      };
}
