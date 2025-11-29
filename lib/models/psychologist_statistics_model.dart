class PsychologistStatistics {
  final RatingStats rating;
  final ClientStats clients;
  final SessionStats sessions;
  final EarningsStats earnings;
  final EffectivenessStats effectiveness;
  final VisibilityStats visibility;

  PsychologistStatistics({
    required this.rating,
    required this.clients,
    required this.sessions,
    required this.earnings,
    required this.effectiveness,
    required this.visibility,
  });

  factory PsychologistStatistics.fromJson(Map<String, dynamic> json) {
    return PsychologistStatistics(
      rating: RatingStats.fromJson(json['ratingStats'] ?? {}),
      clients: ClientStats.fromJson(json['clientStats'] ?? {}),
      sessions: SessionStats.fromJson(json['sessionStats'] ?? {}),
      earnings: EarningsStats.fromJson(json['earningsStats'] ?? {}),
      effectiveness: EffectivenessStats.fromJson(
        json['effectivenessStats'] ?? {},
      ),
      visibility: VisibilityStats.fromJson(json['visibilityStats'] ?? {}),
    );
  }

  factory PsychologistStatistics.empty() {
    return PsychologistStatistics(
      rating: RatingStats.empty(),
      clients: ClientStats.empty(),
      sessions: SessionStats.empty(),
      earnings: EarningsStats.empty(),
      effectiveness: EffectivenessStats.empty(),
      visibility: VisibilityStats.empty(),
    );
  }
}

// ========== РЕЙТИНГ ==========
class RatingStats {
  final double averageRating;
  final int totalReviews;
  final int reviews5Star;
  final int reviews4Star;
  final int reviews3Star;
  final int reviews2Star;
  final int reviews1Star;

  RatingStats({
    required this.averageRating,
    required this.totalReviews,
    required this.reviews5Star,
    required this.reviews4Star,
    required this.reviews3Star,
    required this.reviews2Star,
    required this.reviews1Star,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    return RatingStats(
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      reviews5Star: json['reviews5Star'] ?? 0,
      reviews4Star: json['reviews4Star'] ?? 0,
      reviews3Star: json['reviews3Star'] ?? 0,
      reviews2Star: json['reviews2Star'] ?? 0,
      reviews1Star: json['reviews1Star'] ?? 0,
    );
  }

  factory RatingStats.empty() {
    return RatingStats(
      averageRating: 0.0,
      totalReviews: 0,
      reviews5Star: 0,
      reviews4Star: 0,
      reviews3Star: 0,
      reviews2Star: 0,
      reviews1Star: 0,
    );
  }
}

// ========== КЛИЕНТЫ ==========
class ClientStats {
  final int totalClients;
  final int activeClients;
  final int newClientsThisMonth;

  ClientStats({
    required this.totalClients,
    required this.activeClients,
    required this.newClientsThisMonth,
  });

  factory ClientStats.fromJson(Map<String, dynamic> json) {
    return ClientStats(
      totalClients: json['totalClients'] ?? 0,
      activeClients: json['activeClients'] ?? 0,
      newClientsThisMonth: json['newClientsThisMonth'] ?? 0,
    );
  }

  factory ClientStats.empty() {
    return ClientStats(
      totalClients: 0,
      activeClients: 0,
      newClientsThisMonth: 0,
    );
  }
}

// ========== СЕССИИ ==========
class SessionStats {
  final int totalCompletedSessions;
  final int completedSessionsThisMonth;
  final int successfulSessions;
  final double avgSessionDurationMinutes;
  final int upcomingSessions;
  final int newBookingsThisMonth;

  SessionStats({
    required this.totalCompletedSessions,
    required this.completedSessionsThisMonth,
    required this.successfulSessions,
    required this.avgSessionDurationMinutes,
    required this.upcomingSessions,
    required this.newBookingsThisMonth,
  });

  factory SessionStats.fromJson(Map<String, dynamic> json) {
    return SessionStats(
      totalCompletedSessions: json['totalCompletedSessions'] ?? 0,
      completedSessionsThisMonth: json['completedSessionsThisMonth'] ?? 0,
      successfulSessions: json['successfulSessions'] ?? 0,
      avgSessionDurationMinutes: (json['avgSessionDurationMinutes'] ?? 0.0)
          .toDouble(),
      upcomingSessions: json['upcomingSessions'] ?? 0,
      newBookingsThisMonth: json['newBookingsThisMonth'] ?? 0,
    );
  }

  factory SessionStats.empty() {
    return SessionStats(
      totalCompletedSessions: 0,
      completedSessionsThisMonth: 0,
      successfulSessions: 0,
      avgSessionDurationMinutes: 0.0,
      upcomingSessions: 0,
      newBookingsThisMonth: 0,
    );
  }
}

// ========== ДОХОДЫ ==========
class EarningsStats {
  final double totalEarnings;
  final double monthEarnings;
  final double weekEarnings;

  EarningsStats({
    required this.totalEarnings,
    required this.monthEarnings,
    required this.weekEarnings,
  });

  factory EarningsStats.fromJson(Map<String, dynamic> json) {
    return EarningsStats(
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      monthEarnings: (json['monthEarnings'] ?? 0.0).toDouble(),
      weekEarnings: (json['weekEarnings'] ?? 0.0).toDouble(),
    );
  }

  factory EarningsStats.empty() {
    return EarningsStats(
      totalEarnings: 0.0,
      monthEarnings: 0.0,
      weekEarnings: 0.0,
    );
  }
}

// ========== ЭФФЕКТИВНОСТЬ ==========
class EffectivenessStats {
  final double goalsAchievedRate;
  final double averageSessionRating;

  EffectivenessStats({
    required this.goalsAchievedRate,
    required this.averageSessionRating,
  });

  factory EffectivenessStats.fromJson(Map<String, dynamic> json) {
    return EffectivenessStats(
      goalsAchievedRate: (json['goalsAchievedRate'] ?? 0.0).toDouble(),
      averageSessionRating: (json['averageSessionRating'] ?? 0.0).toDouble(),
    );
  }

  factory EffectivenessStats.empty() {
    return EffectivenessStats(
      goalsAchievedRate: 0.0,
      averageSessionRating: 0.0,
    );
  }
}

// ========== ПОПУЛЯРНОСТЬ ==========
class VisibilityStats {
  final int profileViewsWeek;
  final int profileViewsMonth;
  final int profileViewsTotal;

  VisibilityStats({
    required this.profileViewsWeek,
    required this.profileViewsMonth,
    required this.profileViewsTotal,
  });

  factory VisibilityStats.fromJson(Map<String, dynamic> json) {
    return VisibilityStats(
      profileViewsWeek: json['profileViewsWeek'] ?? 0,
      profileViewsMonth: json['profileViewsMonth'] ?? 0,
      profileViewsTotal: json['profileViewsTotal'] ?? 0,
    );
  }

  factory VisibilityStats.empty() {
    return VisibilityStats(
      profileViewsWeek: 0,
      profileViewsMonth: 0,
      profileViewsTotal: 0,
    );
  }
}
