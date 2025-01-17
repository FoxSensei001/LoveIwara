import 'package:i_iwara/app/models/user.model.dart';

/// 论坛分类 (目前树的高度为2)
/// 如:
/// - chinese
///   - general-zh
/// - global
///   - general

/// 论坛分类树节点
class ForumCategoryTreeModel {
  final String name; // 分组名称
  final List<ForumCategoryModel> children; // 子分类

  ForumCategoryTreeModel({
    required this.name,
    required this.children,
  });

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}

/// 论坛分类
class ForumCategoryModel {
  final String id;
  final String group; // 分类名称
  final String label; // 显示名称
  final String description; // 分类描述
  final bool locked; // 无用字段
  final int numPosts; // 评论数
  final int numThreads; // 帖子数
  final ForumThreadModel? lastThread; // 最后回复的帖子

  ForumCategoryModel({
    required this.id,
    required this.group,
    required this.label,
    required this.description,
    required this.locked,
    required this.numPosts,
    required this.numThreads,
    required this.lastThread,
  });

  factory ForumCategoryModel.fromJson(Map<String, dynamic> json) {
    return ForumCategoryModel(
      id: json['id'],
      group: json['group'],
      label: json['label'] ?? json['id'],
      description: json['description'] ?? '',
      locked: json['locked'],
      numPosts: json['numPosts'],
      numThreads: json['numThreads'],
      lastThread: json['lastThread'] != null ? ForumThreadModel.fromJson(json['lastThread']) : null,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group': group,
      'label': label,
      'description': description,
      'locked': locked,
      'numPosts': numPosts,
      'numThreads': numThreads,
      'lastThread': lastThread?.toJson(),
    };
  }
}

/// 论坛帖子
class ForumThreadModel {
  final String id;
  final bool approved; // 是否审核通过
  /// slug 是一个用于 URL 的友好字符串，通常用来代替 ID 来创建可读性更好的网址。它通常由标题转化而来，包含小写字母、数字和连字符。
  /// 
  /// 标题: "Flutter 开发入门教程"
  /// slug: "flutter-development-tutorial"
  /// URL 对比：
  /// forum.com/thread/123456
  /// forum.com/thread/flutter-development-tutorial
  final String? slug;
  final String section; // 分类
  final String title; // 标题
  final bool locked; // 是否锁定 决定是否可以发评论
  final bool sticky; // 是否置顶
  final ThreadCommentModel? lastPost; // 最后回复的帖子
  final int numViews; // 浏览数
  final int numPosts; // 评论数
  final DateTime createdAt; // 创建时间
  final DateTime updatedAt; // 更新时间
  final User user; // 创建者

  ForumThreadModel({
    required this.id,
    required this.approved,
    this.slug,
    required this.section,
    required this.title,
    required this.locked,
    required this.sticky,
    required this.lastPost,
    required this.numViews,
    required this.numPosts,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory ForumThreadModel.fromJson(Map<String, dynamic> json) {
    return ForumThreadModel(
      id: json['id'],
      approved: json['approved'],
      slug: json['slug'],
      section: json['section'],
      title: json['title'],
      locked: json['locked'],
      sticky: json['sticky'],
      lastPost: json['lastPost'] != null ? ThreadCommentModel.fromJson(json['lastPost']) : null,
      numViews: json['numViews'],
      numPosts: json['numPosts'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: User.fromJson(json['user']),
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'approved': approved,
      'slug': slug,
      'section': section,
      'title': title,
      'locked': locked,
      'sticky': sticky,
      'lastPost': lastPost?.toJson(),
      'numViews': numViews,
      'numPosts': numPosts,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

/// 论坛帖子评论
class ThreadCommentModel {
  final String id;
  final bool approved; // 是否审核通过
  final String body; // 评论内容
  final int replyNum; // 回复数，其实是楼层号，从0开始
  final User user; // 评论者
  final dynamic thread; // 帖子 nullable
  final DateTime createdAt; // 创建时间
  final DateTime updatedAt; // 更新时间
  final String threadId; // 帖子ID

  ThreadCommentModel({
    required this.id,
    required this.approved,
    required this.body,
    required this.replyNum,
    required this.user,
    this.thread,
    required this.createdAt,
    required this.updatedAt,
    required this.threadId,
  });

  factory ThreadCommentModel.fromJson(Map<String, dynamic> json) {
    return ThreadCommentModel(
      id: json['id'],
      approved: json['approved'],
      body: json['body'],
      replyNum: json['replyNum'],
      user: User.fromJson(json['user']),
      thread: json['thread'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      threadId: json['threadId'],
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'approved': approved,
      'body': body,
      'replyNum': replyNum,
      'user': user.toJson(),
      'thread': thread,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'threadId': threadId,
    };
  }
}
