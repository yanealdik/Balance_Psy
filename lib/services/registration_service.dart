import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class RegistrationService {
  final Dio _dio = ApiClient.instance;

  /// Отправить код верификации на email
  Future<void> sendVerificationCode(
    String email, {
    bool isParentEmail = false,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sendCode,
        data: {'email': email, 'isParentEmail': isParentEmail},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to send code');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to send code');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Проверить код верификации
  Future<bool> verifyCode(
    String email,
    String code, {
    bool isParentEmail = false,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyCode,
        data: {'email': email, 'code': code, 'isParentEmail': isParentEmail},
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Invalid code');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Регистрация пользователя
  ///
  /// Принимает данные из RegistrationProvider и отправляет на backend
  Future<UserModel> register(Map<String, dynamic> data) async {
    try {
      // Форматируем дату рождения
      if (data['dateOfBirth'] is DateTime) {
        data['dateOfBirth'] = (data['dateOfBirth'] as DateTime)
            .toIso8601String()
            .split('T')[0];
      }

      data.removeWhere((key, value) => value == null);

      print('📤 Registration request: ${data.keys}');

      // 🔥 ИЗМЕНЕНО: Определяем endpoint в зависимости от роли
      final endpoint = data.containsKey('specialization')
          ? '/api/auth/register/psychologist' // Психолог
          : '/api/auth/register/client'; // Клиент

      print('🎯 Using endpoint: $endpoint');

      final response = await _dio.post(endpoint, data: data);

      print('📥 Registration response: ${response.statusCode}');

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      print('❌ Registration error: ${e.response?.data}');

      if (e.response?.data != null) {
        final message = e.response!.data['message'] ?? 'Registration failed';
        throw Exception(message);
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Check your internet.');
      }

      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
}
