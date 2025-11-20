import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart'; // Добавили
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/step_indicator.dart';
import '../../../widgets/back_button.dart';
import '../../../providers/registration_provider.dart'; // Добавили
import 'register_step4.dart';

class OnboardingStep3Screen extends StatefulWidget {
  const OnboardingStep3Screen({super.key});

  @override
  State<OnboardingStep3Screen> createState() => _OnboardingStep3ScreenState();
}

class _OnboardingStep3ScreenState extends State<OnboardingStep3Screen> {
  int? selectedGender;

  @override
  void initState() {
    super.initState();
    // Загружаем сохранённые данные
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final regProvider = Provider.of<RegistrationProvider>(
        context,
        listen: false,
      );
      if (regProvider.gender != null) {
        setState(() {
          selectedGender = regProvider.gender == 'male' ? 0 : 1;
        });
      }
    });
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
                  StepIndicator(currentStep: 3, totalSteps: 5),
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
                      'Кто ты?',
                      style: AppTextStyles.h2.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 40),
                    _buildGenderOption(
                      index: 0,
                      title: 'Мужчина',
                      icon: Icons.male,
                    ),
                    const SizedBox(height: 20),
                    _buildGenderOption(
                      index: 1,
                      title: 'Женщина',
                      icon: Icons.female,
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        // Пропустить выбор пола
                        final regProvider = Provider.of<RegistrationProvider>(
                          context,
                          listen: false,
                        );
                        regProvider.setGender(null);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingStep4Screen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Предпочитаю пропустить. Спасибо',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
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
