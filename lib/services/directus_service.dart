import 'package:dio/dio.dart';
import '../models/article_model.dart';
import '../core/constants/app_constants.dart';

class DirectusService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.directusUrl,
      connectTimeout: const Duration(milliseconds: 15000),
      receiveTimeout: const Duration(milliseconds: 15000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  DirectusService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🔵 DIRECTUS REQUEST: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ DIRECTUS RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          print(
            '❌ DIRECTUS ERROR: ${error.response?.statusCode} ${error.message}',
          );
          return handler.next(error);
        },
      ),
    );
  }

  Future<DirectusArticlesResponse> getArticles({
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'filter[status][_eq]': 'published',
        'fields':
            'id,title,slug,excerpt,category,read_time,image_url,content,date_created',
        'sort': '-date_created', // Используем системное поле Directus
        'limit': limit,
        'offset': offset,
        'meta': 'total_count',
      };

      // Добавляем фильтр по категории если указан
      if (category != null && category.isNotEmpty) {
        queryParams['filter[category][_eq]'] = category;
      }

      print('🔍 Directus Query: $queryParams');

      final response = await _dio.get(
        '/items/articles',
        queryParameters: queryParams,
      );

      print('✅ Directus Response Status: ${response.statusCode}');
      print('📦 Directus Response Data: ${response.data}');

      return DirectusArticlesResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      print('❌ Directus Error Details:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Headers: ${e.response?.headers}');
      throw _handleError(e);
    }
  }

  /// Получить статью по slug
  Future<ArticleModel?> getArticleBySlug(String slug) async {
    try {
      final response = await _dio.get(
        '/items/articles',
        queryParameters: {
          'filter[slug][_eq]': slug,
          'filter[status][_eq]': 'published',
          'limit': 1,
        },
      );

      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return null;
      }

      return ArticleModel.fromJson(data.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Поиск статей по тексту (title или excerpt)
  Future<DirectusArticlesResponse> searchArticles(String query) async {
    try {
      final response = await _dio.get(
        '/items/articles',
        queryParameters: {
          'filter[status][_eq]': 'published',
          'filter[_or][0][title][_contains]': query,
          'filter[_or][1][excerpt][_contains]': query,
          'fields': 'id,title,slug,excerpt,category,read_time,image_url',
          'sort[]': '-created_at',
          'limit': 20,
        },
      );

      return DirectusArticlesResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Получить статьи по массиву ID (для "Похожие статьи")
  Future<List<ArticleModel>> getArticlesByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    try {
      final response = await _dio.get(
        '/items/articles',
        queryParameters: {
          'filter[status][_eq]': 'published',
          'filter[id][_in]': ids.join(','),
          'fields': 'id,title,slug,excerpt,category,read_time,image_url',
        },
      );

      final data = response.data['data'] as List<dynamic>;
      return data
          .map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Обработка ошибок Directus
  String _handleError(DioException error) {
    if (error.response?.data != null) {
      final errorData = error.response!.data;
      if (errorData is Map && errorData.containsKey('errors')) {
        final errors = errorData['errors'] as List;
        if (errors.isNotEmpty) {
          return errors.first['message'] ?? 'Unknown error';
        }
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Превышено время ожидания. Проверьте подключение к интернету.';
      case DioExceptionType.badResponse:
        return 'Ошибка сервера: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Запрос отменен';
      default:
        return 'Ошибка соединения с сервером';
    }
  }
}
