import 'package:dio/dio.dart';
import '../models/appointment_model.dart';
import '../core/api/api_client.dart';

/// Сервис для работы с записями на приём
class AppointmentService {
  final Dio _dio = ApiClient.instance;

  /// Создать новую запись на приём
  ///
  /// Параметры:
  /// - data: Карта с данными записи:
  ///   * clientId (int, optional) - ID существующего клиента
  ///   * clientPhone (String, optional) - Телефон нового клиента
  ///   * clientName (String, optional) - Имя нового клиента
  ///   * psychologistId (int) - ID психолога
  ///   * appointmentDate (String) - Дата в формате YYYY-MM-DD
  ///   * startTime (String) - Время начала в формате HH:mm
  ///   * endTime (String) - Время окончания в формате HH:mm
  ///   * format (String) - Формат сессии: VIDEO, CHAT, AUDIO
  ///   * issueDescription (String, optional) - Описание проблемы
  ///   * price (double, optional) - Стоимость сессии
  Future<AppointmentModel> createAppointment(Map<String, dynamic> data) async {
    try {
      // Формируем тело запроса согласно требованиям backend
      final requestData = <String, dynamic>{};

      // Обязательные поля
      if (data['clientId'] != null) {
        requestData['clientId'] = data['clientId'];
      }

      if (data['clientPhone'] != null) {
        requestData['clientPhone'] = data['clientPhone'];
      }

      if (data['clientName'] != null) {
        requestData['clientName'] = data['clientName'];
      }

      // Психолог определяется из токена, но можем передать явно
      if (data['psychologistId'] != null) {
        requestData['psychologistId'] = data['psychologistId'];
      }

      requestData['appointmentDate'] = data['appointmentDate'];
      requestData['startTime'] = data['startTime'];
      requestData['endTime'] = data['endTime'];
      requestData['format'] = data['format'];

      // Опциональные поля
      if (data.containsKey('issueDescription') &&
          data['issueDescription'] != null &&
          (data['issueDescription'] as String).isNotEmpty) {
        requestData['issueDescription'] = data['issueDescription'];
      }

      if (data.containsKey('price') && data['price'] != null) {
        requestData['price'] = data['price'];
      }

      final response = await _dio.post('/api/appointments', data: requestData);

      return AppointmentModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response == null) {
        throw Exception('Не удалось подключиться к серверу. Проверьте адрес API.');
      }

      final errorData = e.response!.data;

      // Обработка различных ошибок
      if (e.response!.statusCode == 403) {
        throw Exception('Доступ запрещён. Проверьте права доступа.');
      } else if (e.response!.statusCode == 400) {
        // Извлекаем сообщение об ошибке валидации
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else if (errorData is Map && errorData.containsKey('errors')) {
          // Если есть список ошибок валидации
          final errors = errorData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          throw Exception(firstError);
        }
        throw Exception('Некорректные данные записи');
      } else if (e.response!.statusCode == 404) {
        throw Exception('Психолог не найден');
      } else if (e.response!.statusCode == 409) {
        throw Exception('Это время уже занято');
      }

      throw Exception(errorData['message'] ?? 'Ошибка создания записи');
    } catch (e) {
      throw Exception('Произошла ошибка при создании записи');
    }
  }

  /// Получить записи текущего пользователя (клиента)
  Future<List<AppointmentModel>> getMyAppointments() async {
    try {
      final response = await _dio.get('/api/appointments/me');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => AppointmentModel.fromJson(json)).toList();
      }

      throw Exception('Не удалось загрузить записи');
    } on DioException catch (e) {
      print('❌ Error fetching appointments: ${e.message}');

      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Ошибка загрузки записей',
        );
      }

      throw Exception('Ошибка соединения с сервером');
    }
  }

  /// Получить записи психолога
  Future<List<AppointmentModel>> getPsychologistAppointments() async {
    try {
      print('🔍 Fetching psychologist appointments...');

      final response = await _dio.get('/api/appointments/psychologist/me');

      print('✅ Appointments loaded: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => AppointmentModel.fromJson(json)).toList();
      }

      throw Exception('Не удалось загрузить записи');
    } on DioException catch (e) {
      print('❌ Error fetching psychologist appointments: ${e.message}');

      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Ошибка загрузки записей',
        );
      }

      throw Exception('Ошибка соединения с сервером');
    }
  }

  /// Подтвердить запись (психолог)
  Future<void> confirmAppointment(int appointmentId) async {
    try {
      print('✅ Confirming appointment: $appointmentId');

      await _dio.put('/api/appointments/$appointmentId/confirm');

      print('✅ Appointment confirmed');
    } on DioException catch (e) {
      print('❌ Error confirming appointment: ${e.message}');

      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Ошибка подтверждения записи',
        );
      }

      throw Exception('Ошибка соединения с сервером');
    }
  }

  /// Отклонить запись (психолог)
  Future<void> rejectAppointment(int appointmentId, String reason) async {
    try {
      print('❌ Rejecting appointment: $appointmentId');

      await _dio.put(
        '/api/appointments/$appointmentId/reject',
        data: {'reason': reason},
      );

      print('✅ Appointment rejected');
    } on DioException catch (e) {
      print('❌ Error rejecting appointment: ${e.message}');

      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Ошибка отклонения записи',
        );
      }

      throw Exception('Ошибка соединения с сервером');
    }
  }

  /// Отменить запись (клиент или психолог)
  Future<void> cancelAppointment(int appointmentId, String reason) async {
    try {
      print('❌ Cancelling appointment: $appointmentId');

      await _dio.put(
        '/api/appointments/$appointmentId/cancel',
        data: {'reason': reason},
      );

      print('✅ Appointment cancelled');
    } on DioException catch (e) {
      print('❌ Error cancelling appointment: ${e.message}');

      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Ошибка отмены записи');
      }

      throw Exception('Ошибка соединения с сервером');
    }
  }

  /// Начать сессию (психолог)
  Future<void> startSession(int appointmentId) async {
    try {
      print('▶️ Starting session: $appointmentId');

      await _dio.put('/api/appointments/$appointmentId/start');

      print('✅ Session started');
    } on DioException catch (e) {
      print('❌ Error starting session: ${e.message}');

      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Ошибка начала сессии');
      }

      throw Exception('Ошибка соединения с сервером');
    }
  }

  /// Завершить сессию (психолог)
  Future<void> completeSession(int appointmentId) async {
    try {
      print('✔️ Completing session: $appointmentId');

      await _dio.put('/api/appointments/$appointmentId/complete');

      print('✅ Session completed');
    } on DioException catch (e) {
      print('❌ Error completing session: ${e.message}');

      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Ошибка завершения сессии',
        );
      }

      throw Exception('Ошибка соединения с сервером');
    }
  }

  /// Отметить, что клиент не пришёл (NO_SHOW)
  Future<void> markAsNoShow(int appointmentId) async {
    try {
      print('🚫 Marking as no-show: $appointmentId');

      await _dio.put('/api/appointments/$appointmentId/no-show');

      print('✅ Marked as no-show');
    } on DioException catch (e) {
      print('❌ Error marking as no-show: ${e.message}');

      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Ошибка отметки неявки');
      }

      throw Exception('Ошибка соединения с сервером');
    }
  }
}
