import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/psychologist_model.dart';

class PsychologistService {
  final Dio _dio = ApiClient.instance;

  /// Получить всех доступных психологов
  Future<List<PsychologistModel>> getAvailablePsychologists() async {
    try {
      final response = await _dio.get('/api/psychologists');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((json) => PsychologistModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load psychologists');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load psychologists');
    }
  }

  /// Получить топ психологов
  Future<List<PsychologistModel>> getTopPsychologists() async {
    try {
      final response = await _dio.get('/api/psychologists/top');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((json) => PsychologistModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load top psychologists');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load psychologists');
    }
  }

  /// Получить психолога по ID
  Future<PsychologistModel> getPsychologistById(int id) async {
    try {
      final response = await _dio.get('/api/psychologists/$id');

      if (response.data['success'] == true) {
        return PsychologistModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load psychologist');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load psychologist');
    }
  }
}