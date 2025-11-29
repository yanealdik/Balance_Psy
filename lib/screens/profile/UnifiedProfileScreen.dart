import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/ProgressService.dart';
import '../../../services/StatisticsService.dart';
import '../../../models/client_progress_model.dart';
import '../../../models/psychologist_statistics_model.dart';
import '../login/login_screen.dart';
import 'detailed_statistics_screen.dart';
import 'edit/edit_screen.dart';
import 'setting/setting_screen.dart';
import 'FAQ/faq_screen.dart';
import '../../../widgets/psychologist/profile/stat_item_widget.dart';
import '../../../widgets/psychologist/profile/action_item_widget.dart';

/// Unified Profile Screen for both CLIENT and PSYCHOLOGIST roles
class UnifiedProfileScreen extends StatefulWidget {
  const UnifiedProfileScreen({super.key});

  @override
  State<UnifiedProfileScreen> createState() => _UnifiedProfileScreenState();
}

class _UnifiedProfileScreenState extends State<UnifiedProfileScreen> {
  final AuthService _authService = AuthService();
  final ProgressService _progressService = ProgressService();
  final StatisticsService _statisticsService = StatisticsService();

  bool _isLoading = false;
  bool _notificationsEnabled = true;

  // Данные прогресса и статистики
  ClientProgress? _clientProgress;
  PsychologistStatistics? _psychologistStats;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadUser();

      // Загружаем данные в зависимости от роли
      if (authProvider.user?.role == 'CLIENT') {
        await _loadClientProgress();
      } else if (authProvider.user?.role == 'PSYCHOLOGIST') {
        await _loadPsychologistStatistics();
      }
    } catch (e) {
      if (mounted) {
        _showError('Ошибка загрузки профиля: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadClientProgress() async {
    try {
      final progress = await _progressService.getMyProgress();
      if (mounted) {
        setState(() => _clientProgress = progress);
      }
    } catch (e) {
      print('⚠️ Failed to load client progress: $e');
      // Используем пустой прогресс при ошибке
      if (mounted) {
        setState(() => _clientProgress = ClientProgress.empty());
      }
    }
  }

  Future<void> _loadPsychologistStatistics() async {
    try {
      final stats = await _statisticsService.getMyStatistics();
      if (mounted) {
        setState(() => _psychologistStats = stats);
      }
    } catch (e) {
      print('⚠️ Failed to load psychologist statistics: $e');
      // Используем пустую статистику при ошибке
      if (mounted) {
        setState(() => _psychologistStats = PsychologistStatistics.empty());
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (_isLoading || user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final bool isPsychologist = user.role == 'PSYCHOLOGIST';

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildAvatar(user.avatarUrl),
                  const SizedBox(height: 16),
                  _buildNameAndRole(user.fullName, isPsychologist),
                  const SizedBox(height: 24),
                  _buildEditButton(),
                  const SizedBox(height: 24),

                  // Psychologist Stats
                  if (isPsychologist) ...[
                    _buildPsychologistStats(),
                    const SizedBox(height: 24),
                  ],

                  // Client Progress
                  if (!isPsychologist) ...[
                    _buildClientProgress(),
                    const SizedBox(height: 24),
                  ],

                  _buildActionsCard(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Мой профиль', style: AppTextStyles.h2.copyWith(fontSize: 28)),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: avatarUrl != null && avatarUrl.isNotEmpty
            ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
            : null,
        color: avatarUrl == null ? AppColors.primary.withOpacity(0.2) : null,
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 3),
      ),
      child: avatarUrl == null
          ? const Icon(Icons.person, size: 60, color: AppColors.primary)
          : null,
    );
  }

  Widget _buildNameAndRole(String fullName, bool isPsychologist) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Text(fullName, style: AppTextStyles.h3.copyWith(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isPsychologist ? 'Психолог BalancePsy' : 'Пациент BalancePsy',
          style: AppTextStyles.body2.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CustomButton(
        text: 'Редактировать профиль',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
          if (result == true) {
            _loadProfile();
          }
        },
        isFullWidth: true,
      ),
    );
  }

  Widget _buildPsychologistStats() {
    if (_psychologistStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = _psychologistStats!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статистика', style: AppTextStyles.h3.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItemWidget(
                  title: 'Пациенты',
                  value: '${stats.clients.totalClients}',
                  icon: Icons.people_outline,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: AppColors.inputBorder.withOpacity(0.3),
                ),
                StatItemWidget(
                  title: 'Сессии',
                  value: '${stats.sessions.totalCompletedSessions}',
                  icon: Icons.event_note,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: AppColors.inputBorder.withOpacity(0.3),
                ),
                StatItemWidget(
                  title: 'Рейтинг',
                  value: stats.rating.averageRating.toStringAsFixed(1),
                  icon: Icons.star_outline,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailedStatisticsScreen(
                      statistics: _psychologistStats!,
                    ),
                  ),
                );
              },
              child: Text('Подробнее →'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientProgress() {
    if (_clientProgress == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final progress = _clientProgress!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Прогресс',
                  style: AppTextStyles.h3.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Общий прогресс
            _buildProgressBar(progress.overallProgress),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.check_circle_outline,
                    label: 'Сессии',
                    value:
                        '${progress.completedSessions}/${progress.totalSessions}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Активность',
                    value: '${progress.activeDaysStreak} дн.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.flag_outlined,
                    label: 'Цели',
                    value: '${progress.completedGoals}/${progress.totalGoals}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.star_outline,
                    label: 'Оценка',
                    value: progress.averageSessionRating.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Общий прогресс',
              style: AppTextStyles.body2.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$progress%',
              style: AppTextStyles.h3.copyWith(
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: AppColors.inputBorder.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h3.copyWith(fontSize: 18)),
          Text(
            label,
            style: AppTextStyles.body3.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Действия', style: AppTextStyles.h3.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            ActionItemWidget(
              title: 'Уведомления',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
                activeColor: AppColors.primary,
              ),
            ),
            _buildDivider(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQScreen()),
                );
              },
              child: ActionItemWidget(
                title: 'Помощь и поддержка',
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: Text(
                'Выйти из Аккаунта',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.inputBorder.withOpacity(0.3), height: 1);
  }
}
