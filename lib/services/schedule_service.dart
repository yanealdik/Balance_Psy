import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/schedule_slot_model.dart';

class ScheduleService {
  final Dio _dio = ApiClient.instance;

  Future<List<ScheduleSlotModel>> getMySchedule() async {
    try {
      final response = await _dio.get('/api/psychologists/me/schedule');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ScheduleSlotModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load schedule');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load schedule');
    }
  }

  Future<ScheduleSlotModel> createScheduleSlot(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(
        '/api/psychologists/me/schedule',
        data: data,
      );
      if (response.data['success'] == true) {
        return ScheduleSlotModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to create slot');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create slot');
    }
  }

  Future<void> deleteScheduleSlot(int id) async {
    try {
      await _dio.delete('/api/psychologists/me/schedule/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete slot');
    }
  }

  Future<List<ScheduleSlotModel>> getPsychologistSchedule(
    int psychologistId,
  ) async {
    try {
      final response = await _dio.get(
        '/api/psychologists/$psychologistId/schedule',
      );
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ScheduleSlotModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load schedule');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load schedule');
    }
  }
}
