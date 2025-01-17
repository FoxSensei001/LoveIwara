
import 'package:i_iwara/app/models/user.model.dart';

class PostModel {
  final String id;
  final String title;
  final String body;
  final int? numViews;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;


  PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.numViews,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      numViews: json['numViews'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'numViews': numViews,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }

  PostModel copyWith({
    String? id,
    String? title,
    String? body,
    int? numViews,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) => PostModel(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    numViews: numViews ?? this.numViews,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    user: user ?? this.user,
  );
}

class PostCooldownModel {
  final bool limited;
  final int remaining;

  PostCooldownModel({
    required this.limited,
    required this.remaining,
  });

  factory PostCooldownModel.fromJson(Map<String, dynamic> json) {
    return PostCooldownModel(
      limited: json['limited'],
      remaining: json['remaining'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limited': limited,
      'remaining': remaining,
    };
  }
}
