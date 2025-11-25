import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/session_format.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _issueController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  SessionFormat _selectedFormat = SessionFormat.video;
  bool _isLoading = false;
  bool _clientExists = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _issueController.dispose();
    _notesController.dispose();
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
        title: Text(
          'Создать запись',
          style: AppTextStyles.h2.copyWith(fontSize: 22),
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
                        'Укажите телефон клиента. Если он зарегистрирован, его данные загрузятся автоматически.',
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

              // Поле: Телефон клиента
              Text(
                'Телефон клиента *',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+7 (___) ___-__-__',
                  hintStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                  suffixIcon: _clientExists
                      ? Icon(Icons.check_circle, color: AppColors.success)
                      : null,
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
                onChanged: (value) {
                  // TODO: В будущем можно добавить проверку существования клиента
                  // через API endpoint /api/users/check-phone
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите телефон клиента';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Поле: Имя клиента (если не найден)
              if (!_clientExists) ...[
                Text(
                  'Имя клиента *',
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Укажите имя, если клиент ещё не зарегистрирован',
                  style: AppTextStyles.body3.copyWith(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Например: Иван Иванов',
                    hintStyle: AppTextStyles.body2.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: Icon(Icons.person, color: AppColors.primary),
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
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                  ),
                  validator: (value) {
                    if (!_clientExists &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Введите имя клиента';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Формат сессии
              Text(
                'Формат сессии *',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFormatButton(
                    format: SessionFormat.video,
                    icon: Icons.videocam,
                    label: 'Видео',
                    color: const Color(0xFF00BCD4),
                  ),
                  const SizedBox(width: 12),
                  _buildFormatButton(
                    format: SessionFormat.chat,
                    icon: Icons.chat_bubble,
                    label: 'Чат',
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 12),
                  _buildFormatButton(
                    format: SessionFormat.audio,
                    icon: Icons.phone,
                    label: 'Аудио',
                    color: const Color(0xFFFF9800),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Дата
              Text(
                'Дата сессии *',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Выберите дату'
                            : DateFormat(
                                'd MMMM yyyy',
                                'ru',
                              ).format(_selectedDate!),
                        style: AppTextStyles.body1.copyWith(
                          fontSize: 15,
                          color: _selectedDate == null
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Время
              Text(
                'Время сессии *',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime == null
                            ? 'Выберите время'
                            : _selectedTime!.format(context),
                        style: AppTextStyles.body1.copyWith(
                          fontSize: 15,
                          color: _selectedTime == null
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Описание проблемы
              Text(
                'Описание проблемы *',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _issueController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Опишите проблему или тему сессии...',
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
                    return 'Введите описание проблемы';
                  }
                  if (value.trim().length < 10) {
                    return 'Описание должно содержать минимум 10 символов';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Заметки (необязательно)
              Text('Заметки', style: AppTextStyles.h3.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                'Необязательное поле для дополнительной информации',
                style: AppTextStyles.body3.copyWith(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Дополнительная информация...',
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

              // Кнопка создания
              CustomButton(
                text: 'Создать запись',
                onPressed: _isLoading ? null : _handleCreateAppointment,
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

  Widget _buildFormatButton({
    required SessionFormat format,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedFormat == format;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFormat = format),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.15)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.inputBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  fontSize: 12,
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ru'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _handleCreateAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      _showError('Выберите дату сессии');
      return;
    }

    if (_selectedTime == null) {
      _showError('Выберите время сессии');
      return;
    }

    setState(() => _isLoading = true);

    // Объединяем дату и время
    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final endDateTime = scheduledDateTime.add(const Duration(hours: 1));
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final psychologistId = authProvider.user?.userId;

    if (psychologistId == null) {
      setState(() => _isLoading = false);
      _showError('Не удалось определить профиль психолога');
      return;
    }

    final provider = Provider.of<AppointmentProvider>(context, listen: false);

    // TODO: Здесь нужно сначала проверить существование клиента по телефону
    // и получить его clientId. Если клиента нет, можно либо:
    // 1. Создать нового пользователя через отдельный endpoint
    // 2. Или отправить запрос с телефоном, и backend сам создаст пользователя

    final success = await provider.createAppointment(
      psychologistId: psychologistId,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      startTime: DateFormat('HH:mm').format(scheduledDateTime),
      endTime: DateFormat('HH:mm').format(endDateTime),
      format: _selectedFormat,
      issueDescription: _issueController.text.trim(),
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
                'Запись создана!',
                style: AppTextStyles.h2.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 12),
              Text(
                'Запись отправлена клиенту на подтверждение',
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
                  Navigator.pop(context); // Закрываем AppointmentScreen
                },
                isFullWidth: true,
              ),
            ],
          ),
        ),
      );
    } else {
      _showError(provider.errorMessage ?? 'Не удалось создать запись');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
