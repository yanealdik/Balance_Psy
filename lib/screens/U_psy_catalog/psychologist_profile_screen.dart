import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/psychologist_model.dart';
import '../../widgets/custom_button.dart';
import 'booking_screen.dart';

class PsychologistProfileScreen extends StatefulWidget {
  final PsychologistModel psychologist;

  const PsychologistProfileScreen({super.key, required this.psychologist});

  @override
  State<PsychologistProfileScreen> createState() =>
      _PsychologistProfileScreenState();
}

class _PsychologistProfileScreenState extends State<PsychologistProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildMainInfo(),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildTabBar(),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(),
                _buildReviewsTab(),
                _buildScheduleTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.psychologist.avatarUrl != null
                ? Image.network(
                    widget.psychologist.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withOpacity(0.5),
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppColors.primary.withOpacity(0.5),
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.psychologist.fullName,
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      if (widget.psychologist.isAvailable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Онлайн',
                            style: AppTextStyles.body2.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.psychologist.specialization,
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(Icons.star, size: 24, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                widget.psychologist.rating.toStringAsFixed(1),
                style: AppTextStyles.h2.copyWith(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.psychologist.reviewsCount} отзывов)',
                style: AppTextStyles.body2.copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.work_outline,
            'Опыт работы',
            '${widget.psychologist.experienceYears} лет',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.payments_outlined,
            'Стоимость сессии',
            '${widget.psychologist.hourlyRate.toStringAsFixed(0)} ₸ / час',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body3.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.body1.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              widget.psychologist.totalSessions.toString(),
              'Сессий',
              Icons.event_note,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              widget.psychologist.isVerified ? 'Да' : 'Нет',
              'Верифицирован',
              Icons.verified,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h3.copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.body3.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        labelColor: AppColors.textWhite,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.button.copyWith(fontSize: 14),
        tabs: const [
          Tab(text: 'О себе'),
          Tab(text: 'Отзывы'),
          Tab(text: 'Расписание'),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Обо мне', style: AppTextStyles.h3.copyWith(fontSize: 20)),
          const SizedBox(height: 12),
          Text(
            widget.psychologist.bio,
            style: AppTextStyles.body1.copyWith(fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 24),
          Text('Образование', style: AppTextStyles.h3.copyWith(fontSize: 20)),
          const SizedBox(height: 12),
          Text(
            widget.psychologist.education,
            style: AppTextStyles.body1.copyWith(fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Подходы в работе',
            style: AppTextStyles.h3.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.psychologist.approaches
                .map((approach) => _buildApproachChip(approach))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildApproachChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.body2.copyWith(
          fontSize: 13,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Center(
      child: Text(
        'Отзывы будут доступны после реализации системы отзывов',
        style: AppTextStyles.body2,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Center(
      child: Text(
        'Расписание будет доступно в следующем обновлении',
        style: AppTextStyles.body2,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text: 'Записаться на сессию',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(
                  psychologistId: widget.psychologist.id,
                  psychologistName: widget.psychologist.fullName,
                  psychologistImage: widget.psychologist.avatarUrl ?? '',
                  specialty: widget.psychologist.specialization,
                  rating: widget.psychologist.rating,
                  hourlyRate: widget.psychologist.hourlyRate,
                ),
              ),
            );
          },
          isFullWidth: true,
        ),
      ),
    );
  }
}
