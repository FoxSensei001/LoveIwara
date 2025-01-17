/// 论坛帖子分类的DTO
class ForumThreadSectionDto {
  final String id; // 分类id
  String name; // 分类名称
  String description; // 分类描述
  String group; // 组
  bool locked; // 是否锁定
  int numPosts; // 帖子数
  int numThreads; // 主题数

  ForumThreadSectionDto({
    required this.id,
    this.name = '',
    this.description = '',
    this.group = '',
    this.locked = false,
    this.numPosts = 0,
    this.numThreads = 0,
  });

  factory ForumThreadSectionDto.fromJson(Map<String, dynamic> json) {
    return ForumThreadSectionDto(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      group: json['group'] ?? '',
      locked: json['locked'] ?? false,
      numPosts: json['numPosts'] ?? 0,
      numThreads: json['numThreads'] ?? 0,
    );
  }
}
