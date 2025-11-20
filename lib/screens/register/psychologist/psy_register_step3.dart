import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/psychologist/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/step_indicator.dart';
import '../../../widgets/back_button.dart';
import '../../../providers/psychologist_registration_provider.dart';
import 'psy_register_step4.dart';

class PsyRegisterStep3 extends StatefulWidget {
  const PsyRegisterStep3({super.key});

  @override
  State<PsyRegisterStep3> createState() => _PsyRegisterStep3State();
}

class _PsyRegisterStep3State extends State<PsyRegisterStep3> {
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _bioController = TextEditingController();

  List<int> _selectedApproaches = [];

  final List<Map<String, dynamic>> _approaches = [
    {
      'icon': Icons.self_improvement,
      'text': 'Системная терапия',
      'color': const Color(0xFF6366F1),
    },
    {
      'icon': Icons.psychology_outlined,
      'text': 'Психоанализ',
      'color': const Color(0xFFEC4899),
    },
    {
      'icon': Icons.spa,
      'text': 'Гуманистическая терапия',
      'color': const Color(0xFF8B5CF6),
    },
    {
      'icon': Icons.favorite_outline,
      'text': 'Гештальт-терапия',
      'color': const Color(0xFFF43F5E),
    },
    {
      'icon': Icons.psychology,
      'text': 'Когнитивно-поведенческая терапия (КПТ)',
      'color': const Color(0xFF3B82F6),
    },
    {
      'icon': Icons.family_restroom,
      'text': 'Семейная терапия',
      'color': const Color(0xFF10B981),
    },
    {
      'icon': Icons.child_care,
      'text': 'Детская психология',
      'color': const Color(0xFFF59E0B),
    },
  ];

  @override
  void initState() {
    super.initState();

    // Загружаем сохраненные данные
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PsychologistRegistrationProvider>(
        context,
        listen: false,
      );

      if (provider.specialization != null) {
        _specializationController.text = provider.specialization!;
      }
      if (provider.experienceYears != null) {
        _experienceController.text = provider.experienceYears.toString();
      }
      if (provider.education != null) {
        _educationController.text = provider.education!;
      }
      if (provider.bio != null) {
        _bioController.text = provider.bio!;
      }
      if (provider.approaches.isNotEmpty) {
        setState(() {
          _selectedApproaches = provider.approaches
              .map((name) => _approaches.indexWhere((a) => a['text'] == name))
              .where((index) => index != -1)
              .toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _specializationController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _toggleApproach(int index) {
    setState(() {
      if (_selectedApproaches.contains(index)) {
        _selectedApproaches.remove(index);
      } else {
        _selectedApproaches.add(index);
      }
    });
  }

  bool get _canContinue {
    return _specializationController.text.trim().length >= 3 &&
        _experienceController.text.isNotEmpty &&
        int.tryParse(_experienceController.text) != null &&
        _educationController.text.trim().length >= 20 &&
        _bioController.text.trim().length >= 100 &&
        _selectedApproaches.isNotEmpty;
  }

  void _continue() {
    if (!_canContinue) return;

    final provider = Provider.of<PsychologistRegistrationProvider>(
      context,
      listen: false,
    );

    final selectedApproachNames = _selectedApproaches
        .map((index) => _approaches[index]['text'] as String)
        .toList();

    provider.setProfessionalInfo(
      specialization: _specializationController.text.trim(),
      experienceYears: int.parse(_experienceController.text),
      education: _educationController.text.trim(),
      bio: _bioController.text.trim(),
      approaches: selectedApproachNames,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PsyRegisterStep4()),
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
                  const StepIndicator(currentStep: 3, totalSteps: 5),
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

                    Text(
                      'Профессиональная информация',
                      style: AppTextStyles.h1.copyWith(fontSize: 26),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Расскажите о своем образовании и опыте работы',
                      style: AppTextStyles.body2.copyWith(fontSize: 15),
                    ),

                    const SizedBox(height: 32),

                    // Специализация
                    Text(
                      'Специализация',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _specializationController,
                      hintText: 'Например: Клиническая психология',
                      prefixIcon: Icons.school_outlined,
                      onChanged: (value) => setState(() {}),
                    ),

                    const SizedBox(height: 24),

                    // Опыт работы
                    Text(
                      'Опыт работы (в годах)',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _experienceController,
                      hintText: '0',
                      prefixIcon: Icons.work_outline,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      onChanged: (value) => setState(() {}),
                    ),
                    if (_experienceController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          _getExperienceText(
                            int.tryParse(_experienceController.text) ?? 0,
                          ),
                          style: AppTextStyles.body3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Образование
                    Text(
                      'Образование',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Укажите ваше профильное образование (минимум 20 символов)',
                      style: AppTextStyles.body3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _educationController,
                      maxLines: 4,
                      maxLength: 500,
                      style: AppTextStyles.input,
                      decoration: InputDecoration(
                        hintText:
                            'Например: МГУ им. М.В. Ломоносова, факультет психологии, специальность "Клиническая психология", 2015-2020',
                        hintStyle: AppTextStyles.inputHint,
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        counterStyle: AppTextStyles.body3,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),

                    const SizedBox(height: 24),

                    // О себе
                    Text(
                      'О себе',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Расскажите о себе, своем подходе к работе и опыте (минимум 100 символов)',
                      style: AppTextStyles.body3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bioController,
                      maxLines: 6,
                      maxLength: 1000,
                      style: AppTextStyles.input,
                      decoration: InputDecoration(
                        hintText:
                            'Опишите ваш опыт работы, подходы к терапии, с какими проблемами работаете...',
                        hintStyle: AppTextStyles.inputHint,
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        counterStyle: AppTextStyles.body3,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),

                    const SizedBox(height: 24),

                    // Подходы в работе
                    Text(
                      'Подходы в работе',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Выберите один или несколько подходов',
                      style: AppTextStyles.body3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                        _approaches.length,
                        (index) => _buildApproachChip(index),
                      ),
                    ),

                    if (_selectedApproaches.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
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
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${_selectedApproaches.length}',
                                  style: AppTextStyles.body3.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _getApproachCountText(),
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 18,
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
                onPressed: _canContinue ? _continue : null,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApproachChip(int index) {
    final approach = _approaches[index];
    final isSelected = _selectedApproaches.contains(index);

    return GestureDetector(
      onTap: () => _toggleApproach(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? approach['color'].withOpacity(0.15)
              : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? approach['color'].withOpacity(0.5)
                : AppColors.inputBorder,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: approach['color'].withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              approach['icon'],
              size: 20,
              color: isSelected ? approach['color'] : AppColors.textSecondary,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                approach['text'],
                style: AppTextStyles.body2.copyWith(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? approach['color'] : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 5),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: approach['color'],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 11, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getExperienceText(int years) {
    if (years == 0) return 'Только начинаю практику';
    if (years == 1) return '1 год опыта';
    if (years >= 2 && years <= 4) return '$years года опыта';
    return '$years лет опыта';
  }

  String _getApproachCountText() {
    final count = _selectedApproaches.length;
    if (count == 1) return 'Выбран 1 подход';
    if (count >= 2 && count <= 4) return 'Выбрано $count подхода';
    return 'Выбрано $count подходов';
  }
}
