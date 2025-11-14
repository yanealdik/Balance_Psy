import '../models/article_model.dart';
import 'directus_service.dart';

class ArticleService {
  final DirectusService _directusService = DirectusService();

  /// Получить рекомендованные статьи для главной (топ-3)
  Future<List<ArticleModel>> getRecommendedArticles() async {
    try {
      final response = await _directusService.getArticles(limit: 3);
      return response.data;
    } catch (e) {
      print('❌ Error fetching recommended articles: $e');
      return _getFallbackArticles();
    }
  }

  /// Получить все статьи с пагинацией
  Future<DirectusArticlesResponse> getArticles({
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    return await _directusService.getArticles(
      category: category,
      limit: limit,
      offset: offset,
    );
  }

  /// Поиск статей
  Future<List<ArticleModel>> searchArticles(String query) async {
    try {
      final response = await _directusService.searchArticles(query);
      return response.data;
    } catch (e) {
      print('❌ Error searching articles: $e');
      return [];
    }
  }

  /// Получить статью по slug
  Future<ArticleModel?> getArticleBySlug(String slug) async {
    return await _directusService.getArticleBySlug(slug);
  }

  /// Fallback статьи (если Directus недоступен)
  List<ArticleModel> _getFallbackArticles() {
    return [
      ArticleModel(
        id: 1,
        status: 'published',
        title: 'Как прожить грусть с пользой',
        slug: 'how-to-deal-with-sadness',
        excerpt:
            'Грусть — это нормальная эмоция. Узнайте, как правильно её проживать.',
        category: 'emotions',
        readTime: 5,
        imageUrl: 'assets/images/article/sad.png',
      ),
      ArticleModel(
        id: 2,
        status: 'published',
        title: 'Что делать, когда нет сил',
        slug: 'what-to-do-when-tired',
        excerpt: 'Выгорание и усталость — как с ними справиться.',
        category: 'self_help',
        readTime: 6,
        imageUrl: 'assets/images/article/depressed.png',
      ),
      ArticleModel(
        id: 3,
        status: 'published',
        title: 'Почему любовь нас вдохновляет',
        slug: 'why-love-inspires',
        excerpt: 'Любовь — мощный источник мотивации.',
        category: 'relationships',
        readTime: 7,
        imageUrl: 'assets/images/article/love.png',
      ),
    ];
  }
}
