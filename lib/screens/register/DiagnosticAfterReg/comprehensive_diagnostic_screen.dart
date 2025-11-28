import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../models/diagnostic_model.dart';
import '../../../services/diagnostic_service.dart';
import '../../intro/intro_screen.dart';

/// Комплексная психологическая диагностика
class ComprehensiveDiagnosticScreen extends StatefulWidget {
  const ComprehensiveDiagnosticScreen({super.key});

  @override
  State<ComprehensiveDiagnosticScreen> createState() =>
      _ComprehensiveDiagnosticScreenState();
}

class _ComprehensiveDiagnosticScreenState
    extends State<ComprehensiveDiagnosticScreen> {
  final PageController _pageController = PageController();
  final DiagnosticService _diagnosticService = DiagnosticService();

  int _currentPage = 0;
  bool _isSubmitting = false;

  // Ответы на тесты
  final List<int?> _phq9Answers = List.filled(9, null);
  final List<int?> _gad7Answers = List.filled(7, null);
  final List<int?> _eat26Answers = List.filled(26, null);
  final List<int?> _perfectionismAnswers = List.filled(12, null);

  // BDD ответы
  bool? _bddQ1;
  bool? _bddQ2;
  final List<String> _bddBodyParts = [];
  bool? _bddWeightConcern;
  bool? _bddDistress;
  bool? _bddSocialImpact;
  bool? _bddWorkProblems;
  bool? _bddAvoidance;
  int? _bddTimeThinking;

  // Всего страниц
  static const int totalPages = 6;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_canProceed()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _phq9Answers.every((answer) => answer != null);
      case 1:
        return _gad7Answers.every((answer) => answer != null);
      case 2:
        return _eat26Answers.every((answer) => answer != null);
      case 3:
        return _bddQ1 != null &&
            _bddQ2 != null &&
            _bddWeightConcern != null &&
            _bddDistress != null &&
            _bddSocialImpact != null &&
            _bddWorkProblems != null &&
            _bddAvoidance != null &&
            _bddTimeThinking != null;
      case 4:
        return _perfectionismAnswers.every((answer) => answer != null);
      case 5:
        // Итоговая страница: сюда попадаем только после заполнения всего,
        // поэтому кнопка может быть всегда активна
        return true;
      default:
        return false;
    }
  }

  Future<void> _submitDiagnostic() async {
    setState(() => _isSubmitting = true);

    try {
      final request = DiagnosticSubmissionRequest(
        phq9Answers: _phq9Answers.map((a) => a!).toList(),
        gad7Answers: _gad7Answers.map((a) => a!).toList(),
        eat26Answers: _eat26Answers.map((a) => a!).toList(),
        bddAnswers: BddAnswers(
          concernedAboutAppearance: _bddQ1!,
          thinksAboutItALot: _bddQ2!,
          bodyPartsNotLiked: _bddBodyParts,
          mainConcernIsWeight: _bddWeightConcern!,
          causesDistress: _bddDistress!,
          interferesWithSocialLife: _bddSocialImpact!,
          causesWorkProblems: _bddWorkProblems!,
          avoidsThings: _bddAvoidance!,
          timeThinkingPerDay: _bddTimeThinking!,
        ),
        perfectionismAnswers: _perfectionismAnswers.map((a) => a!).toList(),
      );

      await _diagnosticService.submitDiagnostic(request);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const IntroScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildPhq9Page(),
                  _buildGad7Page(),
                  _buildEat26Page(),
                  _buildBddPage(),
                  _buildPerfectionismPage(),
                  _buildSummaryPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(),
          ),
          Expanded(
            child: Text(
              'Психологическая диагностика',
              style: AppTextStyles.h3.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentPage + 1) / totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Шаг ${_currentPage + 1} из $totalPages',
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
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhq9Page() {
    const questions = [
      'Утрата интереса или удовольствия от дел, которые обычно нравятся',
      'Пониженное настроение, чувство грусти, подавленности или безнадёжности',
      'Проблемы со сном: трудности с засыпанием, частые пробуждения или наоборот — слишком долгий сон',
      'Усталость, потеря энергии',
      'Снижение аппетита или переедание',
      'Низкая самооценка: чувство, что вы плохой человек или разочаровали себя/окружающих',
      'Трудности с концентрацией: сложно сосредоточиться на чтении, работе, делах',
      'Замедленность движений или речи, или наоборот – беспокойство, суетливость',
      'Мысли, что лучше умереть или причинить себе вред',
    ];

    return _buildTestPage(
      title: 'PHQ-9: Депрессия',
      subtitle:
          'За последние 2 недели, как часто вас беспокоили следующие проблемы?',
      questions: questions,
      answers: _phq9Answers,
      options: const [
        'Вовсе нет',
        'Несколько дней',
        'Более половины дней',
        'Почти каждый день',
      ],
    );
  }

  Widget _buildGad7Page() {
    const questions = [
      'Чувство нервозности, тревоги или "на взводе"',
      'Неспособность остановить или контролировать беспокойство',
      'Излишнее беспокойство о разных вещах сразу',
      'Трудности с расслаблением',
      'Беспокойство, что что-то плохое может произойти',
      'Чувство нетерпения, будто трудно усидеть на месте',
      'Легко раздражающееся состояние или ощущение, что ты быстро выходишь из себя',
    ];

    return _buildTestPage(
      title: 'GAD-7: Тревога',
      subtitle:
          'За последние 2 недели, как часто тебя беспокоили следующие симптомы?',
      questions: questions,
      answers: _gad7Answers,
      options: const [
        'Вовсе нет',
        'Несколько дней',
        'Больше половины дней',
        'Почти каждый день',
      ],
    );
  }

  Widget _buildEat26Page() {
    const questions = [
      'Я боюсь быть толстой/толстым',
      'Я избегаю еды с высоким содержанием углеводов',
      'Я чувствую себя хуже и виню себя после того, как много съедаю',
      'Я ем меньше, чтобы не поправиться',
      'Я занята мыслями о еде',
      'Я считаю калории, чтобы контролировать вес',
      'Я чувствую, что у меня есть контроль над тем, сколько я ем',
      'Я пропускаю приёмы пищи, чтобы похудеть',
      'Я ем диетическую или «лёгкую» еду',
      'Я чувствую страх, когда набираю вес',
      'Я ем очень медленно',
      'Я задаюсь вопросом, не слишком ли я ем',
      'Я испытываю напряжение во время приёма пищи',
      'Мне нравится, когда мой желудок пустой',
      'После еды я чувствую дискомфорт из-за ощущения переполнения',
      'Я одержима желанием быть худой',
      'Я пью много воды, кофе, чая, чтобы подавить голод',
      'Я тренируюсь чрезмерно, чтобы сжечь калории',
      'Я считаю, что моя жизнь была бы лучше, если бы я похудела',
      'Я ем одна/один, потому что стыдно есть при других',
      'У меня бывают переедания, когда я теряю контроль',
      'После переедания у меня есть желание вызвать рвоту',
      'Я иногда принимаю слабительные, мочегонные',
      'Я очень обеспокоена своим телом и фигурой',
      'Люди говорят, что я слишком худая, хотя я так не считаю',
      'Я была на жёсткой диете хотя бы 1–2 дня за последние 3 месяца',
    ];

    return _buildTestPage(
      title: 'EAT-26: Пищевое поведение',
      subtitle: 'Оцени утверждения по частоте за последние 3 месяца',
      questions: questions,
      answers: _eat26Answers,
      options: const ['Никогда', 'Редко', 'Иногда', 'Часто'],
    );
  }

  // ================== BDD ==================

  Widget _buildBddPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BDD: Образ тела',
            style: AppTextStyles.h2.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Вопросы о переживаниях, связанных с внешностью',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Вопрос 1
          _buildBoolQuestion(
            'Вы переживаете из-за того, как вы выглядите?',
            _bddQ1,
            (value) => setState(() => _bddQ1 = value),
          ),

          if (_bddQ1 == true) ...[
            const SizedBox(height: 16),
            _buildBoolQuestion(
              'Думаете ли вы много о своих «проблемах во внешности» и хотели бы думать об этом меньше?',
              _bddQ2,
              (value) => setState(() => _bddQ2 = value),
            ),
          ],

          if (_bddQ1 == true && _bddQ2 == true) ...[
            const SizedBox(height: 20),
            Text(
              'Перечислите части тела, которые вам не нравятся (необязательно):',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  [
                    'Кожа',
                    'Волосы',
                    'Нос',
                    'Рот',
                    'Живот',
                    'Бёдра',
                    'Грудь',
                    'Другое',
                  ].map((part) {
                    final isSelected = _bddBodyParts.contains(part);
                    return FilterChip(
                      label: Text(part),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _bddBodyParts.add(part);
                          } else {
                            _bddBodyParts.remove(part);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),
            _buildBoolQuestion(
              'Является ли вашим основным переживанием то, что вы недостаточно худы?',
              _bddWeightConcern,
              (value) => setState(() => _bddWeightConcern = value),
            ),

            const SizedBox(height: 16),
            _buildBoolQuestion(
              'Часто ли это сильно расстраивает вас?',
              _bddDistress,
              (value) => setState(() => _bddDistress = value),
            ),

            const SizedBox(height: 16),
            _buildBoolQuestion(
              'Мешает ли это заниматься чем-либо с друзьями или социальными активностями?',
              _bddSocialImpact,
              (value) => setState(() => _bddSocialImpact = value),
            ),

            const SizedBox(height: 16),
            _buildBoolQuestion(
              'Вызывало ли это проблемы в школе, на работе или других видах деятельности?',
              _bddWorkProblems,
              (value) => setState(() => _bddWorkProblems = value),
            ),

            const SizedBox(height: 16),
            _buildBoolQuestion(
              'Есть ли вещи, которых вы избегаете из-за того, как выглядите?',
              _bddAvoidance,
              (value) => setState(() => _bddAvoidance = value),
            ),

            const SizedBox(height: 20),
            Text(
              'В среднем, сколько времени в день вы думаете о том, как выглядите?',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 12),
            _buildRadioGroup(
              ['Менее 1 часа', '1–3 часа', 'Более 3 часов'],
              _bddTimeThinking,
              (value) => setState(() => _bddTimeThinking = value),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================== Перфекционизм ==================

  Widget _buildPerfectionismPage() {
    const questions = [
      'Я ставлю перед собой очень высокие стандарты',
      'Даже если я добился хорошего результата, я всё равно ощущаю, что мог лучше',
      'Я часто сомневаюсь в качестве своей работы',
      'Ошибки для меня недопустимы',
      'Я чувствую сильное давление соответствовать ожиданиям важных для меня людей',
      'Мне трудно расслабиться, если что-то сделано не идеально',
      'Я часто сравниваю свои результаты с результатами других',
      'Если я не сделаю что-то на высшем уровне, я считаю, что провалился',
      'Я слишком много думаю о возможных ошибках',
      'Я часто чувствую, что разочаровываю себя или других',
      'Я склонен откладывать дела, потому что боюсь сделать их недостаточно хорошо',
      'Мне сложно быть довольным своими достижениями',
    ];

    return _buildScalePage(
      title: 'Перфекционизм',
      subtitle: 'Оцените, насколько каждое утверждение вам подходит',
      questions: questions,
      answers: _perfectionismAnswers,
      options: const [
        'Совершенно не согласен',
        'Скорее не согласен',
        'Частично согласен',
        'Скорее согласен',
        'Полностью согласен',
      ],
    );
  }

  // ================== Итоговая страница ==================

  Widget _buildSummaryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Диагностика завершена',
            style: AppTextStyles.h2.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Вы ответили на все вопросы. Нажмите "Отправить", чтобы сохранить результаты.',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          _buildSummaryCard(
            'PHQ-9 (Депрессия)',
            '9 вопросов',
            Icons.sentiment_dissatisfied,
          ),
          _buildSummaryCard('GAD-7 (Тревога)', '7 вопросов', Icons.psychology),
          _buildSummaryCard(
            'EAT-26 (Пищевое поведение)',
            '26 вопросов',
            Icons.restaurant,
          ),
          _buildSummaryCard(
            'BDD (Образ тела)',
            'Структурированный',
            Icons.face,
          ),
          _buildSummaryCard('Перфекционизм', '12 вопросов', Icons.star),

          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ваши результаты будут сохранены и доступны для просмотра психологам',
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green),
          ),
          const SizedBox(width: 12),
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
                Text(
                  subtitle,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }

  // ... (продолжение в следующем файле с вспомогательными методами)
  // ============================================
  // ЧАСТЬ 3: Вспомогательные виджеты и навигация
  // Добавьте эти методы в класс _ComprehensiveDiagnosticScreenState
  // ============================================

  // ================== Общие виджеты ==================

  Widget _buildTestPage({
    required String title,
    required String subtitle,
    required List<String> questions,
    required List<int?> answers,
    required List<String> options,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2.copyWith(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          ...List.generate(questions.length, (index) {
            return Column(
              children: [
                _buildQuestion(
                  questionNumber: index + 1,
                  questionText: questions[index],
                  options: options,
                  selectedValue: answers[index],
                  onChanged: (value) => setState(() => answers[index] = value),
                ),
                if (index < questions.length - 1) const SizedBox(height: 20),
              ],
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScalePage({
    required String title,
    required String subtitle,
    required List<String> questions,
    required List<int?> answers,
    required List<String> options,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2.copyWith(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          ...List.generate(questions.length, (index) {
            return Column(
              children: [
                _buildScaleQuestion(
                  questionNumber: index + 1,
                  questionText: questions[index],
                  options: options,
                  selectedValue: answers[index],
                  onChanged: (value) => setState(() => answers[index] = value),
                ),
                if (index < questions.length - 1) const SizedBox(height: 20),
              ],
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuestion({
    required int questionNumber,
    required String questionText,
    required List<String> options,
    required int? selectedValue,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedValue != null
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.inputBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: selectedValue != null
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: AppTextStyles.body2.copyWith(
                      color: selectedValue != null
                          ? Colors.white
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  questionText,
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            final isSelected = selectedValue == index;
            return GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.inputBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        options[index],
                        style: AppTextStyles.body2.copyWith(
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
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScaleQuestion({
    required int questionNumber,
    required String questionText,
    required List<String> options,
    required int? selectedValue,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedValue != null
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.inputBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: selectedValue != null
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: AppTextStyles.body2.copyWith(
                      color: selectedValue != null
                          ? Colors.white
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  questionText,
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(options.length, (index) {
              final isSelected = selectedValue == (index + 1);
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(index + 1),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < options.length - 1 ? 4 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.inputBorder,
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body2.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                options.first,
                style: AppTextStyles.body3.copyWith(fontSize: 11),
              ),
              Text(
                options.last,
                style: AppTextStyles.body3.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoolQuestion(
    String question,
    bool? value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: AppTextStyles.body2),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  'Да',
                  value == true,
                  () => onChanged(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOptionButton(
                  'Нет',
                  value == false,
                  () => onChanged(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioGroup(
    List<String> options,
    int? selectedValue,
    Function(int) onChanged,
  ) {
    return Column(
      children: List.generate(options.length, (index) {
        final isSelected = selectedValue == index;
        return GestureDetector(
          onTap: () => onChanged(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.inputBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    options[index],
                    style: AppTextStyles.body2.copyWith(
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
      }),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.body2.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================== Навигация ==================

  Widget _buildNavigationButtons() {
    final isLastPage = _currentPage == totalPages - 1;
    final canProceed = _canProceed();

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
                onPressed: _previousPage,
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
              text: isLastPage
                  ? (_isSubmitting ? 'Отправка...' : 'Отправить')
                  : 'Далее',
              onPressed: canProceed && !_isSubmitting
                  ? (isLastPage ? _submitDiagnostic : _nextPage)
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
          'Прервать диагностику?',
          style: AppTextStyles.h3.copyWith(fontSize: 20),
        ),
        content: Text(
          'Ваш прогресс не будет сохранён. Вы уверены?',
          style: AppTextStyles.body1.copyWith(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Продолжить',
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
              Navigator.pop(context);
            },
            child: Text(
              'Выйти',
              style: AppTextStyles.body1.copyWith(
                fontSize: 15,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
