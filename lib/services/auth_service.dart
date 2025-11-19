import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';
import '../models/profile_response.dart';

class AuthService {
  final Dio _dio = ApiClient.instance;

  /// ✅ Регистрация клиента
  Future<UserModel> registerClient(Map<String, dynamic> data) async {
    try {
      print('📤 Registering CLIENT: ${data['email']}');

      final response = await _dio.post('/api/auth/register/client', data: data);

      print('✅ Client registered: ${response.statusCode}');

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      print('❌ Client registration error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to register client',
      );
    }
  }

  /// ✅ Регистрация психолога
  Future<UserModel> registerPsychologist(Map<String, dynamic> data) async {
    try {
      print('📤 Registering PSYCHOLOGIST: ${data['email']}');

      final response = await _dio.post(
        '/api/auth/register/psychologist',
        data: data,
      );

      print('✅ Psychologist registered: ${response.statusCode}');

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      print('❌ Psychologist registration error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to register psychologist',
      );
    }
  }

  /// ✅ Логин (для CLIENT и PSYCHOLOGIST)
  Future<LoginResponse> login(String email, String password) async {
    try {
      print('🔵 Logging in: $email');

      final response = await _dio.post(
        ApiEndpoints.login, // '/api/auth/login'
        data: {'email': email, 'password': password},
      );

      print('✅ Login response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final loginResponse = LoginResponse.fromJson(response.data['data']);

        // Сохраняем токен
        await TokenStorage.saveToken(loginResponse.token);
        await TokenStorage.saveEmail(email);

        print('🎉 Login successful, token saved');
        return loginResponse;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      print('❌ Login error: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to login');
    }
  }

  /// ✅ Получить расширенный профиль (с psychologistProfile для PSYCHOLOGIST)
  Future<ProfileResponse> getProfile() async {
    try {
      print('🔵 Getting profile...');

      final response = await _dio.get('/api/auth/profile/me');

      print('✅ Profile response: ${response.statusCode}');

      if (response.data['success'] == true) {
        return ProfileResponse.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load profile');
      }
    } on DioException catch (e) {
      print('❌ Profile error: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to load profile');
    }
  }

  /// Логаут
  Future<void> logout() async {
    await TokenStorage.clearAll();
  }

  /// Проверка авторизации
  Future<bool> isAuthenticated() async {
    return await TokenStorage.hasToken();
  }

  /// Получить текущего пользователя (простая версия без psychologistProfile)
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiEndpoints.userMe);

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load user');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load user');
    }
  }
}
