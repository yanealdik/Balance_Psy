import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/intro_model.dart';

class IntroService {
  final Dio _dio = ApiClient.instance;

  /// Получить контент интро
  Future<List<IntroContent>> getIntroContent() async {
    try {
      print('📚 Fetching intro content...');

      final response = await _dio.get('/api/intro/content');

      print('✅ Intro content response: ${response.statusCode}');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final content = data
            .map((json) => IntroContent.fromJson(json))
            .toList();

        print('📋 Loaded ${content.length} intro items');
        return content;
      }

      throw Exception('Failed to load intro content');
    } on DioException catch (e) {
      print('❌ Get intro content error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load intro content',
      );
    }
  }

  /// Отметить интро как завершённое
  Future<void> completeIntro() async {
    try {
      print('✅ Marking intro as completed...');

      final response = await _dio.post('/api/intro/complete');

      if (response.data['success'] == true) {
        print('✅ Intro marked as completed');
      }
    } on DioException catch (e) {
      print('❌ Complete intro error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to complete intro',
      );
    }
  }

  /// Проверить статус интро
  Future<bool> getIntroStatus() async {
    try {
      print('📋 Checking intro status...');

      final response = await _dio.get('/api/intro/status');

      if (response.data['success'] == true) {
        return response.data['data'] as bool;
      }

      return false;
    } on DioException catch (e) {
      print('❌ Get intro status error: ${e.response?.data}');
      return false;
    }
  }
}
