import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/psychologist_model.dart';
import '../models/schedule_slot_model.dart';

class PsychologistService {
  final Dio _dio = ApiClient.instance;

  /// ✅ Получить всех доступных психологов (PUBLIC)
  Future<List<PsychologistModel>> getAvailablePsychologists() async {
    try {
      print('🔵 Fetching available psychologists...');

      final response = await _dio.get(
        '/api/psychologists',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('✅ Response: ${response.statusCode}');
      print('📦 Data: ${response.data}');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];

        if (data.isEmpty) {
          print('⚠️ No psychologists found in database');
          return [];
        }

        return data.map((json) {
          try {
            return PsychologistModel.fromJson(json);
          } catch (e) {
            print('❌ Error parsing psychologist: $e');
            print('📦 JSON: $json');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to load psychologists',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('❌ Response: ${e.response?.statusCode} - ${e.response?.data}');
      print('❌ Message: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('API endpoint not found. Check backend configuration.');
      }

      throw Exception(
        e.response?.data['message'] ??
            'Failed to load psychologists: ${e.message}',
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to load psychologists: $e');
    }
  }

  /// ✅ Получить топ психологов (PUBLIC)
  Future<List<PsychologistModel>> getTopPsychologists() async {
    try {
      print('🔵 Fetching top psychologists...');

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

  /// ✅ Получить психолога по ID (PUBLIC)
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

  /// ✅ Получить расписание психолога (PUBLIC)
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

  /// ✅ НОВЫЙ МЕТОД: Проверить доступность психолога для записи
  Future<bool> checkAvailability({
    required int psychologistId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      // Получаем расписание психолога
      final schedule = await getPsychologistSchedule(psychologistId);

      // Проверяем, есть ли доступные слоты на эту дату и время
      // Здесь должна быть логика проверки занятости

      return schedule.isNotEmpty;
    } catch (e) {
      print('❌ Error checking availability: $e');
      return false;
    }
  }
}
