class UserDTO {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final DateTime? likedTime;

  UserDTO({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    this.likedTime,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      likedTime: json['likedTime'] != null ? DateTime.parse(json['likedTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatarUrl': avatarUrl,
      'likedTime': likedTime?.toIso8601String(),
    };
  }
}