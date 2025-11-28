import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/back_button.dart';

class IntroArticleScreen extends StatefulWidget {
  final String title;
  final String content;

  const IntroArticleScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<IntroArticleScreen> createState() => _IntroArticleScreenState();
}

class _IntroArticleScreenState extends State<IntroArticleScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReadToEnd = false;

  // Статический контент, если не загружен из БД
  static const String defaultContent = '''
**Введение**

BalancePsy — это научно обоснованная платформа для поддержки ментального здоровья, созданная командой психологов и разработчиков. Мы объединили современные психотерапевтические методы с удобными цифровыми инструментами.

**Научный подход**

Каждая техника и практика в BalancePsy основана на доказательной психотерапии:

• **Когнитивно-поведенческая терапия (КПТ)** — помогает изменить негативные мысли и поведение
• **Диалектическая поведенческая терапия (ДБТ)** — учит регулировать эмоции и справляться со стрессом
• **Mindfulness (осознанность)** — развивает навык присутствия "здесь и сейчас"
• **Acceptance and Commitment Therapy (ACT)** — помогает принимать сложные эмоции и действовать согласно ценностям

**Медитация и осознанность**

Регулярная практика медитации оказывает измеримое влияние на мозг и психику:

• Снижение уровня кортизола (гормона стресса)
• Улучшение работы префронтальной коры (принятие решений)
• Повышение активности в области, отвечающей за эмпатию
• Укрепление иммунной системы

Исследования показывают, что всего 10-15 минут медитации в день в течение 8 недель приводят к заметным изменениям в структуре мозга.

**Дыхательные практики**

Контролируемое дыхание — это самый быстрый способ влиять на нервную систему:

• **Диафрагмальное дыхание** активирует парасимпатическую нервную систему ("отдых и восстановление")
• **Дыхание 4-7-8** помогает быстро успокоиться при тревоге
• **Box breathing** используется спецназом для сохранения спокойствия в стрессе

Всего несколько минут осознанного дыхания могут снизить пульс и кровяное давление.

**Когнитивные техники**

КПТ — это золотой стандарт психотерапии для работы с тревогой и депрессией:

• **Дневник мыслей** — помогает отслеживать и изменять негативное мышление
• **Поведенческая активация** — возвращает в жизнь приятные активности
• **Градуированная экспозиция** — постепенно снижает страхи
• **Сократический диалог** — учит задавать вопросы своим убеждениям

Эффективность КПТ подтверждена тысячами исследований.

**Персонализация**

BalancePsy адаптируется под твои потребности:

• Анализ твоих ответов в диагностических опросниках
• Отслеживание прогресса и паттернов настроения
• Рекомендации практик, основанные на твоём состоянии
• Напоминания в удобное для тебя время

**Безопасность и конфиденциальность**

Твои данные под надёжной защитой:

• Шифрование данных по стандартам банковского уровня
• Соответствие GDPR и другим стандартам защиты данных
• Никакая информация не передаётся третьим лицам
• Ты всегда можешь удалить свой аккаунт и все данные

**Работа с психологом**

BalancePsy — это не замена профессиональной психотерапии, а дополнение:

• Все психологи на платформе имеют подтверждённое образование
• Ты можешь выбрать специалиста по специализации и подходу
• Видео-сессии, чат и голосовые сообщения
• Полная конфиденциальность всех консультаций

**Начни сегодня**

BalancePsy — это твой карманный помощник в путешествии к психологическому благополучию.

Регулярная практика приводит к реальным изменениям. Главное — делать маленькие шаги каждый день.

**Научная база**

Наш подход основан на исследованиях ведущих университетов:

• Harvard Medical School (США)
• Oxford Mindfulness Centre (Великобритания)
• Karolinska Institutet (Швеция)
• Centre for Mindfulness Studies (Канада)

Мы постоянно обновляем методики с учётом последних научных открытий.

**Заключение**

Забота о ментальном здоровье — это не роскошь, а необходимость. В мире высокого темпа жизни и постоянного стресса важно иметь инструменты для поддержки себя.

BalancePsy делает профессиональную психологическую помощь доступной и удобной.

Начни свой путь к балансу прямо сейчас!
''';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasReadToEnd) {
        setState(() {
          _hasReadToEnd = true;
        });
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
    final contentToShow = widget.content.isNotEmpty
        ? widget.content
        : defaultContent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя часть с кнопкой назад
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CustomBackButton(
                    onPressed: () => Navigator.pop(context, _hasReadToEnd),
                  ),
                ],
              ),
            ),

            // Контент статьи
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок
                    Text(
                      widget.title.isNotEmpty
                          ? widget.title
                          : 'Как BalancePsy помогает',
                      style: AppTextStyles.h2.copyWith(fontSize: 26),
                    ),

                    const SizedBox(height: 8),

                    // Время чтения
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '5 минут чтения',
                          style: AppTextStyles.body3.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Изображение (опционально)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.primary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome,
                          size: 80,
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Текст статьи с форматированием
                    _buildFormattedContent(contentToShow),

                    const SizedBox(height: 40),

                    // Индикатор прочтения
                    if (_hasReadToEnd)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Статья прочитана! Можешь продолжить',
                                style: AppTextStyles.body2.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
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
                              Icons.arrow_downward,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Прокрути до конца, чтобы продолжить',
                                style: AppTextStyles.body3.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Кнопка "Продолжить"
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Продолжить',
                showArrow: true,
                onPressed: _hasReadToEnd
                    ? () => Navigator.pop(context, true)
                    : null,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedContent(String content) {
    // Простой парсер Markdown для заголовков и списков
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      line = line.trim();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      // Заголовки (например: **Введение**)
      if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.replaceAll('**', ''),
              style: AppTextStyles.h3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        continue;
      }

      // Списки (например: • Пункт)
      if (line.startsWith('• ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: AppTextStyles.body2.copyWith(
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Обычный текст
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            line,
            style: AppTextStyles.body2.copyWith(fontSize: 15, height: 1.6),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
