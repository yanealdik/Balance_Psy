import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../intro/intro_screen.dart';
import '../welcome/welcome_screen.dart';
import '../login/login_screen.dart';

/// Стартовый экран с выбором действия - Новый скриншот
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Верхняя часть с логотипом (занимает оставшееся пространство)
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Логотип
                          _buildLogo(),
                          const SizedBox(height: 24),
                          // Название приложения
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Balance',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Psy',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Средняя часть с текстом
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 40,
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 18, height: 1.5),
                        children: [
                          TextSpan(
                            text: 'Твоя ',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: 'поддержка',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '. Твой ',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: 'баланс',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '.',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Нижняя часть с кнопками (прижата к низу)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary.withOpacity(0.1), AppColors.primary],
                stops: const [0.0, 0.7],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(60),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),

                  // Кнопка "Начать сейчас"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: CustomButton(
                      text: 'Начать сейчас',
                      isPrimary: false, // Белая кнопка
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IntroScreen(),
                          ),
                        );
                      }, isFullWidth: true,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Текст "Уже есть аккаунт? Войти"
                  GestureDetector(
                    onTap: () {
                      // Переход на экран входа
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Уже есть аккаунт? ',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: 'Войти',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Создаем логотип (упрощенная версия)
  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primaryLight.withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Иконка головы (профиль) - слева
          const Positioned(
            left: 25,
            child: Icon(Icons.face, size: 50, color: AppColors.textWhite),
          ),
          // Иконка весов - справа
          Positioned(
            right: 20,
            child: Icon(
              Icons.balance,
              size: 45,
              color: AppColors.textWhite.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
