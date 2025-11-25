
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/article_model.dart';
import '../models/article_page_response.dart';

class ArticleService {
  final Dio _dio = ApiClient.instance;

  /// Получить список статей с пагинацией
  Future<ArticlePageResponse> getArticles({
    String? category,
    int page = 0,
    int size = 20,
  }) async {
    try {
      print('📋 Fetching articles: category=$category, page=$page, size=$size');

      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final response = await _dio.get(
        '/api/articles',
        queryParameters: queryParams,
      );

      print('✅ Articles fetched: ${response.statusCode}');

      if (response.data['success'] == true) {
        return ArticlePageResponse.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }

      throw Exception(response.data['message'] ?? 'Failed to load articles');
    } on DioException catch (e) {
      print('❌ Failed to fetch articles: ${e.message}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load articles',
      );
    }
  }

  /// Получить статью по slug
  Future<ArticleModel> getArticleBySlug(String slug) async {
    try {
      print('📖 Fetching article: $slug');

      final response = await _dio.get('/api/articles/slug/$slug');

      print('✅ Article fetched: ${response.statusCode}');

      if (response.data['success'] == true) {
        return ArticleModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }

      throw Exception(response.data['message'] ?? 'Article not found');
    } on DioException catch (e) {
      print('❌ Failed to fetch article: ${e.message}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load article',
      );
    }
  }

  /// Поиск статей
  Future<ArticlePageResponse> searchArticles({
    required String query,
    int page = 0,
    int size = 20,
  }) async {
    try {
      print('🔍 Searching articles: query=$query');

      final response = await _dio.get(
        '/api/articles/search',
        queryParameters: {
          'query': query,
          'page': page,
          'size': size,
        },
      );

      if (response.data['success'] == true) {
        return ArticlePageResponse.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }

      throw Exception(response.data['message'] ?? 'Search failed');
    } on DioException catch (e) {
      print('❌ Search failed: ${e.message}');
      throw Exception(e.response?.data['message'] ?? 'Search failed');
    }
  }

  /// Получить топ статей
  Future<List<ArticleModel>> getTopArticles({int limit = 10}) async {
    try {
      print('⭐ Fetching top articles');

      final response = await _dio.get(
        '/api/articles/top',
        queryParameters: {'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to load top articles');
    } on DioException catch (e) {
      print('❌ Failed to fetch top articles: ${e.message}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load top articles',
      );
    }
  }

  /// Получить рекомендованные статьи (для главной)
  Future<List<ArticleModel>> getRecommendedArticles() async {
    try {
      final response = await getArticles(page: 0, size: 3);
      return response.articles;
    } catch (e) {
      print('❌ Error loading recommended articles: $e');
      return [];
    }
  }
}