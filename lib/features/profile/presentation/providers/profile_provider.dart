import 'package:flutter/material.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/change_password.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfile getProfileUseCase;
  final UpdateProfile updateProfileUseCase;
  final ChangePassword changePasswordUseCase;

  ProfileProvider({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
  });

  ProfileEntity? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileEntity? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get Profile
  Future<bool> fetchProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await getProfileUseCase.call(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update Profile
  Future<bool> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await updateProfileUseCase.call(userId, data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Change Password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await changePasswordUseCase.call(oldPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
