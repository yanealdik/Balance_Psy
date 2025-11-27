import 'package:dio/dio.dart';
import '../models/appointment_model.dart';
import '../core/api/api_client.dart';

class AppointmentService {
  final Dio _dio = ApiClient.instance;

  /// ✅ ИСПРАВЛЕНО: Создать новую запись на приём
  Future<AppointmentModel> createAppointment(Map<String, dynamic> data) async {
    try {
      print('📤 Creating appointment...');
      print('📦 Input data: $data');

      // ✅ КРИТИЧНО: Формируем правильное тело запроса
      final requestData = <String, dynamic>{
        'psychologistId': data['psychologistId'],
        'appointmentDate': data['appointmentDate'], // YYYY-MM-DD
        'startTime': data['startTime'], // HH:mm
        'endTime': data['endTime'], // HH:mm
        'format': data['format'], // VIDEO/CHAT/AUDIO
      };

      // Опциональные поля
      if (data['clientId'] != null) {
        requestData['clientId'] = data['clientId'];
      }

      if (data['clientPhone'] != null) {
        requestData['clientPhone'] = data['clientPhone'];
      }

      if (data['clientName'] != null) {
        requestData['clientName'] = data['clientName'];
      }

      if (data['issueDescription'] != null &&
          (data['issueDescription'] as String).isNotEmpty) {
        requestData['issueDescription'] = data['issueDescription'];
      }

      print('📦 Final request data: $requestData');

      final response = await _dio.post('/api/appointments', data: requestData);

      print('✅ Response: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      // ✅ ИСПРАВЛЕНО: Правильная обработка ответа
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Backend возвращает ApiResponse с data внутри
        final responseData = response.data;

        if (responseData is Map && responseData['success'] == true) {
          return AppointmentModel.fromJson(responseData['data']);
        } else if (responseData is Map && responseData['id'] != null) {
          // Если backend вернул объект напрямую
          return AppointmentModel.fromJson(
            responseData as Map<String, dynamic>,
          );
        }
      }

      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('❌ Response: ${e.response?.statusCode}');
      print('❌ Data: ${e.response?.data}');

      if (e.response == null) {
        throw Exception('Не удалось подключиться к серверу');
      }

      final errorData = e.response!.data;

      // Детальная обработка ошибок
      if (e.response!.statusCode == 400) {
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
        throw Exception('Некорректные данные записи');
      } else if (e.response!.statusCode == 404) {
        throw Exception('Психолог не найден');
      } else if (e.response!.statusCode == 409) {
        throw Exception('Это время уже занято');
      }

      throw Exception(errorData['message'] ?? 'Ошибка создания записи');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Произошла ошибка: $e');
    }
  }

  // Остальные методы без изменений...
  Future<List<AppointmentModel>> getMyAppointments() async {
    try {
      final response = await _dio.get('/api/appointments/me');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map && responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => AppointmentModel.fromJson(json)).toList();
        } else if (responseData is List) {
          return responseData
              .map((json) => AppointmentModel.fromJson(json))
              .toList();
        }
      }

      throw Exception('Не удалось загрузить записи');
    } on DioException catch (e) {
      print('❌ Error fetching appointments: ${e.message}');
      throw Exception(e.response?.data['message'] ?? 'Ошибка загрузки записей');
    }
  }

  Future<List<AppointmentModel>> getPsychologistAppointments() async {
    try {
      final response = await _dio.get('/api/appointments/psychologist/me');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map && responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => AppointmentModel.fromJson(json)).toList();
        } else if (responseData is List) {
          return responseData
              .map((json) => AppointmentModel.fromJson(json))
              .toList();
        }
      }

      throw Exception('Не удалось загрузить записи');
    } on DioException catch (e) {
      print('❌ Error: ${e.message}');
      throw Exception(e.response?.data['message'] ?? 'Ошибка загрузки записей');
    }
  }

  Future<void> confirmAppointment(int appointmentId) async {
    try {
      await _dio.put('/api/appointments/$appointmentId/confirm');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Ошибка подтверждения');
    }
  }

  Future<void> rejectAppointment(int appointmentId, String reason) async {
    try {
      await _dio.put(
        '/api/appointments/$appointmentId/reject',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Ошибка отклонения');
    }
  }

  Future<void> cancelAppointment(int appointmentId, String reason) async {
    try {
      await _dio.put(
        '/api/appointments/$appointmentId/cancel',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Ошибка отмены');
    }
  }

  Future<void> startSession(int appointmentId) async {
    try {
      await _dio.put('/api/appointments/$appointmentId/start');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Ошибка начала сессии');
    }
  }

  Future<void> completeSession(int appointmentId) async {
    try {
      await _dio.put('/api/appointments/$appointmentId/complete');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Ошибка завершения');
    }
  }

  Future<void> markAsNoShow(int appointmentId) async {
    try {
      await _dio.put('/api/appointments/$appointmentId/no-show');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Ошибка отметки');
    }
  }
}
