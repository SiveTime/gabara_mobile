// lib/features/auth/data/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;
  final String role; // <-- TAMBAHAN PENTING

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.role, // <-- Tambahkan di constructor
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      role: json['role'] ?? 'student', // <-- Default ke student jika null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'role': role, // <-- Masukkan ke JSON
    };
  }
}