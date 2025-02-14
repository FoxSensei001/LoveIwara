class UserDTO {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  DateTime? likedTime;

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

  UserDTO copyWith({
    String? name,
    String? username,
    String? avatarUrl,
    DateTime? likedTime,
  }) {
    return UserDTO(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      likedTime: likedTime ?? this.likedTime,
    );
  }
}