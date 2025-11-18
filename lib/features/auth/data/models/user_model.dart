import '../../domain/entities/user_entity.dart';

// UserModel sekarang mewakili data di tabel 'profiles'
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Konversi JSON dari Supabase (tabel 'profiles') ke UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      // Memetakan 'full_name' dari DB ke 'name' di model
      name: json['full_name'] ?? '', 
      email: json['email'] ?? '', // Sebaiknya email juga disimpan di profil
      role: json['role'] ?? 'siswa', // Default ke 'siswa' jika tidak ada
    );
  }

  // Konversi UserModel ke JSON untuk dikirim ke Supabase (saat mendaftar)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Memetakan 'name' dari model ke 'full_name' di DB
      'full_name': name, 
      'email': email,
      'role': role,
    };
  }

  // Helper untuk mengonversi Model (data) ke Entity (domain)
  // Token didapat dari Auth, bukan dari tabel 'profiles'
  UserEntity toEntity(String token) {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      token: token,
    );
  }
}