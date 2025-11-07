import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/back_button.dart';
import '../register/agreement_screen.dart';

/// Экран приветствия - Скриншот 2
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя часть с кнопкой назад
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(children: [CustomBackButton()]),
            ),

            // Контент (скроллящаяся часть)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 0),

                    // Заголовок
                    Text(
                      'Добро пожаловать!',
                      style: AppTextStyles.h1.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 60),

                    // Иллюстрация медитации
                    Image.asset(
                      'assets/images/meditation.png',
                      width: 280,
                      height: 280,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 60),

                    // Текст описания
                    Text(
                      'Расскажи немного о себе, чтобы мы подобрали рекомендации под твои цели.',
                      style: AppTextStyles.body1.copyWith(
                        fontSize: 16,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Это займет не больше минуты.',
                      style: AppTextStyles.body3.copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Кнопка "Продолжить" (фиксированная внизу)
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Продолжить',
                showArrow: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgreementScreen(),
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
}
