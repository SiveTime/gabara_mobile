import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<UserEntity> call(
    String name,
    String email,
    String password,
    String phone,
    String gender,
    String birthDate,
    String role,
  ) {
    return repository.register(name, email, password, phone, gender, birthDate, role);
  }
}
