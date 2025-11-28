import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/diagnostic_model.dart';

class TutorialService {
  final Dio _dio = ApiClient.instance;

  /// Получить контент туториала
  Future<List<TutorialContent>> getTutorialContent() async {
    try {
      print('📚 Fetching tutorial content...');

      final response = await _dio.get('/api/tutorial/content');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => TutorialContent.fromJson(json)).toList();
      }

      throw Exception('Failed to load tutorial content');
    } on DioException catch (e) {
      print('❌ Get tutorial content error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load tutorial content',
      );
    }
  }

  /// Отметить туториал как завершённый
  Future<void> completeTutorial() async {
    try {
      print('✅ Marking tutorial as completed...');

      await _dio.post('/api/tutorial/complete');
      print('✅ Tutorial completed');
    } on DioException catch (e) {
      print('❌ Complete tutorial error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to complete tutorial',
      );
    }
  }

  /// Проверить статус туториала
  Future<bool> getTutorialStatus() async {
    try {
      print('📋 Checking tutorial status...');

      final response = await _dio.get('/api/tutorial/status');

      if (response.data['success'] == true) {
        return response.data['data'] as bool;
      }

      return false;
    } on DioException catch (e) {
      print('❌ Get tutorial status error: ${e.response?.data}');
      return false;
    }
  }
}
