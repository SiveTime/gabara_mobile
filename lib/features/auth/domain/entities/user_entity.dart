class UserEntity {
  final String id;
  final String name;
  final String email;
  final String token;
  final String role; // <-- Tambahkan ini

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.role, // <-- Tambahkan di constructor
  });
}