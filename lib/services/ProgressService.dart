class ProgressService {
  final ApiService _api;

  Future<ClientProgress> getMyProgress() async {
    final response = await _api.get('/api/progress/me');
    return ClientProgress.fromJson(response.data['data']);
  }
}

class StatisticsService {
  final ApiService _api;

  Future<PsychologistStatistics> getMyStatistics() async {
    final response = await _api.get('/api/statistics/me');
    return PsychologistStatistics.fromJson(response.data['data']);
  }
}
