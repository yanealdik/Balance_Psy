import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/psychologist_statistics_model.dart';

/// Детальная статистика психолога (можно открыть в отдельном экране)
class DetailedPsychologistStatsWidget extends StatelessWidget {
  final PsychologistStatistics stats;

  const DetailedPsychologistStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRatingSection(),
          const SizedBox(height: 16),
          _buildClientsSection(),
          const SizedBox(height: 16),
          _buildSessionsSection(),
          const SizedBox(height: 16),
          _buildEarningsSection(),
          const SizedBox(height: 16),
          _buildEffectivenessSection(),
          const SizedBox(height: 16),
          _buildVisibilitySection(),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return _buildSection(
      title: 'Рейтинг и отзывы',
      icon: Icons.star,
      children: [
        _buildStatRow(
          'Средний рейтинг',
          '${stats.rating.averageRating.toStringAsFixed(1)} / 5.0',
        ),
        _buildStatRow('Всего отзывов', '${stats.rating.totalReviews}'),
        const SizedBox(height: 12),
        _buildRatingDistribution(),
      ],
    );
  }

  Widget _buildRatingDistribution() {
    return Column(
      children: [
        _buildRatingBar(
          5,
          stats.rating.reviews5Star,
          stats.rating.totalReviews,
        ),
        _buildRatingBar(
          4,
          stats.rating.reviews4Star,
          stats.rating.totalReviews,
        ),
        _buildRatingBar(
          3,
          stats.rating.reviews3Star,
          stats.rating.totalReviews,
        ),
        _buildRatingBar(
          2,
          stats.rating.reviews2Star,
          stats.rating.totalReviews,
        ),
        _buildRatingBar(
          1,
          stats.rating.reviews1Star,
          stats.rating.totalReviews,
        ),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    double percentage = total > 0 ? (count / total) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$stars★', style: AppTextStyles.body3.copyWith(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 6,
                backgroundColor: AppColors.inputBorder.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getRatingColor(stars),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: AppTextStyles.body3.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Color _getRatingColor(int stars) {
    if (stars >= 4) return AppColors.success;
    if (stars == 3) return Colors.orange;
    return AppColors.error;
  }

  Widget _buildClientsSection() {
    return _buildSection(
      title: 'Клиенты',
      icon: Icons.people,
      children: [
        _buildStatRow('Всего клиентов', '${stats.clients.totalClients}'),
        _buildStatRow('Активные клиенты', '${stats.clients.activeClients}'),
        _buildStatRow(
          'Новые в этом месяце',
          '+${stats.clients.newClientsThisMonth}',
        ),
      ],
    );
  }

  Widget _buildSessionsSection() {
    return _buildSection(
      title: 'Сессии',
      icon: Icons.event_note,
      children: [
        _buildStatRow(
          'Всего завершено',
          '${stats.sessions.totalCompletedSessions}',
        ),
        _buildStatRow(
          'Завершено в этом месяце',
          '${stats.sessions.completedSessionsThisMonth}',
        ),
        _buildStatRow(
          'Предстоящие сессии',
          '${stats.sessions.upcomingSessions}',
        ),
        _buildStatRow(
          'Новые записи за месяц',
          '+${stats.sessions.newBookingsThisMonth}',
        ),
        _buildStatRow(
          'Средняя длительность',
          '${stats.sessions.avgSessionDurationMinutes.toStringAsFixed(0)} мин',
        ),
      ],
    );
  }

  Widget _buildEarningsSection() {
    return _buildSection(
      title: 'Доходы',
      icon: Icons.attach_money,
      children: [
        _buildStatRow(
          'Всего заработано',
          '${stats.earnings.totalEarnings.toStringAsFixed(0)} ₸',
        ),
        _buildStatRow(
          'За этот месяц',
          '${stats.earnings.monthEarnings.toStringAsFixed(0)} ₸',
        ),
        _buildStatRow(
          'За последнюю неделю',
          '${stats.earnings.weekEarnings.toStringAsFixed(0)} ₸',
        ),
      ],
    );
  }

  Widget _buildEffectivenessSection() {
    return _buildSection(
      title: 'Эффективность',
      icon: Icons.insights,
      children: [
        _buildStatRow(
          'Достигнутые цели клиентов',
          '${(stats.effectiveness.goalsAchievedRate * 100).toStringAsFixed(0)}%',
        ),
        _buildStatRow(
          'Средняя оценка сессий',
          '${stats.effectiveness.averageSessionRating.toStringAsFixed(1)} / 5.0',
        ),
      ],
    );
  }

  Widget _buildVisibilitySection() {
    return _buildSection(
      title: 'Популярность профиля',
      icon: Icons.visibility,
      children: [
        _buildStatRow(
          'Просмотров за неделю',
          '${stats.visibility.profileViewsWeek}',
        ),
        _buildStatRow(
          'Просмотров за месяц',
          '${stats.visibility.profileViewsMonth}',
        ),
        _buildStatRow(
          'Всего просмотров',
          '${stats.visibility.profileViewsTotal}',
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(value, style: AppTextStyles.h3.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
