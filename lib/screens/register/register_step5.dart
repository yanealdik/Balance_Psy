import 'package:balance_psy/screens/register/DiagnosticAfterReg/DiagnosticScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/utils/error_handler.dart';
import '../../providers/registration_provider.dart';
import '../../services/registration_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/back_button.dart';
import '../success/success_screen.dart';

/// Экран онбординга Шаг 5 - Email и Пароль
class OnboardingStep5Screen extends StatefulWidget {
  const OnboardingStep5Screen({super.key});

  @override
  State<OnboardingStep5Screen> createState() => _OnboardingStep5ScreenState();
}

class _OnboardingStep5ScreenState extends State<OnboardingStep5Screen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isEmailValid = false;
  bool _isCodeSent = false;
  bool _isCodeVerified = false;
  String? _emailError;
  String? _codeError;
  String? _passwordError;
  int _countdown = 60;
  Timer? _timer;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _checkEmail() {
    final email = _emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        _emailError = 'Введите email';
        _isEmailValid = false;
      } else if (!_validateEmail(email)) {
        _emailError = 'Неверный формат email';
        _isEmailValid = false;
      } else {
        _emailError = null;
        _isEmailValid = true;
      }
    });
  }

  void _sendCode() {
    if (!_isEmailValid) {
      _checkEmail();
      return;
    }

    // Имитация отправки кода (без backend)
    setState(() {
      _isCodeSent = true;
      _countdown = 60;
    });

    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Код: 123456 (для теста)',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 5), // Показываем дольше
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _verifyCode() {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _codeError = 'Введите код';
      });
      return;
    }

    if (code.length != 6) {
      setState(() {
        _codeError = 'Код должен содержать 6 цифр';
      });
      return;
    }

    // Для теста принимаем код "123456"
    if (code != '123456') {
      setState(() {
        _codeError = 'Неверный код. Используйте: 123456';
      });
      return;
    }

    setState(() {
      _isCodeVerified = true;
      _codeError = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.verified, color: Colors.white),
            SizedBox(width: 12),
            Text('Email подтвержден!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _validatePasswords() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _passwordError = 'Заполните оба поля пароля';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _passwordError = 'Пароль должен быть не менее 6 символов';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _passwordError = 'Пароли не совпадают';
      });
      return;
    }

    setState(() {
      _passwordError = null;
    });
  }

  bool get _canComplete {
    return _isCodeVerified &&
        _passwordController.text.length >= 6 &&
        _passwordController.text == _confirmPasswordController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя часть с кнопкой назад и индикатором
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                  StepIndicator(currentStep: 5, totalSteps: 5),
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
                      'Последний шаг!',
                      style: AppTextStyles.h2.copyWith(fontSize: 26),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Создайте аккаунт для сохранения прогресса',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // СЕКЦИЯ 1: EMAIL
                    _buildSectionHeader('1', 'Email', _isCodeVerified),

                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'example@mail.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isCodeVerified,
                      maxLength: 100,
                      showSuccess: _isCodeVerified,
                      onChanged: (value) {
                        if (_emailError != null) {
                          setState(() {
                            _emailError = null;
                          });
                        }
                      },
                    ),

                    if (_emailError != null) ...[
                      const SizedBox(height: 8),
                      _buildErrorMessage(_emailError!),
                    ],

                    if (!_isCodeVerified) ...[
                      const SizedBox(height: 12),
                      CustomButton(
                        text: _isCodeSent
                            ? 'Отправить код повторно ${_countdown > 0 ? "($_countdown)" : ""}'
                            : 'Отправить код',
                        isPrimary: true,
                        onPressed: _countdown == 0 || !_isCodeSent
                            ? _sendCode
                            : null,
                        isFullWidth: true,
                      ),
                    ],

                    if (_isCodeSent && !_isCodeVerified) ...[
                      const SizedBox(height: 24),

                      // СЕКЦИЯ 2: КОД ПОДТВЕРЖДЕНИЯ
                      _buildSectionHeader('2', 'Код подтверждения', false),

                      const SizedBox(height: 8),

                      Text(
                        'Введите 6-значный код из письма',
                        style: AppTextStyles.body3.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _codeController,
                        hintText: '000000',
                        prefixIcon: Icons.vpn_key,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        enabled: true,
                        onChanged: (value) {
                          if (_codeError != null) {
                            setState(() {
                              _codeError = null;
                            });
                          }
                          // Автоматическая проверка при вводе 6 цифр
                          if (value.length == 6) {
                            _verifyCode();
                          }
                        },
                      ),

                      if (_codeError != null) ...[
                        const SizedBox(height: 8),
                        _buildErrorMessage(_codeError!),
                      ],

                      const SizedBox(height: 12),

                      CustomButton(
                        text: 'Подтвердить',
                        isPrimary: true,
                        onPressed: _verifyCode,
                        isFullWidth: true,
                      ),
                    ],

                    if (_isCodeVerified) ...[
                      const SizedBox(height: 24),

                      // СЕКЦИЯ 3: ПАРОЛЬ
                      _buildSectionHeader('2', 'Пароль', false),

                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Минимум 6 символов',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        showEyeIcon: true,
                        enabled: true,
                        maxLength: 50,
                        onChanged: (value) {
                          if (_passwordError != null) {
                            setState(() {
                              _passwordError = null;
                            });
                          }
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Подтвердите пароль',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Повторите пароль',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        showEyeIcon: true,
                        enabled: true,
                        maxLength: 50,
                        onChanged: (value) {
                          if (_passwordError != null) {
                            setState(() {
                              _passwordError = null;
                            });
                          }
                          setState(() {});
                        },
                      ),

                      if (_passwordError != null) ...[
                        const SizedBox(height: 12),
                        _buildErrorMessage(_passwordError!),
                      ],

                      // Требования к паролю
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPasswordRequirement(
                              'Минимум 6 символов',
                              _passwordController.text.length >= 6,
                            ),
                            const SizedBox(height: 6),
                            _buildPasswordRequirement(
                              'Пароли совпадают',
                              _passwordController.text.isNotEmpty &&
                                  _passwordController.text ==
                                      _confirmPasswordController.text,
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

            // Кнопка "Завершить регистрацию"
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Завершить регистрацию',
                showArrow: true,
                onPressed: _canComplete
                    ? () async {
                        _validatePasswords();
                        if (_passwordError == null) {
                          final regProvider = Provider.of<RegistrationProvider>(
                            context,
                            listen: false,
                          );

                          // Собираем данные для регистрации
                          final registrationData = regProvider
                              .getRegistrationData();

                          try {
                            // Отправляем данные на бэкенд
                            final registrationService = RegistrationService();
                            await registrationService.register(
                              registrationData,
                            );

                            // Переходим на диагностику
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const InitialDiagnosticScreen(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ErrorHandler.getErrorMessage(e)),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    : null,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String number, String title, bool isCompleted) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    number,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: isCompleted ? Colors.green : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body3.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? Colors.green : AppColors.textTertiary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.body3.copyWith(
            color: isMet ? Colors.green : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
