import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/report_provider.dart';
import '../../widgets/custom_button.dart';

class CreateReportScreen extends StatefulWidget {
  final int appointmentId;
  final String clientName;

  const CreateReportScreen({
    super.key,
    required this.appointmentId,
    required this.clientName,
  });

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _themeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _recommendationsController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _themeController.dispose();
    _descriptionController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Создание отчёта',
              style: AppTextStyles.h2.copyWith(fontSize: 20),
            ),
            Text(
              widget.clientName,
              style: AppTextStyles.body2.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Инфо карточка
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Заполните все поля для создания отчёта по завершённой сессии',
                        style: AppTextStyles.body2.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Поле: Тема сеанса
              Text(
                'Тема сеанса *',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _themeController,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Например: Работа с тревожностью',
                  hintStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  counterText: '',
                  prefixIcon: Icon(Icons.psychology, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите тему сеанса';
                  }
                  if (value.trim().length < 5) {
                    return 'Тема должна содержать минимум 5 символов';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Поле: Описание сеанса
              Text(
                'Описание сеанса *',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText:
                      'Опишите ход сеанса, обсуждаемые темы, реакции клиента...',
                  hintStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите описание сеанса';
                  }
                  if (value.trim().length < 20) {
                    return 'Описание должно содержать минимум 20 символов';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Поле: Рекомендации
              Text(
                'Рекомендации',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Необязательно, но желательно',
                style: AppTextStyles.body3.copyWith(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _recommendationsController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText:
                      'Рекомендации для клиента, домашние задания, литература...',
                  hintStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
              ),

              const SizedBox(height: 32),

              // Кнопка сохранения
              CustomButton(
                text: 'Сохранить отчёт',
                onPressed: _isLoading ? null : _handleSave,
                isFullWidth: true,
                isLoading: _isLoading,
                showArrow: true,
              ),

              const SizedBox(height: 16),

              // Кнопка отмены
              CustomButton(
                text: 'Отмена',
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                isFullWidth: true,
                backgroundColor: Colors.transparent,
                textColor: AppColors.textSecondary,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<ReportProvider>(context, listen: false);

    final success = await provider.createReport(
      appointmentId: widget.appointmentId,
      sessionTheme: _themeController.text.trim(),
      sessionDescription: _descriptionController.text.trim(),
      recommendations: _recommendationsController.text.trim().isEmpty
          ? null
          : _recommendationsController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Показываем успешное сообщение
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 56,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Отчёт создан!',
                style: AppTextStyles.h2.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 12),
              Text(
                'Отчёт успешно сохранён и доступен в разделе "Отчёты"',
                textAlign: TextAlign.center,
                style: AppTextStyles.body1.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Готово',
                onPressed: () {
                  Navigator.pop(context); // Закрываем диалог
                  Navigator.pop(context); // Закрываем CreateReportScreen
                },
                isFullWidth: true,
              ),
            ],
          ),
        ),
      );
    } else {
      // Показываем ошибку
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Не удалось создать отчёт'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
