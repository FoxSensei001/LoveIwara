import 'package:i_iwara/app/models/user.model.dart';

/// 会话模型
class ConversationModel {
  final String id;
  String title;
  bool unread;
  DateTime createdAt;
  DateTime updatedAt;
  int numMessages;
  List<User> participants;
  MessageModel lastMessage;

  ConversationModel({
    required this.id,
    this.title = '',
    this.unread = false,
    required this.createdAt,
    required this.updatedAt,
    this.numMessages = 0,
    required this.participants,
    required this.lastMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      unread: json['unread'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      numMessages: json['numMessages'] as int? ?? 0,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastMessage: MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'unread': unread,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'numMessages': numMessages,
        'participants': participants.map((e) => e.toJson()).toList(),
        'lastMessage': lastMessage.toJson(),
      };

  ConversationModel copyWith({
    String? id,
    String? title,
    bool? unread,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? numMessages,
    List<User>? participants,
    MessageModel? lastMessage,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      unread: unread ?? this.unread,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      numMessages: numMessages ?? this.numMessages,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}

/// 消息模型
class MessageModel {
  final String id;
  String body;
  String conversation;  // conversation id
  DateTime createdAt;
  DateTime updatedAt;
  User user;

  MessageModel({
    required this.id,
    this.body = '',
    required this.conversation,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      body: json['body'] as String? ?? '',
      conversation: json['conversation'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'body': body,
        'conversation': conversation,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'user': user.toJson(),
      };
}
