class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarInitials,
  });

  final String id;
  final String name;
  final String email;
  final String avatarInitials;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    return UserModel(
      id: (json['_id'] ?? json['id']).toString(),
      name: name,
      email: json['email'] as String,
      avatarInitials: _initialsFromName(name),
    );
  }

  static String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}
