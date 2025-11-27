import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';
import '../../widgets/custom_button.dart';
import '../P_ReportsScreen/CreateReportScreen.dart';

/// Экран управления сессией для психолога
/// Позволяет: начать сессию, завершить, отметить как "не явился"
class SessionControlScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const SessionControlScreen({super.key, required this.appointment});

  @override
  State<SessionControlScreen> createState() => _SessionControlScreenState();
}

class _SessionControlScreenState extends State<SessionControlScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final isPast = _isPastAppointment(appointment);
    final isToday = _isTodayAppointment(appointment);
    final canStart = appointment.status == 'CONFIRMED' && (isToday || isPast);
    final canComplete = appointment.status == 'IN_PROGRESS';
    final canNoShow = appointment.status == 'CONFIRMED' && isPast;

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
          'Управление сессией',
          style: AppTextStyles.h2.copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка клиента
            _buildClientCard(appointment),

            const SizedBox(height: 24),

            // Информация о сессии
            _buildSessionInfo(appointment),

            const SizedBox(height: 24),

            // Статус сессии
            _buildStatusBadge(appointment.status),

            const SizedBox(height: 32),

            // Действия в зависимости от статуса
            if (appointment.status == 'CONFIRMED') ...[
              _buildConfirmedActions(canStart, canNoShow, isPast),
            ] else if (appointment.status == 'IN_PROGRESS') ...[
              _buildInProgressActions(),
            ] else if (appointment.status == 'COMPLETED') ...[
              _buildCompletedActions(),
            ],

            const SizedBox(height: 32),

            // Дополнительная информация
            if (appointment.issueDescription != null &&
                appointment.issueDescription!.isNotEmpty)
              _buildSection(
                'Запрос клиента',
                appointment.issueDescription!,
                Icons.psychology,
              ),

            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection('Заметки', appointment.notes!, Icons.notes),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard(AppointmentModel appointment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          // Аватар клиента
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipOval(
              child: appointment.clientAvatarUrl != null
                  ? Image.network(
                      appointment.clientAvatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.clientName,
                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Клиент #${appointment.clientId}',
                      style: AppTextStyles.body2.copyWith(fontSize: 13),
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

  Widget _buildSessionInfo(AppointmentModel appointment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Информация о сессии',
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.calendar_today,
            'Дата',
            _formatDate(appointment.appointmentDate),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            'Время',
            '${appointment.startTime} - ${appointment.endTime}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            _getFormatIcon(appointment.format),
            'Формат',
            appointment.formatDisplayName,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.payments,
            'Стоимость',
            '${appointment.price.toStringAsFixed(0)} ₸',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text('$label: ', style: AppTextStyles.body2.copyWith(fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.h3.copyWith(fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            color: _getStatusTextColor(status),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(status),
            style: AppTextStyles.h3.copyWith(
              fontSize: 15,
              color: _getStatusTextColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedActions(bool canStart, bool canNoShow, bool isPast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Действия', style: AppTextStyles.h3.copyWith(fontSize: 16)),
        const SizedBox(height: 16),

        // Кнопка "Начать сессию"
        if (canStart)
          CustomButton(
            text: 'Начать сессию',
            onPressed: _isLoading ? null : _handleStartSession,
            isFullWidth: true,
            isLoading: _isLoading,
            backgroundColor: AppColors.success,
            icon: Icons.play_circle_filled,
          ),

        if (!canStart && !isPast)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Начать сессию можно в день приёма',
                    style: AppTextStyles.body2.copyWith(
                      fontSize: 13,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // Кнопка "Не явился"
        if (canNoShow)
          CustomButton(
            text: 'Клиент не явился',
            onPressed: _isLoading ? null : _handleNoShow,
            isFullWidth: true,
            backgroundColor: AppColors.error.withOpacity(0.1),
            textColor: AppColors.error,
            icon: Icons.event_busy,
          ),

        const SizedBox(height: 12),

        // Кнопка "Отменить"
        CustomButton(
          text: 'Отменить запись',
          onPressed: _isLoading ? null : _handleCancel,
          isFullWidth: true,
          backgroundColor: Colors.transparent,
          textColor: AppColors.textSecondary,
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }

  Widget _buildInProgressActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Индикатор идущей сессии
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.success.withOpacity(0.2),
                AppColors.success.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.timer, size: 48, color: AppColors.success),
              const SizedBox(height: 12),
              Text(
                'Сессия идёт',
                style: AppTextStyles.h3.copyWith(
                  fontSize: 18,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Завершите сессию после консультации',
                style: AppTextStyles.body2.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Кнопка завершения
        CustomButton(
          text: 'Завершить сессию',
          onPressed: _isLoading ? null : _handleComplete,
          isFullWidth: true,
          isLoading: _isLoading,
          backgroundColor: AppColors.primary,
          icon: Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildCompletedActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.check_circle, size: 48, color: AppColors.success),
              const SizedBox(height: 12),
              Text(
                'Сессия завершена',
                style: AppTextStyles.h3.copyWith(
                  fontSize: 18,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Вы можете создать отчёт по сессии',
                style: AppTextStyles.body2.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        CustomButton(
          text: 'Создать отчёт',
          onPressed: () => _navigateToCreateReport(),
          isFullWidth: true,
          icon: Icons.description,
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.h3.copyWith(fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.body2.copyWith(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ✅ Обработчики действий
  Future<void> _handleStartSession() async {
    setState(() => _isLoading = true);

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.startSession(widget.appointment.id);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      _showSuccessDialog('Сессия начата!', 'Статус обновлён на "В процессе"');
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Ошибка начала сессии');
    }
  }

  Future<void> _handleComplete() async {
    setState(() => _isLoading = true);

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.completeSession(widget.appointment.id);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Показываем диалог с предложением создать отчёт
      _showCompleteDialog();
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Ошибка завершения сессии');
    }
  }

  Future<void> _handleNoShow() async {
    final confirm = await _showConfirmDialog(
      'Клиент не явился?',
      'Вы уверены? Это действие нельзя отменить.',
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.markAsNoShow(widget.appointment.id);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Запись отмечена как "не явился"'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Ошибка');
    }
  }

  Future<void> _handleCancel() async {
    final confirm = await _showConfirmDialog(
      'Отменить запись?',
      'Клиент получит уведомление об отмене.',
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.cancelAppointment(
      widget.appointment.id,
      'Отменено психологом',
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Запись отменена'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Ошибка отмены');
    }
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              'Сессия завершена!',
              style: AppTextStyles.h2.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              'Создать отчёт по этой сессии?',
              textAlign: TextAlign.center,
              style: AppTextStyles.body1.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Создать отчёт',
              onPressed: () {
                Navigator.pop(context); // Закрываем диалог
                _navigateToCreateReport();
              },
              isFullWidth: true,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Позже',
              onPressed: () {
                Navigator.pop(context); // Закрываем диалог
                Navigator.pop(context); // Закрываем SessionControlScreen
              },
              isFullWidth: true,
              backgroundColor: Colors.transparent,
              textColor: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateReport() {
    Navigator.pop(context); // Закрываем текущий экран
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReportScreen(
          appointmentId: widget.appointment.id,
          clientName: widget.appointment.clientName,
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            Text(title, style: AppTextStyles.h2.copyWith(fontSize: 22)),
            const SizedBox(height: 12),
            Text(
              message,
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
                Navigator.pop(context);
                Navigator.pop(context);
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTextStyles.h2.copyWith(fontSize: 18)),
        content: Text(
          message,
          style: AppTextStyles.body1.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Подтвердить',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Вспомогательные методы
  bool _isPastAppointment(AppointmentModel appointment) {
    try {
      final date = DateTime.parse(appointment.appointmentDate);
      final time = appointment.startTime.split(':');
      final sessionDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(time[0]),
        int.parse(time[1]),
      );
      return sessionDateTime.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  bool _isTodayAppointment(AppointmentModel appointment) {
    try {
      final date = DateTime.parse(appointment.appointmentDate);
      final now = DateTime.now();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } catch (e) {
      return false;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return 'Сегодня';
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day + 1) {
        return 'Завтра';
      }

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

      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getFormatIcon(String format) {
    switch (format.toUpperCase()) {
      case 'VIDEO':
        return Icons.videocam;
      case 'CHAT':
        return Icons.chat_bubble;
      case 'AUDIO':
        return Icons.phone;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFFFF4E0);
      case 'CONFIRMED':
        return const Color(0xFFE3F2FD);
      case 'IN_PROGRESS':
        return const Color(0xFFE8F5E9);
      case 'COMPLETED':
        return const Color(0xFFE8F5E9);
      case 'CANCELLED':
      case 'NO_SHOW':
        return const Color(0xFFFFE8E8);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFD4A747);
      case 'CONFIRMED':
        return const Color(0xFF1976D2);
      case 'IN_PROGRESS':
        return const Color(0xFF4CAF50);
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELLED':
      case 'NO_SHOW':
        return AppColors.error;
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'IN_PROGRESS':
        return Icons.play_circle_filled;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
      case 'NO_SHOW':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Ожидается подтверждение';
      case 'CONFIRMED':
        return 'Подтверждено';
      case 'IN_PROGRESS':
        return 'Сессия идёт';
      case 'COMPLETED':
        return 'Завершено';
      case 'CANCELLED':
        return 'Отменено';
      case 'NO_SHOW':
        return 'Клиент не явился';
      default:
        return status;
    }
  }
}
