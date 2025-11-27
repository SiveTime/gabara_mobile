import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<ProfileEntity> call(String userId, Map<String, dynamic> data) {
    return repository.updateProfile(userId, data);
  }
}
