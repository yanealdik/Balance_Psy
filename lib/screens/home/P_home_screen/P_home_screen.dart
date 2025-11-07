import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_navbar.dart';
import '../../../widgets/psychologist/psychologist_header.dart';
import '../../../widgets/psychologist/stats_card.dart';
import '../../../widgets/psychologist/request_card.dart';
import '../../../widgets/psychologist/session_card_p.dart';
import '../../../widgets/psychologist/notifications_bottom_sheet.dart';
import '../../P_ReportsScreen/PsychologistReportsScreen.dart';
import '../../P_ScheduleScreen/PsychologistScheduleScreen.dart';
import '../../chats/P_chats/P_chats_screen.dart';
import '../../profile/P_profile/psycho_profile.dart';

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

  final List<Map<String, dynamic>> pendingRequests = [
    {
      'id': 1,
      'clientName': 'Анна Ким',
      'clientImage': 'https://i.pravatar.cc/150?img=25',
      'date': '21 октября',
      'time': '15:00',
      'format': 'video',
      'requestDate': '20 окт, 14:30',
      'issue': 'Работа с тревожностью',
      'isFirstSession': true,
    },
    {
      'id': 2,
      'clientName': 'Дмитрий Петров',
      'clientImage': 'https://i.pravatar.cc/150?img=12',
      'date': '22 октября',
      'time': '10:00',
      'format': 'chat',
      'requestDate': '20 окт, 16:15',
      'issue': 'Проблемы в отношениях',
      'isFirstSession': false,
    },
  ];

  final List<Map<String, dynamic>> upcomingSessions = [
    {
      'id': 3,
      'clientName': 'Елена Смирнова',
      'clientImage': 'https://i.pravatar.cc/150?img=30',
      'date': '20 октября',
      'time': '18:00',
      'format': 'video',
      'status': 'soon',
      'notes': 'Продолжение работы с самооценкой',
    },
    {
      'id': 4,
      'clientName': 'Максим Иванов',
      'clientImage': 'https://i.pravatar.cc/150?img=15',
      'date': '21 октября',
      'time': '11:00',
      'format': 'video',
      'status': 'today',
      'notes': 'Первая сессия',
    },
  ];

  final Map<String, dynamic> stats = {
    'todaySessions': 3,
    'pendingRequests': 2,
    'weekRevenue': 42000,
    'rating': 4.9,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          PsychologistHeader(
            name: 'Галия Аубакирова',
            avatarUrl: 'https://i.pravatar.cc/150?img=5',
            onNotificationsTap: _showNotificationsItem,
            hasNotifications: pendingRequests.isNotEmpty,
          ),
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
                        '${(stats['weekRevenue'] / 1000).toStringAsFixed(0)}к',
                    unit: '₸',
                    icon: Icons.wallet,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTabBar(),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildRequestsTab(), _buildSessionsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
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
                if (pendingRequests.isNotEmpty) ...[
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
                      '${pendingRequests.length}',
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

  Widget _buildRequestsTab() {
    if (pendingRequests.isEmpty) {
      return _buildEmptyState(
        'Нет новых заявок',
        'Новые заявки от клиентов появятся здесь',
        Icons.notifications_none,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RequestCard(
            request: pendingRequests[index],
            onAccept: () => _acceptRequest(pendingRequests[index]['id']),
            onDecline: () => _declineRequest(pendingRequests[index]['id']),
          ),
        );
      },
    );
  }

  Widget _buildSessionsTab() {
    if (upcomingSessions.isEmpty) {
      return _buildEmptyState(
        'Нет запланированных сессий',
        'Подтвержденные сессии появятся здесь',
        Icons.event_available,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: upcomingSessions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SessionCardP(
            session: upcomingSessions[index],
            onChatTap: () {},
          ),
        );
      },
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

  void _acceptRequest(int requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            onPressed: () {
              Navigator.pop(context);
              setState(
                () => pendingRequests.removeWhere((r) => r['id'] == requestId),
              );
            },
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
  }

  void _declineRequest(int requestId) {
    showDialog(
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(
                () => pendingRequests.removeWhere((r) => r['id'] == requestId),
              );
            },
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
  }

  void _showNotificationsItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsBottomSheet(),
    );
  }

  String _getRequestsWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'новая заявка';
    } else if ([2, 3, 4].contains(count % 10) &&
        ![12, 13, 14].contains(count % 100)) {
      return 'новые заявки';
    } else {
      return 'новых заявок';
    }
  }
}
