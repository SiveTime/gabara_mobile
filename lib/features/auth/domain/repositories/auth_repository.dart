import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(
    String name,
    String email,
    String password,
    String phone,
    String gender,
    String birthDate,
    String role,
  );
}
