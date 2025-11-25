import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class UserService {
  final Dio _dio = ApiClient.instance;

  // Получить профиль
  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.userMe);

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load profile');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  // Обновить профиль
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    List<String>? interests,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['fullName'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth;
      if (gender != null) data['gender'] = gender;
      if (interests != null) data['interests'] = interests;

      final response = await _dio.put(ApiEndpoints.userMe, data: data);

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Update failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Update failed');
    }
  }

  // Сменить пароль
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.userPassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Password change failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Password change failed');
    }
  }

  Future<Map<String, dynamic>?> checkOrCreateClient({
    required String phoneNumber,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/users/check-or-create-client',
        data: {'phoneNumber': phoneNumber, 'fullName': fullName},
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error checking/creating client: $e');
      return null;
    }
  }
}
