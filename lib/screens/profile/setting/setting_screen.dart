import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'change_password_screen.dart';
import 'delete_account_screen.dart';
import '../FAQ/faq_screen.dart';

/// Экран настроек приложения
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ✅ Настройки уведомлений
  bool pushNotificationsEnabled = true;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool meditationReminders = true;
  bool exerciseReminders = true;

  // ✅ Настройки конфиденциальности
  bool shareDataForResearch = false;
  bool analyticsEnabled = true;

  String selectedLanguage = 'Русский';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Настройки',
          style: AppTextStyles.h2.copyWith(fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ✅ Секция: Уведомления
            _buildSection(
              title: 'Уведомления',
              children: [
                _buildSwitchItem(
                  title: 'Push-уведомления',
                  subtitle: 'Получать push-уведомления',
                  value: pushNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      pushNotificationsEnabled = value;
                      // TODO: Интеграция с Firebase Cloud Messaging
                    });
                    _showSavedSnackBar();
                  },
                ),
                _buildDivider(),
                _buildSwitchItem(
                  title: 'Звук уведомлений',
                  subtitle: 'Воспроизводить звуки',
                  value: soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      soundEnabled = value;
                    });
                    _showSavedSnackBar();
                  },
                ),
                _buildDivider(),
                _buildSwitchItem(
                  title: 'Вибрация',
                  subtitle: 'Вибрировать при уведомлениях',
                  value: vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      vibrationEnabled = value;
                    });
                    _showSavedSnackBar();
                  },
                ),
                _buildDivider(),
                _buildSwitchItem(
                  title: 'Напоминания о медитации',
                  subtitle: 'Ежедневные напоминания',
                  value: meditationReminders,
                  onChanged: (value) {
                    setState(() {
                      meditationReminders = value;
                    });
                    _showSavedSnackBar();
                  },
                ),
                _buildDivider(),
                _buildSwitchItem(
                  title: 'Напоминания об упражнениях',
                  subtitle: 'Напоминать о выполнении упражнений',
                  value: exerciseReminders,
                  onChanged: (value) {
                    setState(() {
                      exerciseReminders = value;
                    });
                    _showSavedSnackBar();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ✅ Секция: Внешний вид
            _buildSection(
              title: 'Внешний вид',
              children: [
                _buildNavigationItem(
                  title: 'Язык приложения',
                  subtitle: selectedLanguage,
                  onTap: () {
                    _showLanguageDialog();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ✅ Секция: Конфиденциальность
            _buildSection(
              title: 'Конфиденциальность',
              children: [
                _buildSwitchItem(
                  title: 'Аналитика использования',
                  subtitle: 'Помогать улучшать приложение',
                  value: analyticsEnabled,
                  onChanged: (value) {
                    setState(() {
                      analyticsEnabled = value;
                    });
                    _showSavedSnackBar();
                  },
                ),
                _buildDivider(),
                _buildSwitchItem(
                  title: 'Данные для исследований',
                  subtitle: 'Использовать анонимные данные для исследований',
                  value: shareDataForResearch,
                  onChanged: (value) {
                    setState(() {
                      shareDataForResearch = value;
                    });
                    _showSavedSnackBar();
                  },
                ),
                _buildDivider(),
                _buildNavigationItem(
                  title: 'Политика конфиденциальности',
                  subtitle: 'Как мы обрабатываем ваши данные',
                  onTap: () {
                    _showPrivacyPolicy();
                  },
                ),
                _buildDivider(),
                _buildNavigationItem(
                  title: 'Условия использования',
                  subtitle: 'Правила и условия',
                  onTap: () {
                    _showTermsOfService();
                  },
                ),
                _buildDivider(),
                _buildNavigationItem(
                  title: 'Управление данными',
                  subtitle: 'Экспорт и удаление данных',
                  onTap: () {
                    _showDataManagement();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Секция: Учетная запись
            _buildSectionHeader('Учетная запись'),
            _buildSettingTile(
              icon: Icons.lock_outline,
              title: 'Изменить пароль',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.delete_outline,
              title: 'Удалить аккаунт',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeleteAccountScreen(),
                  ),
                );
              },
              isDestructive: true, // Красный цвет
            ),

            const SizedBox(height: 24),

            // Секция: Поддержка
            _buildSectionHeader('Поддержка'),
            _buildSettingTile(
              icon: Icons.help_outline,
              title: 'Помощь и поддержка',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQScreen()),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.info_outline,
              title: 'О приложении',
              subtitle: 'Версия 1.0.0',
              onTap: () => _showAboutDialog(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Секция настроек
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1.5,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                title,
                style: AppTextStyles.h3.copyWith(fontSize: 18),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  // Заголовок для группы настроек без карточки
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.h3.copyWith(fontSize: 18),
        ),
      ),
    );
  }

  // Элемент настройки с иконкой
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.inputBorder.withOpacity(0.3),
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body1.copyWith(
                        fontSize: 16,
                        color: isDestructive
                            ? AppColors.error
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.body2.copyWith(fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Элемент с переключателем
  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body1.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.body2.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // Элемент с навигацией
  Widget _buildNavigationItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                      fontSize: 16,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.body2.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // Разделитель
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: AppColors.inputBorder.withOpacity(0.3), height: 1),
    );
  }

  // ✅ Уведомление о сохранении
  void _showSavedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Настройки сохранены'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Диалог выбора языка
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Выберите язык',
          style: AppTextStyles.h3.copyWith(fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Русский'),
            // _buildLanguageOption('Қазақша'),
            // _buildLanguageOption('English'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = selectedLanguage == language;
    return ListTile(
      title: Text(
        language,
        style: AppTextStyles.body1.copyWith(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() {
          selectedLanguage = language;
        });
        Navigator.pop(context);
        _showSavedSnackBar();
      },
    );
  }

  // ✅ Управление данными
  void _showDataManagement() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Управление данными', style: AppTextStyles.h3),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.download, color: AppColors.primary),
              title: const Text('Экспорт данных'),
              subtitle: const Text('Скачать все ваши данные'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon();
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text('Удалить все данные'),
              subtitle: const Text('Безвозвратное удаление'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteAccountDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Политика конфиденциальности
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Политика конфиденциальности',
          style: AppTextStyles.h3.copyWith(fontSize: 20),
        ),
        content: SingleChildScrollView(
          child: Text(
            '''Мы серьезно относимся к защите ваших данных:

• Все данные шифруются при передаче и хранении
• Мы не передаем ваши данные третьим лицам без согласия
• Вы можете удалить свой аккаунт в любое время
• Анонимные данные могут использоваться для улучшения сервиса

Подробнее: balancepsy.com/privacy''',
            style: AppTextStyles.body1.copyWith(fontSize: 15),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Понятно',
              style: AppTextStyles.body1.copyWith(
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Условия использования
  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Условия использования',
          style: AppTextStyles.h3.copyWith(fontSize: 20),
        ),
        content: SingleChildScrollView(
          child: Text(
            '''Используя BalancePsy, вы соглашаетесь:

• Использовать приложение в соответствии с законом
• Не распространять вредоносный контент
• Не нарушать права других пользователей
• Предоставлять точную информацию

Подробнее: balancepsy.com/terms''',
            style: AppTextStyles.body1.copyWith(fontSize: 15),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Понятно',
              style: AppTextStyles.body1.copyWith(
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Диалог удаления аккаунта
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Удалить аккаунт?',
          style: AppTextStyles.h3.copyWith(fontSize: 20),
        ),
        content: Text(
          'Вы действительно хотите удалить свой аккаунт? Это действие необратимо.',
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
              // TODO: Удалить аккаунт
              _showComingSoon();
            },
            child: Text(
              'Удалить',
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

  // Диалог о приложении
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'О приложении',
          style: AppTextStyles.h3.copyWith(fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BalancePsy',
              style: AppTextStyles.h3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Версия 1.0.0',
              style: AppTextStyles.body2.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Платформа для психологической поддержки и консультаций с профессиональными психологами.',
              style: AppTextStyles.body1.copyWith(fontSize: 15),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Закрыть',
              style: AppTextStyles.body1.copyWith(
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Скоро будет доступно'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
