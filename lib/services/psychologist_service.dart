import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/psychologist_model.dart';
import '../models/schedule_slot_model.dart';

class PsychologistService {
  final Dio _dio = ApiClient.instance;

  /// Получить всех доступных психологов (PUBLIC)
  Future<List<PsychologistModel>> getAvailablePsychologists() async {
    try {
      print('🔵 Fetching available psychologists...');
      final response = await _dio.get('/api/psychologists');

      print('✅ Response: ${response.statusCode}');
      print('📦 Data: ${response.data}');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PsychologistModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load psychologists');
      }
    } on DioException catch (e) {
      print('❌ Error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load psychologists',
      );
    }
  }

  /// Получить топ психологов (PUBLIC)
  Future<List<PsychologistModel>> getTopPsychologists() async {
    try {
      final response = await _dio.get('/api/psychologists/top');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PsychologistModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load top psychologists');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load psychologists',
      );
    }
  }

  /// Получить психолога по ID (PUBLIC)
  Future<PsychologistModel> getPsychologistById(int id) async {
    try {
      print('🔵 Fetching psychologist by ID: $id');
      final response = await _dio.get('/api/psychologists/$id');

      if (response.data['success'] == true) {
        return PsychologistModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load psychologist');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load psychologist',
      );
    }
  }

  /// Получить расписание психолога (PUBLIC) ✅ НОВОЕ
  Future<List<ScheduleSlotModel>> getPsychologistSchedule(int id) async {
    try {
      print('🔵 Fetching schedule for psychologist: $id');
      final response = await _dio.get('/api/psychologists/$id/schedule');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ScheduleSlotModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schedule');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load schedule');
    }
  }
}
