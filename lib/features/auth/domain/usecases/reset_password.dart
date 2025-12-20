// lib/features/auth/domain/usecases/reset_password.dart

import '../repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  Future<void> call(String accessToken, String newPassword) async {
    return await repository.resetPassword(accessToken, newPassword);
  }
}
