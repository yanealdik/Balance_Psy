class ClientProgress {
  final int overallProgress;
  final int completedSessions;
  final int totalSessions;
  final int upcomingSessionsCount;
  final double attendanceRate;
  final int activeDaysStreak;
  final int completedGoals;
  final int totalGoals;
  final double averageSessionRating;
  final DateTime? lastSessionDate;
  final DateTime? nextSessionDate;

  ClientProgress({
    required this.overallProgress,
    required this.completedSessions,
    required this.totalSessions,
    required this.upcomingSessionsCount,
    required this.attendanceRate,
    required this.activeDaysStreak,
    required this.completedGoals,
    required this.totalGoals,
    required this.averageSessionRating,
    this.lastSessionDate,
    this.nextSessionDate,
  });

  factory ClientProgress.fromJson(Map<String, dynamic> json) {
    return ClientProgress(
      overallProgress: json['overallProgress'] ?? 0,
      completedSessions: json['completedSessions'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      upcomingSessionsCount: json['upcomingSessionsCount'] ?? 0,
      attendanceRate: (json['attendanceRate'] ?? 0.0).toDouble(),
      activeDaysStreak: json['activeDaysStreak'] ?? 0,
      completedGoals: json['completedGoals'] ?? 0,
      totalGoals: json['totalGoals'] ?? 0,
      averageSessionRating: (json['averageSessionRating'] ?? 0.0).toDouble(),
      lastSessionDate: json['lastSessionDate'] != null
          ? DateTime.parse(json['lastSessionDate'])
          : null,
      nextSessionDate: json['nextSessionDate'] != null
          ? DateTime.parse(json['nextSessionDate'])
          : null,
    );
  }
}
