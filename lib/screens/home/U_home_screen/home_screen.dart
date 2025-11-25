import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_calendar.dart';
import '../../../widgets/session_card.dart';
import '../../../widgets/home/welcome_card.dart';
import '../../../widgets/home/mood_tracker.dart';
import '../../../widgets/home/top_bar.dart';
import '../../../widgets/home/section_header.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/appointment_provider.dart'; // ✅ Добавлено
import '../../../services/article_service.dart';
import '../../../models/article_model.dart';
import '../../U_psy_catalog/psy_catalog.dart';
import '../../U_articles/article_screen.dart';
import '../../MoodSurvey/MoodSurveyScreen.dart';
import '../../chats/Message/Message_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadRecommendedArticles();
    // ✅ Загружаем записи пользователя
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  // ✅ НОВЫЙ МЕТОД: Загрузка записей
  Future<void> _loadAppointments() async {
    final appointmentProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );
    await appointmentProvider.loadMyAppointments();
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

  Future<void> _openChat(int psychologistId) async {
    final chatProvider = context.read<ChatProvider>();

    // Показать индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      // ✅ Получить или создать чат
      final chat = await chatProvider.getOrCreateChat(psychologistId);

      // Закрыть индикатор
      if (mounted) Navigator.pop(context);

      if (chat != null && mounted) {
        // Перейти в чат
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageScreen(
              chatRoomId: chat.id,
              partnerName: chat.partnerName,
              partnerImage: chat.partnerImage,
              isOnline: chat.isPartnerOnline,
            ),
          ),
        );
      } else {
        // Ошибка создания чата
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не удалось открыть чат'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      // Закрыть индикатор
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AppointmentProvider>(
      builder: (context, authProvider, appointmentProvider, child) {
        final user = authProvider.user;
        final userName = user?.fullName?.split(' ')[0] ?? 'Пользователь';

        // ✅ Получаем реальные записи
        final allAppointments = appointmentProvider.appointments;

        // ✅ Ближайшая предстоящая запись
        final upcomingAppointment =
            allAppointments.where((apt) {
              return apt.status == 'PENDING' || apt.status == 'CONFIRMED';
            }).isNotEmpty
            ? allAppointments.firstWhere(
                (apt) => apt.status == 'PENDING' || apt.status == 'CONFIRMED',
              )
            : null;

        // ✅ Даты с записями для календаря
        final appointmentDates = allAppointments
            .map((apt) {
              try {
                return DateTime.parse(apt.appointmentDate);
              } catch (e) {
                return null;
              }
            })
            .where((date) => date != null)
            .cast<DateTime>()
            .toList();

        return SafeArea(
          child: Column(
            children: [
              HomeTopBar(
                onAvatarTap: () => _goToTab(context, 4),
                onCalendarTap: () => _showFullCalendar(appointmentDates),
                onNotificationsTap: _showNotifications,
                formattedDate: _getFormattedDate(),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadAppointments();
                    await _loadRecommendedArticles();
                  },
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
                          onExpand: () => _showFullCalendar(appointmentDates),
                          highlightedDates: appointmentDates,
                        ),
                        const SizedBox(height: 30),

                        // ✅ ОБНОВЛЕНО: Показываем реальную ближайшую запись
                        SectionHeader(title: 'Ближайшая сессия'),
                        const SizedBox(height: 16),

                        if (appointmentProvider.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (upcomingAppointment == null)
                          _buildNoSessionCard()
                        else
                          SessionCard(
                            psychologistName:
                                upcomingAppointment.psychologistName,
                            psychologistImage:
                                upcomingAppointment.psychologistAvatarUrl ??
                                'https://i.pravatar.cc/150?img=5',
                            dateTime:
                                '${_formatDate(upcomingAppointment.appointmentDate)}, ${upcomingAppointment.startTime}',
                            status: _getStatusText(upcomingAppointment.status),
                            statusColor: _getStatusColor(
                              upcomingAppointment.status,
                            ),
                            onChatTap: () => _openChat(
                              upcomingAppointment.psychologistId,
                            ), // ✅ ИСПРАВЛЕНО
                            showActions:
                                upcomingAppointment.status == 'CONFIRMED',
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
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ НОВЫЙ ВИДЖЕТ: Карточка когда нет записей
  Widget _buildNoSessionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'У вас пока нет записей',
            style: AppTextStyles.h3.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Найдите психолога и запишитесь на консультацию',
            style: AppTextStyles.body2.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _goToTab(context, 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Найти психолога',
                  style: AppTextStyles.button.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
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
      onTap: () => _goToTab(context, 2),
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
    Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: article.thumbnailUrl != null && article.thumbnailUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                article.thumbnailUrl!,
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

  // ✅ Вспомогательные методы
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return 'Сегодня';
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day + 1) {
        return 'Завтра';
      }

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

      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Ожидается подтверждение';
      case 'CONFIRMED':
        return 'Подтверждено';
      case 'COMPLETED':
        return 'Завершено';
      case 'CANCELLED':
        return 'Отменено';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFD4A747);
      case 'CONFIRMED':
        return const Color(0xFF1976D2);
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELLED':
        return AppColors.error;
      default:
        return const Color(0xFF757575);
    }
  }

  void _showFullCalendar(List<DateTime> appointmentDates) {
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
