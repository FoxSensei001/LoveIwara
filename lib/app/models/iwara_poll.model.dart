import 'package:i_iwara/app/models/user.model.dart';

/// Iwara 投票（`GET /poll/{id}`）。
///
/// 投票本身没有列表入口也搜不到，只靠把 `https://www.iwara.tv/poll/<id>`
/// 贴进 markdown 正文传播，网页端会把这条链接就地渲染成投票卡片。
/// 接口实测记录在 `docs/poll-workstream.md`（只留本地）。
class IwaraPoll {
  final String id;
  final String title;

  /// 总票数。
  final int numVotes;
  final List<IwaraPollOption> options;

  /// 当前账号投的那个选项的 id；没投过、未登录读取时都是 null。
  ///
  /// 创建接口的返回体里**没有这个键**（不是 null），这里同样解析成 null。
  final int? vote;
  final User? user;
  final DateTime? createdAt;

  const IwaraPoll({
    required this.id,
    required this.title,
    required this.numVotes,
    required this.options,
    this.vote,
    this.user,
    this.createdAt,
  });

  bool get hasVoted => vote != null;

  /// 只改「我投了哪项」，票数原样（不在本地猜算票数）。
  IwaraPoll withVote(int optionId) => IwaraPoll(
    id: id,
    title: title,
    numVotes: numVotes,
    options: options,
    vote: optionId,
    user: user,
    createdAt: createdAt,
  );

  factory IwaraPoll.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final userJson = json['user'];
    return IwaraPoll(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      numVotes: (json['numVotes'] as num?)?.toInt() ?? 0,
      options: rawOptions is List
          ? rawOptions
                .whereType<Map<String, dynamic>>()
                .map(IwaraPollOption.fromJson)
                .toList(growable: false)
          : const [],
      vote: (json['vote'] as num?)?.toInt(),
      user: userJson is Map<String, dynamic> ? User.fromJson(userJson) : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class IwaraPollOption {
  final int id;
  final String title;
  final int numVotes;

  const IwaraPollOption({
    required this.id,
    required this.title,
    required this.numVotes,
  });

  factory IwaraPollOption.fromJson(Map<String, dynamic> json) {
    return IwaraPollOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      numVotes: (json['numVotes'] as num?)?.toInt() ?? 0,
    );
  }
}
