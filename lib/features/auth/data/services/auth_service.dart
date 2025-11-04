import 'package:gabara_mobile/core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<UserModel> login(String email, String password) async {
    final response = await apiClient.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(response);
  }

  Future<UserModel> register(String name, String email, String password) async {
    final response = await apiClient.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(response);
  }
}
