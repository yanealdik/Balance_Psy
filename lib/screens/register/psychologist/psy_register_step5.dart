import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/psychologist/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/step_indicator.dart';
import '../../../widgets/back_button.dart';
import '../../../providers/psychologist_registration_provider.dart';
import '../../../services/auth_service.dart'; // ✅ Добавлено
import '../../../core/utils/error_handler.dart'; // ✅ Добавлено
import 'psy_register_success.dart';

class PsyRegisterStep5 extends StatefulWidget {
  const PsyRegisterStep5({super.key});

  @override
  State<PsyRegisterStep5> createState() => _PsyRegisterStep5State();
}

class _PsyRegisterStep5State extends State<PsyRegisterStep5> {
  final _priceController = TextEditingController();
  final AuthService _authService = AuthService(); // ✅ Инициализация
  bool _isSubmitting = false;
  String? _errorMessage; // ✅ Для отображения ошибок

  final List<int> _suggestedPrices = [2000, 3000, 4000, 5000, 6000, 8000];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PsychologistRegistrationProvider>(
        context,
        listen: false,
      );

      if (provider.sessionPrice != null) {
        _priceController.text = provider.sessionPrice!.toInt().toString();
      }
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _selectSuggestedPrice(int price) {
    setState(() {
      _priceController.text = price.toString();
    });
  }

  bool get _canSubmit {
    if (_priceController.text.isEmpty) return false;
    final price = double.tryParse(_priceController.text);
    return price != null && price >= 500 && price <= 50000;
  }

  // ✅ ИСПРАВЛЕНО: Реальная отправка на бэкенд
  Future<void> _submitApplication() async {
    if (!_canSubmit || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<PsychologistRegistrationProvider>(
        context,
        listen: false,
      );

      // Сохраняем цену
      provider.setSessionPrice(double.parse(_priceController.text));

      // Получаем все данные
      final registrationData = provider.getRegistrationData();

      print('📤 Submitting psychologist registration...');
      print('Email: ${registrationData['email']}');
      print('Name: ${registrationData['fullName']}');

      // ✅ Отправка через AuthService
      final user = await _authService.registerPsychologist(registrationData);

      print('✅ Psychologist registered successfully! User ID: ${user.userId}');

      // Обновляем статус
      provider.setApplicationStatus('pending');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PsychRegisterSuccess()),
        );
      }
    } catch (e) {
      print('❌ Registration failed: $e');

      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.body2.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
                  const StepIndicator(currentStep: 5, totalSteps: 5),
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
                      'Стоимость консультации',
                      style: AppTextStyles.h1.copyWith(fontSize: 26),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Укажите стоимость одной сессии продолжительностью 50 минут',
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

                    // Поле ввода цены
                    Text(
                      'Стоимость сессии (₸)',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _priceController,
                      hintText: '0',
                      prefixIcon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      onChanged: (value) => setState(() {}),
                    ),

                    if (_priceController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          _getPriceValidation(),
                          style: AppTextStyles.body3.copyWith(
                            color: _canSubmit
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Рекомендуемые цены
                    Text(
                      'Рекомендуемые цены',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Выберите один из вариантов или укажите свою цену',
                      style: AppTextStyles.body3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _suggestedPrices.map((price) {
                        final isSelected =
                            _priceController.text == price.toString();

                        return GestureDetector(
                          onTap: () => _selectSuggestedPrice(price),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.12)
                                  : AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.inputBorder,
                                width: isSelected ? 2 : 1.5,
                              ),
                            ),
                            child: Text(
                              '$price ₸',
                              style: AppTextStyles.body2.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Информация о ценах
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.lightbulb_outline,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Рекомендации по ценообразованию',
                                  style: AppTextStyles.body1.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildPricingTip(
                            'Средняя цена сессии на платформе: 4 000 - 6 000 ₸',
                          ),
                          _buildPricingTip(
                            'Учитывайте ваш опыт и специализацию',
                          ),
                          _buildPricingTip(
                            'Вы сможете изменить цену в любое время',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Что дальше?
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Что будет после отправки?',
                                  style: AppTextStyles.body1.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildNextStep(
                            '1',
                            'Администратор проверит ваши документы',
                          ),
                          _buildNextStep(
                            '2',
                            'Вы получите уведомление на email',
                          ),
                          _buildNextStep(
                            '3',
                            'После одобрения профиль станет активным',
                          ),
                        ],
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
                text: _isSubmitting ? 'Отправка...' : 'Отправить заявку',
                showArrow: false,
                onPressed: _canSubmit ? _submitApplication : null,
                isFullWidth: true,
                isLoading: _isSubmitting,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body3.copyWith(
                color: AppColors.primary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.body3.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body3.copyWith(
                color: AppColors.success,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPriceValidation() {
    if (_priceController.text.isEmpty) return '';

    final price = double.tryParse(_priceController.text);
    if (price == null) return 'Введите корректную цену';
    if (price < 500) return 'Минимальная цена: 500 ₸';
    if (price > 50000) return 'Максимальная цена: 50 000 ₸';

    return 'Отличный выбор! ✓';
  }
}
