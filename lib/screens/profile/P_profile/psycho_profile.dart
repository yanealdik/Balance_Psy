import 'package:balance_psy/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/psychologist/profile/stat_item_widget.dart';
import '../../../widgets/psychologist/profile/schedule_item_widget.dart';
import '../../../widgets/psychologist/profile/action_item_widget.dart';
import '../../../services/auth_service.dart';
import '../FAQ/faq_screen.dart';
import '../edit/P_edit_screen.dart';
import '../setting/setting_screen.dart';

/// Экран профиля психолога
class PsychologistProfileScreen extends StatefulWidget {
  const PsychologistProfileScreen({super.key});

  @override
  State<PsychologistProfileScreen> createState() =>
      _PsychologistProfileScreenState();
}

class _PsychologistProfileScreenState extends State<PsychologistProfileScreen> {
  final AuthService _authService = AuthService();
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  double _rating = 0;
  int _totalSessions = 0;
  int _patientsCount = 0;
  String _fullName = '';
  String _specialization = '';
  String? _avatarUrl;
  String _roleDescription = 'Психолог BalancePsy';
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final authService = AuthService();
      final profile = await authService.getProfile();

      if (!mounted) return;

      setState(() {
        _fullName = profile.fullName;
        _avatarUrl = profile.avatarUrl;
        _roleDescription = profile.role == 'PSYCHOLOGIST'
            ? 'Психолог BalancePsy'
            : profile.role;

        if (profile.psychologistProfile != null) {
          final psychProfile = profile.psychologistProfile!;
          _specialization = psychProfile.specialization;
          _rating = psychProfile.rating.toDouble();
          _totalSessions = psychProfile.totalSessions;
          _patientsCount = psychProfile.reviewsCount;
        }

        _isLoadingProfile = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
      if (!mounted) return;
      setState(() => _isLoadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider avatarImage =
        (_avatarUrl != null && _avatarUrl!.isNotEmpty)
        ? NetworkImage(_avatarUrl!)
        : const AssetImage('assets/images/avatar/Galiya.png');

    return Material(
      color: AppColors.backgroundLight,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Верхняя панель
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Мой профиль',
                      style: AppTextStyles.h2.copyWith(fontSize: 28),
                    ),
                    // Кнопка настроек
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
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
              ),

              // Аватар и имя
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: avatarImage, fit: BoxFit.cover),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 3,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Имя психолога
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
                  Text(
                    _fullName.isNotEmpty
                        ? _fullName
                        : (_isLoadingProfile
                              ? 'Загрузка...'
                              : 'Имя не указано'),
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                _roleDescription,
                style: AppTextStyles.body2.copyWith(fontSize: 14),
              ),

              const SizedBox(height: 8),

              // Специализация
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _specialization.isNotEmpty
                      ? _specialization
                      : 'Специализация не указана',
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Кнопка редактирования профиля
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  text: 'Редактировать профиль',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PSYEditProfileScreen(),
                      ),
                    );
                  },
                  isFullWidth: true,
                ),
              ),

              const SizedBox(height: 24),

              // Статистика работы
              Padding(
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
                      Text(
                        'Статистика',
                        style: AppTextStyles.h3.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          StatItemWidget(
                            title: 'Пациенты',
                            value: _patientsCount.toString(),
                            icon: Icons.people_outline,
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: AppColors.inputBorder.withOpacity(0.3),
                          ),
                          StatItemWidget(
                            title: 'Сессии',
                            value: _totalSessions.toString(),
                            icon: Icons.event_note,
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: AppColors.inputBorder.withOpacity(0.3),
                          ),
                          StatItemWidget(
                            title: 'Рейтинг',
                            value: _rating.toStringAsFixed(1),
                            icon: Icons.star_outline,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Расписание
              Padding(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Расписание на сегодня',
                            style: AppTextStyles.h3.copyWith(fontSize: 20),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ScheduleItemWidget(
                        time: '10:00 - 11:00',
                        clientName: 'Алексей Иванов',
                        status: 'upcoming',
                      ),
                      const SizedBox(height: 12),
                      ScheduleItemWidget(
                        time: '14:00 - 15:00',
                        clientName: 'Мария Петрова',
                        status: 'upcoming',
                      ),
                      const SizedBox(height: 12),
                      ScheduleItemWidget(
                        time: '16:00 - 17:00',
                        clientName: 'Свободно',
                        status: 'free',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Действия
              Padding(
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
                      Text(
                        'Действия',
                        style: AppTextStyles.h3.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      ActionItemWidget(
                        title: 'Уведомления',
                        trailing: Switch(
                          value: notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              notificationsEnabled = value;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                      _buildDivider(),
                      ActionItemWidget(
                        title: 'Темная тема',
                        trailing: Switch(
                          value: darkModeEnabled,
                          onChanged: (value) {
                            setState(() {
                              darkModeEnabled = value;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                      _buildDivider(),
                      GestureDetector(
                        onTap: () {
                          // Переход к списку пациентов
                        },
                        child: ActionItemWidget(
                          title: 'Мои пациенты',
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      _buildDivider(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FAQScreen(),
                            ),
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
              ),

              const SizedBox(height: 24),

              // Кнопка выхода
              Padding(
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
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
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
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Разделитель
  Widget _buildDivider() {
    return Divider(color: AppColors.inputBorder.withOpacity(0.3), height: 1);
  }
}
