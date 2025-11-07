import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient.instance;

  // Логин
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        final loginResponse = LoginResponse.fromJson(response.data['data']);

        // Сохраняем токен
        await TokenStorage.saveToken(loginResponse.token);
        await TokenStorage.saveEmail(email);

        return loginResponse;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Login failed');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Логаут
  Future<void> logout() async {
    await TokenStorage.clearAll();
  }

  // Проверка авторизации
  Future<bool> isAuthenticated() async {
    return await TokenStorage.hasToken();
  }

  // Получить текущего пользователя
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
