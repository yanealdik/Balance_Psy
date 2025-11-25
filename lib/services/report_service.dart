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

  Future<Map<String, List<ReportModel>>> getReportsGroupedByDate() async {
    try {
      print('📋 Fetching reports grouped by date...');

      final reports = await getMyReports();

      // Группируем по датам
      final Map<String, List<ReportModel>> grouped = {};

      for (var report in reports) {
        final dateKey = report.sessionDate; // YYYY-MM-DD

        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }

        grouped[dateKey]!.add(report);
      }

      // Сортируем даты (новые сверху)
      final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

      final Map<String, List<ReportModel>> sortedGrouped = {};
      for (var key in sortedKeys) {
        sortedGrouped[key] = grouped[key]!;
      }

      return sortedGrouped;
    } catch (e) {
      print('❌ Error grouping reports: $e');
      throw Exception('Failed to group reports');
    }
  }

  /// ✅ НОВЫЙ МЕТОД: Получить историю клиента (псевдоним для существующего метода)
  Future<List<ReportModel>> getClientHistory(int clientId) async {
    return getClientReports(clientId);
  }
}
