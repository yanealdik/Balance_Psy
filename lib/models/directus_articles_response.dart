import 'article_model.dart';

class DirectusArticlesResponse {
  final List<ArticleModel> articles;
  final int totalCount;

  DirectusArticlesResponse({
    required this.articles,
    required this.totalCount,
  });

  factory DirectusArticlesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final List<dynamic> rawList =
        data is List ? data : data == null ? <dynamic>[] : [data];

    final meta = json['meta'];
    final total = meta is Map<String, dynamic>
        ? meta['total_count'] ?? meta['filter_count']
        : null;

    return DirectusArticlesResponse(
      articles: rawList
          .whereType<Map<String, dynamic>>()
          .map(ArticleModel.fromDirectusJson)
          .toList(),
      totalCount: total is num ? total.toInt() : rawList.length,
    );
  }
}
