import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthRemoteDataSource(this._apiClient)
      : _secureStorage = const FlutterSecureStorage();

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final user = UserModel.fromJson(response.data);
      await _saveToken(user.token ?? '');
      await _saveUser(user);
      return user;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString() ?? 'Login failed'
          : 'Login failed';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } on DioException {
      // Ignore logout errors
    }
    await clearToken();
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _apiClient.dio.get('/users/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString() ?? 'Failed to get user'
          : 'Failed to get user';
      throw Exception(message);
    }
  }

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> _saveUser(UserModel user) async {
    await _secureStorage.write(key: AppConstants.roleKey, value: user.role);
    await _secureStorage.write(key: AppConstants.userKey, value: user.name);
  }

  Future<String?> getSavedRole() async {
    return await _secureStorage.read(key: AppConstants.roleKey);
  }

  Future<String?> getSavedUserName() async {
    return await _secureStorage.read(key: AppConstants.userKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.deleteAll();
  }
}
