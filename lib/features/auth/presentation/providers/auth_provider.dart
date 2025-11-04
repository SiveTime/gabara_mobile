import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

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

  void _setLoading() {
    _status = AuthStatus.loading;
    _failure = null;
    notifyListeners();
  }

  void _setError(Failure failure) {
    _status = AuthStatus.error;
    _failure = failure;
    notifyListeners();
  }

  void _setAuthenticated(UserEntity user) {
    _status = AuthStatus.authenticated;
    _user = user;
    _failure = null;
    notifyListeners();
  }

  Future<UserEntity?> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw const ValidationFailure(
          message: 'Email dan password harus diisi',
        );
      }
      _setLoading();
      _user = await loginUser(email, password);
      _setAuthenticated(_user!);
      return _user;
    } on Failure catch (e) {
      _setError(e);
      return null;
    } catch (e) {
      _setError(ServerFailure(message: e.toString()));
      return null;
    }
  }

  Future<UserEntity?> register(String name, String email, String password) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw const ValidationFailure(
          message: 'Semua field harus diisi',
        );
      }
      _setLoading();
      _user = await registerUser(name, email, password);
      _setAuthenticated(_user!);
      return _user;
    } on Failure catch (e) {
      _setError(e);
      return null;
    } catch (e) {
      _setError(ServerFailure(message: e.toString()));
      return null;
    }
  }

  void logout() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
