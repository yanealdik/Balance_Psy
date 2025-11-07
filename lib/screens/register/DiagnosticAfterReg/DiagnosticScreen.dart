import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../intro/intro_screen.dart';

/// Первичная диагностика после регистрации (5-7 ключевых вопросов)
class InitialDiagnosticScreen extends StatefulWidget {
  const InitialDiagnosticScreen({super.key});

  @override
  State<InitialDiagnosticScreen> createState() =>
      _InitialDiagnosticScreenState();
}

class _InitialDiagnosticScreenState extends State<InitialDiagnosticScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<int, dynamic> _answers = {};

  // Короткие ключевые вопросы для первичной диагностики
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Как часто ты испытываешь тревогу?',
      'type': 'scale',
      'category': 'anxiety',
      'options': [
        {'label': 'Редко', 'value': 1},
        {'label': 'Иногда', 'value': 2},
        {'label': 'Часто', 'value': 3},
        {'label': 'Почти всегда', 'value': 4},
      ],
    },
    {
      'question': 'Как бы ты оценил своё настроение в последнюю неделю?',
      'type': 'mood',
      'category': 'depression',
      'options': [
        {'emoji': '😊', 'label': 'Отлично', 'value': 5},
        {'emoji': '😌', 'label': 'Хорошо', 'value': 4},
        {'emoji': '😐', 'label': 'Нормально', 'value': 3},
        {'emoji': '😔', 'label': 'Грустно', 'value': 2},
        {'emoji': '😢', 'label': 'Очень плохо', 'value': 1},
      ],
    },
    {
      'question': 'Насколько ты испытываешь стресс сейчас?',
      'type': 'slider',
      'category': 'stress',
      'min': 0,
      'max': 10,
      'labels': ['Нет стресса', 'Максимальный стресс'],
    },
    {
      'question': 'Как ты спишь последнее время?',
      'type': 'single',
      'category': 'sleep',
      'options': [
        {'label': 'Сплю отлично', 'icon': Icons.bedtime, 'value': 4},
        {'label': 'Нормально', 'icon': Icons.hotel, 'value': 3},
        {'label': 'Плохо засыпаю', 'icon': Icons.nightlight_round, 'value': 2},
        {'label': 'Бессонница', 'icon': Icons.nights_stay, 'value': 1},
      ],
    },
    {
      'question': 'Есть ли у тебя проблемы с концентрацией?',
      'type': 'scale',
      'category': 'focus',
      'options': [
        {'label': 'Нет проблем', 'value': 1},
        {'label': 'Иногда', 'value': 2},
        {'label': 'Часто', 'value': 3},
        {'label': 'Постоянно', 'value': 4},
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
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _buildQuestionPage(index),
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
            onPressed: () => _showSkipDialog(),
          ),
          Text(
            'Первичная диагностика',
            style: AppTextStyles.h3.copyWith(fontSize: 18),
          ),
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
          if (type == 'scale') _buildScaleOptions(index),
          if (type == 'single') _buildSingleOptions(index),
        ],
      ),
    );
  }

  Widget _buildMoodOptions(int questionIndex) {
    final options = _questions[questionIndex]['options'] as List;
    return Column(
      children: options.map((option) {
        final isSelected = _answers[questionIndex] == option['value'];
        return GestureDetector(
          onTap: () =>
              setState(() => _answers[questionIndex] = option['value']),
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
          Slider(
            value: currentValue,
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: AppColors.primary,
            onChanged: (value) =>
                setState(() => _answers[questionIndex] = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map(
                  (label) => Text(
                    label,
                    style: AppTextStyles.body2.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleOptions(int questionIndex) {
    final options = _questions[questionIndex]['options'] as List;
    return Column(
      children: options.map((option) {
        final isSelected = _answers[questionIndex] == option['value'];
        return GestureDetector(
          onTap: () =>
              setState(() => _answers[questionIndex] = option['value']),
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
            ),
            child: Row(
              children: [
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

  Widget _buildSingleOptions(int questionIndex) {
    final options =
        _questions[questionIndex]['options'] as List<Map<String, dynamic>>;
    return Column(
      children: options.map((option) {
        final isSelected = _answers[questionIndex] == option['value'];
        return GestureDetector(
          onTap: () =>
              setState(() => _answers[questionIndex] = option['value']),
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
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
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
            child: CustomButton(
              text: isLastPage ? 'Завершить' : 'Далее',
              onPressed: hasAnswer
                  ? () {
                      if (isLastPage) {
                        _completeDiagnostic();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const IntroScreen(), // ← Переход на знакомство
                          ),
                        );
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

  void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Пропустить диагностику?',
          style: AppTextStyles.h3.copyWith(fontSize: 20),
        ),
        content: Text(
          'Первичная диагностика поможет нам лучше понять твоё состояние и подобрать подходящие рекомендации.',
          style: AppTextStyles.body1.copyWith(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Продолжить тест',
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
              Navigator.pop(context, {'skipped': true});
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

  void _completeDiagnostic() {
    // Расчет базовых показателей
    final results = _calculateResults();

    Navigator.pop(context, {
      'completed': true,
      'answers': _answers,
      'results': results,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✓ Первичная диагностика завершена!'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Map<String, dynamic> _calculateResults() {
    // Простой расчет для демонстрации
    int anxietyScore = _answers[0] ?? 0;
    num depressionScore = 5 - (_answers[1] ?? 3);
    double stressScore = _answers[2] ?? 5.0;
    num sleepScore = 5 - (_answers[3] ?? 3);
    int focusScore = _answers[4] ?? 0;

    return {
      'anxiety': anxietyScore,
      'depression': depressionScore,
      'stress': stressScore,
      'sleep': sleepScore,
      'focus': focusScore,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
