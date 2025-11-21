import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _service = AppointmentService();

  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMyAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await _service.getMyAppointments();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPsychologistAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await _service.getPsychologistAppointments();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAppointment({
    required int psychologistId,
    required String date,
    required String startTime,
    required String endTime,
    required String format,
    String? issueDescription,
  }) async {
    try {
      final data = {
        'psychologistId': psychologistId,
        'appointmentDate': date,
        'startTime': startTime,
        'endTime': endTime,
        'format': format,
        'issueDescription': issueDescription,
      };

      final appointment = await _service.createAppointment(data);
      _appointments.insert(0, appointment);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmAppointment(int appointmentId) async {
    try {
      await _service.confirmAppointment(appointmentId);
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        // Обновить статус локально (или перезагрузить)
        await loadPsychologistAppointments();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelAppointment(int appointmentId, String reason) async {
    try {
      await _service.cancelAppointment(appointmentId, reason);
      await loadMyAppointments();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
