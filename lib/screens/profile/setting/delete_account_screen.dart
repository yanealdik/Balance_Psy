import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/back_button.dart';
import '../../../../services/auth_service.dart';
import '../../login/login_screen.dart';
import 'package:dio/dio.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isConfirmationChecked = false;

  Future<void> _deleteAccount() async {
    if (_passwordController.text.isEmpty) {
      _showError('Введите пароль для подтверждения');
      return;
    }

    if (!_isConfirmationChecked) {
      _showError('Подтвердите удаление аккаунта');
      return;
    }

    // Финальное подтверждение
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Не найден токен авторизации');
      }

      final dio = Dio();
      final response = await dio.delete(
        'http://localhost:8080/api/users/me',
        queryParameters: {'password': _passwordController.text},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Delete account response: ${response.statusCode}');
      print('📋 Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Очищаем токен
        await _authService.logout();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Аккаунт успешно удалён'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Переходим на экран логина
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } else {
        throw Exception(
          response.data['message'] ?? 'Не удалось удалить аккаунт',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.data}');
      String errorMessage = 'Не удалось удалить аккаунт';

      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Превышено время ожидания';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Ошибка подключения к серверу';
      }

      _showError(errorMessage);
    } catch (e) {
      print('❌ Error deleting account: $e');
      _showError('Произошла ошибка: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Удалить аккаунт?',
                    style: AppTextStyles.h3.copyWith(fontSize: 20),
                  ),
                ),
              ],
            ),
            content: Text(
              'Это действие нельзя отменить. Все ваши данные будут безвозвратно удалены.',
              style: AppTextStyles.body1.copyWith(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Отмена',
                  style: AppTextStyles.body1.copyWith(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Удалить',
                  style: AppTextStyles.body1.copyWith(
                    fontSize: 15,
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
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
                    'Удаление аккаунта',
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
                    // Предупреждение
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber,
                            color: Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Внимание!',
                                  style: AppTextStyles.h3.copyWith(
                                    color: Colors.red,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Удаление аккаунта - необратимое действие',
                                  style: AppTextStyles.body1.copyWith(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Что будет удалено
                    Text(
                      'Что будет удалено:',
                      style: AppTextStyles.h3.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    _buildDeletionItem('Вся личная информация'),
                    _buildDeletionItem('История настроения и прогресс'),
                    _buildDeletionItem('Записи к психологам'),
                    _buildDeletionItem('Сохранённые упражнения и медитации'),
                    _buildDeletionItem('Достижения и статистика'),

                    const SizedBox(height: 30),

                    // Подтверждение пароля
                    Text(
                      'Подтвердите пароль',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: AppTextStyles.body1,
                      decoration: InputDecoration(
                        hintText: 'Введите ваш пароль',
                        hintStyle: AppTextStyles.body2.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.red,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            );
                          },
                        ),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Чекбокс подтверждения
                    CheckboxListTile(
                      value: _isConfirmationChecked,
                      onChanged: (value) {
                        setState(() => _isConfirmationChecked = value ?? false);
                      },
                      activeColor: Colors.red,
                      title: Text(
                        'Я понимаю, что это действие нельзя отменить',
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 20),

                    // Альтернатива
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Не уверены?',
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Вместо удаления аккаунта вы можете:\n• Временно выйти из приложения\n• Обратиться в поддержку за помощью',
                            style: AppTextStyles.body2.copyWith(
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

            // Кнопка удаления
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CustomButton(
                    text: _isLoading ? 'Удаление...' : 'Удалить аккаунт',
                    onPressed: _isLoading ? null : _deleteAccount,
                    isFullWidth: true,
                    backgroundColor: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Отмена',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.close, size: 20, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
