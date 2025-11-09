import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../core/app_constants.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String _currentLanguage = 'ar'; // Default to Arabic for Egypt

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentLanguage => _currentLanguage;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      await _apiService.setAccessToken(response['access']);
      await _apiService.setRefreshToken(response['refresh']);

      _currentUser = UserModel.fromJson(response['user']);
      _currentLanguage = _currentUser!.preferredLanguage;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.post(
        AppConstants.registerEndpoint,
        userData,
        requiresAuth: false,
      );

      await _apiService.setAccessToken(response['tokens']['access']);
      await _apiService.setRefreshToken(response['tokens']['refresh']);

      _currentUser = UserModel.fromJson(response['user']);
      _currentLanguage = _currentUser!.preferredLanguage;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _apiService.clearTokens();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.patch('/auth/users/me/', data);
      _currentUser = UserModel.fromJson(response);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final token = await _apiService.getAccessToken();
    if (token != null) {
      try {
        final response = await _apiService.get('/auth/users/me/');
        _currentUser = UserModel.fromJson(response);
        _currentLanguage = _currentUser!.preferredLanguage;
        _isAuthenticated = true;
        notifyListeners();
      } catch (e) {
        _isAuthenticated = false;
        notifyListeners();
      }
    }
  }
}
