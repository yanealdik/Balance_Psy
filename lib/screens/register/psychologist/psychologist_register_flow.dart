import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/back_button.dart';
import '../../../providers/registration_provider.dart';
import '../../../services/auth_service.dart';
import '../../login/login_screen.dart';

class PsychologistRegisterFlow extends StatefulWidget {
  const PsychologistRegisterFlow({super.key});

  @override
  State<PsychologistRegisterFlow> createState() =>
      _PsychologistRegisterFlowState();
}

class _PsychologistRegisterFlowState extends State<PsychologistRegisterFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers для дополнительных полей психолога
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _bioController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  List<String> _selectedApproaches = [];
  bool _isRegistering = false;

  final List<String> _availableApproaches = [
    'Когнитивно-поведенческая терапия (КПТ)',
    'Психоанализ',
    'Гештальт-терапия',
    'Системная терапия',
    'Гуманистическая терапия',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_selectedApproaches.isEmpty) {
      _showError('Выберите хотя бы один подход');
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final regProvider = Provider.of<RegistrationProvider>(
        context,
        listen: false,
      );

      final data = {
        ...regProvider.getRegistrationData(),
        'specialization': _specializationController.text.trim(),
        'experienceYears': int.parse(_experienceController.text.trim()),
        'education': _educationController.text.trim(),
        'bio': _bioController.text.trim(),
        'approaches': _selectedApproaches,
        'hourlyRate': double.parse(_hourlyRateController.text.trim()),
      };

      final authService = AuthService();
      await authService.registerPsychologist(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Регистрация успешна! Ожидайте верификации.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isRegistering = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CustomBackButton(),
                  const SizedBox(width: 16),
                  Text(
                    'Регистрация психолога',
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _specializationController,
                      hintText:
                          'Специализация (напр. "Тревожность, депрессия")',
                      prefixIcon: Icons.psychology,
                      enabled: !_isRegistering,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _experienceController,
                      hintText: 'Опыт работы (лет)',
                      prefixIcon: Icons.work,
                      keyboardType: TextInputType.number,
                      enabled: !_isRegistering,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _educationController,
                      hintText: 'Образование (минимум 10 символов)',
                      prefixIcon: Icons.school,
                      maxLength: 3,
                      enabled: !_isRegistering,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _bioController,
                      hintText: 'О себе (минимум 50 символов)',
                      prefixIcon: Icons.info,
                      maxLength: 5,
                      enabled: !_isRegistering,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _hourlyRateController,
                      hintText: 'Стоимость часа (₸)',
                      prefixIcon: Icons.monetization_on,
                      keyboardType: TextInputType.number,
                      enabled: !_isRegistering,
                    ),
                    const SizedBox(height: 24),

                    // Выбор подходов
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Подходы (выберите минимум 1):',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableApproaches.map((approach) {
                        final isSelected = _selectedApproaches.contains(
                          approach,
                        );
                        return FilterChip(
                          label: Text(approach),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedApproaches.add(approach);
                              } else {
                                _selectedApproaches.remove(approach);
                              }
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                    CustomButton(
                      text: _isRegistering
                          ? 'Регистрация...'
                          : 'Зарегистрироваться',
                      onPressed: _isRegistering ? null : _register,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
