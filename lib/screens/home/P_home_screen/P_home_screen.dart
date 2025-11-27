import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_navbar.dart';
import '../../../widgets/psychologist/psychologist_header.dart';
import '../../../widgets/psychologist/stats_card.dart';
import '../../../widgets/psychologist/request_card.dart';
import '../../../widgets/session_card_p.dart';
import '../../../widgets/psychologist/notifications_bottom_sheet.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../P_ReportsScreen/PsychologistReportsScreen.dart';
import '../../P_ScheduleScreen/PsychologistScheduleScreen.dart';
import '../../chats/P_chats/P_chats_screen.dart';
import '../../profile/P_profile/psycho_profile.dart';
import '../../P_AppointmentsScreen/SessionControlScreen.dart';

class PsychologistHomeScreen extends StatefulWidget {
  const PsychologistHomeScreen({super.key});
  @override
  State<PsychologistHomeScreen> createState() => _PsychologistHomeScreenState();
}

class _PsychologistHomeScreenState extends State<PsychologistHomeScreen> {
  int _index = 0;
  final _screens = const [
    _HomeContent(),
    PsychologistScheduleScreen(),
    PsychologistReportsScreen(),
    PsychologistChatsScreen(),
    PsychologistProfileScreen(),
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
        icons: NavConfig.psychologistIcons,
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

class _HomeContentState extends State<_HomeContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    final appointmentProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );
    await appointmentProvider.loadPsychologistAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final user = authProvider.user;
    final allAppointments = appointmentProvider.appointments;

    // ✅ ИСПРАВЛЕНО: Фильтруем записи по статусу
    final pendingRequests = allAppointments
        .where((apt) => apt.status == 'PENDING')
        .toList();

    // ✅ ИСПРАВЛЕНО: Показываем CONFIRMED и IN_PROGRESS сессии
    final upcomingSessions = allAppointments
        .where(
          (apt) => apt.status == 'CONFIRMED' || apt.status == 'IN_PROGRESS',
        )
        .toList();

    // ✅ НОВАЯ ЛОГИКА: Отдельно фильтруем сегодняшние сессии
    final todayAppointments = allAppointments.where((apt) {
      if (apt.status == 'CANCELLED' || apt.status == 'NO_SHOW') {
        return false;
      }

      final now = DateTime.now();
      final aptDate = DateTime.parse(apt.appointmentDate);
      return aptDate.year == now.year &&
          aptDate.month == now.month &&
          aptDate.day == now.day;
    }).toList();

    // ✅ Рассчитываем статистику
    final stats = {
      'todaySessions': todayAppointments.length,
      'pendingRequests': pendingRequests.length,
      'weekRevenue': _calculateWeekRevenue(allAppointments),
      'rating': 4.9,
    };

    return SafeArea(
      child: Column(
        children: [
          PsychologistHeader(
            name: user?.fullName ?? 'Психолог',
            avatarUrl: user?.avatarUrl,
            onNotificationsTap: _showNotificationsItem,
            hasNotifications: pendingRequests.isNotEmpty,
          ),

          // Статистика
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: StatsCard(
                    label: 'Сегодня',
                    value: '${stats['todaySessions']}',
                    unit: 'сессий',
                    icon: Icons.event_note,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatsCard(
                    label: 'Новые',
                    value: '${stats['pendingRequests']}',
                    unit: 'заявки',
                    icon: Icons.notifications_active,
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatsCard(
                    label: 'Неделя',
                    value:
                        '${((stats['weekRevenue'] as double) / 1000).toStringAsFixed(0)}к',
                    unit: '₸',
                    icon: Icons.wallet,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildTabBar(pendingRequests.length),
          const SizedBox(height: 20),

          Expanded(
            child: appointmentProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRequestsTab(pendingRequests),
                      _buildSessionsTab(upcomingSessions),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(int requestCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.button.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.button.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Заявки'),
                if (requestCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$requestCount',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'Расписание'),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(List<dynamic> pendingRequests) {
    if (pendingRequests.isEmpty) {
      return _buildEmptyState(
        'Нет новых заявок',
        'Новые заявки от клиентов появятся здесь',
        Icons.notifications_none,
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: pendingRequests.length,
        itemBuilder: (context, index) {
          final appointment = pendingRequests[index];

          final request = {
            'id': appointment.id,
            'clientName': appointment.clientName,
            'clientImage':
                appointment.clientAvatarUrl ??
                'https://i.pravatar.cc/150?img=25',
            'date': _formatDate(appointment.appointmentDate),
            'time': appointment.startTime,
            'format': appointment.format.toLowerCase(),
            'requestDate': _formatDateTime(appointment.createdAt),
            'issue': appointment.issueDescription ?? 'Консультация',
            'isFirstSession': true,
          };

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RequestCard(
              request: request,
              onAccept: () => _acceptRequest(appointment.id),
              onDecline: () => _declineRequest(appointment.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionsTab(List<dynamic> upcomingSessions) {
    if (upcomingSessions.isEmpty) {
      return _buildEmptyState(
        'Нет запланированных сессий',
        'Подтвержденные сессии появятся здесь',
        Icons.event_available,
      );
    }

    // ✅ КРИТИЧНО: Сортируем по дате и времени
    upcomingSessions.sort((a, b) {
      final dateA = DateTime.parse(a.appointmentDate);
      final dateB = DateTime.parse(b.appointmentDate);
      final comparison = dateA.compareTo(dateB);

      if (comparison != 0) return comparison;

      // Если даты равны, сортируем по времени
      return a.startTime.compareTo(b.startTime);
    });

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: upcomingSessions.length,
        itemBuilder: (context, index) {
          final appointment = upcomingSessions[index];

          final session = {
            'id': appointment.id,
            'clientName': appointment.clientName,
            'clientImage':
                appointment.clientAvatarUrl ??
                'https://i.pravatar.cc/150?img=30',
            'date': _formatDate(appointment.appointmentDate),
            'time': appointment.startTime,
            'format': appointment.format.toLowerCase(),
            'status': _getSessionStatus(appointment),
            'notes': appointment.notes ?? appointment.issueDescription,
          };

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SessionCardP(
              session: session,
              onChatTap: () {},
              onDetailsTap: () {
                // ✅ ИСПРАВЛЕНО: Переход в SessionControlScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SessionControlScreen(appointment: appointment),
                  ),
                ).then((_) {
                  // Обновляем список после возврата
                  _loadAppointments();
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.copyWith(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptRequest(int requestId) async {
    final appointmentProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );
    final success = await appointmentProvider.confirmAppointment(requestId);

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Заявка подтверждена!',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: const Text(
            'Клиент получит уведомление о подтверждении сессии.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Понятно',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appointmentProvider.errorMessage ?? 'Ошибка подтверждения',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _declineRequest(int requestId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cancel, color: AppColors.error, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Отклонить заявку?', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: const Text(
          'Вы уверены, что хотите отклонить эту заявку? Клиент получит уведомление.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Отклонить',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (result != true || !mounted) return;

    final appointmentProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );

    final success = await appointmentProvider.rejectAppointment(
      requestId,
      'Отклонено психологом',
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appointmentProvider.errorMessage ?? 'Ошибка отклонения',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showNotificationsItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsBottomSheet(),
    );
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

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} мин назад';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} ч назад';
      } else {
        return '${dt.day}.${dt.month}.${dt.year}';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  // ✅ ИСПРАВЛЕНА: Логика определения статуса сессии
  String _getSessionStatus(dynamic appointment) {
    // Если статус уже IN_PROGRESS, возвращаем его
    if (appointment.status == 'IN_PROGRESS') {
      return 'in_progress';
    }

    try {
      final date = DateTime.parse(appointment.appointmentDate);
      final time = appointment.startTime.split(':');
      final sessionDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(time[0]),
        int.parse(time[1]),
      );
      final now = DateTime.now();

      // ✅ ИСПРАВЛЕНО: Если сессия в прошлом, возвращаем 'past'
      if (sessionDateTime.isBefore(now)) {
        return 'past';
      }

      final diff = sessionDateTime.difference(now);

      // Скоро начнётся (менее 30 минут)
      if (diff.inMinutes < 30 && diff.inMinutes > 0) {
        return 'soon';
      }
      // Сегодня
      else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return 'today';
      }

      // Будущая сессия
      return 'upcoming';
    } catch (e) {
      return 'upcoming';
    }
  }

  double _calculateWeekRevenue(List<dynamic> appointments) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return appointments
        .where((apt) {
          try {
            final aptDate = DateTime.parse(apt.appointmentDate);
            return aptDate.isAfter(weekAgo) &&
                aptDate.isBefore(now) &&
                apt.status == 'COMPLETED';
          } catch (e) {
            return false;
          }
        })
        .fold(0.0, (sum, apt) => sum + (apt.price?.toDouble() ?? 0.0));
  }
}
