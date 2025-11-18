import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart'; // Import UserModel

class AuthRepositoryImpl implements AuthRepository {
  // Dapatkan Supabase client instance
  final _supabase = Supabase.instance.client;

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      // 1. Login pengguna
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      final session = authResponse.session;

      if (user == null || session == null) {
        throw Exception('Login gagal: User atau Sesi tidak ditemukan.');
      }

      // 2. Ambil data profil dari tabel 'profiles'
      final profileData = await _supabase
          .from('profiles')
          .select() // Ambil semua data profil
          .eq('id', user.id) // Filter berdasarkan ID pengguna
          .single(); // Ambil satu baris

      // 3. Konversi JSON ke UserModel
      final userModel = UserModel.fromJson(profileData);

      // 4. Konversi UserModel ke UserEntity dengan token
      return userModel.toEntity(session.accessToken);
    } on AuthException catch (e) {
      // Tangani error spesifik Supabase Auth
      throw Exception('Error Login: ${e.message}');
    } catch (e) {
      // Tangani error umum (misal: profil tidak ditemukan)
      throw Exception('Error: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> register(String name, String email, String password) async {
    try {
      // 1. Daftarkan pengguna baru
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      final session = authResponse.session;

      // --- PERUBAHAN LOGIKA ---
      // Kita hanya butuh 'user' untuk dibuat, 'session' bisa null
      // jika konfirmasi email diperlukan.
      if (user == null) {
        // Jika user-nya sendiri null, berarti ada masalah
        throw Exception('Registrasi gagal: User tidak dibuat.');
      }
      // --- AKHIR PERUBAHAN ---

      // 2. Buat UserModel untuk data profil
      final userModel = UserModel(
        id: user.id,
        name: name,
        email: email,
        role: 'siswa', // Default role saat registrasi
      );

      // 3. Simpan data profil ke tabel 'profiles'
      await _supabase
        .from('profiles')
        .insert(userModel.toJson()); // -> userModel.toJson() mengirim 'id' sebagai UUID// Gunakan toJson()

      // 4. Kembalikan UserEntity
      // Jika sesi null (perlu konfirmasi), token akan 'null' atau dummy.
      // UI Anda harus memeriksa ini.
      return userModel.toEntity(session?.accessToken ?? 'KONFIRMASI_EMAIL_DIPERLUKAN');
    } on AuthException catch (e) {
      // Tangani error spesifik Supabase Auth (misal: pengguna sudah ada)
      throw Exception('Error Registrasi: ${e.message}');
    } catch (e) {
      // Tangani error umum
      throw Exception('Error: ${e.toString()}');
    }
  }

  // --- TAMBAHAN UNTUK FUNGSI ADMIN ---

  // Fungsi ini HANYA boleh dipanggil oleh pengguna yang rolenya ADMIN
  // Keamanan di-handle oleh RLS di Supabase
  Future<void> updateUserRole(String userIdToUpdate, String newRole) async {
    try {
      await _supabase
          .from('profiles')
          .update({'role': newRole}) // Data yang di-update
          .eq('id', userIdToUpdate); // Target user

      print('Sukses update role untuk user $userIdToUpdate menjadi $newRole');

    } on PostgrestException catch (e) {
      // Error ini akan muncul jika RLS memblokir (misal: "siswa" mencoba update)
      throw Exception('Update role gagal (RLS): ${e.message}');
    } catch (e) {
      throw Exception('Update role gagal: ${e.toString()}');
    }
  }
}