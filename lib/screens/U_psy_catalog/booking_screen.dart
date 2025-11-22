import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import 'payment_screen.dart';

/// Экран записи на сессию с выбором времени
class BookingScreen extends StatefulWidget {
  final String psychologistName;
  final String psychologistImage;
  final String specialty;
  final double rating;

  const BookingScreen({
    super.key,
    required this.psychologistName,
    required this.psychologistImage,
    required this.specialty,
    required this.rating, required double hourlyRate, required int psychologistId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  String selectedFormat = 'video'; // video или chat

  // Пример доступных слотов времени
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
        title: Text(
          'Запись на сессию',
          style: AppTextStyles.h3.copyWith(fontSize: 18),
        ),
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
                    // Карточка психолога
                    _buildPsychologistInfo(),

                    const SizedBox(height: 24),

                    // Выбор формата
                    Text(
                      'Формат сессии',
                      style: AppTextStyles.h3.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    _buildFormatSelector(),

                    const SizedBox(height: 24),

                    // Выбор даты
                    Text(
                      'Выберите дату',
                      style: AppTextStyles.h3.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    _buildDateSelector(),

                    const SizedBox(height: 24),

                    // Выбор времени
                    Text(
                      'Доступное время',
                      style: AppTextStyles.h3.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    _buildTimeSlots(),

                    const SizedBox(height: 24),

                    // Информация о сессии
                    _buildSessionInfo(),
                  ],
                ),
              ),
            ),

            // Кнопка подтверждения
            Container(
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
                  text: 'Отправить заявку',
                  onPressed: selectedTime != null ? _confirmBooking : null,
                  isFullWidth: true,
                ),
              ),
            ),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: widget.psychologistImage.startsWith('http')
                    ? NetworkImage(widget.psychologistImage)
                    : AssetImage(widget.psychologistImage) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.psychologistName,
                  style: AppTextStyles.h3.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.specialty,
                  style: AppTextStyles.body2.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      widget.rating.toString(),
                      style: AppTextStyles.body2.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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
        Expanded(
          child: _buildFormatOption(
            'video',
            'Видео-звонок',
            Icons.videocam_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFormatOption('chat', 'Чат', Icons.chat_bubble_outline),
        ),
      ],
    );
  }

  Widget _buildFormatOption(String format, String label, IconData icon) {
    final isSelected = selectedFormat == format;
    return GestureDetector(
      onTap: () => setState(() => selectedFormat = format),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
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
        itemCount: 14, // Показываем 2 недели вперед
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
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.inputBorder,
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
                        color: isSelected
                            ? AppColors.textWhite
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 20,
                        color: isSelected
                            ? AppColors.textWhite
                            : AppColors.textPrimary,
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
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
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
            '• Психолог подтвердит запись в течение 2 часов\n'
            '• Вы получите уведомление о подтверждении\n'
            '• Отменить можно за 24 часа до начала',
            style: AppTextStyles.body2.copyWith(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
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

  String _getMonthName(int month) {
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return months[month - 1];
  }

  void _confirmBooking() {
    if (selectedTime == null) return;

    // Переходим на экран оплаты
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          psychologistName: widget.psychologistName,
          psychologistImage: widget.psychologistImage,
          sessionDate:
              '${selectedDate.day} ${_getMonthName(selectedDate.month)}',
          sessionTime: selectedTime!,
          price: 8000, // TODO: Получать цену из профиля психолога
          sessionFormat: selectedFormat,
        ),
      ),
    );
  }
}
