import '../repositories/profile_repository.dart';

class ChangePassword {
  final ProfileRepository repository;

  ChangePassword(this.repository);

  Future<void> call(String oldPassword, String newPassword) {
    return repository.changePassword(oldPassword, newPassword);
  }
}
