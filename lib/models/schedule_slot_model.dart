class ScheduleSlotModel {
  final int id;
  final int psychologistId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isActive;

  ScheduleSlotModel({
    required this.id,
    required this.psychologistId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory ScheduleSlotModel.fromJson(Map<String, dynamic> json) {
    return ScheduleSlotModel(
      id: json['id'] as int,
      psychologistId: json['psychologistId'] as int,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isActive: json['isActive'] as bool,
    );
  }
}
