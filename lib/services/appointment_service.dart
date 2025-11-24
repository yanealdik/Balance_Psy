import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/appointment_model.dart';
import '../models/session_format.dart';

class AppointmentService {
  final Dio _dio = ApiClient.instance;

  /// ✅ Создать запись (CLIENT)
  Future<AppointmentModel> createAppointment(Map<String, dynamic> data) async {
    try {
      print('📤 Creating appointment: $data');

      final requestData = {
        'psychologistId': data['psychologistId'],
        'appointmentDate': data['appointmentDate'], // YYYY-MM-DD
        'startTime': data['startTime'], // HH:mm
        'endTime': data['endTime'], // HH:mm
        'format': sessionFormatToApi(data['format'] as SessionFormat),
        'issueDescription': data['issueDescription'] ?? '',
      };

      print('📦 Request data: $requestData');

      final response = await _dio.post('/api/appointments', data: requestData);

      print('✅ Response: ${response.statusCode}');
      print('📥 Data: ${response.data}');

      if (response.data['success'] == true) {
        return AppointmentModel.fromJson(response.data['data']);
      }
      throw Exception(
        response.data['message'] ?? 'Failed to create appointment',
      );
    } on DioException catch (e) {
      print('❌ Appointment creation failed: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create appointment',
      );
    }
  }

  /// ✅ Получить свои записи (CLIENT)
  Future<List<AppointmentModel>> getMyAppointments() async {
    try {
      print('🔵 Fetching my appointments...');
      final response = await _dio.get('/api/appointments/me');

      print('✅ Response: ${response.statusCode}');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AppointmentModel.fromJson(json)).toList();
      }
      throw Exception(
        response.data['message'] ?? 'Failed to load appointments',
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load appointments',
      );
    }
  }

  /// ✅ Получить записи психолога (PSYCHOLOGIST)
  Future<List<AppointmentModel>> getPsychologistAppointments() async {
    try {
      print('🔵 Fetching psychologist appointments...');
      final response = await _dio.get('/api/appointments/psychologist/me');

      print('✅ Response: ${response.statusCode}');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AppointmentModel.fromJson(json)).toList();
      }
      throw Exception(
        response.data['message'] ?? 'Failed to load appointments',
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load appointments',
      );
    }
  }

  /// ✅ Подтвердить запись (PSYCHOLOGIST)
  Future<void> confirmAppointment(int appointmentId) async {
    try {
      print('🔵 Confirming appointment: $appointmentId');
      final response = await _dio.put(
        '/api/appointments/$appointmentId/confirm',
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to confirm');
      }
      print('✅ Appointment confirmed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to confirm');
    }
  }

  /// ✅ НОВЫЙ МЕТОД: Отклонить запись (PSYCHOLOGIST)
  Future<void> rejectAppointment(int appointmentId, String reason) async {
    try {
      print('🔵 Rejecting appointment: $appointmentId');
      final response = await _dio.put(
        '/api/appointments/$appointmentId/reject',
        data: {'reason': reason},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to reject');
      }
      print('✅ Appointment rejected');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to reject');
    }
  }

  /// ✅ Отменить запись (CLIENT или PSYCHOLOGIST)
  Future<void> cancelAppointment(int appointmentId, String reason) async {
    try {
      print('🔵 Cancelling appointment: $appointmentId');
      final response = await _dio.put(
        '/api/appointments/$appointmentId/cancel',
        data: {'reason': reason},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to cancel');
      }
      print('✅ Appointment cancelled');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to cancel');
    }
  }
}
