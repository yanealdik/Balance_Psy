import 'package:flutter/foundation.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';

/// Provider для управления записями на приём
class AppointmentProvider with ChangeNotifier {
  final AppointmentService _service = AppointmentService();

  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Загрузить записи клиента
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

  /// Загрузить записи психолога
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

  /// Создать новую запись
  ///
  /// Параметры передаются как Map с ключами:
  /// - clientId (int, optional) - для существующего клиента
  /// - clientPhone (String, optional) - для нового клиента
  /// - clientName (String, optional) - для нового клиента
  /// - appointmentDate (String) - дата в формате YYYY-MM-DD
  /// - startTime (String) - время начала HH:mm
  /// - endTime (String) - время окончания HH:mm
  /// - format (String) - VIDEO, CHAT, AUDIO
  /// - issueDescription (String, optional)
  /// - price (double, optional)
  Future<bool> createAppointment(Map<String, dynamic> data) async {
    try {
      final appointment = await _service.createAppointment(data);

      // Добавляем новую запись в начало списка
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

  /// Подтвердить запись (психолог)
  Future<bool> confirmAppointment(int appointmentId) async {
    try {
      await _service.confirmAppointment(appointmentId);

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

  /// Отклонить запись (психолог)
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

  /// Отменить запись
  Future<bool> cancelAppointment(int appointmentId, String reason) async {
    try {
      await _service.cancelAppointment(appointmentId, reason);

      // Перезагружаем список
      await loadMyAppointments();
      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Начать сессию (психолог)
  Future<bool> startSession(int appointmentId) async {
    try {
      await _service.startSession(appointmentId);

      // Обновляем статус записи локально
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        final appointment = _appointments[index];
        _appointments[index] = AppointmentModel(
          id: appointment.id,
          clientId: appointment.clientId,
          clientName: appointment.clientName,
          clientAvatarUrl: appointment.clientAvatarUrl,
          psychologistId: appointment.psychologistId,
          psychologistName: appointment.psychologistName,
          psychologistAvatarUrl: appointment.psychologistAvatarUrl,
          appointmentDate: appointment.appointmentDate,
          startTime: appointment.startTime,
          endTime: appointment.endTime,
          format: appointment.format,
          status: 'IN_PROGRESS', // Обновляем статус
          issueDescription: appointment.issueDescription,
          notes: appointment.notes,
          price: appointment.price,
          createdAt: appointment.createdAt,
          confirmedAt: appointment.confirmedAt,
          completedAt: appointment.completedAt,
          cancelledAt: appointment.cancelledAt,
          cancellationReason: appointment.cancellationReason,
        );
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

  /// Завершить сессию (психолог)
  Future<bool> completeSession(int appointmentId) async {
    try {
      await _service.completeSession(appointmentId);

      // Удаляем из текущего списка или обновляем статус
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        final appointment = _appointments[index];
        _appointments[index] = AppointmentModel(
          id: appointment.id,
          clientId: appointment.clientId,
          clientName: appointment.clientName,
          clientAvatarUrl: appointment.clientAvatarUrl,
          psychologistId: appointment.psychologistId,
          psychologistName: appointment.psychologistName,
          psychologistAvatarUrl: appointment.psychologistAvatarUrl,
          appointmentDate: appointment.appointmentDate,
          startTime: appointment.startTime,
          endTime: appointment.endTime,
          format: appointment.format,
          status: 'COMPLETED', // Обновляем статус
          issueDescription: appointment.issueDescription,
          notes: appointment.notes,
          price: appointment.price,
          createdAt: appointment.createdAt,
          confirmedAt: appointment.confirmedAt,
          completedAt: DateTime.now().toIso8601String(),
          cancelledAt: appointment.cancelledAt,
          cancellationReason: appointment.cancellationReason,
        );
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

  /// Отметить как "клиент не пришёл" (NO_SHOW)
  Future<bool> markAsNoShow(int appointmentId) async {
    try {
      await _service.markAsNoShow(appointmentId);

      // Обновляем статус записи локально
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        final appointment = _appointments[index];
        _appointments[index] = AppointmentModel(
          id: appointment.id,
          clientId: appointment.clientId,
          clientName: appointment.clientName,
          clientAvatarUrl: appointment.clientAvatarUrl,
          psychologistId: appointment.psychologistId,
          psychologistName: appointment.psychologistName,
          psychologistAvatarUrl: appointment.psychologistAvatarUrl,
          appointmentDate: appointment.appointmentDate,
          startTime: appointment.startTime,
          endTime: appointment.endTime,
          format: appointment.format,
          status: 'NO_SHOW', // Обновляем статус
          issueDescription: appointment.issueDescription,
          notes: appointment.notes,
          price: appointment.price,
          createdAt: appointment.createdAt,
          confirmedAt: appointment.confirmedAt,
          completedAt: appointment.completedAt,
          cancelledAt: appointment.cancelledAt,
          cancellationReason: 'Клиент не явился',
        );
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

  /// Получить предстоящие записи
  List<AppointmentModel> get upcomingAppointments {
    return _appointments.where((appointment) {
      return appointment.status == 'PENDING' ||
          appointment.status == 'CONFIRMED' ||
          appointment.status == 'IN_PROGRESS';
    }).toList();
  }

  /// Получить завершённые записи
  List<AppointmentModel> get completedAppointments {
    return _appointments.where((appointment) {
      return appointment.status == 'COMPLETED';
    }).toList();
  }

  /// Получить отменённые записи
  List<AppointmentModel> get cancelledAppointments {
    return _appointments.where((appointment) {
      return appointment.status == 'CANCELLED' ||
          appointment.status == 'NO_SHOW';
    }).toList();
  }

  /// Получить записи, ожидающие подтверждения (для психолога)
  List<AppointmentModel> get pendingAppointments {
    return _appointments.where((appointment) {
      return appointment.status == 'PENDING';
    }).toList();
  }

  /// Получить подтверждённые записи (расписание психолога)
  List<AppointmentModel> get confirmedAppointments {
    return _appointments.where((appointment) {
      return appointment.status == 'CONFIRMED' ||
          appointment.status == 'IN_PROGRESS';
    }).toList();
  }

  /// Очистить сообщение об ошибке
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
