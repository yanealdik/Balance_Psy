class AppointmentModel {
  final int id;
  final int clientId;
  final String clientName;
  final String? clientAvatarUrl;
  final int psychologistId;
  final String psychologistName;
  final String? psychologistAvatarUrl;
  final String appointmentDate;
  final String startTime;
  final String endTime;
  final String format;
  final String status;
  final String? issueDescription;
  final String? notes;
  final double price;
  final String createdAt;

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
    );
  }
}
