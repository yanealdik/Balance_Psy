import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Добавили
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/back_button.dart';
import '../../providers/registration_provider.dart'; // Добавили
import '../register/register_step5.dart';
import '../register/parental_consent.dart';

class OnboardingStep4Screen extends StatefulWidget {
  const OnboardingStep4Screen({super.key});
  @override
  State<OnboardingStep4Screen> createState() => _OnboardingStep4ScreenState();
}

class _OnboardingStep4ScreenState extends State<OnboardingStep4Screen> {
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();
  String? errorMessage;
  @override
  void initState() {
    super.initState();
    // Загружаем сохранённые данные
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final regProvider = Provider.of<RegistrationProvider>(
        context,
        listen: false,
      );
      if (regProvider.dateOfBirth != null) {
        final date = regProvider.dateOfBirth!;
        _dayController.text = date.day.toString().padLeft(2, '0');
        _monthController.text = date.month.toString().padLeft(2, '0');
        _yearController.text = date.year.toString();
      }
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  int _calculateAge(int day, int month, int year) {
    final today = DateTime.now();
    final birthDate = DateTime(year, month, day);
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  bool _isValidDate(int day, int month, int year) {
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
      return day <= 29;
    }
    return day <= daysInMonth[month - 1];
  }

  void _validateAndProceed() {
    setState(() {
      errorMessage = null;
    });
    if (_dayController.text.isEmpty ||
        _monthController.text.isEmpty ||
        _yearController.text.isEmpty) {
      setState(() {
        errorMessage = 'Пожалуйста, введите полную дату рождения';
      });
      return;
    }
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);
    if (day == null || month == null || year == null) {
      setState(() {
        errorMessage = 'Введите корректную дату';
      });
      return;
    }
    if (year < 1900 || year > DateTime.now().year) {
      setState(() {
        errorMessage = 'Введите корректный год';
      });
      return;
    }
    if (!_isValidDate(day, month, year)) {
      setState(() {
        errorMessage = 'Такой даты не существует';
      });
      return;
    }
    final age = _calculateAge(day, month, year);
    if (age < 13) {
      setState(() {
        errorMessage = 'Минимальный возраст для регистрации - 13 лет';
      });
      return;
    } // Сохраняем дату рождения и возраст в provider
    final regProvider = Provider.of<RegistrationProvider>(
      context,
      listen: false,
    );
    final birthDate = DateTime(year, month, day);
    regProvider.setDateOfBirth(
      birthDate,
      age,
    ); // Если возраст меньше 18, показываем экран согласия родителей
    if (age < 18) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParentalConsentScreen(age: age),
        ),
      );
    } else {
      // Если 18+, переходим к следующему шагу
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingStep5Screen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                  StepIndicator(currentStep: 4, totalSteps: 5),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Ваша дата рождения?',
                      style: AppTextStyles.h2.copyWith(fontSize: 26),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Это поможет нам персонализировать ваш опыт',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDateField(
                          controller: _dayController,
                          focusNode: _dayFocus,
                          nextFocus: _monthFocus,
                          hint: 'ДД',
                          maxLength: 2,
                          width: 70,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '/',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        _buildDateField(
                          controller: _monthController,
                          focusNode: _monthFocus,
                          nextFocus: _yearFocus,
                          hint: 'ММ',
                          maxLength: 2,
                          width: 70,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '/',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        _buildDateField(
                          controller: _yearController,
                          focusNode: _yearFocus,
                          hint: 'ГГГГ',
                          maxLength: 4,
                          width: 100,
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: AppTextStyles.body2.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Пользователям младше 18 лет потребуется согласие родителей',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Продолжить',
                showArrow: true,
                onPressed: _validateAndProceed,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String hint,
    required int maxLength,
    required double width,
    bool isLast = false,
  }) {
    return Container(
      width: width,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: focusNode.hasFocus ? AppColors.primary : AppColors.inputBorder,
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: maxLength,
        style: AppTextStyles.h2.copyWith(fontSize: 24),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.h2.copyWith(
            fontSize: 24,
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
        onChanged: (value) {
          if (value.length == maxLength && !isLast && nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
          if (errorMessage != null) {
            setState(() {
              errorMessage = null;
            });
          }
        },
        onTap: () {
          setState(() {});
        },
      ),
    );
  }
}
