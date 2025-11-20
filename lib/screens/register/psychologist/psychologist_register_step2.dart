import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/step_indicator.dart';
import '../../../widgets/back_button.dart';
import '../../../providers/psychologist_registration_provider.dart';
import '../../../services/registration_service.dart';
import '../../../core/utils/error_handler.dart';
import 'psychologist_register_step3.dart';

/// Шаг 2: Email и пароль с верификацией
class PsychologistRegisterStep2 extends StatefulWidget {
  const PsychologistRegisterStep2({super.key});

  @override
  State<PsychologistRegisterStep2> createState() =>
      _PsychologistRegisterStep2State();
}

class _PsychologistRegisterStep2State extends State<PsychologistRegisterStep2> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final RegistrationService _registrationService = RegistrationService();

  bool _isCodeSent = false;
  bool _isCodeVerified = false;
  String? _emailError;
  String? _codeError;
  String? _passwordError;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PsychologistRegistrationProvider>(
        context,
        listen: false,
      );
      if (provider.email != null) {
        _emailController.text = provider.email!;
      }
      if (provider.password != null) {
        _passwordController.text = provider.password!;
        _confirmPasswordController.text = provider.password!;
      }
    });
  }

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

  Future<void> _sendCode() async {
    if (!_validateEmail(_emailController.text.trim())) {
      setState(() => _emailError = 'Неверный формат email');
      return;
    }

    setState(() => _emailError = null);

    try {
      await _registrationService.sendVerificationCode(
        _emailController.text.trim(),
        isParentEmail: false,
      );

      setState(() {
        _isCodeSent = true;
        _countdown = 60;
      });

      _startCountdown();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.email, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Код отправлен на ${_emailController.text}'),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      setState(() => _emailError = ErrorHandler.getErrorMessage(e));
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
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() => _codeError = 'Введите код');
      return;
    }

    if (code.length != 6) {
      setState(() => _codeError = 'Код должен содержать 6 цифр');
      return;
    }

    try {
      final verified = await _registrationService.verifyCode(
        _emailController.text.trim(),
        code,
        isParentEmail: false,
      );

      if (verified) {
        setState(() {
          _isCodeVerified = true;
          _codeError = null;
        });

        if (!mounted) return;

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        setState(() => _codeError = 'Неверный код');
      }
    } catch (e) {
      setState(() => _codeError = ErrorHandler.getErrorMessage(e));
    }
  }

  void _validateAndProceed() {
    setState(() => _passwordError = null);

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (!_isCodeVerified) {
      setState(() => _emailError = 'Подтвердите email');
      return;
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _passwordError = 'Заполните оба поля пароля');
      return;
    }

    if (password.length < 6) {
      setState(() => _passwordError = 'Пароль должен быть не менее 6 символов');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _passwordError = 'Пароли не совпадают');
      return;
    }

    // Сохраняем данные
    final provider = Provider.of<PsychologistRegistrationProvider>(
      context,
      listen: false,
    );

    provider.setEmail(_emailController.text.trim());
    provider.setPassword(password);
    provider.setEmailVerified(true);

    // Переход к следующему шагу
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PsychologistRegisterStep3(),
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
                  StepIndicator(currentStep: 2, totalSteps: 4),
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
                      'Создание аккаунта',
                      style: AppTextStyles.h2.copyWith(fontSize: 26),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Укажите email и придумайте надежный пароль',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Email
                    Text(
                      'Email *',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                          setState(() => _emailError = null);
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
                            ? 'Отправить повторно ${_countdown > 0 ? "($_countdown)" : ""}'
                            : 'Отправить код',
                        onPressed: _countdown == 0 || !_isCodeSent
                            ? _sendCode
                            : null,
                        isFullWidth: true,
                      ),
                    ],

                    // Код верификации
                    if (_isCodeSent && !_isCodeVerified) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Код подтверждения',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _codeController,
                        hintText: '000000',
                        prefixIcon: Icons.vpn_key,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        enabled: true,
                        onChanged: (value) {
                          if (_codeError != null) {
                            setState(() => _codeError = null);
                          }
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
                        onPressed: _verifyCode,
                        isFullWidth: true,
                      ),
                    ],

                    // Пароли
                    if (_isCodeVerified) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Пароль *',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                            setState(() => _passwordError = null);
                          }
                        },
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'Подтвердите пароль *',
                        style: AppTextStyles.body1.copyWith(
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
                            setState(() => _passwordError = null);
                          }
                        },
                      ),

                      if (_passwordError != null) ...[
                        const SizedBox(height: 12),
                        _buildErrorMessage(_passwordError!),
                      ],
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
                onPressed: _isCodeVerified ? _validateAndProceed : null,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
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
}
