import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/back_button.dart';
import 'role_selection_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/registration_provider.dart';

/// Экран принятия пользовательского соглашения
class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  bool _isAgreed = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Проверяем, долистал ли пользователь до конца
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() => _hasScrolledToBottom = true);
      }
    }
  }

  void _onAcceptAgreement() {
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Пожалуйста, примите соглашение',
            style: AppTextStyles.body2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Сохраняем согласие в провайдер
    Provider.of<RegistrationProvider>(
      context,
      listen: false,
    ).setAgreementAccepted(true);

    // Переход к выбору роли
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
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
            _buildHeader(),

            // Индикатор прокрутки
            if (!_hasScrolledToBottom)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                color: AppColors.primary.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_downward,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Пожалуйста, прочитайте соглашение до конца',
                        style: AppTextStyles.body3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Контент соглашения
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: _buildAgreementContent(),
              ),
            ),

            // Чекбокс и кнопка
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CustomBackButton(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Пользовательское соглашение',
                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  'Версия 1.0 от 28.11.2024',
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Введение
        _buildSection(
          title: '1. Общие положения',
          content: [
            'Настоящее Пользовательское соглашение (далее — «Соглашение») регулирует отношения между пользователем (далее — «Пользователь») и владельцем мобильного приложения BalancePsy (далее — «Приложение», «Сервис»).',
            '',
            'Используя Приложение, Пользователь безоговорочно принимает условия настоящего Соглашения. Если вы не согласны с условиями, пожалуйста, не используйте Приложение.',
          ],
        ),

        const SizedBox(height: 24),

        // Услуги
        _buildSection(
          title: '2. Описание услуг',
          content: [
            'BalancePsy предоставляет пользователям доступ к:',
            '• Психологическим тестам и диагностике',
            '• Медитациям и дыхательным практикам',
            '• Образовательным материалам',
            '• Возможности связи с сертифицированными психологами',
            '• Ведению личного дневника настроения',
            '',
            'Сервис не является заменой профессиональной медицинской или психологической помощи в экстренных случаях.',
          ],
        ),

        const SizedBox(height: 24),

        // Регистрация
        _buildSection(
          title: '3. Регистрация и учетная запись',
          content: [
            'Для использования полного функционала Приложения необходимо создать учетную запись, предоставив достоверную информацию.',
            '',
            'Пользователь несет ответственность за сохранность своих учетных данных и все действия, совершенные через его аккаунт.',
            '',
            'Для пользователей младше 18 лет требуется согласие родителей или законных представителей.',
          ],
        ),

        const SizedBox(height: 24),

        // Конфиденциальность
        _buildSection(
          title: '4. Конфиденциальность и обработка данных',
          content: [
            'Мы серьезно относимся к защите ваших персональных данных. Вся информация обрабатывается в соответствии с нашей Политикой конфиденциальности.',
            '',
            'Собираемые данные:',
            '• Личная информация (имя, email, возраст)',
            '• Результаты тестов и диагностики',
            '• Записи в дневнике настроения',
            '• Статистика использования Приложения',
            '',
            'Ваши данные не передаются третьим лицам без вашего согласия, за исключением случаев, предусмотренных законодательством.',
          ],
        ),

        const SizedBox(height: 24),

        // Психологические консультации
        _buildSection(
          title: '5. Психологические консультации',
          content: [
            'Консультации с психологами проводятся дипломированными специалистами, прошедшими проверку.',
            '',
            'Важно понимать:',
            '• Консультации не заменяют экстренную медицинскую помощь',
            '• При суицидальных мыслях необходимо обратиться в экстренные службы',
            '• Конфиденциальность сеансов гарантируется в рамках законодательства',
          ],
        ),

        const SizedBox(height: 24),

        // Оплата
        _buildSection(
          title: '6. Оплата услуг',
          content: [
            'Некоторые функции Приложения могут быть платными. Информация о стоимости предоставляется до совершения покупки.',
            '',
            'Политика возврата средств действует в соответствии с законодательством о защите прав потребителей.',
          ],
        ),

        const SizedBox(height: 24),

        // Интеллектуальная собственность
        _buildSection(
          title: '7. Интеллектуальная собственность',
          content: [
            'Все материалы Приложения (тексты, изображения, аудио, видео, дизайн) являются объектами интеллектуальной собственности и защищены законом.',
            '',
            'Запрещается копирование, распространение или коммерческое использование материалов без письменного разрешения правообладателя.',
          ],
        ),

        const SizedBox(height: 24),

        // Ограничение ответственности
        _buildSection(
          title: '8. Ограничение ответственности',
          content: [
            'Приложение предоставляется «как есть». Мы не гарантируем бесперебойную работу и отсутствие ошибок.',
            '',
            'Владелец Приложения не несет ответственности за:',
            '• Действия или решения Пользователя, принятые на основе информации из Приложения',
            '• Технические сбои, недоступность сервиса',
            '• Потерю данных в результате форс-мажорных обстоятельств',
          ],
        ),

        const SizedBox(height: 24),

        // Изменения соглашения
        _buildSection(
          title: '9. Изменение условий',
          content: [
            'Мы оставляем за собой право изменять условия настоящего Соглашения. Об изменениях Пользователи будут уведомлены через Приложение.',
            '',
            'Продолжение использования Приложения после внесения изменений означает принятие новых условий.',
          ],
        ),

        const SizedBox(height: 24),

        // Контакты
        _buildSection(
          title: '10. Контактная информация',
          content: [
            'Если у вас есть вопросы по Соглашению, свяжитесь с нами:',
            '',
            'Email: support@balancepsy.com',
            'Телефон: +7 (777) 123-45-67',
            '',
            'Дата последнего обновления: 28 ноября 2024 г.',
          ],
        ),

        const SizedBox(height: 32),

        // Важное предупреждение
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ВАЖНО',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Если вы испытываете мысли о самоповреждении или суициде, немедленно обратитесь в экстренные службы:\n\n'
                      '🆘 Телефон доверия: 8-800-2000-122\n'
                      '🆘 Скорая помощь: 103',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSection({required String title, required List<String> content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...content.map((text) {
          if (text.isEmpty) {
            return const SizedBox(height: 8);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              text,
              style: AppTextStyles.body2.copyWith(fontSize: 14, height: 1.5),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFooter() {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Чекбокс
          GestureDetector(
            onTap: _hasScrolledToBottom
                ? () => setState(() => _isAgreed = !_isAgreed)
                : _showScrollWarning,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hasScrolledToBottom
                    ? (_isAgreed
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent)
                    : AppColors.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasScrolledToBottom
                      ? (_isAgreed ? AppColors.primary : AppColors.inputBorder)
                      : AppColors.textTertiary,
                  width: _isAgreed ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isAgreed ? Icons.check_box : Icons.check_box_outline_blank,
                    color: _hasScrolledToBottom
                        ? (_isAgreed
                              ? AppColors.primary
                              : AppColors.textSecondary)
                        : AppColors.textTertiary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.body2.copyWith(
                          fontSize: 14,
                          color: _hasScrolledToBottom
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                        children: [
                          const TextSpan(text: 'Я прочитал(а) и принимаю '),
                          TextSpan(
                            text: 'Пользовательское соглашение',
                            style: TextStyle(
                              color: _hasScrolledToBottom
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' и '),
                          TextSpan(
                            text: 'Политику конфиденциальности',
                            style: TextStyle(
                              color: _hasScrolledToBottom
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Кнопка продолжить
          CustomButton(
            text: 'Продолжить',
            onPressed: _isAgreed && _hasScrolledToBottom
                ? _onAcceptAgreement
                : null,
            isFullWidth: true,
            showArrow: true,
          ),
        ],
      ),
    );
  }

  void _showScrollWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Пожалуйста, прочитайте соглашение до конца',
          style: AppTextStyles.body2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
