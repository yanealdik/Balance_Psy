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

  /// ✅ Регистрация психолога (С ДЕТАЛЬНОЙ ОТЛАДКОЙ)
  Future<UserModel> registerPsychologist(Map<String, dynamic> data) async {
    try {
      print('📤 Registering PSYCHOLOGIST: ${data['email']}');
      print('📋 Full data received:');
      print('  - email: ${data['email']}');
      print('  - fullName: ${data['fullName']}');
      print(
        '  - dateOfBirth: ${data['dateOfBirth']} (${data['dateOfBirth'].runtimeType})',
      );
      print('  - phone: ${data['phone']}');
      print('  - gender: ${data['gender']}');
      print('  - specialization: ${data['specialization']}');
      print(
        '  - experienceYears: ${data['experienceYears']} (${data['experienceYears'].runtimeType})',
      );
      print('  - education length: ${data['education']?.toString().length}');
      print('  - bio length: ${data['bio']?.toString().length}');
      print(
        '  - approaches: ${data['approaches']} (${data['approaches'].runtimeType})',
      );
      print(
        '  - sessionPrice: ${data['sessionPrice']} (${data['sessionPrice'].runtimeType})',
      );

      // ✅ ИСПРАВЛЕНО: Преобразуем данные в правильный формат
      final requestData = {
        'email': data['email'],
        'password': data['password'],
        'passwordRepeat': data['password'],
        'fullName': data['fullName'],
        'dateOfBirth': data['dateOfBirth'], // Уже в формате "YYYY-MM-DD"
        'phone': data['phone'],
        'gender': data['gender'],
        'specialization': data['specialization'],
        'experienceYears': data['experienceYears'],
        'education': data['education'],
        'bio': data['bio'],
        'approaches': (data['approaches'] as Set)
            .toList(), // ✅ Преобразуем Set -> List
        'hourlyRate': data['sessionPrice'], // ✅ Отправляем как число
      };

      print('📦 Prepared request data:');
      print('  - dateOfBirth: ${requestData['dateOfBirth']}');
      print('  - experienceYears: ${requestData['experienceYears']}');
      print('  - approaches: ${requestData['approaches']}');
      print('  - hourlyRate: ${requestData['hourlyRate']}');

      final response = await _dio.post(
        '/api/auth/register/psychologist',
        data: requestData,
      );

      print('✅ Psychologist registered: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      print('❌ Psychologist registration error:');
      print('   Status code: ${e.response?.statusCode}');
      print('   Response data: ${e.response?.data}');
      print('   Message: ${e.message}');

      // ✅ УЛУЧШЕНО: Извлекаем детальное сообщение об ошибке
      String errorMessage = 'Failed to register psychologist';

      if (e.response?.data != null) {
        try {
          if (e.response!.data is Map) {
            final data = e.response!.data as Map<String, dynamic>;

            // Ищем сообщение об ошибке в разных полях
            if (data['message'] != null) {
              errorMessage = data['message'];
            } else if (data['error'] != null) {
              errorMessage = data['error'];
            } else if (data['errors'] != null) {
              errorMessage = data['errors'].toString();
            }
          } else {
            errorMessage = e.response!.data.toString();
          }
        } catch (parseError) {
          print('⚠️ Error parsing error response: $parseError');
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      print('🔴 Final error message: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Unexpected error: ${e.toString()}');
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

  /// ✅ Получить расширенный профиль
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
