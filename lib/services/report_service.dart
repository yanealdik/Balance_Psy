import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/report_model.dart';

class ReportService {
  final Dio _dio = ApiClient.instance;

  /// ✅ Создать отчёт
  Future<ReportModel> createReport(CreateReportRequest request) async {
    try {
      print('📝 Creating report for appointment: ${request.appointmentId}');

      final response = await _dio.post('/api/reports', data: request.toJson());

      if (response.data['success'] == true) {
        return ReportModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create report');
    } on DioException catch (e) {
      print('❌ Create report error: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to create report');
    }
  }

  /// ✅ Обновить отчёт
  Future<ReportModel> updateReport(
    int reportId,
    UpdateReportRequest request,
  ) async {
    try {
      print('📝 Updating report: $reportId');

      final response = await _dio.put(
        '/api/reports/$reportId',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return ReportModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update report');
    } on DioException catch (e) {
      print('❌ Update report error: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to update report');
    }
  }

  /// ✅ Получить все отчёты психолога
  Future<List<ReportModel>> getMyReports() async {
    try {
      print('📋 Fetching my reports...');

      final response = await _dio.get('/api/reports/my');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ReportModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load reports');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load reports');
    }
  }

  /// ✅ Получить незавершённые отчёты
  Future<List<ReportModel>> getIncompleteReports() async {
    try {
      print('📋 Fetching incomplete reports...');

      final response = await _dio.get('/api/reports/incomplete');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ReportModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load incomplete reports');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load incomplete reports',
      );
    }
  }

  /// ✅ Получить историю отчётов по клиенту
  Future<List<ReportModel>> getClientReports(int clientId) async {
    try {
      print('📋 Fetching reports for client: $clientId');

      final response = await _dio.get('/api/reports/client/$clientId');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ReportModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load client reports');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load client reports',
      );
    }
  }

  /// ✅ Получить отчёт по ID
  Future<ReportModel> getReportById(int reportId) async {
    try {
      print('📖 Fetching report: $reportId');

      final response = await _dio.get('/api/reports/$reportId');

      if (response.data['success'] == true) {
        return ReportModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to load report');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load report');
    }
  }
}
