import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/psychologist_statistics_model.dart';

class StatisticsService {
  final Dio _dio = ApiClient.instance;

  /// Получить статистику психолога
  Future<PsychologistStatistics> getMyStatistics() async {
    try {
      print('🔵 Fetching psychologist statistics...');

      final response = await _dio.get('/api/statistics/me');

      print('✅ Statistics response: ${response.statusCode}');

      if (response.data['success'] == true) {
        return PsychologistStatistics.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load statistics');
      }
    } on DioException catch (e) {
      print('❌ Statistics error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load statistics',
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to load statistics: $e');
    }
  }
}
