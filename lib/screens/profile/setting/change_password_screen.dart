import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/back_button.dart';
import '../../../../services/auth_service.dart';
import 'package:dio/dio.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _changePassword() async {
    // Валидация
    if (_currentPasswordController.text.isEmpty) {
      _showError('Введите текущий пароль');
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      _showError('Введите новый пароль');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showError('Новый пароль должен содержать минимум 6 символов');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Пароли не совпадают');
      return;
    }

    if (_currentPasswordController.text == _newPasswordController.text) {
      _showError('Новый пароль должен отличаться от текущего');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Не найден токен авторизации');
      }

      final dio = Dio();
      final response = await dio.post(
        'http://localhost:8080/api/users/me/change-password',
        data: {
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
          'confirmPassword': _confirmPasswordController.text,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Change password response: ${response.statusCode}');
      print('📋 Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Пароль успешно изменён'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(
          response.data['message'] ?? 'Не удалось изменить пароль',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.data}');
      String errorMessage = 'Не удалось изменить пароль';

      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Превышено время ожидания';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Ошибка подключения к серверу';
      }

      _showError(errorMessage);
    } catch (e) {
      print('❌ Error changing password: $e');
      _showError('Произошла ошибка: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Шапка
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CustomBackButton(),
                  const SizedBox(width: 16),
                  Text(
                    'Изменить пароль',
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),

            // Контент
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Информационный блок
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Пароль должен содержать минимум 6 символов',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Текущий пароль
                    Text(
                      'Текущий пароль',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      hint: 'Введите текущий пароль',
                      isVisible: _isCurrentPasswordVisible,
                      onVisibilityToggle: () {
                        setState(
                          () => _isCurrentPasswordVisible =
                              !_isCurrentPasswordVisible,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Новый пароль
                    Text(
                      'Новый пароль',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      hint: 'Введите новый пароль',
                      isVisible: _isNewPasswordVisible,
                      onVisibilityToggle: () {
                        setState(
                          () => _isNewPasswordVisible = !_isNewPasswordVisible,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Подтверждение пароля
                    Text(
                      'Подтвердите пароль',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hint: 'Повторите новый пароль',
                      isVisible: _isConfirmPasswordVisible,
                      onVisibilityToggle: () {
                        setState(
                          () => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible,
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Требования к паролю
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Требования к паролю:',
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRequirement('Минимум 6 символов'),
                          _buildRequirement(
                            'Новый пароль должен отличаться от текущего',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Кнопка
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: _isLoading ? 'Изменение...' : 'Изменить пароль',
                onPressed: _isLoading ? null : _changePassword,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: AppTextStyles.body1,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textTertiary),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: onVisibilityToggle,
        ),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body3.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
