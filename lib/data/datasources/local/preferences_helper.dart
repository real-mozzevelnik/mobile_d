import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/auth_model.dart';

class PreferencesHelper {
  static SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Auth preferences
  Future<void> setIsLoggedIn(bool isLoggedIn) async {
    await _preferences?.setBool('is_logged_in', isLoggedIn);
  }

  bool getIsLoggedIn() {
    return _preferences?.getBool('is_logged_in') ?? false;
  }

  Future<void> setAuthData(AuthModel authData) async {
    await _preferences?.setString('auth_data', json.encode(authData.toJson()));
  }

  AuthModel? getAuthData() {
    final authString = _preferences?.getString('auth_data');
    if (authString != null) {
      return AuthModel.fromJson(json.decode(authString));
    }
    return null;
  }

  Future<void> clearAuthData() async {
    await _preferences?.remove('auth_data');
    await _preferences?.remove('is_logged_in');
  }

  Future<void> clearAll() async {
    await _preferences?.clear();
  }
}
