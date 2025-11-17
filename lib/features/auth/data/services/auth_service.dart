import 'package:supabase_flutter/supabase_flutter.dart'; // <-- IMPORT BARU
import '../models/user_model.dart';

class AuthService {
  // Ganti ApiClient menjadi SupabaseClient
  final SupabaseClient supabaseClient;

  AuthService(this.supabaseClient);

  Future<UserModel> login(String email, String password) async {
    // Gunakan Supabase auth
    final authResponse = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    final user = authResponse.user;
    if (user == null) {
      throw Exception('Login gagal: User tidak ditemukan');
    }

    // Buat UserModel (ini bisa disesuaikan jika Anda menyimpan data 'name' di tabel 'profiles')
    return UserModel(
      id: user.id,
      name: user.userMetadata?['name'] ?? 'User', // Ambil nama dari metadata jika ada
      email: user.email ?? '',
      token: authResponse.session?.accessToken ?? '', // Ambil token dari session
    );
  }

  Future<UserModel> register(
    String name,
    String email,
    String password,
    String noHp,
    String jenisKelamin,
    String tanggalLahir,
  ) async {
    // Gunakan Supabase auth signUp
    final authResponse = await supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name, // Kirim data tambahan (pastikan ini sesuai setup Supabase Anda)
        'phone': noHp,
        'gender': jenisKelamin,
        'birth_date': tanggalLahir,
      },
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('Registrasi gagal');
    }
    
    // Buat UserModel
    return UserModel(
      id: user.id,
      name: user.userMetadata?['full_name'] ?? name, // Ambil nama dari metadata
      email: user.email ?? '',
      token: authResponse.session?.accessToken ?? '', // Ambil token dari session
    );
  }
}