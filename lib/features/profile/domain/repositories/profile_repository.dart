import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile(String userId);
  Future<ProfileEntity> updateProfile(String userId, Map<String, dynamic> data);
  Future<void> changePassword(String oldPassword, String newPassword);
}
