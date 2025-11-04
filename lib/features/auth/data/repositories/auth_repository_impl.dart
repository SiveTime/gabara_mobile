import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserEntity> login(String email, String password) async {
    // TODO: Implement actual login with API
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return UserEntity(
      id: '1',
      name: 'Test User',
      email: email,
      token: 'dummy_token',
    );
  }

  @override
  Future<UserEntity> register(String name, String email, String password) async {
    // TODO: Implement actual registration with API
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return UserEntity(
      id: '1',
      name: name,
      email: email,
      token: 'dummy_token',
    );
  }
}