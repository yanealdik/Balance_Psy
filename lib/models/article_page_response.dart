import 'article_model.dart';

class ArticlePageResponse {
  final List<ArticleModel> articles;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;

  ArticlePageResponse({
    required this.articles,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
  });

  factory ArticlePageResponse.fromJson(Map<String, dynamic> json) {
    return ArticlePageResponse(
      articles: (json['articles'] as List<dynamic>)
          .map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      totalItems: (json['totalItems'] as num).toInt(),
      pageSize: json['pageSize'] as int,
    );
  }
}
