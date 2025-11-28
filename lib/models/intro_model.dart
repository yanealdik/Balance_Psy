class IntroContent {
  final int id;
  final String contentType; // video, article, meditation
  final String title;
  final String? description;
  final String? contentUrl;
  final String? contentText;
  final String? audioUrl;
  final int? durationSeconds;
  final int sortOrder;

  IntroContent({
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

  factory IntroContent.fromJson(Map<String, dynamic> json) {
    return IntroContent(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentType': contentType,
      'title': title,
      'description': description,
      'contentUrl': contentUrl,
      'contentText': contentText,
      'audioUrl': audioUrl,
      'durationSeconds': durationSeconds,
      'sortOrder': sortOrder,
    };
  }
}
