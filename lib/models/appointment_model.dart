import 'dart:ui';

/// ✅ Обновлённая модель на основе реального backend API
class AppointmentModel {
  final int id;
  final int clientId;
  final String clientName;
  final String? clientAvatarUrl;
  final int psychologistId;
  final String psychologistName;
  final String? psychologistAvatarUrl;
  final String appointmentDate; // LocalDate в формате YYYY-MM-DD
  final String startTime; // LocalTime в формате HH:mm
  final String endTime;
  final String format; // VIDEO, CHAT, AUDIO
  final String status; // PENDING, CONFIRMED, COMPLETED, CANCELLED, NO_SHOW
  final String? issueDescription;
  final String? notes;
  final double price;
  final String createdAt;
  final String? confirmedAt;
  final String? completedAt;
  final String? cancelledAt;
  final String? cancellationReason;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    this.clientAvatarUrl,
    required this.psychologistId,
    required this.psychologistName,
    this.psychologistAvatarUrl,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.format,
    required this.status,
    this.issueDescription,
    this.notes,
    required this.price,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int,
      clientId: json['clientId'] as int,
      clientName: json['clientName'] as String,
      clientAvatarUrl: json['clientAvatarUrl'] as String?,
      psychologistId: json['psychologistId'] as int,
      psychologistName: json['psychologistName'] as String,
      psychologistAvatarUrl: json['psychologistAvatarUrl'] as String?,
      appointmentDate: json['appointmentDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      format: json['format'] as String,
      status: json['status'] as String,
      issueDescription: json['issueDescription'] as String?,
      notes: json['notes'] as String?,
      price: (json['price'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
      confirmedAt: json['confirmedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'clientAvatarUrl': clientAvatarUrl,
      'psychologistId': psychologistId,
      'psychologistName': psychologistName,
      'psychologistAvatarUrl': psychologistAvatarUrl,
      'appointmentDate': appointmentDate,
      'startTime': startTime,
      'endTime': endTime,
      'format': format,
      'status': status,
      'issueDescription': issueDescription,
      'notes': notes,
      'price': price,
      'createdAt': createdAt,
      'confirmedAt': confirmedAt,
      'completedAt': completedAt,
      'cancelledAt': cancelledAt,
      'cancellationReason': cancellationReason,
    };
  }

  // ✅ UI Helper Methods
  String get statusDisplayName {
    switch (status) {
      case 'PENDING':
        return 'Ожидается';
      case 'CONFIRMED':
        return 'Подтверждено';
      case 'IN_PROGRESS': 
        return 'В процессе'; 
      case 'COMPLETED':
        return 'Завершено';
      case 'CANCELLED':
        return 'Отменено';
      case 'NO_SHOW':
        return 'Не явился';
      default:
        return status;
    }
  }

  String get formatDisplayName {
    switch (format.toUpperCase()) {
      case 'VIDEO':
        return 'Видео-звонок';
      case 'CHAT':
        return 'Чат';
      case 'AUDIO':
        return 'Аудио';
      default:
        return format;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFFFF4E0); // Жёлтый
      case 'CONFIRMED':
        return const Color(0xFFE3F2FD); // Синий
      case 'COMPLETED':
        return const Color(0xFFE8F5E9); // Зелёный
      case 'CANCELLED':
      case 'NO_SHOW':
        return const Color(0xFFFFE8E8); // Красный
      default:
        return const Color(0xFFF5F5F5); // Серый
    }
  }

  Color get statusTextColor {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFD4A747);
      case 'CONFIRMED':
        return const Color(0xFF1976D2);
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELLED':
      case 'NO_SHOW':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  // ✅ Проверки состояния
  bool get canStart => status == 'CONFIRMED';
  bool get canComplete => status == 'CONFIRMED';
  bool get canCancel => status == 'PENDING' || status == 'CONFIRMED';
  bool get needsReport => status == 'COMPLETED';
}
