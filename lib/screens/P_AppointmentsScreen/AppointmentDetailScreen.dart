import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/custom_button.dart';
import '../P_ReportsScreen/CreateReportScreen.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

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
          'Детали записи',
          style: AppTextStyles.h2.copyWith(fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статус
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: appointment.statusColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(appointment.status),
                      size: 20,
                      color: appointment.statusTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.statusDisplayName,
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 16,
                        color: appointment.statusTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Клиент
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(
                      appointment.clientAvatarUrl ??
                          'https://i.pravatar.cc/150?img=25',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Клиент',
                          style: AppTextStyles.body2.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.clientName,
                          style: AppTextStyles.h3.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Дата и время
            _buildInfoCard(
              icon: Icons.calendar_today,
              title: 'Дата и время',
              content:
                  '${_formatDate(appointment.appointmentDate)}\n${appointment.startTime} - ${appointment.endTime}',
            ),

            const SizedBox(height: 16),

            // Формат
            _buildInfoCard(
              icon: _getFormatIcon(appointment.format),
              title: 'Формат',
              content: appointment.formatDisplayName,
              iconColor: _getFormatColor(appointment.format),
            ),

            const SizedBox(height: 16),

            // Проблема
            if (appointment.issueDescription != null &&
                appointment.issueDescription!.isNotEmpty)
              _buildInfoCard(
                icon: Icons.description,
                title: 'Описание проблемы',
                content: appointment.issueDescription!,
              ),

            const SizedBox(height: 16),

            // Заметки
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              _buildInfoCard(
                icon: Icons.notes,
                title: 'Заметки',
                content: appointment.notes!,
              ),

            const SizedBox(height: 32),

            // Кнопки действий
            _buildActionButtons(context),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: AppTextStyles.body1.copyWith(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);

    // CONFIRMED → можно Start / Cancel
    if (appointment.status == 'CONFIRMED') {
      return Column(
        children: [
          CustomButton(
            text: 'Начать сессию',
            onPressed: () => _handleStart(context, provider),
            isFullWidth: true,
            showArrow: true,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Отменить',
            onPressed: () => _handleCancel(context, provider),
            isFullWidth: true,
            backgroundColor: Colors.transparent,
            textColor: AppColors.error,
          ),
        ],
      );
    }

    // COMPLETED → можно создать отчёт
    if (appointment.status == 'COMPLETED') {
      return CustomButton(
        text: 'Создать отчёт',
        onPressed: () => _navigateToCreateReport(context),
        isFullWidth: true,
        showArrow: true,
      );
    }

    // PENDING → можно только отменить
    if (appointment.status == 'PENDING') {
      return CustomButton(
        text: 'Отменить запись',
        onPressed: () => _handleCancel(context, provider),
        isFullWidth: true,
        backgroundColor: AppColors.error,
      );
    }

    return const SizedBox();
  }

  Future<void> _handleStart(
    BuildContext context,
    AppointmentProvider provider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Начать сессию?', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: const Text(
          'Вы уверены, что хотите начать сессию с этим клиентом?',
          style: TextStyle(fontSize: 14),
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
              'Начать',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final success = await provider.startSession(appointment.id);

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context); // Закрываем детали
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сессия начата'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Ошибка'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCancel(
    BuildContext context,
    AppointmentProvider provider,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Причина отмены'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Укажите причину...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text(
                'Подтвердить',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (reason == null || !context.mounted) return;

    final success = await provider.cancelAppointment(
      appointment.id,
      reason.isEmpty ? 'Отменено психологом' : reason,
    );

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Запись отменена'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Ошибка'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateToCreateReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReportScreen(
          appointmentId: appointment.id,
          clientName: appointment.clientName,
        ),
      ),
    );
  }

  // Helper methods
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'COMPLETED':
        return Icons.verified;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.circle;
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

  Color _getFormatColor(String format) {
    switch (format.toUpperCase()) {
      case 'VIDEO':
        return const Color(0xFF00BCD4);
      case 'CHAT':
        return const Color(0xFF4CAF50);
      case 'AUDIO':
        return const Color(0xFFFF9800);
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
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
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
