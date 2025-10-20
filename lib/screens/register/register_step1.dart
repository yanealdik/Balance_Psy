import 'package:balance_psy/screens/success/success_screen.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/back_button.dart';
import '../register/register_step2.dart';

/// Экран онбординга Шаг 1 - Скриншот 3
class OnboardingStep1Screen extends StatefulWidget {
  const OnboardingStep1Screen({Key? key}) : super(key: key);

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen> {
  int? selectedGoal;

  final List<Map<String, dynamic>> goals = [
    {'icon': Icons.favorite, 'text': 'Найти внутренний баланс'},
    {'icon': Icons.psychology, 'text': 'Узнать себя лучше'},
    {'icon': Icons.emoji_emotions, 'text': 'Получить советы от психолога'},
    {'icon': Icons.flag, 'text': 'Другое'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя часть с кнопкой назад и индикатором
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

            // Контент
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Заголовок
                    Text(
                      'С какой целью ты хочешь использовать BalancePsy?',
                      style: AppTextStyles.h2.copyWith(fontSize: 26),
                      textAlign: TextAlign.left,
                    ),

                    const SizedBox(height: 20),

                    // Иллюстрация
                    Center(
                      child: Image.asset(
                        'assets/stepimages/step1.png',
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Варианты целей
                    ...List.generate(goals.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildGoalOption(index),
                      );
                    }),

                    const SizedBox(height: 10),
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
                onPressed: selectedGoal != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SuccessScreen(),
                          ),
                        );
                      }
                    : null, isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Вариант цели
  Widget _buildGoalOption(int index) {
    final goal = goals[index];
    final isSelected = selectedGoal == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 2.5 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 3,
                    offset: const Offset(0, 10),
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Icon(
              goal['icon'],
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                goal['text'],
                style: AppTextStyles.body1.copyWith(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
