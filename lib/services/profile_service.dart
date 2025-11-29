import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../core/api/api_client.dart';
import '../models/user_model.dart';

/// Unified Profile Service for both CLIENT and PSYCHOLOGIST roles
class ProfileService {
  final Dio _dio = ApiClient.instance;

  /// Get current user profile (works for both roles)
  Future<Map<String, dynamic>> getProfile() async {
    try {
      print('🔵 Getting profile...');

      final response = await _dio.get('/api/profile/me');

      print('✅ Profile response: ${response.statusCode}');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load profile');
      }
    } on DioException catch (e) {
      print('❌ Profile error: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to load profile');
    }
  }

  /// Update profile (works for both roles)
  Future<UserModel> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    try {
      print('📝 Updating profile: fullName=$fullName, phone=$phone');

      final requestData = <String, dynamic>{'fullName': fullName};

      if (phone != null && phone.isNotEmpty) {
        requestData['phone'] = phone;
      }

      final response = await _dio.put('/api/profile/me', data: requestData);

      print('✅ Profile updated: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final profileData = response.data['data'];

        // ✅ ИСПРАВЛЕНО: Правильная обработка dateOfBirth
        DateTime? dateOfBirth;
        if (profileData['dateOfBirth'] != null) {
          if (profileData['dateOfBirth'] is String) {
            dateOfBirth = DateTime.parse(profileData['dateOfBirth']);
          } else if (profileData['dateOfBirth'] is List) {
            // Формат [year, month, day]
            final parts = profileData['dateOfBirth'] as List;
            dateOfBirth = DateTime(parts[0], parts[1], parts[2]);
          }
        }

        // ✅ ИСПРАВЛЕНО: Проверка и корректировка avatarUrl
        String? avatarUrl = profileData['avatarUrl'];
        if (avatarUrl != null && !avatarUrl.startsWith('http')) {
          // Если это просто UUID, добавляем базовый URL
          avatarUrl = 'http://localhost:8055/assets/$avatarUrl';
          print('⚠️ Fixed avatar URL: $avatarUrl');
        }

        return UserModel(
          userId: profileData['userId'],
          email: profileData['email'],
          fullName: profileData['fullName'],
          phone: profileData['phone'],
          dateOfBirth: dateOfBirth,
          avatarUrl: avatarUrl,
          role: profileData['role'],
          gender: profileData['gender'],
          interests: profileData['interests'] != null
              ? Set<String>.from(profileData['interests'])
              : null,
          registrationGoal: profileData['registrationGoal'],
          isActive: profileData['isActive'],
          emailVerified: profileData['emailVerified'],
        );
      }

      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      print('❌ Error updating profile: ${e.message}');

      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');

        if (e.response!.statusCode == 400) {
          final errorData = e.response!.data;
          if (errorData is Map && errorData.containsKey('message')) {
            throw Exception(errorData['message']);
          }
          throw Exception('Некорректные данные профиля');
        } else if (e.response!.statusCode == 401) {
          throw Exception('Требуется авторизация');
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

  /// Upload avatar (Directus URL)
  Future<String> uploadAvatar(File file) async {
    try {
      print('📸 Uploading avatar...');

      // Prepare multipart file
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType('image', fileName.split('.').last),
        ),
      });

      final response = await _dio.post(
        '/api/profile/me/avatar',
        data: formData,
      );

      print('✅ Avatar uploaded: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final avatarUrl = response.data['data']['avatarUrl'];
        print('✅ Avatar URL: $avatarUrl');
        return avatarUrl;
      }

      throw Exception('Failed to upload avatar');
    } on DioException catch (e) {
      print('❌ Error uploading avatar: ${e.message}');
      print('❌ Response: ${e.response?.data}');

      if (e.response != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }

      throw Exception('Ошибка загрузки аватара');
    } catch (e) {
      print('❌ Unexpected error uploading avatar: $e');
      throw Exception('Произошла ошибка при загрузке аватара');
    }
  }

  /// Delete avatar
  Future<void> deleteAvatar() async {
    try {
      print('🗑️ Deleting avatar...');

      final response = await _dio.delete('/api/profile/me/avatar');

      print('✅ Avatar deleted: ${response.statusCode}');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception('Failed to delete avatar');
      }
    } on DioException catch (e) {
      print('❌ Error deleting avatar: ${e.message}');

      if (e.response != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }

      throw Exception('Ошибка удаления аватара');
    } catch (e) {
      print('❌ Unexpected error deleting avatar: $e');
      throw Exception('Произошла ошибка при удалении аватара');
    }
  }

  /// Update psychologist availability (PSYCHOLOGIST only)
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      print('🔄 Updating availability: $isAvailable');

      final response = await _dio.put(
        '/api/profile/me/availability',
        data: {'isAvailable': isAvailable},
      );

      print('✅ Availability updated: ${response.statusCode}');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception('Failed to update availability');
      }
    } on DioException catch (e) {
      print('❌ Error updating availability: ${e.message}');

      if (e.response != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }

      throw Exception('Ошибка обновления доступности');
    } catch (e) {
      print('❌ Unexpected error updating availability: $e');
      throw Exception('Произошла ошибка при обновлении доступности');
    }
  }
}
