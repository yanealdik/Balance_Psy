// Request model
class MoodSurveyRequest {
  final int moodScore;
  final int stressLevel;
  final List<String>? concerns;
  final String? sleepQuality;
  final String? helpfulAction;

  MoodSurveyRequest({
    required this.moodScore,
    required this.stressLevel,
    this.concerns,
    this.sleepQuality,
    this.helpfulAction,
  });

  Map<String, dynamic> toJson() {
    return {
      'moodScore': moodScore,
      'stressLevel': stressLevel,
      if (concerns != null && concerns!.isNotEmpty) 'concerns': concerns,
      if (sleepQuality != null) 'sleepQuality': sleepQuality,
      if (helpfulAction != null) 'helpfulAction': helpfulAction,
    };
  }
}

// Response model
class MoodSurveyResponse {
  final int id;
  final int userId;
  final int moodScore;
  final int stressLevel;
  final List<String>? concerns;
  final String? sleepQuality;
  final String? helpfulAction;
  final double overallScore;
  final DateTime createdAt;

  MoodSurveyResponse({
    required this.id,
    required this.userId,
    required this.moodScore,
    required this.stressLevel,
    this.concerns,
    this.sleepQuality,
    this.helpfulAction,
    required this.overallScore,
    required this.createdAt,
  });

  factory MoodSurveyResponse.fromJson(Map<String, dynamic> json) {
    return MoodSurveyResponse(
      id: json['id'],
      userId: json['userId'],
      moodScore: json['moodScore'],
      stressLevel: json['stressLevel'],
      concerns: json['concerns'] != null
          ? List<String>.from(json['concerns'])
          : null,
      sleepQuality: json['sleepQuality'],
      helpfulAction: json['helpfulAction'],
      overallScore: (json['overallScore'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get moodEmoji {
    if (moodScore >= 5) return '😊';
    if (moodScore == 4) return '😌';
    if (moodScore == 3) return '😐';
    if (moodScore == 2) return '😔';
    return '😢';
  }

  String get moodLabel {
    if (moodScore >= 5) return 'Отлично';
    if (moodScore == 4) return 'Хорошо';
    if (moodScore == 3) return 'Нормально';
    if (moodScore == 2) return 'Грустно';
    return 'Плохо';
  }
}

// History model
class MoodHistoryResponse {
  final int totalSurveys;
  final double avgMoodScore;
  final double avgStressLevel;
  final double avgOverallScore;
  final DateTime? lastSurveyDate;
  final int? lastMoodScore;
  final double moodTrend7Days;
  final List<MoodSurveyResponse> recentSurveys;

  MoodHistoryResponse({
    required this.totalSurveys,
    required this.avgMoodScore,
    required this.avgStressLevel,
    required this.avgOverallScore,
    this.lastSurveyDate,
    this.lastMoodScore,
    required this.moodTrend7Days,
    required this.recentSurveys,
  });

  factory MoodHistoryResponse.fromJson(Map<String, dynamic> json) {
    return MoodHistoryResponse(
      totalSurveys: json['totalSurveys'] ?? 0,
      avgMoodScore: (json['avgMoodScore'] ?? 0.0).toDouble(),
      avgStressLevel: (json['avgStressLevel'] ?? 0.0).toDouble(),
      avgOverallScore: (json['avgOverallScore'] ?? 0.0).toDouble(),
      lastSurveyDate: json['lastSurveyDate'] != null
          ? DateTime.parse(json['lastSurveyDate'])
          : null,
      lastMoodScore: json['lastMoodScore'],
      moodTrend7Days: (json['moodTrend7Days'] ?? 0.0).toDouble(),
      recentSurveys:
          (json['recentSurveys'] as List?)
              ?.map((e) => MoodSurveyResponse.fromJson(e))
              .toList() ??
          [],
    );
  }

  bool get isTrendPositive => moodTrend7Days > 0;
  bool get isTrendNeutral => moodTrend7Days.abs() < 5.0;

  String get trendLabel {
    if (isTrendNeutral) return 'Стабильно';
    return isTrendPositive ? 'Улучшение' : 'Ухудшение';
  }

  String get trendEmoji {
    if (isTrendNeutral) return '➡️';
    return isTrendPositive ? '📈' : '📉';
  }
}
