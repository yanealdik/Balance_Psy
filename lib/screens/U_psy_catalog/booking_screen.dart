import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/psychologist/psychologist_avatar.dart';
import '../../models/session_format.dart';

class BookingScreen extends StatefulWidget {
  final String psychologistName;
  final String? psychologistImage;
  final String specialty;
  final double rating;
  final double hourlyRate;
  final int psychologistId;

  const BookingScreen({
    super.key,
    required this.psychologistName,
    required this.psychologistImage,
    required this.specialty,
    required this.rating,
    required this.hourlyRate,
    required this.psychologistId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  SessionFormat selectedFormat = SessionFormat.video;
  String selectedIssue = '';
  bool _isCreating = false;

  final List<String> availableSlots = [
    '09:00',
    '10:00',
    '11:30',
    '13:00',
    '14:30',
    '16:00',
    '17:30',
    '19:00',
  ];

  final List<Map<String, dynamic>> _issues = [
    {'title': 'Тревожность', 'icon': Icons.psychology},
    {'title': 'Депрессия', 'icon': Icons.cloud},
    {'title': 'Отношения', 'icon': Icons.favorite},
    {'title': 'Самооценка', 'icon': Icons.star},
    {'title': 'Стресс', 'icon': Icons.flash_on},
    {'title': 'Другое', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Запись на сессию', style: AppTextStyles.h3.copyWith(fontSize: 18)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPsychologistInfo(),
                    const SizedBox(height: 24),
                    Text('Формат сессии', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    _buildFormatSelector(),
                    const SizedBox(height: 24),
                    Text('Выберите дату', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    _buildDateSelector(),
                    const SizedBox(height: 24),
                    Text('Доступное время', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    _buildTimeSlots(),
                    const SizedBox(height: 24),
                    Text('Тема обращения', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    _buildIssueSelector(),
                    const SizedBox(height: 24),
                    _buildSessionInfo(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPsychologistInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: buildPsychologistAvatar(
              widget.psychologistImage,
              widget.psychologistName,
              radius: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.psychologistName, style: AppTextStyles.h3.copyWith(fontSize: 17)),
                const SizedBox(height: 4),
                Text(widget.specialty, style: AppTextStyles.body2.copyWith(fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      widget.rating.toString(),
                      style: AppTextStyles.body2.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Row(
      children: [
        Expanded(child: _buildFormatOption(SessionFormat.video, 'Видео-звонок', Icons.videocam_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildFormatOption(SessionFormat.chat, 'Чат', Icons.chat_bubble_outline)),
        const SizedBox(width: 12),
        Expanded(child: _buildFormatOption(SessionFormat.audio, 'Телефон', Icons.phone_outlined)),
      ],
    );
  }

  Widget _buildFormatOption(SessionFormat format, String label, IconData icon) {
    final isSelected = selectedFormat == format;
    return GestureDetector(
      onTap: () => setState(() => selectedFormat = format),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.body1.copyWith(
                fontSize: 14,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = _isSameDay(date, selectedDate);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => selectedDate = date),
              child: Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.inputBorder,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getWeekday(date.weekday),
                      style: AppTextStyles.body2.copyWith(
                        fontSize: 12,
                        color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 20,
                        color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: availableSlots.map((time) {
        final isSelected = selectedTime == time;
        return GestureDetector(
          onTap: () => setState(() => selectedTime = time),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.inputBorder,
                width: 1.5,
              ),
            ),
            child: Text(
              time,
              style: AppTextStyles.body1.copyWith(
                fontSize: 15,
                color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIssueSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _issues.map((issue) {
        final isSelected = selectedIssue == issue['title'];
        return GestureDetector(
          onTap: () => setState(() => selectedIssue = issue['title']),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.inputBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  issue['icon'],
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  issue['title'],
                  style: AppTextStyles.body1.copyWith(
                    fontSize: 14,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Информация о записи',
                style: AppTextStyles.body1.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Длительность сессии: 60 минут\n'
            '• Стоимость: ${widget.hourlyRate.toStringAsFixed(0)} ₸/час\n'
            '• Психолог подтвердит запись в течение 2 часов\n'
            '• Отменить можно за 24 часа до начала',
            style: AppTextStyles.body2.copyWith(
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text: _isCreating ? 'Отправка...' : 'Отправить заявку',
          onPressed: selectedTime != null && !_isCreating ? _confirmBooking : null,
          isFullWidth: true,
          isLoading: _isCreating,
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (selectedTime == null || selectedIssue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите время и тему обращения')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      
      // Вычисляем endTime (час после startTime)
      final startParts = selectedTime!.split(':');
      final startHour = int.parse(startParts[0]);
      final endTime = '${(startHour + 1).toString().padLeft(2, '0')}:${startParts[1]}';

      final success = await appointmentProvider.createAppointment({
        'date': _formatDate(selectedDate),
        'startTime': selectedTime!,
        'endTime': endTime,
        'psychologistId': widget.psychologistId,
        'format': selectedFormat,
        'issue': selectedIssue,
      });

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заявка успешно отправлена!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(appointmentProvider.errorMessage ?? 'Ошибка создания записи');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return weekdays[weekday - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
