import 'dart:convert';
import '../datasources/local/preferences_helper.dart';
import '../datasources/remote/api_service.dart';
import '../models/auth_model.dart';

class AuthRepository {
  final PreferencesHelper preferences;
  final ApiService apiService;

  AuthRepository({
    required this.preferences,
    required this.apiService,
  });

  Future<AuthModel?> login(LoginRequest request) async {
    try {
      final authData = await apiService.login(request);

      // Save auth data to preferences
      await preferences.setAuthData(authData);
      await preferences.setIsLoggedIn(true);

      return authData;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<AuthModel?> register(RegisterRequest request) async {
    try {
      final authData = await apiService.register(request);

      // Save auth data to preferences
      await preferences.setAuthData(authData);
      await preferences.setIsLoggedIn(true);

      return authData;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> logout() async {
      await preferences.clearAuthData();
      await preferences.setIsLoggedIn(false);
  }

  Future<bool> isLoggedIn() async {
    return preferences.getIsLoggedIn();
  }

  Future<AuthModel?> getCurrentUser() async {
    if (await isLoggedIn()) {
      return preferences.getAuthData();
    }
    return null;
  }

}
