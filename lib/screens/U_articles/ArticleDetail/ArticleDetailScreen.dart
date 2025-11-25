// ========== lib/screens/U_articles/ArticleDetail/ArticleDetailScreen.dart (ОБНОВЛЁННЫЙ) ==========

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/article_model.dart';
import '../../../services/article_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String slug;
  final String? title;
  final String? thumbnailUrl;
  final String? category;
  final int? readTime;

  const ArticleDetailScreen({
    super.key,
    required this.slug,
    this.title,
    this.thumbnailUrl,
    this.category,
    this.readTime,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ArticleService _articleService = ArticleService();
  final ScrollController _scrollController = ScrollController();

  ArticleModel? _article;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isBookmarked = false;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadArticle();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showTitle) {
      setState(() => _showTitle = true);
    } else if (_scrollController.offset <= 200 && _showTitle) {
      setState(() => _showTitle = false);
    }
  }

  Future<void> _loadArticle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final article = await _articleService.getArticleBySlug(widget.slug);

      setState(() {
        _article = article;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_article == null) {
      return _buildNotFoundState();
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildArticleHeader(),
              const Divider(height: 32),
              _buildArticleContent(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    // ✅ HEADER IMAGE (широкая картинка в шапке)
    final headerUrl = _article?.headerUrl ?? widget.thumbnailUrl;
    final title = _article?.title ?? widget.title ?? 'Статья';

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isBookmarked
                        ? 'Статья добавлена в закладки'
                        : 'Статья удалена из закладок',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: AppColors.textPrimary),
            onPressed: _shareArticle,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: _showTitle
            ? Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ✅ HEADER IMAGE (широкая картинка)
            if (headerUrl != null)
              Image.network(
                headerUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
            else
              _buildPlaceholderImage(),

            // Градиент снизу
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: const Center(
        child: Icon(Icons.article_outlined, size: 80, color: AppColors.primary),
      ),
    );
  }

  Widget _buildArticleHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Категория
          if (_article!.category.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _article!.categoryDisplayName,
                style: AppTextStyles.body2.copyWith(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Заголовок
          Text(
            _article!.title,
            style: AppTextStyles.h1.copyWith(fontSize: 28, height: 1.3),
          ),

          const SizedBox(height: 16),

          // Метаданные
          Row(
            children: [
              if (_article!.readTime != null) ...[
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_article!.readTime} мин',
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
              ],

              if (_article!.viewCount != null) ...[
                const Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_article!.viewCount} просмотров',
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
              ],

              if (_article!.createdAt != null) ...[
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(_article!.createdAt!),
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent() {
    if (_article!.content == null || _article!.content!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          _article!.excerpt ?? 'Содержимое статьи отсутствует.',
          style: AppTextStyles.body1.copyWith(fontSize: 16, height: 1.7),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Html(
        data: _article!.content!,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(16),
            lineHeight: LineHeight.number(1.7),
            color: AppColors.textPrimary,
            fontFamily: 'Manrope',
          ),
          "h1": Style(
            fontSize: FontSize(24),
            fontWeight: FontWeight.w700,
            margin: Margins.only(top: 24, bottom: 16),
          ),
          "h2": Style(
            fontSize: FontSize(22),
            fontWeight: FontWeight.w600,
            margin: Margins.only(top: 20, bottom: 12),
          ),
          "h3": Style(
            fontSize: FontSize(20),
            fontWeight: FontWeight.w600,
            margin: Margins.only(top: 16, bottom: 10),
          ),
          "p": Style(margin: Margins.only(bottom: 16)),
          "ul": Style(margin: Margins.only(bottom: 16, left: 20)),
          "ol": Style(margin: Margins.only(bottom: 16, left: 20)),
          "li": Style(margin: Margins.only(bottom: 8)),
          "blockquote": Style(
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 4),
            ),
            margin: Margins.symmetric(vertical: 16),
            padding: HtmlPaddings.only(left: 16),
            backgroundColor: AppColors.primary.withOpacity(0.05),
          ),
          "code": Style(
            backgroundColor: AppColors.inputBorder.withOpacity(0.3),
            padding: HtmlPaddings.symmetric(horizontal: 6, vertical: 2),
            fontFamily: 'monospace',
          ),
        },
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
              onPressed: _loadArticle,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Статья не найдена',
              style: AppTextStyles.h3.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareArticle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Функция "Поделиться" будет доступна скоро'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
