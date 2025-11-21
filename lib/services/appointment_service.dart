import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final Dio _dio = ApiClient.instance;

  Future<AppointmentModel> createAppointment(Map<String, dynamic> data) async {
    try {
      print('📤 Creating appointment: $data');
      final response = await _dio.post('/api/appointments', data: data);

      if (response.data['success'] == true) {
        print('✅ Appointment created successfully');
        return AppointmentModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to create appointment');
    } on DioException catch (e) {
      print('❌ Appointment creation failed: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create appointment',
      );
    }
  }

  Future<List<AppointmentModel>> getMyAppointments() async {
    try {
      final response = await _dio.get('/api/appointments/me');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AppointmentModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load appointments');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load appointments',
      );
    }
  }

  Future<List<AppointmentModel>> getPsychologistAppointments() async {
    try {
      final response = await _dio.get('/api/appointments/psychologist/me');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AppointmentModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load appointments');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load appointments',
      );
    }
  }

  Future<void> confirmAppointment(int appointmentId) async {
    try {
      await _dio.put('/api/appointments/$appointmentId/confirm');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to confirm');
    }
  }

  Future<void> cancelAppointment(int appointmentId, String reason) async {
    try {
      await _dio.put(
        '/api/appointments/$appointmentId/cancel',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to cancel');
    }
  }
}
