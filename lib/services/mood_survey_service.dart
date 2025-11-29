import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/mood_survey_models.dart';

class MoodSurveyService {
  final Dio _dio = ApiClient.instance;

  /// Сохранить результаты опроса
  Future<MoodSurveyResponse> saveMoodSurvey(MoodSurveyRequest request) async {
    try {
      print('💭 Saving mood survey...');

      final response = await _dio.post(
        '/api/mood-surveys',
        data: request.toJson(),
      );

      print('✅ Mood survey saved: ${response.statusCode}');

      if (response.data['success'] == true) {
        return MoodSurveyResponse.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to save mood survey');
      }
    } on DioException catch (e) {
      print('❌ Mood survey error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to save mood survey',
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to save mood survey: $e');
    }
  }

  /// Получить историю опросов
  Future<MoodHistoryResponse> getMoodHistory({int limit = 30}) async {
    try {
      print('📊 Fetching mood history...');

      final response = await _dio.get(
        '/api/mood-surveys/history',
        queryParameters: {'limit': limit},
      );

      print('✅ Mood history fetched: ${response.statusCode}');

      if (response.data['success'] == true) {
        return MoodHistoryResponse.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load mood history');
      }
    } on DioException catch (e) {
      print('❌ Mood history error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load mood history',
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to load mood history: $e');
    }
  }
}
