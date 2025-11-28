class DiagnosticSubmissionRequest {
  final List<int> phq9Answers;
  final List<int> gad7Answers;
  final List<int> eat26Answers;
  final BddAnswers bddAnswers;
  final List<int> perfectionismAnswers;

  DiagnosticSubmissionRequest({
    required this.phq9Answers,
    required this.gad7Answers,
    required this.eat26Answers,
    required this.bddAnswers,
    required this.perfectionismAnswers,
  });

  Map<String, dynamic> toJson() {
    return {
      'phq9Answers': phq9Answers,
      'gad7Answers': gad7Answers,
      'eat26Answers': eat26Answers,
      'bddAnswers': bddAnswers.toJson(),
      'perfectionismAnswers': perfectionismAnswers,
    };
  }
}

class BddAnswers {
  final bool concernedAboutAppearance;
  final bool thinksAboutItALot;
  final List<String> bodyPartsNotLiked;
  final bool mainConcernIsWeight;
  final bool causesDistress;
  final bool interferesWithSocialLife;
  final bool causesWorkProblems;
  final bool avoidsThings;
  final int timeThinkingPerDay; // 0: <1h, 1: 1-3h, 2: >3h

  BddAnswers({
    required this.concernedAboutAppearance,
    required this.thinksAboutItALot,
    required this.bodyPartsNotLiked,
    required this.mainConcernIsWeight,
    required this.causesDistress,
    required this.interferesWithSocialLife,
    required this.causesWorkProblems,
    required this.avoidsThings,
    required this.timeThinkingPerDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'concernedAboutAppearance': concernedAboutAppearance,
      'thinksAboutItALot': thinksAboutItALot,
      'bodyPartsNotLiked': bodyPartsNotLiked,
      'mainConcernIsWeight': mainConcernIsWeight,
      'causesDistress': causesDistress,
      'interferesWithSocialLife': interferesWithSocialLife,
      'causesWorkProblems': causesWorkProblems,
      'avoidsThings': avoidsThings,
      'timeThinkingPerDay': timeThinkingPerDay,
    };
  }
}

class DiagnosticResult {
  final int? id;
  final int? userId;
  final int? phq9Score;
  final String? phq9Interpretation;
  final int? gad7Score;
  final String? gad7Interpretation;
  final int? eat26Score;
  final String? eat26Interpretation;
  final bool? bddPositive;
  final String? bddInterpretation;
  final int? perfectionismScore;
  final String? perfectionismInterpretation;
  final DateTime? completedAt;
  final DateTime? createdAt;

  DiagnosticResult({
    this.id,
    this.userId,
    this.phq9Score,
    this.phq9Interpretation,
    this.gad7Score,
    this.gad7Interpretation,
    this.eat26Score,
    this.eat26Interpretation,
    this.bddPositive,
    this.bddInterpretation,
    this.perfectionismScore,
    this.perfectionismInterpretation,
    this.completedAt,
    this.createdAt,
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      phq9Score: json['phq9Score'] as int?,
      phq9Interpretation: json['phq9Interpretation'] as String?,
      gad7Score: json['gad7Score'] as int?,
      gad7Interpretation: json['gad7Interpretation'] as String?,
      eat26Score: json['eat26Score'] as int?,
      eat26Interpretation: json['eat26Interpretation'] as String?,
      bddPositive: json['bddPositive'] as bool?,
      bddInterpretation: json['bddInterpretation'] as String?,
      perfectionismScore: json['perfectionismScore'] as int?,
      perfectionismInterpretation:
          json['perfectionismInterpretation'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

class IntroContentItem {
  final int id;
  final String contentType; // video, article, meditation
  final String title;
  final String? description;
  final String? contentUrl;
  final String? contentText;
  final String? audioUrl;
  final int? durationSeconds;
  final int sortOrder;

  IntroContentItem({
    required this.id,
    required this.contentType,
    required this.title,
    this.description,
    this.contentUrl,
    this.contentText,
    this.audioUrl,
    this.durationSeconds,
    required this.sortOrder,
  });

  factory IntroContentItem.fromJson(Map<String, dynamic> json) {
    return IntroContentItem(
      id: json['id'] as int,
      contentType: json['contentType'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      contentUrl: json['contentUrl'] as String?,
      contentText: json['contentText'] as String?,
      audioUrl: json['audioUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      sortOrder: json['sortOrder'] as int,
    );
  }
}
