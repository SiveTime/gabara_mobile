import 'package:supabase_flutter/supabase_flutter.dart'; // <-- IMPORT BARU
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';
// import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;

  AuthRepositoryImpl(this.authService);

  @override
  Future<UserEntity> login(String email, String password) async {
    // --- SELESAIKAN TODO LOGIN ---
    try {
      final userModel = await authService.login(email, password);
      // Konversi dari UserModel (Data) ke UserEntity (Domain)
      return UserEntity(
        id: userModel.id,
        name: userModel.name,
        email: userModel.email,
        token: userModel.token,
        role: userModel.role,
      );
    } on AuthException catch (e) {
      // Tangani error spesifik Supabase
      throw Exception('Login gagal: ${e.message}');
    } catch (e) {
      // Tangani error umum
      rethrow;
    }
    // -----------------------------
  }

  @override
  Future<UserEntity> register(
    String name,
    String email,
    String password,
    String phone,
    String gender,
    String birthDate,
    String role,
  ) async {
    // --- GANTI MOCK DENGAN API CALL ---
    try {
      final userModel = await authService.register(
        name,
        email,
        password,
        phone,
        gender,
        birthDate,
        role,
      );

      // Konversi dari UserModel (Data) ke UserEntity (Domain)
      return UserEntity(
        id: userModel.id,
        name: userModel.name,
        email: userModel.email,
        token: userModel.token,
        role: userModel.role,
      );
    } on AuthException catch (e) {
      // Tangani error spesifik Supabase
      throw Exception('Registrasi gagal: ${e.message}');
    } catch (e) {
      // Tangani error umum
      rethrow;
    }
    // --------------------------------
  }
}
