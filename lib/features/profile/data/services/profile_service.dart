import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileService {
  final SupabaseClient supabaseClient;

  ProfileService(this.supabaseClient);

  Future<ProfileModel> getProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil profil: $e');
    }
  }

  Future<ProfileModel> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Update profile di database
      final response = await supabaseClient
          .from('profiles')
          .update(data)
          .eq('id', userId)
          .select()
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memperbarui profil: $e');
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      // Update password via Supabase Auth
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Gagal mengubah password: $e');
    }
  }

  // Verify old password (optional, untuk keamanan)
  Future<bool> verifyPassword(String email, String password) async {
    try {
      // Coba login dengan password lama
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      return false;
    }
  }
}
