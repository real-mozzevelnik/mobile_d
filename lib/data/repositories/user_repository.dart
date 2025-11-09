import 'package:mobile_d/data/models/auth_model.dart';

import '../datasources/local/preferences_helper.dart';
import '../datasources/remote/api_service.dart';

class UserRepository {
  final PreferencesHelper preferences;
  final ApiService apiService;

  UserRepository({
    required this.preferences,
    required this.apiService,
  });

  AuthModel getUserProfile() {
    return preferences.getAuthData()!;
  }


  double getBudgetLimit() {
    return getUserProfile().budgetLimit;
  }

  Future<void> setBudgetLimit(double limit) async {
    Map<String, dynamic> user = getUserProfile().toJson();
    user['budgetLimit'] = limit;
    preferences.setAuthData(AuthModel.fromJson(user));
    await apiService.updateBudgetLimit(getUserProfile().userId, limit);
  }

  Future<int> getUserId() async {
    return preferences.getAuthData()?.userId ?? -1;
  }
}
