class UserNotifications {
  final bool mention;
  final bool reply;
  final bool comment;

  UserNotifications({
    this.mention = false,
    this.reply = false,
    this.comment = false,
  });

  factory UserNotifications.fromJson(Map<String, dynamic> json) {
    return UserNotifications(
      mention: json['mention'] ?? false,
      reply: json['reply'] ?? false,
      comment: json['comment'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'mention': mention, 'reply': reply, 'comment': comment};
  }

  UserNotifications copyWith({bool? mention, bool? reply, bool? comment}) {
    return UserNotifications(
      mention: mention ?? this.mention,
      reply: reply ?? this.reply,
      comment: comment ?? this.comment,
    );
  }
}
