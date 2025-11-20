import 'package:dio/dio.dart';
import 'dart:io';
import '../core/api/api_client.dart';

class PsychologistRegistrationService {
  final Dio _dio = ApiClient.instance;

  /// Отправка кода верификации на email
  Future<bool> sendVerificationCode(String email) async {
    try {
      final response = await _dio.post(
        '/api/auth/send-verification-code',
        data: {
          'email': email,
          'purpose': 'REGISTRATION',
          'isParentEmail': false,
        },
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Ошибка отправки кода');
    }
  }

  /// Проверка кода верификации
  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '/api/auth/verify-email',
        data: {'email': email, 'code': code},
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Неверный код');
    }
  }

  /// Загрузка сертификата/документа
  Future<String> uploadCertificate(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        '/api/psychologist/upload-certificate',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.data['success'] == true) {
        return response.data['data']['url'];
      } else {
        throw Exception('Ошибка загрузки файла');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Ошибка загрузки сертификата',
      );
    }
  }

  /// Регистрация психолога (отправка заявки)
  Future<Map<String, dynamic>> registerPsychologist({
    required String email,
    required String password,
    required String fullName,
    required String dateOfBirth,
    String? gender,
    String? phone,
    required String specialization,
    required int experienceYears,
    required String education,
    required String bio,
    required List<String> approaches,
    required double sessionPrice,
    String? certificateUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register/psychologist',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'phone': phone,
          'role': 'PSYCHOLOGIST',
          'specialization': specialization,
          'experienceYears': experienceYears,
          'education': education,
          'bio': bio,
          'approaches': approaches,
          'sessionPrice': sessionPrice,
          'certificateUrl': certificateUrl,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Ошибка регистрации');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Ошибка регистрации психолога',
      );
    }
  }

  /// Проверка доступности email
  Future<bool> checkEmailAvailability(String email) async {
    try {
      final response = await _dio.post(
        '/api/auth/check-email',
        data: {'email': email},
      );

      return response.data['data']['available'] == true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Ошибка проверки email');
    }
  }

  /// Получить статус заявки психолога
  Future<Map<String, dynamic>> getApplicationStatus(int userId) async {
    try {
      final response = await _dio.get(
        '/api/psychologist/application-status/$userId',
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Ошибка получения статуса');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Ошибка получения статуса заявки',
      );
    }
  }
}
