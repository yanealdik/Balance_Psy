import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/diagnostic_model.dart';

class DiagnosticService {
  final Dio _dio = ApiClient.instance;

  /// Отправить результаты диагностики
  Future<DiagnosticResult> submitDiagnostic(
    DiagnosticSubmissionRequest request,
  ) async {
    try {
      print('📤 Submitting diagnostic...');

      final response = await _dio.post(
        '/api/diagnostic/submit',
        data: request.toJson(),
      );

      print('✅ Diagnostic submitted: ${response.statusCode}');

      if (response.data['success'] == true) {
        return DiagnosticResult.fromJson(response.data['data']);
      }

      throw Exception(
        response.data['message'] ?? 'Failed to submit diagnostic',
      );
    } on DioException catch (e) {
      print('❌ Submit diagnostic error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to submit diagnostic',
      );
    }
  }

  /// Получить последнюю диагностику
  Future<DiagnosticResult> getLatestDiagnostic() async {
    try {
      print('📋 Fetching latest diagnostic...');

      final response = await _dio.get('/api/diagnostic/latest');

      if (response.data['success'] == true) {
        return DiagnosticResult.fromJson(response.data['data']);
      }

      throw Exception('No diagnostic found');
    } on DioException catch (e) {
      print('❌ Get diagnostic error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load diagnostic',
      );
    }
  }

  /// Получить историю диагностик
  Future<List<DiagnosticResult>> getDiagnosticHistory() async {
    try {
      print('📋 Fetching diagnostic history...');

      final response = await _dio.get('/api/diagnostic/history');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => DiagnosticResult.fromJson(json)).toList();
      }

      throw Exception('Failed to load history');
    } on DioException catch (e) {
      print('❌ Get history error: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to load history');
    }
  }

  /// Получить диагностику клиента (для психолога)
  Future<DiagnosticResult> getClientDiagnostic(int clientId) async {
    try {
      print('📋 Fetching client diagnostic: $clientId');

      final response = await _dio.get('/api/diagnostic/client/$clientId');

      if (response.data['success'] == true) {
        return DiagnosticResult.fromJson(response.data['data']);
      }

      throw Exception('No diagnostic found for this client');
    } on DioException catch (e) {
      print('❌ Get client diagnostic error: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load client diagnostic',
      );
    }
  }
}
