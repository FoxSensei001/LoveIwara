
class UserNotificationCount {
  final int messages; // 消息
  final int notifications; // 通知
  final int friendRequests; // 好友请求

  UserNotificationCount({required this.messages, required this.notifications, required this.friendRequests});

  factory UserNotificationCount.fromJson(Map<String, dynamic> json) {
    return UserNotificationCount(
      messages: json['messages'],
      notifications: json['notifications'],
      friendRequests: json['friendRequests'],
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'messages': messages,
      'notifications': notifications,
      'friendRequests': friendRequests,
    };
  }
}
