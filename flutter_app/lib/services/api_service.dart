import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/app_constants.dart';

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _accessToken;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String?> getAccessToken() async {
    if (_accessToken == null) {
      _accessToken = await _storage.read(key: AppConstants.accessTokenKey);
    }
    return _accessToken;
  }

  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await http.get(
        url,
        headers: await _getHeaders(includeAuth: requiresAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await http.post(
        url,
        headers: await _getHeaders(includeAuth: requiresAuth),
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await http.put(
        url,
        headers: await _getHeaders(includeAuth: requiresAuth),
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await http.patch(
        url,
        headers: await _getHeaders(includeAuth: requiresAuth),
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await http.delete(
        url,
        headers: await _getHeaders(includeAuth: requiresAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, try to refresh
      _refreshToken();
      throw Exception('Unauthorized');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? error['detail'] ?? 'Request failed');
    }
  }

  Future<void> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await post(
        AppConstants.refreshTokenEndpoint,
        {'refresh': refreshToken},
        requiresAuth: false,
      );

      await setAccessToken(response['access']);
    } catch (e) {
      await clearTokens();
      throw Exception('Session expired');
    }
  }
}
