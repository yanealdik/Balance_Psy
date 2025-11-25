import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../models/session_format.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _service = AppointmentService();

  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// ✅ Загрузить записи клиента
  Future<void> loadMyAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await _service.getMyAppointments();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _appointments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Загрузить записи психолога
  Future<void> loadPsychologistAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await _service.getPsychologistAppointments();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _appointments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Создать запись
  Future<bool> createAppointment({
    required int psychologistId,
    required String date,
    required String startTime,
    required String endTime,
    required SessionFormat format,
    String? issueDescription,
  }) async {
    try {
      final data = {
        'psychologistId': psychologistId,
        'appointmentDate': date,
        'startTime': startTime,
        'endTime': endTime,
        'format': format,
        'issueDescription': issueDescription ?? '',
      };

      final appointment = await _service.createAppointment(data);
      _appointments.insert(0, appointment);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ Подтвердить запись (психолог)
  Future<bool> confirmAppointment(int appointmentId) async {
    try {
      await _service.confirmAppointment(appointmentId);

      // Обновляем локально
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        await loadPsychologistAppointments();
      }

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ НОВЫЙ МЕТОД: Отклонить запись (психолог)
  Future<bool> rejectAppointment(int appointmentId, String reason) async {
    try {
      await _service.rejectAppointment(appointmentId, reason);

      // Перезагружаем список
      await loadPsychologistAppointments();

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ Отменить запись
  Future<bool> cancelAppointment(int appointmentId, String reason) async {
    try {
      await _service.cancelAppointment(appointmentId, reason);

      // Перезагружаем список
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        await loadMyAppointments();
      }

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> startSession(int appointmentId) async {
    try {
      await _service.startSession(appointmentId);

      // Перезагружаем список
      await loadPsychologistAppointments();

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ НОВЫЙ МЕТОД: Завершить сессию
  Future<bool> completeSession(int appointmentId) async {
    try {
      await _service.completeSession(appointmentId);

      // Перезагружаем список
      await loadPsychologistAppointments();

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ Получить предстоящие записи
  List<AppointmentModel> get upcomingAppointments {
    return _appointments.where((appointment) {
      return appointment.status == 'PENDING' ||
          appointment.status == 'CONFIRMED';
    }).toList();
  }

  /// ✅ Получить завершенные записи
  List<AppointmentModel> get completedAppointments {
    return _appointments.where((appointment) {
      return appointment.status == 'COMPLETED';
    }).toList();
  }

  /// ✅ Получить отмененные записи
  List<AppointmentModel> get cancelledAppointments {
    return _appointments.where((appointment) {
      return appointment.status == 'CANCELLED';
    }).toList();
  }

  /// ✅ Очистить ошибку
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
