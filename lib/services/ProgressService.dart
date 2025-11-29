import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/client_progress_model.dart';

class ProgressService {
  final Dio _dio = ApiClient.instance;

  /// Получить прогресс клиента
  Future<ClientProgress> getMyProgress() async {
    try {
      print('🔵 Fetching client progress...');

      final response = await _dio.get('/api/progress/me');

      print('✅ Progress response: ${response.statusCode}');

      if (response.data['success'] == true) {
        return ClientProgress.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load progress');
      }
    } on DioException catch (e) {
      print('❌ Progress error: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to load progress');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to load progress: $e');
    }
  }
}
