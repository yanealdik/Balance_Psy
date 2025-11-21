import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/psychologist/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/step_indicator.dart';
import '../../../widgets/back_button.dart';
import '../../../providers/psychologist_registration_provider.dart';
import '../../../services/registration_service.dart'; // ✅ Добавлено
import '../../../core/utils/error_handler.dart'; // ✅ Добавлено
import 'psy_register_step3.dart';

class PsyRegisterStep2 extends StatefulWidget {
  const PsyRegisterStep2({super.key});

  @override
  State<PsyRegisterStep2> createState() => _PsyRegisterStep2State();
}

class _PsyRegisterStep2State extends State<PsyRegisterStep2> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final RegistrationService _registrationService =
      RegistrationService(); // ✅ Инициализация

  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _codeSent = false;
  bool _isVerifying = false;
  bool _isSendingCode = false;

  Timer? _resendTimer;
  int _resendCountdown = 0;

  String? _errorMessage; // ✅ Добавлено для ошибок

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
      if (provider.emailVerified) {
        setState(() {
          _codeSent = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isPasswordStrong(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  bool get _canSendCode {
    return _isValidEmail(_emailController.text) &&
        _passwordController.text.length >= 8 &&
        _passwordController.text == _confirmPasswordController.text &&
        !_isSendingCode &&
        _resendCountdown == 0;
  }

  bool get _canVerify {
    return _codeControllers.every((c) => c.text.length == 1);
  }

  void _startResendTimer() {
    setState(() => _resendCountdown = 60);

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  // ✅ ИСПРАВЛЕНО: Реальная отправка кода через RegistrationService
  Future<void> _sendVerificationCode() async {
    if (!_canSendCode) return;

    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
    });

    try {
      print('📤 Sending verification code to: ${_emailController.text.trim()}');

      await _registrationService.sendVerificationCode(
        _emailController.text.trim(),
        isParentEmail: false, // ✅ Психолог — не родительский email
      );

      setState(() {
        _codeSent = true;
        _isSendingCode = false;
      });

      _startResendTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Код отправлен на ${_emailController.text}',
              style: AppTextStyles.body2.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      _codeFocusNodes[0].requestFocus();
    } catch (e) {
      print('❌ Send code error: $e');
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
        _isSendingCode = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _errorMessage!,
              style: AppTextStyles.body2.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // ✅ ИСПРАВЛЕНО: Реальная проверка кода через RegistrationService
  Future<void> _verifyCode() async {
    if (!_canVerify) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final code = _codeControllers.map((c) => c.text).join();

    try {
      print('📤 Verifying code: $code for ${_emailController.text.trim()}');

      final verified = await _registrationService.verifyCode(
        _emailController.text.trim(),
        code,
        isParentEmail: false,
      );

      if (verified) {
        final provider = Provider.of<PsychologistRegistrationProvider>(
          context,
          listen: false,
        );

        provider.setEmail(_emailController.text.trim());
        provider.setPassword(_passwordController.text);
        provider.setVerificationCode(code);
        provider.setEmailVerified(true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Email успешно подтвержден!',
                style: AppTextStyles.body2.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PsyRegisterStep3()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Неверный код подтверждения';
        });
      }
    } catch (e) {
      print('❌ Verify code error: $e');
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
      });
    } finally {
      setState(() => _isVerifying = false);
    }
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
                  const StepIndicator(currentStep: 2, totalSteps: 5),
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
                      'Создание аккаунта',
                      style: AppTextStyles.h1.copyWith(fontSize: 28),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Укажите email и придумайте надежный пароль',
                      style: AppTextStyles.body2.copyWith(fontSize: 15),
                    ),

                    const SizedBox(height: 32),

                    // ✅ Показ ошибок
                    if (_errorMessage != null) ...[
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
                      const SizedBox(height: 16),
                    ],

                    if (!_codeSent) ...[
                      // Email
                      Text(
                        'Email',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'example@mail.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_codeSent,
                        onChanged: (value) => setState(() {}),
                      ),
                      if (_emailController.text.isNotEmpty &&
                          !_isValidEmail(_emailController.text))
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            'Введите корректный email',
                            style: AppTextStyles.body3.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Пароль
                      Text(
                        'Пароль',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Минимум 8 символов',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        enabled: !_codeSent,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                        onChanged: (value) => setState(() {}),
                      ),

                      // Индикатор сложности пароля
                      if (_passwordController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPasswordRequirement(
                                'Минимум 8 символов',
                                _passwordController.text.length >= 8,
                              ),
                              _buildPasswordRequirement(
                                'Заглавная буква',
                                RegExp(
                                  r'[A-Z]',
                                ).hasMatch(_passwordController.text),
                              ),
                              _buildPasswordRequirement(
                                'Строчная буква',
                                RegExp(
                                  r'[a-z]',
                                ).hasMatch(_passwordController.text),
                              ),
                              _buildPasswordRequirement(
                                'Цифра',
                                RegExp(
                                  r'[0-9]',
                                ).hasMatch(_passwordController.text),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Подтверждение пароля
                      Text(
                        'Подтвердите пароль',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Повторите пароль',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        enabled: !_codeSent,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            );
                          },
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      if (_confirmPasswordController.text.isNotEmpty &&
                          _passwordController.text !=
                              _confirmPasswordController.text)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            'Пароли не совпадают',
                            style: AppTextStyles.body3.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ] else ...[
                      // Экран ввода кода
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mark_email_unread_outlined,
                                size: 60,
                                color: AppColors.primary,
                              ),
                            ),

                            const SizedBox(height: 24),

                            Text('Проверьте email', style: AppTextStyles.h2),

                            const SizedBox(height: 12),

                            Text(
                              'Мы отправили код подтверждения на',
                              style: AppTextStyles.body2,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _emailController.text,
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 32),

                            // Поля для ввода кода
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(6, (index) {
                                return Container(
                                  width: 50,
                                  height: 60,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: TextField(
                                    controller: _codeControllers[index],
                                    focusNode: _codeFocusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    style: AppTextStyles.h2,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: AppColors.inputBackground,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.inputBorder,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.inputBorder,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.isNotEmpty && index < 5) {
                                        _codeFocusNodes[index + 1]
                                            .requestFocus();
                                      }
                                      if (value.isEmpty && index > 0) {
                                        _codeFocusNodes[index - 1]
                                            .requestFocus();
                                      }
                                      setState(() {});
                                    },
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 24),

                            // Кнопка "Отправить повторно"
                            if (_resendCountdown == 0)
                              TextButton(
                                onPressed: _sendVerificationCode,
                                child: Text(
                                  'Отправить код повторно',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              Text(
                                'Отправить повторно через $_resendCountdown сек',
                                style: AppTextStyles.body3.copyWith(
                                  color: AppColors.textTertiary,
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: _codeSent ? 'Подтвердить' : 'Отправить код',
                showArrow: true,
                onPressed: _codeSent
                    ? (_canVerify && !_isVerifying ? _verifyCode : null)
                    : (_canSendCode ? _sendVerificationCode : null),
                isFullWidth: true,
                isLoading: _isSendingCode || _isVerifying,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.body3.copyWith(
              color: isMet ? AppColors.success : AppColors.textSecondary,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
