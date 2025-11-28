// lib/features/auth/data/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient supabaseClient;

  AuthService(this.supabaseClient);

  Future<UserModel> login(String email, String password) async {
    try {
      // 1. Login ke Auth Supabase
      final authResponse = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception('Login gagal: User tidak ditemukan');
      }

      // 2. AMBIL DATA PROFILE DARI TABEL PUBLIC (PENTING!)
      // Kita butuh 'full_name' yang up-to-date dari database
      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      // 3. AMBIL ROLE DARI user_roles JOIN roles
      final roleResponse = await supabaseClient
          .from('user_roles')
          .select('roles!inner(name)')
          .eq('user_id', user.id);

      String userRole = 'student'; // default
      if (roleResponse.isNotEmpty) {
        userRole = roleResponse[0]['roles']['name'];
      }

      // 4. Kembalikan UserModel lengkap dengan Role
      return UserModel(
        id: user.id,
        name:
            profileData['full_name'] ??
            user.userMetadata?['full_name'] ??
            'User',
        email: user.email ?? '',
        token: authResponse.session?.accessToken ?? '',
        role: userRole,
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login: $e');
    }
  }

  Future<UserModel> register(
    String name,
    String email,
    String password,
    String phone,
    String gender,
    String birthDate,
    String role,
  ) async {
    try {
      // 1. Daftar ke Auth Supabase
      // Data di 'data' akan masuk ke user_metadata dan diproses Trigger SQL
      // untuk masuk ke tabel profiles secara otomatis.
      final authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'phone': phone,
          'gender': gender,
          'birth_date': birthDate,
          'role': role,
        },
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception('Registrasi gagal');
      }

      // 2. Return UserModel
      return UserModel(
        id: user.id,
        name: name,
        email: user.email ?? '',
        token: authResponse.session?.accessToken ?? '',
        role: role,
      );
    } catch (e) {
      throw Exception('Gagal registrasi: $e');
    }
  }

  // Tambahan: Fitur Logout
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }

  // Tambahan: Cek User yang sedang login (untuk auto-login)
  User? getCurrentUser() {
    return supabaseClient.auth.currentUser;
  }
}
