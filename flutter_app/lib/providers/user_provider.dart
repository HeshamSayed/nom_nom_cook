import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<UserModel> _followers = [];
  List<UserModel> _following = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get followers => _followers;
  List<UserModel> get following => _following;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch user's followers
  Future<void> fetchFollowers(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.get('/auth/users/$userId/followers/');
      _followers = (data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching followers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch users the current user is following
  Future<void> fetchFollowing(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.get('/auth/users/$userId/following/');
      _following = (data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching following: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Follow a user
  Future<bool> followUser(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.post('/social/follows/', {
        'followed_user_id': userId,
      });

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error following user: $e');
      return false;
    }
  }

  // Unfollow a user
  Future<bool> unfollowUser(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.delete('/social/follows/$userId/');

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error unfollowing user: $e');
      return false;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(int userId) async {
    try {
      final data = await _apiService.get('/auth/users/$userId/', requiresAuth: false);
      return UserModel.fromJson(data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
