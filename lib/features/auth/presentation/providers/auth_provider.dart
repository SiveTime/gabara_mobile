import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthProvider({required this.loginUser, required this.registerUser});

  UserEntity? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _user != null;

  // Fungsi Login (DIPERBAIKI)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // KOREKSI: Langsung kirim email & password, tanpa LoginParams
      final result = await loginUser.call(email, password);

      _user = result;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fungsi Register (DIPERBAIKI)
  Future<bool> register(
    String name,
    String email,
    String password,
    String role, 
    String phone, 
    String gender,
    String birthDate,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // KOREKSI: Langsung kirim semua argumen berurutan, tanpa RegisterParams
      final result = await registerUser.call(
        name,
        email,
        password,
        role, 
        phone, 
        gender,
        birthDate,
      );

      _user = result;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _user = null;
    notifyListeners();
  }
}
