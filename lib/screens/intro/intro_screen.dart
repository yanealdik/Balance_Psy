import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/back_button.dart';
import '../login/login_screen.dart';
import '../../services/intro_service.dart';
import '../../models/intro_model.dart';
import 'intro_video.dart';
import 'intro_article.dart';
import 'intro_meditation.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final IntroService _introService = IntroService();

  Set<int> completedSteps = {};
  bool _isCompleting = false;
  bool _isLoading = true;
  List<IntroContent> _introContent = [];

  @override
  void initState() {
    super.initState();
    _loadIntroContent();
  }

  Future<void> _loadIntroContent() async {
    try {
      final content = await _introService.getIntroContent();
      setState(() {
        _introContent = content;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading intro content: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось загрузить контент интро'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openStep(int index) async {
    if (index >= _introContent.length) return;

    final content = _introContent[index];
    Widget? screen;

    switch (content.contentType) {
      case 'video':
        screen = IntroVideoScreen(
          title: content.title,
          description: content.description ?? '',
          videoPath: content.contentUrl ?? '',
        );
        break;
      case 'article':
        screen = IntroArticleScreen(
          title: content.title,
          content: content.contentText ?? '',
        );
        break;
      case 'meditation':
        screen = IntroMeditationScreen(
          title: content.title,
          description: content.description ?? '',
          audioUrl: content.audioUrl ?? '',
          durationSeconds: content.durationSeconds ?? 300,
        );
        break;
    }

    if (screen != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );

      if (result == true) {
        setState(() {
          completedSteps.add(index);
        });
      }
    }
  }

  bool get _allStepsCompleted => 
      _introContent.isNotEmpty && 
      completedSteps.length == _introContent.length;

  Future<void> _completeIntro() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    try {
      await _introService.completeIntro();

      if (mounted) {
        _navigateToLogin();
      }
    } catch (e) {
      print('❌ Error completing intro: $e');
      if (mounted) {
        _navigateToLogin();
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  void _skipIntro() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Пропустить интро?',
          style: AppTextStyles.h3.copyWith(fontSize: 20),
        ),
        content: Text(
          'Ты можешь пройти интро позже в настройках.',
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

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

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
                          '${completedSteps.length}/${_introContent.length}',
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
              child: _introContent.isEmpty
                  ? Center(
                      child: Text(
                        'Контент интро недоступен',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _introContent.length,
                      itemBuilder: (context, index) {
                        final content = _introContent[index];
                        final isCompleted = completedSteps.contains(index);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildInfoCard(
                            number: index + 1,
                            title: content.title,
                            description: content.description ?? '',
                            icon: _getIconForType(content.contentType),
                            duration: _getDurationText(content),
                            isCompleted: isCompleted,
                            onTap: () => _openStep(index),
                          ),
                        );
                      },
                    ),
            ),

            // Подсказка
            if (!_allStepsCompleted && _introContent.isNotEmpty)
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  // Кнопка "Завершить"
                  CustomButton(
                    text: _isCompleting ? 'Завершение...' : 'Завершить',
                    showArrow: !_isCompleting,
                    onPressed: _allStepsCompleted && !_isCompleting
                        ? _completeIntro
                        : null,
                    isFullWidth: true,
                  ),

                  const SizedBox(height: 12),

                  // Кнопка "Пропустить"
                  TextButton(
                    onPressed: _isCompleting ? null : _skipIntro,
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

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_outline;
      case 'article':
        return Icons.article_outlined;
      case 'meditation':
        return Icons.self_improvement;
      default:
        return Icons.help_outline;
    }
  }

  String _getDurationText(IntroContent content) {
    if (content.durationSeconds != null) {
      final minutes = content.durationSeconds! ~/ 60;
      return '$minutes мин';
    }
    return '5 мин';
  }

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
