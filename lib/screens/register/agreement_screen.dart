import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/back_button.dart';
import 'role_selection_screen.dart';

/// Экран соглашения пользователя перед регистрацией
class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToEnd = false;
  bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToEnd) {
        setState(() => _hasScrolledToEnd = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  Text(
                    'Пользовательское соглашение',
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),

            // Контент соглашения
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Добро пожаловать в BalancePsy',
                      style: AppTextStyles.h2.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Прежде чем начать, ознакомься с условиями использования нашего сервиса.',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      '1. Принятие условий',
                      'Используя BalancePsy, ты соглашаешься с настоящими условиями использования. Если ты не согласен с какими-либо условиями, пожалуйста, не используй наш сервис.',
                    ),

                    _buildSection(
                      '2. Описание сервиса',
                      'BalancePsy предоставляет платформу для психологической поддержки, медитации и саморазвития. Мы не являемся заменой профессиональной медицинской или психологической помощи.',
                    ),

                    _buildSection(
                      '3. Конфиденциальность',
                      'Мы серьезно относимся к защите твоих персональных данных. Вся информация хранится в зашифрованном виде и используется только для улучшения твоего опыта использования приложения.',
                    ),

                    _buildSection(
                      '4. Согласие на обработку данных',
                      'Регистрируясь, ты даешь согласие на обработку следующих данных:\n'
                          '• Имя и контактная информация\n'
                          '• Демографические данные (возраст, пол)\n'
                          '• Данные о здоровье и самочувствии\n'
                          '• История использования приложения',
                    ),

                    _buildSection(
                      '5. Права пользователя',
                      'Ты имеешь право:\n'
                          '• Получить доступ к своим данным\n'
                          '• Исправить неточные данные\n'
                          '• Удалить свой аккаунт в любой момент\n'
                          '• Отозвать согласие на обработку данных',
                    ),

                    _buildSection(
                      '6. Ограничения использования',
                      'Запрещается использовать сервис для:\n'
                          '• Нарушения законов\n'
                          '• Причинения вреда другим пользователям\n'
                          '• Распространения вредоносного ПО\n'
                          '• Несанкционированного доступа к системам',
                    ),

                    _buildSection(
                      '7. Отказ от ответственности',
                      'BalancePsy предоставляет информационную и образовательную поддержку, но не заменяет профессиональную медицинскую помощь. В случае серьезных психологических проблем обратись к квалифицированному специалисту.',
                    ),

                    _buildSection(
                      '8. Изменение условий',
                      'Мы оставляем за собой право изменять данные условия. О существенных изменениях ты будешь уведомлен через приложение или email.',
                    ),

                    _buildSection(
                      '9. Контакты',
                      'По вопросам использования сервиса свяжись с нами:\n'
                          'Email: support@balancepsy.com\n'
                          'Сайт: www.balancepsy.com',
                    ),

                    const SizedBox(height: 40),

                    // Индикатор прокрутки
                    if (!_hasScrolledToEnd)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_downward,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Прокрути до конца, чтобы продолжить',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Чекбокс согласия
            if (_hasScrolledToEnd)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => setState(() => _isAgreed = !_isAgreed),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isAgreed
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isAgreed
                            ? AppColors.primary
                            : AppColors.inputBorder,
                        width: _isAgreed ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _isAgreed
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: _isAgreed
                                  ? AppColors.primary
                                  : AppColors.inputBorder,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _isAgreed
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Я прочитал(а) и принимаю условия пользовательского соглашения',
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _isAgreed
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Кнопка продолжить
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Принять и продолжить',
                showArrow: true,
                onPressed: _hasScrolledToEnd && _isAgreed
                    ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoleSelectionScreen(),
                          ),
                        );
                      }
                    : null,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.body2.copyWith(fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}
