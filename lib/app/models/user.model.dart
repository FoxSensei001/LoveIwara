import 'package:i_iwara/app/models/user_avatar.model.dart';

class User {
  final String id;
  final String name;
  final String username;
  final String status;
  final String role;
  final bool followedBy;
  final bool following;
  final bool friend;
  final bool premium;
  final bool creatorProgram;
  final String? locale;
  final DateTime seenAt;
  final UserAvatar? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isAdmin => role == 'admin';

  User({
    required this.id,
    this.name = '',
    this.username = '',
    this.status = '',
    this.role = '',
    this.followedBy = false,
    this.following = false,
    this.friend = false,
    this.premium = false,
    this.creatorProgram = false,
    this.locale,
    DateTime? seenAt,
    this.avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : seenAt = seenAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      status: json['status'] ?? '',
      role: json['role'] ?? '',
      followedBy: json['followedBy'] ?? false,
      following: json['following'] ?? false,
      friend: json['friend'] ?? false,
      premium: json['premium'] ?? false,
      creatorProgram: json['creatorProgram'] ?? false,
      locale: json['locale'],
      seenAt: json['seenAt'] != null ? DateTime.parse(json['seenAt']) : null,
      avatar:
          json['avatar'] != null ? UserAvatar.fromJson(json['avatar']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'status': status,
      'role': role,
      'followedBy': followedBy,
      'following': following,
      'friend': friend,
      'premium': premium,
      'creatorProgram': creatorProgram,
      'locale': locale,
      'seenAt': seenAt.toIso8601String(),
      'avatar': avatar?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? status,
    String? role,
    bool? followedBy,
    bool? following,
    bool? friend,
    bool? premium,
    bool? creatorProgram,
    String? locale,
    DateTime? seenAt,
    UserAvatar? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      status: status ?? this.status,
      role: role ?? this.role,
      followedBy: followedBy ?? this.followedBy,
      following: following ?? this.following,
      friend: friend ?? this.friend,
      premium: premium ?? this.premium,
      creatorProgram: creatorProgram ?? this.creatorProgram,
      locale: locale ?? this.locale,
      seenAt: seenAt ?? this.seenAt,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
