import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- IMPORT BARU
import '../../../../core/error/failures.dart';
// ... (import lainnya sama)

// ... (enum AuthStatus sama)

class AuthProvider extends ChangeNotifier {
// ... (kode constructor, status, user, failure, dll sama) ...

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
    } on AuthException catch (e) { // <-- TANGANI ERROR SUPABASE
      _setError(AuthenticationFailure(message: e.message));
      return null;
    } on Failure catch (e) {
      _setError(e);
      return null;
    } catch (e) {
      _setError(ServerFailure(message: e.toString()));
      return null;
    }
  }

  Future<UserEntity?> register(
    String name,
    String email,
    String password,
    String noHp,
    String jenisKelamin,
    String tanggalLahir,
  ) async {
    try {
      // Validasi bisa dilakukan di sini
      if (name.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          noHp.isEmpty ||
          jenisKelamin.isEmpty || // <-- Seharusnya jenisKelamin != null
          tanggalLahir.isEmpty) {
        throw const ValidationFailure(
          message: 'Semua field harus diisi',
        );
      }
      _setLoading();
      _user = await registerUser(
        name,
        email,
        password,
        noHp,
        jenisKelamin,
        tanggalLahir,
      );
      _setAuthenticated(_user!);
      return _user;
    } on AuthException catch (e) { // <-- TANGANI ERROR SUPABASE
      _setError(AuthenticationFailure(message: e.message));
      return null;
    } on Failure catch (e) {
      _setError(e);
      return null;
    } catch (e) {
      _setError(ServerFailure(message: e.toString()));
      return null;
    }
  }

  void logout() {
// ... (kode logout sama) ...
  }
}