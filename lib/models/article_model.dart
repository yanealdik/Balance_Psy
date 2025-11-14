class ArticleModel {
  final int id;
  final String status;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content;
  final String category;
  final int? readTime;
  final String? imageUrl;
  final DateTime? createdAt;

  ArticleModel({
    required this.id,
    required this.status,
    required this.title,
    required this.slug,
    this.excerpt,
    this.content,
    required this.category,
    this.readTime,
    this.imageUrl,
    this.createdAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'draft',
      title: json['title'] as String,
      slug: json['slug'] as String,
      excerpt: json['excerpt'] as String?,
      content: json['content'] as String?,
      category: json['category'] as String,
      readTime: json['read_time'] as int?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'title': title,
      'slug': slug,
      'excerpt': excerpt,
      'content': content,
      'category': category,
      'read_time': readTime,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
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

// Response wrapper для Directus API
class DirectusArticlesResponse {
  final List<ArticleModel> data;
  final int? total;

  DirectusArticlesResponse({required this.data, this.total});

  factory DirectusArticlesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return DirectusArticlesResponse(
      data: dataList
          .map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['meta']?['total_count'] as int?,
    );
  }
}
