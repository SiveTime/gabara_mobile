import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../services/profile_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService profileService;

  ProfileRepositoryImpl(this.profileService);

  @override
  Future<ProfileEntity> getProfile(String userId) async {
    try {
      final profileModel = await profileService.getProfile(userId);
      return profileModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProfileEntity> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final profileModel = await profileService.updateProfile(userId, data);
      return profileModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      // Note: Verifikasi old password dilakukan di provider/UI layer
      await profileService.changePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }
}
