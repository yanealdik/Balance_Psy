import 'dart:ui';

/// Модель отчёта по сессии
class ReportModel {
  final int id;
  final int appointmentId;
  final int clientId;
  final String clientName;
  final String? clientAvatarUrl;
  final String sessionDate; // LocalDate в формате YYYY-MM-DD
  final String sessionFormat; // VIDEO, CHAT, AUDIO
  final String sessionTheme;
  final String sessionDescription;
  final String? recommendations;
  final bool isCompleted;
  final String createdAt;
  final String? completedAt;

  ReportModel({
    required this.id,
    required this.appointmentId,
    required this.clientId,
    required this.clientName,
    this.clientAvatarUrl,
    required this.sessionDate,
    required this.sessionFormat,
    required this.sessionTheme,
    required this.sessionDescription,
    this.recommendations,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as int,
      appointmentId: json['appointmentId'] as int,
      clientId: json['clientId'] as int,
      clientName: json['clientName'] as String,
      clientAvatarUrl: json['clientAvatarUrl'] as String?,
      sessionDate: json['sessionDate'] as String,
      sessionFormat: json['sessionFormat'] as String,
      sessionTheme: json['sessionTheme'] as String,
      sessionDescription: json['sessionDescription'] as String,
      recommendations: json['recommendations'] as String?,
      isCompleted: json['isCompleted'] as bool,
      createdAt: json['createdAt'] as String,
      completedAt: json['completedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'clientId': clientId,
      'clientName': clientName,
      'clientAvatarUrl': clientAvatarUrl,
      'sessionDate': sessionDate,
      'sessionFormat': sessionFormat,
      'sessionTheme': sessionTheme,
      'sessionDescription': sessionDescription,
      'recommendations': recommendations,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'completedAt': completedAt,
    };
  }

  // ✅ UI Helper Methods
  String get formatDisplayName {
    switch (sessionFormat.toUpperCase()) {
      case 'VIDEO':
        return 'Видеоконсультация';
      case 'CHAT':
        return 'Чат';
      case 'AUDIO':
        return 'Аудио';
      default:
        return sessionFormat;
    }
  }

  Color get formatColor {
    switch (sessionFormat.toUpperCase()) {
      case 'VIDEO':
        return const Color(0xFF4CAF50);
      case 'CHAT':
        return const Color(0xFF2196F3);
      case 'AUDIO':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String get statusText {
    return isCompleted ? 'Завершён' : 'Черновик';
  }

  Color get statusColor {
    return isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF4E0);
  }

  Color get statusTextColor {
    return isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFD4A747);
  }
}

/// DTO для создания отчёта
class CreateReportRequest {
  final int appointmentId;
  final String sessionTheme;
  final String sessionDescription;
  final String? recommendations;

  CreateReportRequest({
    required this.appointmentId,
    required this.sessionTheme,
    required this.sessionDescription,
    this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'sessionTheme': sessionTheme,
      'sessionDescription': sessionDescription,
      'recommendations': recommendations,
    };
  }
}

/// DTO для обновления отчёта
class UpdateReportRequest {
  final String? sessionTheme;
  final String? sessionDescription;
  final String? recommendations;
  final bool? isCompleted;

  UpdateReportRequest({
    this.sessionTheme,
    this.sessionDescription,
    this.recommendations,
    this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (sessionTheme != null) data['sessionTheme'] = sessionTheme;
    if (sessionDescription != null)
      data['sessionDescription'] = sessionDescription;
    if (recommendations != null) data['recommendations'] = recommendations;
    if (isCompleted != null) data['isCompleted'] = isCompleted;
    return data;
  }
}
