import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/back_button.dart';
import '../login/login_screen.dart';
import '../home/U_home_screen/home_screen.dart';
import '../../services/tutorial_service.dart';
import 'intro_video.dart';
import 'intro_article.dart';
import 'intro_meditation.dart';

/// Экран знакомства с приложением (туториал)
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final TutorialService _tutorialService = TutorialService();

  // Отслеживаем завершенные шаги
  Set<int> completedSteps = {};
  bool _isCompleting = false;

  final List<Map<String, dynamic>> steps = [
    {
      'number': 1,
      'type': 'video',
      'title': '1. Что такое BalancePsy',
      'description':
          'BalancePsy — это твой персональный гид в мире психологического благополучия. Мы создали пространство, где ты можешь найти поддержку, понимание и инструменты для гармоничной жизни.',
      'icon': Icons.play_circle_outline,
      'duration': '2 мин',
      'videoPath': 'assets/video/intro.mp4',
    },
    {
      'number': 2,
      'type': 'article',
      'title': '2. Как BalancePsy помогает',
      'description':
          'Через научно обоснованные практики медитации, дыхательные упражнения и когнитивные техники мы поможем тебе справляться со стрессом, улучшать сон и находить внутренний покой.',
      'icon': Icons.article_outlined,
      'duration': '3 мин чтения',
    },
    {
      'number': 3,
      'type': 'meditation',
      'title': '3. Твой первый шаг',
      'description':
          'Начни свой путь с простой медитации осознанности. Всего 5 минут в день могут изменить твое отношение к жизни и помочь обрести гармонию.',
      'icon': Icons.self_improvement,
      'duration': '5 мин практики',
    },
  ];

  void _openStep(int index) async {
    final step = steps[index];
    Widget? screen;

    switch (step['type']) {
      case 'video':
        screen = IntroVideoScreen(
          title: step['title'],
          description: step['description'],
          videoPath: step['videoPath'],
        );
        break;
      case 'article':
        screen = const IntroArticleScreen();
        break;
      case 'meditation':
        screen = const IntroMeditationScreen();
        break;
    }

    if (screen != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );

      // Если вернулось true - шаг завершен
      if (result == true) {
        setState(() {
          completedSteps.add(index);
        });
      }
    }
  }

  bool get _allStepsCompleted => completedSteps.length == steps.length;

  /// Завершить туториал (отметить как пройденный)
  Future<void> _completeTutorial() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    try {
      // Сохраняем факт прохождения туториала
      await _tutorialService.completeTutorial();

      if (mounted) {
        _navigateToLogin();
      }
    } catch (e) {
      print('❌ Error completing tutorial: $e');
      if (mounted) {
        // Даже если ошибка - переводим на логин
        _navigateToLogin();
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  /// Пропустить туториал
  void _skipTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Пропустить туториал?',
          style: AppTextStyles.h3.copyWith(fontSize: 20),
        ),
        content: Text(
          'Ты можешь пройти знакомство с приложением позже в настройках.',
          style: AppTextStyles.body1.copyWith(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Остаться',
              style: AppTextStyles.body1.copyWith(
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToLogin();
            },
            child: Text(
              'Пропустить',
              style: AppTextStyles.body1.copyWith(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Переход на экран логина
  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Шапка
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CustomBackButton(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Знакомство с BalancePsy',
                      style: AppTextStyles.h3.copyWith(fontSize: 18),
                    ),
                  ),
                  // Прогресс
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${completedSteps.length}/${steps.length}',
                          style: AppTextStyles.body3.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Заголовок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Добро пожаловать в BalancePsy',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // Подзаголовок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Твоя дорога к внутреннему равновесию начинается здесь',
                style: AppTextStyles.body3.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            // Список карточек
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isCompleted = completedSteps.contains(index);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildInfoCard(
                      number: step['number'],
                      title: step['title'],
                      description: step['description'],
                      icon: step['icon'],
                      duration: step['duration'],
                      isCompleted: isCompleted,
                      onTap: () => _openStep(index),
                    ),
                  );
                },
              ),
            ),

            // Подсказка
            if (!_allStepsCompleted)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Пройди все шаги или нажми "Пропустить" ниже',
                          style: AppTextStyles.body3.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Кнопки
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Кнопка "Завершить"
                  CustomButton(
                    text: _isCompleting ? 'Завершение...' : 'Завершить',
                    showArrow: true,
                    onPressed: _allStepsCompleted && !_isCompleting
                        ? _completeTutorial
                        : null,
                    isFullWidth: true,
                  ),

                  const SizedBox(height: 12),

                  // Кнопка "Пропустить"
                  TextButton(
                    onPressed: _isCompleting ? null : _skipTutorial,
                    child: Text(
                      'Пропустить',
                      style: AppTextStyles.body2.copyWith(
                        color: _isCompleting
                            ? AppColors.textTertiary
                            : AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                        fontSize: 15,
                      ),
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

  // Карточка с информацией
  Widget _buildInfoCard({
    required int number,
    required String title,
    required String description,
    required IconData icon,
    required String duration,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: isCompleted
              ? Border.all(color: Colors.green.withOpacity(0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? Colors.green.withOpacity(0.2)
                  : AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Номер
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Colors.green
                        : AppColors.primary.withOpacity(0.1),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : Text(
                            '$number',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.primary,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Контент
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h3.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: AppTextStyles.body2.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            icon,
                            size: 20,
                            color: isCompleted
                                ? Colors.green
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            duration,
                            style: AppTextStyles.body3.copyWith(
                              color: isCompleted
                                  ? Colors.green
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Бейдж "Завершено"
            if (isCompleted)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Завершено',
                    style: AppTextStyles.body3.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
