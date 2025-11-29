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
      rating: RatingStats.fromJson(json['rating'] ?? {}),
      clients: ClientStats.fromJson(json['clients'] ?? {}),
      sessions: SessionStats.fromJson(json['sessions'] ?? {}),
      earnings: EarningsStats.fromJson(json['earnings'] ?? {}),
      effectiveness: EffectivenessStats.fromJson(json['effectiveness'] ?? {}),
      visibility: VisibilityStats.fromJson(json['visibility'] ?? {}),
    );
  }
}

// ... Nested classes (см. в PROGRESS_STATISTICS_SPEC.md)
