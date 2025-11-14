import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/article_model.dart';
import '../../services/directus_service.dart';
import 'ArticleDetail/ArticleDetailScreen.dart';

/// Экран полезных статей - интеграция с Directus
class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final DirectusService _directusService = DirectusService();

  int selectedCategory = 0;
  List<ArticleModel> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<CategoryItem> categories = [
    CategoryItem(name: 'Все', value: null),
    CategoryItem(name: 'Эмоции', value: 'emotions'),
    CategoryItem(name: 'Самопомощь', value: 'self_help'),
    CategoryItem(name: 'Отношения', value: 'relationships'),
    CategoryItem(name: 'Стресс', value: 'stress'),
  ];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final category = categories[selectedCategory].value;
      final response = await _directusService.getArticles(
        category: category,
        limit: 50,
      );

      setState(() {
        _articles = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Группировка статей по секциям
  Map<String, List<ArticleModel>> get groupedArticles {
    if (_articles.isEmpty) return {};

    // Простая группировка: все статьи в одну секцию по категориям
    Map<String, List<ArticleModel>> grouped = {};

    for (var article in _articles) {
      final sectionName = article.categoryDisplayName;
      if (!grouped.containsKey(sectionName)) {
        grouped[sectionName] = [];
      }
      grouped[sectionName]!.add(article);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Полезные статьи',
                    style: AppTextStyles.h2.copyWith(fontSize: 28),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Категории
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildCategoryChip(index),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Контент
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_articles.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadArticles,
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildSections(),
        ),
      ),
    );
  }

  List<Widget> _buildSections() {
    List<Widget> sections = [];
    final grouped = groupedArticles;

    grouped.forEach((sectionTitle, articles) {
      sections.addAll([
        _buildSectionTitle(sectionTitle),
        const SizedBox(height: 16),
        _buildHorizontalArticlesList(articles),
        const SizedBox(height: 32),
      ]);
    });

    if (sections.isNotEmpty) {
      sections.removeLast();
      sections.add(const SizedBox(height: 30));
    }

    return sections;
  }

  Widget _buildHorizontalArticlesList(List<ArticleModel> articles) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < articles.length - 1 ? 16 : 0,
            ),
            child: _buildArticleCard(article),
          );
        },
      ),
    );
  }

  Widget _buildArticleCard(ArticleModel article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              slug: article.slug,
              title: article.title,
              category: article.categoryDisplayName,
              readTime: article.readTime,
              imageUrl: article.imageUrl,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Контейнер со стеком (110x110)
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              children: [
                // Нижний слой (синяя "тень")
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                // Верхний слой (белая карточка с изображением)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 103,
                    height: 103,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: article.imageUrl != null
                          ? Image.network(
                              article.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderIcon();
                              },
                            )
                          : _buildPlaceholderIcon(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Текст под карточкой
          SizedBox(
            width: 110,
            child: Text(
              article.title,
              style: AppTextStyles.body1.copyWith(fontSize: 12, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: const Center(
        child: Icon(Icons.article, size: 40, color: AppColors.primary),
      ),
    );
  }

  Widget _buildCategoryChip(int index) {
    final isSelected = selectedCategory == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = index;
        });
        _loadArticles();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          categories[index].name,
          style: AppTextStyles.body1.copyWith(
            fontSize: 15,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.h3.copyWith(fontSize: 22)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Статей не найдено',
            style: AppTextStyles.h3.copyWith(
              fontSize: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'В этой категории пока нет статей',
            style: AppTextStyles.body2.copyWith(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              setState(() {
                selectedCategory = 0;
              });
              _loadArticles();
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Показать все статьи',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: AppTextStyles.h3.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Неизвестная ошибка',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadArticles,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Вспомогательный класс для категорий
class CategoryItem {
  final String name;
  final String? value;

  CategoryItem({required this.name, this.value});
}

