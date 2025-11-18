import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- BAGIAN INI YANG KURANG DI KODE KAMU ---
import '../../../../core/error/failures.dart'; // Import Failure
import '../../domain/entities/user_entity.dart'; // Import UserEntity
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
// -------------------------------------------

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthProvider({
    required this.loginUser,
    required this.registerUser,
  });

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  Failure? _failure;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  Failure? get failure => _failure;
  bool get isLoading => _status == AuthStatus.loading;

  // Setter state private
  void _setLoading() {
    _status = AuthStatus.loading;
    _failure = null;
    notifyListeners();
  }

  void _setAuthenticated(UserEntity user) {
    _status = AuthStatus.authenticated;
    _user = user;
    _failure = null;
    notifyListeners();
  }

  void _setError(Failure failure) {
    _status = AuthStatus.error;
    _failure = failure;
    notifyListeners();
  }

  // Fungsi Login
  Future<void> login(String email, String password) async {
    _setLoading();
    try {
      final result = await loginUser(email, password);
      _setAuthenticated(result);
    } on Failure catch (e) {
      _setError(e);
    } catch (e) {
      _setError(ServerFailure(message: e.toString()));
    }
  }

  // Fungsi Register (Perbaiki parameter agar sesuai UI)
  Future<void> register(
    String name,
    String email,
    String password,
    String noHp,
    String jenisKelamin,
    String tanggalLahir,
  ) async {
    _setLoading();
    try {
      final result = await registerUser(
        name, 
        email, 
        password, 
        noHp, 
        jenisKelamin, 
        tanggalLahir
      );
      _setAuthenticated(result);
    } on Failure catch (e) {
      _setError(e);
    } catch (e) {
      _setError(ServerFailure(message: e.toString()));
    }
  }

  void logout() {
    Supabase.instance.client.auth.signOut();
    _status = AuthStatus.unauthenticated;
    _user = null;
    notifyListeners();
  }
}