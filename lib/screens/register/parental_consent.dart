),
),
const SizedBox(width: 12),
const Icon(
Icons.close,
color: AppColors.textSecondary,
size: 20,
),
],
),
),
),
const SizedBox(height: 20),
],
),
),
),
        Padding(
          padding: const EdgeInsets.all(24),
          child: CustomButton(
            text: 'Продолжить',
            showArrow: true,
            onPressed: () {
              // Сохраняем пол в provider
              final regProvider = Provider.of<RegistrationProvider>(
                context,
                listen: false,
              );
              
              String? gender;
              if (selectedGender == 0) {
                gender = 'male';
              } else if (selectedGender == 1) {
                gender = 'female';
              }
              
              regProvider.setGender(gender);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnboardingStep4Screen(),
                ),
              );
            },
            isFullWidth: true,
          ),
        ),
      ],
    ),
  ),
);
}
Widget _buildGenderOption({
required int index,
required String title,
required IconData icon,
}) {
final isSelected = selectedGender == index;
return GestureDetector(
  onTap: () {
    setState(() {
      selectedGender = index;
    });
  },
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    height: 180,
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: isSelected ? AppColors.primary : AppColors.inputBorder,
        width: isSelected ? 3 : 2,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
    ),
    child: Stack(
      children: [
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(60),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                index == 0
                    ? 'assets/stepimages/men.svg'
                    : 'assets/stepimages/women.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          top: 24,
          left: 24,
          child: Row(
            children: [
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  fontSize: 22,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ],
          ),
        ),
        if (isSelected)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
          ),
      ],
    ),
  ),
);
}
}

---

## 7. Обновляем OnboardingStep4Screen

**`lib/screens/register/register_step4.dart`:**
```dart
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
      final regProvider = Provider.of<RegistrationProvider>(context, listen: false);
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
    }

    // Сохраняем дату рождения и возраст в provider
    final regProvider = Provider.of<RegistrationProvider>(context, listen: false);
    final birthDate = DateTime(year, month, day);
    regProvider.setDateOfBirth(birthDate, age);

    // Если возраст меньше 18, показываем экран согласия родителей
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
```

---

## 8. Обновляем ParentalConsentScreen

**`lib/screens/register/parental_consent.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart'; // Добавили
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/back_button.dart';
import '../../providers/registration_provider.dart'; // Добавили
import '../../services/registration_service.dart'; // Добавили
import '../register/register_step5.dart';

class ParentalConsentScreen extends StatefulWidget {
  final int age;

  const ParentalConsentScreen({
    super.key,
    required this.age,
  });

  @override
  State<ParentalConsentScreen> createState() => _ParentalConsentScreenState();
}

class _ParentalConsentScreenState extends State<ParentalConsentScreen> {
  final TextEditingController _emailController = TextEditingController();
  final RegistrationService _registrationService = RegistrationService(); // Добавили
  bool _isAgreed = false;
  bool _isLoading = false; // Добавили
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Загружаем сохранённый email
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final regProvider = Provider.of<RegistrationProvider>(context, listen: false);
      if (regProvider.parentEmail != null) {
        _emailController.text = regProvider.parentEmail!;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _sendParentalConsent() async {
    setState(() {
      errorMessage = null;
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        errorMessage = 'Пожалуйста, введите email родителя';
      });
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      setState(() {
        errorMessage = 'Введите корректный email адрес';
      });
      return;
    }

    if (!_isAgreed) {
      setState(() {
        errorMessage = 'Необходимо согласие родителя';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Отправляем код на email родителя
      await _registrationService.sendVerificationCode(
        _emailController.text.trim(),
        isParentEmail: true,
      );

      // Сохраняем email родителя
      final regProvider = Provider.of<RegistrationProvider>(context, listen: false);
      regProvider.setParentEmail(_emailController.text.trim());

      // Показываем диалог подтверждения
      _showConfirmationDialog();
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.email_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Письмо отправлено',
                style: AppTextStyles.h3,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Мы отправили письмо с запросом согласия на адрес:',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.email,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _emailController.text,
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Родитель должен ввести код на следующем экране для подтверждения.',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Переходим к следующему шагу
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnboardingStep5Screen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Продолжить'),
          ),
        ],
      ),
    );
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
                children: [
                  CustomBackButton(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.family_restroom,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Требуется согласие родителя',
                      style: AppTextStyles.h2.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Вам ${widget.age} лет. Для продолжения регистрации необходимо разрешение вашего родителя или опекуна.',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Как это работает:',
                            style: AppTextStyles.h1.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStep('1', 'Введите email вашего родителя'),
                          const SizedBox(height: 12),
                          _buildStep('2', 'Мы отправим письмо с кодом подтверждения'),
                          const SizedBox(height: 12),
                          _buildStep('3', 'Родитель должен ввести код на следующем экране'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Email родителя или опекуна',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      style: AppTextStyles.body1,
                      decoration: InputDecoration(
                        hintText: 'parent@example.com',
                        hintStyle: AppTextStyles.body1.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.inputBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.inputBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (errorMessage != null) {
                          setState(() {
                            errorMessage = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isAgreed = !_isAgreed;
                                if (_isAgreed && errorMessage != null) {
                                  errorMessage = null;
                                }
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isAgreed
                                ? AppColors.primary
                                : AppColors.inputBorder,
                            width: _isAgreed ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text:
                                          'Я подтверждаю, что у меня есть разрешение родителя на предоставление этого email адреса и отправку запроса на согласие.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                            const SizedBoxRetry