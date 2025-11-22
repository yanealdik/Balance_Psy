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
  final String format; // video, chat, phone
  final String status; // PENDING, CONFIRMED, COMPLETED, CANCELLED
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

  // Вспомогательные методы для UI
  String get statusDisplayName {
    switch (status) {
      case 'PENDING':
        return 'Ожидается';
      case 'CONFIRMED':
        return 'Подтверждено';
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
    switch (format.toLowerCase()) {
      case 'video':
        return 'Видео-звонок';
      case 'chat':
        return 'Чат';
      case 'phone':
        return 'Телефон';
      default:
        return format;
    }
  }
}
