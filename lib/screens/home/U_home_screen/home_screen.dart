import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_calendar.dart';
import '../../../widgets/session_card.dart';
import '../../../widgets/home/welcome_card.dart';
import '../../../widgets/home/mood_tracker.dart';
import '../../../widgets/home/top_bar.dart';
import '../../../widgets/home/section_header.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/article_service.dart';
import '../../../models/article_model.dart';
import '../../U_psy_catalog/psy_catalog.dart';
import '../../U_articles/article_screen.dart';
import '../../MoodSurvey/MoodSurveyScreen.dart';
import '../../chats/U_chats/chats_screen.dart';
import '../../profile/U_profile/profile_screen.dart';
import '../../../widgets/custom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    _HomeContent(),
    PsychologistsScreen(),
    ArticlesScreen(),
    ChatsScreen(),
    ProfileScreen(),
  ];

  void navigateToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _screens[_index],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _index,
        onTap: navigateToTab,
        icons: NavConfig.userIcons,
        selectedColor: AppColors.primary,
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  DateTime selectedDate = DateTime.now();
  final ArticleService _articleService = ArticleService();
  List<ArticleModel> _recommendedArticles = [];
  bool _isLoadingArticles = true;

  final appointmentDates = [
    DateTime.now(),
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 5)),
  ];

  @override
  void initState() {
    super.initState();
    _loadRecommendedArticles();
  }

  Future<void> _loadRecommendedArticles() async {
    try {
      final articles = await _articleService.getRecommendedArticles();
      setState(() {
        _recommendedArticles = articles;
        _isLoadingArticles = false;
      });
    } catch (e) {
      print('❌ Error loading articles: $e');
      setState(() => _isLoadingArticles = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final userName = user?.fullName?.split(' ')[0] ?? 'Пользователь';

        return SafeArea(
          child: Column(
            children: [
              HomeTopBar(
                onAvatarTap: () => _goToTab(context, 4),
                onCalendarTap: _showFullCalendar,
                onNotificationsTap: _showNotifications,
                formattedDate: _getFormattedDate(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      WelcomeCard(
                        userName: userName,
                        onSurveyTap: _showMoodSurvey,
                      ),
                      const SizedBox(height: 24),
                      CompactCalendarCard(
                        selectedDate: selectedDate,
                        onDateSelected: (date) =>
                            setState(() => selectedDate = date),
                        onExpand: _showFullCalendar,
                        highlightedDates: appointmentDates,
                      ),
                      const SizedBox(height: 30),
                      SectionHeader(title: 'Ближайшая сессия'),
                      const SizedBox(height: 16),
                      SessionCard(
                        psychologistName: 'Галия Аубакирова',
                        psychologistImage: 'assets/images/avatar/Galiya.png',
                        dateTime: 'Сегодня, 15:30',
                        status: 'Через 2 часа',
                        statusColor: const Color(0xFFD4A747),
                        onChatTap: () => _goToTab(context, 3),
                      ),
                      const SizedBox(height: 30),
                      SectionHeader(title: 'Твоё настроение'),
                      const SizedBox(height: 16),
                      MoodTracker(onMoodSelected: _saveMood),
                      const SizedBox(height: 30),
                      SectionHeader(
                        title: 'Полезно для тебя',
                        onTap: () => _goToTab(context, 2),
                      ),
                      const SizedBox(height: 16),
                      _buildRecommendedArticles(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendedArticles() {
    if (_isLoadingArticles) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recommendedArticles.isEmpty) {
      return Center(
        child: Text('Статьи скоро появятся', style: AppTextStyles.body2),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendedArticles.length,
        itemBuilder: (context, index) {
          final article = _recommendedArticles[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildArticleCard(article),
          );
        },
      ),
    );
  }

  Widget _buildArticleCard(ArticleModel article) {
    return GestureDetector(
      onTap: () {
        // TODO: Навигация к детальному экрану статьи
        _goToTab(context, 2);
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: article.imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.asset(
                        article.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.article,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.article,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: AppTextStyles.h3.copyWith(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article.categoryDisplayName,
                          style: AppTextStyles.body3.copyWith(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${article.readTime ?? 5} мин',
                        style: AppTextStyles.body3.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
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
    return '${now.day} ${months[now.month - 1]}';
  }

  void _showFullCalendar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Календарь',
                style: AppTextStyles.h2.copyWith(fontSize: 24),
              ),
            ),
            Expanded(
              child: CustomCalendar(
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  setState(() => selectedDate = date);
                  Navigator.pop(context);
                },
                highlightedDates: appointmentDates,
                showFullMonth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoodSurvey() => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MoodSurveyScreen()),
  );

  void _saveMood(String mood) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Настроение "$mood" сохранено'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Уведомления',
                style: AppTextStyles.h2.copyWith(fontSize: 24),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Нет новых уведомлений',
                  style: AppTextStyles.body2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _goToTab(BuildContext context, int index) {
  context.findAncestorStateOfType<_HomeScreenState>()?.navigateToTab(index);
}
