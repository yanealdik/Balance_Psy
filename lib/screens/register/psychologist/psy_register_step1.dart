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
import 'psy_register_step2.dart';

class PsyRegisterStep1 extends StatefulWidget {
  const PsyRegisterStep1({super.key});

  @override
  State<PsyRegisterStep1> createState() => _PsyRegisterStep1State();
}

class _PsyRegisterStep1State extends State<PsyRegisterStep1> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _selectedDate;
  int? _calculatedAge;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();

    // Загружаем сохраненные данные
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
        setState(() {
          _selectedDate = provider.dateOfBirth;
          _calculatedAge = provider.age;
        });
      }
      if (provider.gender != null) {
        setState(() {
          _selectedGender = provider.gender;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    final hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? eighteenYearsAgo,
      firstDate: hundredYearsAgo,
      lastDate: eighteenYearsAgo,
      locale: const Locale('ru', 'RU'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _calculatedAge = _calculateAge(date);
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime date) {
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool get _canContinue {
    return _nameController.text.trim().length >= 2 &&
        _selectedDate != null &&
        _calculatedAge != null &&
        _calculatedAge! >= 21 &&
        (_phoneController.text.isEmpty || _phoneController.text.length >= 10);
  }

  void _continue() {
    if (!_canContinue) return;

    final provider = Provider.of<PsychologistRegistrationProvider>(
      context,
      listen: false,
    );

    provider.setPersonalInfo(
      fullName: _nameController.text.trim(),
      dateOfBirth: _selectedDate!,
      age: _calculatedAge!,
      gender: _selectedGender,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PsyRegisterStep2()),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomBackButton(),
                  const StepIndicator(currentStep: 1, totalSteps: 5),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      Text(
                        'Личные данные',
                        style: AppTextStyles.h1.copyWith(fontSize: 28),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Расскажите о себе, чтобы мы могли создать ваш профиль',
                        style: AppTextStyles.body2.copyWith(fontSize: 15),
                      ),

                      const SizedBox(height: 32),

                      // ФИО
                      Text(
                        'Полное имя',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'Иванов Иван Иванович',
                        prefixIcon: Icons.person_outline,
                        onChanged: (value) => setState(() {}),
                      ),
                      if (_nameController.text.isNotEmpty &&
                          _nameController.text.trim().length < 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            'Введите полное имя (минимум 2 символа)',
                            style: AppTextStyles.body3.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Дата рождения
                      Text(
                        'Дата рождения',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _selectedDate != null
                                  ? AppColors.primary
                                  : AppColors.inputBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: _selectedDate != null
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedDate != null
                                      ? _formatDate(_selectedDate!)
                                      : 'Выберите дату рождения',
                                  style: AppTextStyles.input.copyWith(
                                    color: _selectedDate != null
                                        ? AppColors.textPrimary
                                        : AppColors.textTertiary,
                                  ),
                                ),
                              ),
                              if (_calculatedAge != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _calculatedAge! >= 21
                                        ? AppColors.success.withOpacity(0.15)
                                        : AppColors.error.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$_calculatedAge лет',
                                    style: AppTextStyles.body3.copyWith(
                                      color: _calculatedAge! >= 21
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_calculatedAge != null && _calculatedAge! < 21)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Для регистрации психологом необходимо быть старше 21 года',
                                style: AppTextStyles.body3.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Пол
                      Text(
                        'Пол (необязательно)',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildGenderOption('male', 'Мужской', Icons.male),
                          const SizedBox(width: 12),
                          _buildGenderOption('female', 'Женский', Icons.female),
                          const SizedBox(width: 12),
                          _buildGenderOption(
                            'other',
                            'Другой',
                            Icons.transgender,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Телефон
                      Text(
                        'Номер телефона (необязательно)',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: '+7 (___) ___-__-__',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        onChanged: (value) => setState(() {}),
                      ),

                      const SizedBox(height: 32),

                      // Информационная карточка
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.verified_user_outlined,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Ваши данные будут проверены администрацией перед активацией профиля',
                                style: AppTextStyles.body3.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  height: 1.4,
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
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Продолжить',
                showArrow: true,
                onPressed: _canContinue ? _continue : null,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.12)
                : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.inputBorder,
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.body3.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
