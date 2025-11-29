import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../services/mood_survey_service.dart';
import '../../models/mood_survey_models.dart';

/// Экран мини-опроса настроения с сохранением в backend
class MoodSurveyScreen extends StatefulWidget {
  const MoodSurveyScreen({super.key});

  @override
  State<MoodSurveyScreen> createState() => _MoodSurveyScreenState();
}

class _MoodSurveyScreenState extends State<MoodSurveyScreen> {
  final PageController _pageController = PageController();
  final MoodSurveyService _moodSurveyService = MoodSurveyService();

  int _currentPage = 0;
  bool _isSaving = false;

  // Ответы пользователя
  final Map<int, dynamic> _answers = {};

  // Вопросы опроса
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Как ты себя чувствуешь сегодня?',
      'type': 'mood',
      'options': [
        {'emoji': '😊', 'label': 'Отлично', 'value': 5},
        {'emoji': '😌', 'label': 'Хорошо', 'value': 4},
        {'emoji': '😐', 'label': 'Нормально', 'value': 3},
        {'emoji': '😔', 'label': 'Грустно', 'value': 2},
        {'emoji': '😢', 'label': 'Плохо', 'value': 1},
      ],
    },
    {
      'question': 'Как оцениваешь свой уровень стресса?',
      'type': 'slider',
      'min': 0,
      'max': 10,
      'labels': ['Спокоен', 'Очень стрессую'],
    },
    {
      'question': 'Что тебя больше всего беспокоит сейчас?',
      'type': 'multiple',
      'options': [
        'Работа/учеба',
        'Отношения',
        'Здоровье',
        'Финансы',
        'Будущее',
        'Ничего особенного',
      ],
    },
    {
      'question': 'Как ты спал этой ночью?',
      'type': 'single',
      'options': [
        {'label': 'Отлично выспался', 'icon': Icons.bedtime},
        {'label': 'Нормально', 'icon': Icons.hotel},
        {'label': 'Плохо спал', 'icon': Icons.nightlight_round},
        {'label': 'Совсем не спал', 'icon': Icons.nights_stay},
      ],
    },
    {
      'question': 'Что помогло бы тебе сейчас?',
      'type': 'single',
      'options': [
        {'label': 'Поговорить с кем-то', 'icon': Icons.chat_bubble_outline},
        {'label': 'Отдохнуть', 'icon': Icons.self_improvement},
        {'label': 'Заняться делами', 'icon': Icons.work_outline},
        {'label': 'Развлечься', 'icon': Icons.celebration_outlined},
      ],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildProgressBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildQuestionPage(index);
                },
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => _showExitDialog(),
          ),
          Text('Мини-опрос', style: AppTextStyles.h3.copyWith(fontSize: 18)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentPage + 1) / _questions.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Вопрос ${_currentPage + 1} из ${_questions.length}',
                style: AppTextStyles.body2.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.body2.copyWith(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.inputBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index) {
    final question = _questions[index];
    final type = question['type'] as String;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            question['question'] as String,
            style: AppTextStyles.h2.copyWith(fontSize: 24, height: 1.3),
          ),
          const SizedBox(height: 32),
          if (type == 'mood') _buildMoodOptions(index),
          if (type == 'slider') _buildSliderOption(index),
          if (type == 'multiple') _buildMultipleOptions(index),
          if (type == 'single') _buildSingleOptions(index),
        ],
      ),
    );
  }

  // [Все методы _buildMoodOptions, _buildSliderOption и т.д. остаются БЕЗ ИЗМЕНЕНИЙ]
  // Копируем их из оригинального файла...

  Widget _buildMoodOptions(int questionIndex) {
    final options = _questions[questionIndex]['options'] as List;

    return Column(
      children: options.map((option) {
        final isSelected = _answers[questionIndex] == option['value'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _answers[questionIndex] = option['value'];
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  option['emoji'] as String,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option['label'] as String,
                    style: AppTextStyles.body1.copyWith(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSliderOption(int questionIndex) {
    final currentValue = _answers[questionIndex] as double? ?? 5.0;
    final labels = _questions[questionIndex]['labels'] as List<String>;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              currentValue.toInt().toString(),
              style: AppTextStyles.h1.copyWith(
                fontSize: 48,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.inputBorder,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              value: currentValue,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  _answers[questionIndex] = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labels[0],
                style: AppTextStyles.body2.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                labels[1],
                style: AppTextStyles.body2.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleOptions(int questionIndex) {
    final options = _questions[questionIndex]['options'] as List<String>;
    final selected = _answers[questionIndex] as List<String>? ?? [];

    return Column(
      children: options.map((option) {
        final isSelected = selected.contains(option);

        return GestureDetector(
          onTap: () {
            setState(() {
              final currentSelected = List<String>.from(selected);
              if (isSelected) {
                currentSelected.remove(option);
              } else {
                currentSelected.add(option);
              }
              _answers[questionIndex] = currentSelected;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.inputBorder,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: AppTextStyles.body1.copyWith(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleOptions(int questionIndex) {
    final options =
        _questions[questionIndex]['options'] as List<Map<String, dynamic>>;

    return Column(
      children: options.map((option) {
        final isSelected = _answers[questionIndex] == option['label'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _answers[questionIndex] = option['label'];
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    option['icon'] as IconData,
                    color: isSelected ? Colors.white : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option['label'] as String,
                    style: AppTextStyles.body1.copyWith(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastPage = _currentPage == _questions.length - 1;
    final hasAnswer = _answers.containsKey(_currentPage);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.inputBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Назад'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _isSaving
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: isLastPage ? 'Завершить' : 'Далее',
                    onPressed: hasAnswer
                        ? () {
                            if (isLastPage) {
                              _completeSurvey();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          }
                        : null,
                    icon: isLastPage ? Icons.check : Icons.arrow_forward,
                    isFullWidth: true,
                  ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Выйти из опроса?',
          style: AppTextStyles.h3.copyWith(fontSize: 20),
        ),
        content: Text(
          'Твой прогресс не будет сохранён',
          style: AppTextStyles.body1.copyWith(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: AppTextStyles.body1.copyWith(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Выйти',
              style: AppTextStyles.body1.copyWith(
                fontSize: 15,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ОБНОВЛЕНО: Сохранение в backend
  Future<void> _completeSurvey() async {
    setState(() => _isSaving = true);

    try {
      // Собираем данные
      final request = MoodSurveyRequest(
        moodScore: _answers[0] as int,
        stressLevel: (_answers[1] as double).toInt(),
        concerns: _answers[2] as List<String>?,
        sleepQuality: _answers[3] as String?,
        helpfulAction: _answers[4] as String?,
      );

      // Отправляем на сервер
      final response = await _moodSurveyService.saveMoodSurvey(request);

      if (mounted) {
        Navigator.pop(context, true); // Возвращаем true для обновления главной

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Спасибо! Общий балл: ${response.overallScore.toStringAsFixed(0)}/100',
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
