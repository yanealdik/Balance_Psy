import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/back_button.dart';
import '../../providers/registration_provider.dart';
import '../../services/registration_service.dart';
import '../../core/utils/error_handler.dart';
import 'register_step5.dart';

/// Экран родительского согласия для пользователей младше 18 лет
class ParentalConsentScreen extends StatefulWidget {
  final int age;

  const ParentalConsentScreen({super.key, required this.age});

  @override
  State<ParentalConsentScreen> createState() => _ParentalConsentScreenState();
}

class _ParentalConsentScreenState extends State<ParentalConsentScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final RegistrationService _registrationService = RegistrationService();

  bool _isAgreed = false;
  bool _isLoading = false;
  bool _isCodeSent = false;
  bool _isVerified = false;
  String? _errorMessage;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final regProvider = Provider.of<RegistrationProvider>(
        context,
        listen: false,
      );
      if (regProvider.parentEmail != null) {
        _emailController.text = regProvider.parentEmail!;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _sendCode() async {
    setState(() {
      _errorMessage = null;
    });

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Введите email родителя';
      });
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      setState(() {
        _errorMessage = 'Неверный формат email';
      });
      return;
    }

    if (!_isAgreed) {
      setState(() {
        _errorMessage = 'Необходимо подтверждение согласия';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _registrationService.sendVerificationCode(
        _emailController.text.trim(),
        isParentEmail: true,
      );

      // Сохраняем email родителя
      final regProvider = Provider.of<RegistrationProvider>(
        context,
        listen: false,
      );
      regProvider.setParentEmail(_emailController.text.trim());

      setState(() {
        _isCodeSent = true;
        _countdown = 60;
      });

      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.email, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Код отправлен на ${_emailController.text}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  Future<void> _verifyCode() async {
    setState(() {
      _errorMessage = null;
    });

    if (_codeController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Введите код подтверждения';
      });
      return;
    }

    if (_codeController.text.trim().length != 6) {
      setState(() {
        _errorMessage = 'Код должен содержать 6 цифр';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final verified = await _registrationService.verifyCode(
        _emailController.text.trim(),
        _codeController.text.trim(),
        isParentEmail: true,
      );

      if (verified) {
        // Сохраняем статус верификации
        final regProvider = Provider.of<RegistrationProvider>(
          context,
          listen: false,
        );
        regProvider.setParentEmailVerified(true);

        setState(() {
          _isVerified = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.verified, color: Colors.white),
                SizedBox(width: 12),
                Text('Согласие родителя подтверждено!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Переход на следующий шаг через 1.5 секунды
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OnboardingStep5Screen(),
              ),
            );
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Неверный код подтверждения';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
      });
    } finally {
      setState(() => _isLoading = false);
    }
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
              child: Row(children: [CustomBackButton()]),
            ),

            // Контент
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Иконка
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

                    // Заголовок
                    Text(
                      'Требуется согласие родителя',
                      style: AppTextStyles.h2.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Вам ${widget.age} лет. Для продолжения регистрации необходимо разрешение родителя или опекуна.',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Инструкция
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
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStep('1', 'Введи email родителя'),
                          const SizedBox(height: 12),
                          _buildStep('2', 'Мы отправим код подтверждения'),
                          const SizedBox(height: 12),
                          _buildStep('3', 'Родитель вводит код для согласия'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ФОРМА
                    if (!_isVerified) ...[
                      // Email родителя
                      Text(
                        'Email родителя или опекуна',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'parent@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isCodeSent && !_isLoading,
                        maxLength: 100,
                        onChanged: (value) {
                          if (_errorMessage != null) {
                            setState(() => _errorMessage = null);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // Чекбокс согласия
                      GestureDetector(
                        onTap: _isLoading || _isCodeSent
                            ? null
                            : () {
                                setState(() {
                                  _isAgreed = !_isAgreed;
                                  if (_isAgreed && _errorMessage != null) {
                                    _errorMessage = null;
                                  }
                                });
                              },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isAgreed
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.inputBackground,
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
                                child: Text(
                                  'Я подтверждаю, что у меня есть разрешение родителя на предоставление этого email',
                                  style: AppTextStyles.body2.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _isAgreed
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Кнопка отправки кода
                      if (!_isCodeSent)
                        CustomButton(
                          text: 'Отправить код',
                          onPressed: _isLoading ? null : _sendCode,
                          isFullWidth: true,
                        ),

                      // Поле ввода кода
                      if (_isCodeSent) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Код подтверждения',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Родитель должен ввести код из письма',
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
                          enabled: !_isLoading,
                          onChanged: (value) {
                            if (_errorMessage != null) {
                              setState(() => _errorMessage = null);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Подтвердить',
                          onPressed: _isLoading ? null : _verifyCode,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: _countdown > 0
                              ? 'Отправить повторно ($_countdown)'
                              : 'Отправить код повторно',
                          isPrimary: false,
                          onPressed: _countdown == 0 && !_isLoading
                              ? _sendCode
                              : null,
                          isFullWidth: true,
                        ),
                      ],
                    ],

                    // Успешная верификация
                    if (_isVerified)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Согласие получено!',
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.green,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Родитель подтвердил согласие. Продолжаем регистрацию!',
                              style: AppTextStyles.body2,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    // Сообщение об ошибке
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
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

            // Индикатор загрузки
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: AppTextStyles.body2.copyWith(fontSize: 14)),
        ),
      ],
    );
  }
}
