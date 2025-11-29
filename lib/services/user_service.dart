import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/client_search_result.dart';

/// Сервис для работы с пользователями
class UserService {
  final Dio _dio = ApiClient.instance;

  /// Поиск клиента по номеру телефона
  ///
  /// Возвращает данные клиента если найден, null если не найден
  /// Выбрасывает Exception при ошибке сервера
  Future<ClientSearchResult?> searchClientByPhone(String phone) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
      print('🔍 Searching client by phone: $cleanPhone');

      final response = await _dio.get(
        '/api/users/search',
        queryParameters: {'phone': cleanPhone},
      );

      print('✅ Client search response: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      // ✅ ИСПРАВЛЕНО: Проверяем структуру ответа
      if (response.statusCode == 200) {
        if (response.data != null && response.data['success'] == true) {
          final userData = response.data['data'];

          if (userData != null) {
            return ClientSearchResult.fromJson(userData);
          }
        }

        print('ℹ️ Client not found in response');
        return null;
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('ℹ️ Client not found (404)');
        return null;
      }

      print('❌ Error searching client: ${e.message}');

      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Ошибка поиска клиента');
      }

      throw Exception('Ошибка соединения с сервером');
    }
  }

  /// Получить информацию о текущем пользователе
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/api/users/me');

      if (response.statusCode == 200) {
        return response.data;
      }

      throw Exception('Не удалось загрузить данные пользователя');
    } on DioException catch (e) {
      print('❌ Error getting current user: ${e.message}');

      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Ошибка загрузки данных',
        );
      }

      throw Exception('Ошибка соединения с сервером');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    try {
      print('📝 Updating profile: fullName=$fullName, phone=$phone');

      final requestData = <String, dynamic>{'fullName': fullName};

      // Добавляем телефон только если он не пустой
      if (phone != null && phone.isNotEmpty) {
        requestData['phone'] = phone;
      }

      final response = await _dio.put('/api/users/me', data: requestData);

      print('✅ Profile updated: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.data;
      }

      throw Exception('Не удалось обновить профиль');
    } on DioException catch (e) {
      print('❌ Error updating profile: ${e.message}');

      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');

        // Обработка различных ошибок
        if (e.response!.statusCode == 400) {
          final errorData = e.response!.data;
          if (errorData is Map && errorData.containsKey('message')) {
            throw Exception(errorData['message']);
          }
          throw Exception('Некорректные данные профиля');
        } else if (e.response!.statusCode == 401) {
          throw Exception('Требуется авторизация');
        } else if (e.response!.statusCode == 409) {
          throw Exception('Телефон уже используется другим пользователем');
        }

        throw Exception(
          e.response?.data['message'] ?? 'Ошибка обновления профиля',
        );
      }

      throw Exception('Ошибка соединения с сервером');
    } catch (e) {
      print('❌ Unexpected error updating profile: $e');
      throw Exception('Произошла ошибка при обновлении профиля');
    }
  }

  Future getProfile() async {}
}
