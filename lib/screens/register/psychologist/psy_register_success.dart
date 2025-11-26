import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../providers/psychologist_registration_provider.dart';
import 'package:confetti/confetti.dart';

class PsychRegisterSuccess extends StatefulWidget {
  const PsychRegisterSuccess({super.key});

  @override
  State<PsychRegisterSuccess> createState() => _PsychRegisterSuccessState();
}

class _PsychRegisterSuccessState extends State<PsychRegisterSuccess>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _goToHome() {
    // Очищаем данные регистрации
    final provider = Provider.of<PsychologistRegistrationProvider>(
      context,
      listen: false,
    );
    provider.clear();

    // Переход на главный экран или экран входа
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.success,
                Color(0xFF6366F1),
                Color(0xFFEC4899),
                Color(0xFF8B5CF6),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Анимированная иконка
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.success, Color(0xFF059669)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Заголовок
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Заявка отправлена!',
                            style: AppTextStyles.h1.copyWith(fontSize: 32),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Описание
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Спасибо за регистрацию! Мы получили вашу заявку и начали процесс проверки документов.',
                            style: AppTextStyles.body1.copyWith(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Этапы проверки
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Что дальше?',
                                  style: AppTextStyles.h3.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildStep(
                                  icon: Icons.assignment_turned_in_outlined,
                                  title: 'Проверка документов',
                                  subtitle:
                                      'Администратор проверит ваши документы и образование',
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 16),
                                _buildStep(
                                  icon: Icons.email_outlined,
                                  title: 'Уведомление на email',
                                  subtitle:
                                      'Мы отправим результат проверки на вашу почту',
                                  color: const Color(0xFF6366F1),
                                ),
                                const SizedBox(height: 16),
                                _buildStep(
                                  icon: Icons.verified_user_outlined,
                                  title: 'Активация профиля',
                                  subtitle:
                                      'После одобрения вы сможете начать принимать клиентов',
                                  color: AppColors.success,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Информация о времени
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.warning.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  color: AppColors.warning,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Проверка обычно занимает 1-3 рабочих дня',
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Кнопка на главную
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomButton(
                      text: 'Вернуться на главную',
                      onPressed: _goToHome,
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.body3.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
