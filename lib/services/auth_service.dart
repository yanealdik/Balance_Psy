import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient.instance;

  // ✅ Правильный POST-запрос для логина
  Future<LoginResponse> login(String email, String password) async {
    try {
      print(
        '🔵 Отправка запроса на: ${AppConstants.baseUrl}${ApiEndpoints.login}',
      );
      print('📧 Email: $email');

      // ✅ КРИТИЧЕСКИ ВАЖНО: используем POST, не GET!
      final response = await _dio.post(
        ApiEndpoints.login, // '/api/auth/login'
        data: {'email': email, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            // Позволяем обработку даже неуспешных статусов
            return status != null && status < 500;
          },
        ),
      );

      print('✅ Ответ сервера: ${response.statusCode}');
      print('📦 Данные: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final loginResponse = LoginResponse.fromJson(response.data['data']);

        // Сохраняем токен
        await TokenStorage.saveToken(loginResponse.token);
        await TokenStorage.saveEmail(email);

        print('🎉 Логин успешен, токен сохранен');
        return loginResponse;
      } else {
        final errorMessage = response.data['message'] ?? 'Login failed';
        print('❌ Ошибка логина: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('❌ Статус: ${e.response?.statusCode}');
      print('❌ Сообщение: ${e.message}');
      print('❌ Данные ответа: ${e.response?.data}');

      if (e.response?.statusCode == 405) {
        throw Exception(
          'Метод не поддерживается. Проверьте, что используется POST.',
        );
      }

      if (e.response?.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Login failed');
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Тайм-аут соединения. Проверьте IP-адрес сервера.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Не удается подключиться к серверу. Проверьте:\n'
          '1. IP-адрес: ${AppConstants.baseUrl}\n'
          '2. Spring Boot запущен?\n'
          '3. iPhone и Mac в одной Wi-Fi сети?',
        );
      }

      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Неизвестная ошибка: $e');
      throw Exception('Unexpected error: $e');
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
