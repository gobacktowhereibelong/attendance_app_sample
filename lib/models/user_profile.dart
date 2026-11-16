/// Model data profil pengguna.
class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final DateTime createdAt;
  final String role;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.createdAt,
    this.role = 'Pengguna',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'created_at': createdAt.toIso8601String(),
      'role': role,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      role: json['role'] as String? ?? 'Pengguna',
    );
  }
}
