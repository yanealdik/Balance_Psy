class ArticleModel {
  final int id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content;
  final String category;
  final int? readTime;
  final String? thumbnailUrl; // ✅ Для списка
  final String? headerUrl; // ✅ Для детальной страницы
  final int? viewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ArticleModel({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.content,
    required this.category,
    this.readTime,
    this.thumbnailUrl,
    this.headerUrl,
    this.viewCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      excerpt: json['excerpt'] as String?,
      content: json['content'] as String?,
      category: json['category'] as String,
      readTime: json['readTime'] as int?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      headerUrl: json['headerUrl'] as String?,
      viewCount: json['viewCount'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  factory ArticleModel.fromDirectusJson(Map<String, dynamic> json) {
    int? toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    DateTime? parseDate(dynamic value) {
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final imageUrl = json['image_url'] as String?;
    final headerUrl = json['header_url'] as String?;

    return ArticleModel(
      id: toInt(json['id']) ?? 0,
      title: (json['title'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      excerpt: json['excerpt'] as String?,
      content: json['content'] as String?,
      category: (json['category'] as String?) ?? 'other',
      readTime: toInt(json['read_time']),
      thumbnailUrl: imageUrl,
      headerUrl: headerUrl ?? imageUrl,
      viewCount: toInt(json['view_count']),
      createdAt: parseDate(json['date_created'] ?? json['created_at']),
      updatedAt: parseDate(json['date_updated'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'excerpt': excerpt,
      'content': content,
      'category': category,
      'readTime': readTime,
      'thumbnailUrl': thumbnailUrl,
      'headerUrl': headerUrl,
      'viewCount': viewCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Маппинг категорий для UI
  String get categoryDisplayName {
    switch (category) {
      case 'emotions':
        return 'Эмоции';
      case 'self_help':
        return 'Самопомощь';
      case 'relationships':
        return 'Отношения';
      case 'stress':
        return 'Стресс';
      case 'other':
        return 'Другое';
      default:
        return category;
    }
  }
}
