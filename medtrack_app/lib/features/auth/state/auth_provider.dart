import 'package:flutter/foundation.dart';
import '../../../core/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api;
  String? token;
  bool isLoading = false;

  AuthProvider(this.api);

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      token = await api.login(email, password);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    token = null;
    await api.clearToken();
    notifyListeners();
  }

  Future<void> restoreSession() async {
    token = await api.getToken();
    notifyListeners();
  }
}
