import 'package:i_iwara/app/models/user.model.dart';

class Comment {
  final String id;
  final String body;
  final int numReplies;
  final Comment? parent;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? user;
  final String? videoId;
  final String? profileId;
  final String? imageId;
  final String? postId;
  final bool approved;
  final int? floorNumber; // 楼号

  Comment({
    required this.id,
    this.body = '',
    this.numReplies = 0,
    this.parent,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.videoId,
    this.profileId,
    this.imageId,
    this.postId,
    this.approved = false,
    this.floorNumber,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      body: json['body'] as String? ?? '',
      numReplies: json['numReplies'] as int? ?? 0,
      parent: json['parent'] != null
          ? Comment.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      videoId: json['videoId'] as String?,
      profileId: json['profileId'] as String?,
      imageId: json['imageId'] as String?,
      postId: json['postId'] as String?,
      approved: json['approved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'numReplies': numReplies,
      'parent': parent?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
      'videoId': videoId,
      'profileId': profileId,
      'imageId': imageId,
      'postId': postId,
      'approved': approved,
    };
  }

  Comment copyWith({
    String? id,
    String? body,
    int? numReplies,
    Comment? parent,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    String? videoId,
    String? profileId,
    String? imageId,
    String? postId,
    bool? approved,
    int? floorNumber,
  }) {
    return Comment(
      id: id ?? this.id,
      body: body ?? this.body,
      numReplies: numReplies ?? this.numReplies,
      parent: parent ?? this.parent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      videoId: videoId ?? this.videoId,
      profileId: profileId ?? this.profileId,
      imageId: imageId ?? this.imageId,
      postId: postId ?? this.postId,
      approved: approved ?? this.approved,
      floorNumber: floorNumber ?? this.floorNumber,
    );
  }
}
