import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _service = ReportService();

  List<ReportModel> _reports = [];
  Map<String, List<ReportModel>> _groupedReports = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<ReportModel> get reports => _reports;
  Map<String, List<ReportModel>> get groupedReports => _groupedReports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// ✅ Загрузить все отчёты
  Future<void> loadReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reports = await _service.getMyReports();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Загрузить отчёты с группировкой по датам
  Future<void> loadReportsGroupedByDate() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _groupedReports = await _service.getReportsGroupedByDate();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _groupedReports = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Создать отчёт

  Future<bool> createReport({
    required int appointmentId,
    required String sessionTheme,
    required String sessionDescription,
    String? recommendations,
  }) async {
    try {
      final request = CreateReportRequest(
        appointmentId: appointmentId,
        sessionTheme: sessionTheme,
        sessionDescription: sessionDescription,
        recommendations: recommendations,
      );

      // ✅ Используем новый метод createOrUpdateReport
      final report = await _service.createOrUpdateReport(request);

      // Обновляем локальный список
      final index = _reports.indexWhere(
        (r) => r.appointmentId == appointmentId,
      );
      if (index != -1) {
        _reports[index] = report;
      } else {
        _reports.insert(0, report);
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ Обновить отчёт
  Future<bool> updateReport({
    required int reportId,
    String? sessionTheme,
    String? sessionDescription,
    String? recommendations,
    bool? isCompleted,
  }) async {
    try {
      final request = UpdateReportRequest(
        sessionTheme: sessionTheme,
        sessionDescription: sessionDescription,
        recommendations: recommendations,
        isCompleted: isCompleted,
      );

      final updatedReport = await _service.updateReport(reportId, request);

      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = updatedReport;
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ Получить историю клиента
  Future<List<ReportModel>> getClientHistory(int clientId) async {
    try {
      return await _service.getClientHistory(clientId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return [];
    }
  }

  /// ✅ Получить незавершённые отчёты
  Future<void> loadIncompleteReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reports = await _service.getIncompleteReports();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
