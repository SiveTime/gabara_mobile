// lib/features/auth/domain/usecases/forgot_password.dart

import '../repositories/auth_repository.dart';

class ForgotPassword {
  final AuthRepository repository;

  ForgotPassword(this.repository);

  Future<void> call(String email) async {
    return await repository.sendPasswordResetEmail(email);
  }
}
