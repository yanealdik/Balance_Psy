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
  Future<UserModel> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.register, data: data);

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Registration failed');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
