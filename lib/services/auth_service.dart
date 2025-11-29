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

      final requestData = {
        'email': data['email'],
        'password': data['password'],
        'passwordRepeat': data['password'],
        'fullName': data['fullName'],
        'dateOfBirth': data['dateOfBirth'],
        'phone': data['phone'],
        'gender': data['gender'],
        'specialization': data['specialization'],
        'experienceYears': data['experienceYears'],
        'education': data['education'],
        'bio': data['bio'],
        'approaches': (data['approaches'] as Set).toList(),
        'hourlyRate': data['sessionPrice'],
      };

      final response = await _dio.post(
        '/api/auth/register/psychologist',
        data: requestData,
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
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      print('✅ Login response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final loginResponse = LoginResponse.fromJson(response.data['data']);

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

  /// ✅ ИСПРАВЛЕНО: Получить расширенный профиль через /api/profile/me
  Future<ProfileResponse> getProfile() async {
    try {
      print('🔵 Getting profile...');

      final response = await _dio.get('/api/profile/me');

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

  Future<void> logout() async {
    await TokenStorage.clearAll();
  }

  /// Получить сохраненный JWT-токен
  Future<String?> getToken() {
    return TokenStorage.getToken();
  }

  Future<bool> isAuthenticated() async {
    return await TokenStorage.hasToken();
  }

  /// ✅ ИСПРАВЛЕНО: getCurrentUser теперь вызывает getProfile
  Future<UserModel> getCurrentUser() async {
    try {
      final profile = await getProfile();

      // ✅ ИСПРАВЛЕНО: Проверка и корректировка avatarUrl
      String? avatarUrl = profile.avatarUrl;
      if (avatarUrl != null && !avatarUrl.startsWith('http')) {
        // Если это просто UUID, добавляем базовый URL
        avatarUrl = 'http://localhost:8055/assets/$avatarUrl';
        print('⚠️ Fixed avatar URL: $avatarUrl');
      }

      // Конвертируем ProfileResponse в UserModel
      return UserModel(
        userId: profile.userId,
        email: profile.email,
        fullName: profile.fullName,
        phone: profile.phone,
        dateOfBirth: profile.dateOfBirth,
        avatarUrl: avatarUrl,
        role: profile.role,
        gender: profile.gender,
        interests: profile.interests?.toSet(),
        registrationGoal: profile.registrationGoal,
        isActive: profile.isActive,
        emailVerified: profile.emailVerified,
      );
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }
}
