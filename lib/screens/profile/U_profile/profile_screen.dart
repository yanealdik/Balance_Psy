import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/user_service.dart';
import '../../login/login_screen.dart';
import '../edit/edit_screen.dart';
import '../setting/setting_screen.dart';
import '../FAQ/faq_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final profile = await authService.getProfile(); // ← ProfileResponse

      // Конвертируем ProfileResponse → UserModel
      final user = UserModel(
        userId: profile.userId,
        email: profile.email,
        fullName: profile.fullName,
        phone: profile.phone,
        dateOfBirth: profile.dateOfBirth,
        avatarUrl: profile.avatarUrl,
        role: profile.role,
        gender: profile.gender,
        interests: profile.interests,
        registrationGoal: profile.registrationGoal,
        isActive: profile.isActive,
        emailVerified: profile.emailVerified,
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.updateUser(user);
    } catch (e) {
      _showError('Ошибка загрузки профиля: $e');
    } finally {
      setState(() => _isLoading = false);
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

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Мой профиль',
                          style: AppTextStyles.h2.copyWith(fontSize: 28),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
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
                  ),

                  // Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: user.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(user.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: user.avatarUrl == null
                          ? AppColors.primary.withOpacity(0.2)
                          : null,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: user.avatarUrl == null
                        ? Icon(Icons.person, size: 60, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Name
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
                        user.fullName,
                        style: AppTextStyles.h3.copyWith(fontSize: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'Пациент BalancePsy',
                    style: AppTextStyles.body2.copyWith(fontSize: 14),
                  ),

                  const SizedBox(height: 24),

                  // Edit Profile Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomButton(
                      text: 'Редактировать профиль',
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadProfile(); // Перезагрузить профиль
                        }
                      },
                      isFullWidth: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recommendations Card
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
                            'Мои рекомендации',
                            style: AppTextStyles.h3.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 16),
                          _buildRecommendationItem(
                            icon: Icons.bedtime,
                            text: 'Попробуйте 5-минутную медитацию перед сном.',
                          ),
                          const SizedBox(height: 12),
                          _buildRecommendationItem(
                            icon: Icons.article_outlined,
                            text: 'Прочитайте статью: Как говорить о чувствах',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions Card
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
                          _buildActionItem(
                            title: 'Уведомления',
                            trailing: Switch(
                              value: notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  notificationsEnabled = value;
                                });
                              },
                              activeThumbColor: AppColors.primary,
                            ),
                          ),
                          _buildDivider(),
                          _buildActionItem(
                            title: 'Темная тема',
                            trailing: Switch(
                              value: darkModeEnabled,
                              onChanged: (value) {
                                setState(() {
                                  darkModeEnabled = value;
                                });
                              },
                              activeThumbColor: AppColors.primary,
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
                            child: _buildActionItem(
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

                  // Logout Button
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
                          onTap: () async {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            await authProvider.logout();
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
          );
        },
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: AppTextStyles.body1.copyWith(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({required String title, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body1.copyWith(fontSize: 16)),
          trailing,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.inputBorder.withOpacity(0.3), height: 1);
  }
}
