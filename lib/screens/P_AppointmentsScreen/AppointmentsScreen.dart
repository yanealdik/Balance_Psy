import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../providers/appointment_provider.dart';
import '../../services/user_service.dart';
import '../../models/session_format.dart';

/// Экран создания записи психологом для клиента
class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  // Контроллеры полей
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _issueController = TextEditingController();
  final _priceController = TextEditingController();

  // Данные найденного клиента
  int? _foundClientId;
  String? _foundClientName;
  bool _isSearching = false;
  bool _clientNotFound = false;

  // Данные записи
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  SessionFormat _selectedFormat = SessionFormat.video;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _issueController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Поиск клиента по номеру телефона
  Future<void> _searchClient() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите номер телефона'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _clientNotFound = false;
      _foundClientId = null;
      _foundClientName = null;
    });

    try {
      final client = await _userService.searchClientByPhone(
        _phoneController.text,
      );

      setState(() {
        _isSearching = false;

        if (client != null) {
          // Клиент найден
          _foundClientId = client.id;
          _foundClientName = client.fullName;
          _nameController.text = client.fullName;
          _clientNotFound = false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Клиент найден: ${client.fullName}'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          // Клиент не найден
          _clientNotFound = true;
          _nameController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Клиент не найден. Введите имя для новой записи.'),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Выбор даты
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Выбор времени начала
  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
        // Автоматически устанавливаем время окончания (+1 час)
        final endHour = (picked.hour + 1) % 24;
        _endTime = TimeOfDay(hour: endHour, minute: picked.minute);
      });
    }
  }

  /// Выбор времени окончания
  Future<void> _selectEndTime() async {
    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала выберите время начала'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          _endTime ??
          TimeOfDay(
            hour: (_startTime!.hour + 1) % 24,
            minute: _startTime!.minute,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  /// Создание записи
  Future<void> _createAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Проверяем, что все обязательные поля заполнены
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите дату сессии'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите время сессии'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Формируем данные для создания записи
    final appointmentData = <String, dynamic>{
      'appointmentDate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'startTime':
          '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
      'endTime':
          '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
      'format': _selectedFormat.toString().split('.').last,
      'issueDescription': _issueController.text.trim(),
    };

    // Добавляем данные клиента
    if (_foundClientId != null) {
      // Существующий клиент
      appointmentData['clientId'] = _foundClientId;
    } else {
      // Новый клиент
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Введите имя клиента'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      appointmentData['clientPhone'] = _phoneController.text.trim();
      appointmentData['clientName'] = _nameController.text.trim();
    }

    // Добавляем цену если указана
    if (_priceController.text.trim().isNotEmpty) {
      appointmentData['price'] = double.tryParse(_priceController.text.trim());
    }

    // Показываем загрузку
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final provider = Provider.of<AppointmentProvider>(context, listen: false);
      final success = await provider.createAppointment(appointmentData);

      if (!mounted) return;

      // Закрываем диалог загрузки
      Navigator.pop(context);

      if (success) {
        // Показываем успешное сообщение
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Запись успешно создана'),
            backgroundColor: AppColors.success,
          ),
        );

        // Возвращаемся назад
        Navigator.pop(context, true);
      } else {
        // Показываем ошибку
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Не удалось создать запись'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Закрываем диалог загрузки
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Новая запись',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // === БЛОК: Поиск клиента ===
            _buildSectionTitle('Клиент'),
            const SizedBox(height: 16),

            // Поле номера телефона с кнопкой поиска
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Номер телефона',
                      hintText: '+7 (___) ___-__-__',
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[\d\s\+\-\(\)]'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите номер телефона';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Сбрасываем состояние поиска при изменении номера
                      if (_foundClientId != null || _clientNotFound) {
                        setState(() {
                          _foundClientId = null;
                          _foundClientName = null;
                          _clientNotFound = false;
                          _nameController.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchClient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Найти'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Статус поиска клиента
            if (_foundClientId != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Клиент найден: $_foundClientName',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_clientNotFound)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Клиент не найден. Введите имя для новой записи.',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Поле имени клиента
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Имя клиента',
                hintText: 'Введите ФИО',
                prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                enabled: _foundClientId == null, // Блокируем если клиент найден
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (_foundClientId == null &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Введите имя клиента';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // === БЛОК: Дата и время ===
            _buildSectionTitle('Дата и время'),
            const SizedBox(height: 16),

            // Дата
            _buildSelectField(
              label: 'Дата',
              value: _selectedDate != null
                  ? DateFormat('dd MMMM yyyy', 'ru').format(_selectedDate!)
                  : null,
              hint: 'Выберите дату',
              icon: Icons.calendar_today,
              onTap: _selectDate,
            ),

            const SizedBox(height: 12),

            // Время начала и окончания
            Row(
              children: [
                Expanded(
                  child: _buildSelectField(
                    label: 'Начало',
                    value: _startTime != null
                        ? _startTime!.format(context)
                        : null,
                    hint: 'Время',
                    icon: Icons.access_time,
                    onTap: _selectStartTime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSelectField(
                    label: 'Конец',
                    value: _endTime != null ? _endTime!.format(context) : null,
                    hint: 'Время',
                    icon: Icons.access_time,
                    onTap: _selectEndTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // === БЛОК: Формат сессии ===
            _buildSectionTitle('Формат сессии'),
            const SizedBox(height: 16),

            _buildFormatSelector(),

            const SizedBox(height: 24),

            // === БЛОК: Детали ===
            _buildSectionTitle('Детали'),
            const SizedBox(height: 16),

            // Описание проблемы
            TextFormField(
              controller: _issueController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Описание запроса (опционально)',
                hintText: 'Введите описание проблемы или запроса клиента',
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Цена
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Стоимость (опционально)',
                hintText: '0',
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: AppColors.primary,
                ),
                suffixText: '₸',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 32),

            // Кнопка создания
            CustomButton(
              text: 'Создать запись',
              onPressed: _createAppointment,
              isFullWidth: true,
              showArrow: true,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Заголовок секции
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Поле выбора (дата/время)
  Widget _buildSelectField({
    required String label,
    String? value,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: value != null
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Селектор формата сессии
  Widget _buildFormatSelector() {
    return Row(
      children: [
        _buildFormatOption(SessionFormat.video, Icons.videocam, 'Видео'),
        const SizedBox(width: 12),
        _buildFormatOption(SessionFormat.chat, Icons.chat_bubble, 'Чат'),
        const SizedBox(width: 12),
        _buildFormatOption(SessionFormat.audio, Icons.phone, 'Аудио'),
      ],
    );
  }

  /// Опция формата
  Widget _buildFormatOption(SessionFormat format, IconData icon, String label) {
    final isSelected = _selectedFormat == format;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFormat = format;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
