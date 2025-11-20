import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/step_indicator.dart';
import '../../../widgets/back_button.dart';
import '../../../providers/psychologist_registration_provider.dart';
import 'psychologist_register_step2.dart';

/// Шаг 1: Личные данные психолога
class PsychologistRegisterStep1 extends StatefulWidget {
  const PsychologistRegisterStep1({super.key});

  @override
  State<PsychologistRegisterStep1> createState() =>
      _PsychologistRegisterStep1State();
}

class _PsychologistRegisterStep1State extends State<PsychologistRegisterStep1> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();

  String? _gender;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PsychologistRegistrationProvider>(
        context,
        listen: false,
      );
      if (provider.fullName != null) {
        _nameController.text = provider.fullName!;
      }
      if (provider.phone != null) {
        _phoneController.text = provider.phone!;
      }
      if (provider.dateOfBirth != null) {
        final date = provider.dateOfBirth!;
        _dayController.text = date.day.toString().padLeft(2, '0');
        _monthController.text = date.month.toString().padLeft(2, '0');
        _yearController.text = date.year.toString();
      }
      if (provider.gender != null) {
        setState(() => _gender = provider.gender);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
    setState(() => _errorMessage = null);

    // Проверка имени
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Введите ФИО');
      return;
    }

    if (_nameController.text.trim().length < 2) {
      setState(() => _errorMessage = 'ФИО должно содержать минимум 2 символа');
      return;
    }

    // Проверка даты рождения
    if (_dayController.text.isEmpty ||
        _monthController.text.isEmpty ||
        _yearController.text.isEmpty) {
      setState(() => _errorMessage = 'Введите дату рождения');
      return;
    }

    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);

    if (day == null || month == null || year == null) {
      setState(() => _errorMessage = 'Введите корректную дату');
      return;
    }

    if (year < 1950 || year > DateTime.now().year - 21) {
      setState(() => _errorMessage = 'Проверьте год рождения');
      return;
    }

    if (!_isValidDate(day, month, year)) {
      setState(() => _errorMessage = 'Такой даты не существует');
      return;
    }

    final age = _calculateAge(day, month, year);

    // ВАЖНО: Психологи должны быть 21+
    if (age < 21) {
      setState(() {
        _errorMessage = 'Для регистрации психологом необходимо быть старше 21 года';
      });
      return;
    }

    // Сохраняем данные
    final provider = Provider.of<PsychologistRegistrationProvider>(
      context,
      listen: false,
    );

    provider.setPersonalInfo(
      fullName: _nameController.text.trim(),
      dateOfBirth: DateTime(year, month, day),
      age: age,
      gender: _gender,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    // Переход к следующему шагу
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PsychologistRegisterStep2(),
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
            // Шапка
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                  StepIndicator(currentStep: 1, totalSteps: 4),
                ],
              ),
            ),

            // Контент
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Text(
                      'Личные данные',
                      style: AppTextStyles.h2.copyWith(fontSize: 26),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Расскажите о себе, чтобы мы могли создать ваш профиль',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ФИО
                    Text(
                      'Полное имя *',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Иванов Иван Иванович',
                      prefixIcon: Icons.person_outline,
                      enabled: true,
                      maxLength: 255,
                      onChanged: (value) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Дата рождения
                    Text(
                      'Дата рождения * (минимум 21 год)',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
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

                    const SizedBox(height: 24),

                    // Телефон (необязательно)
                    Text(
                      'Телефон (необязательно)',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _phoneController,
                      hintText: '+7 (___) ___-__-__',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      enabled: true,
                      maxLength: 20,
                    ),

                    const SizedBox(height: 24),

                    // Пол (необязательно)
                    Text(
                      'Пол (необязательно)',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderButton('Мужской', 'male'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGenderButton('Женский', 'female'),
                        ),
                      ],
                    ),

                    // Ошибка
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
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
                                _errorMessage!,
                                style: AppTextStyles.body2.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

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
          if (_errorMessage != null) {
            setState(() => _errorMessage = null);
          }
        },
        onTap: () => setState(() {}),
      ),
    );
  }

  Widget _buildGenderButton(String label, String value) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body1.copyWith(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}