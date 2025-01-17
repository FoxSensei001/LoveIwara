import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/models/user.model.dart';

class ProfileUserDto {
  final User? user;
  final Profile? profile;
  final List<Tag>? tagBlacklist;
  final Notifications? notifications;
  final int? balance;

  ProfileUserDto({
    this.user,
    this.profile,
    this.tagBlacklist,
    this.notifications,
    this.balance,
  });

  factory ProfileUserDto.fromJson(Map<String, dynamic> json) {
    return ProfileUserDto(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
      tagBlacklist: json['tagBlacklist'] != null 
          ? (json['tagBlacklist'] as List).map((i) => Tag.fromJson(i)).toList() 
          : null,
      notifications: json['notifications'] != null 
          ? Notifications.fromJson(json['notifications']) 
          : null,
      balance: json['balance'],
    );
  }
}

class Profile {
  final String? body;
  final String? header;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Profile({
    this.body,
    this.header,
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      body: json['body'],
      header: json['header'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
}

class Notifications {
  final bool? mention;
  final bool? reply;
  final bool? comment;

  Notifications({
    this.mention,
    this.reply,
    this.comment,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      mention: json['mention'],
      reply: json['reply'],
      comment: json['comment'],
    );
  }
}
