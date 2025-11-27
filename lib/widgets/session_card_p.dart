import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Виджет карточки сессии для психолога
class SessionCardP extends StatelessWidget {
  final Map<String, dynamic> session;
  final VoidCallback? onChatTap;
  final VoidCallback? onDetailsTap;

  const SessionCardP({
    super.key,
    required this.session,
    this.onChatTap,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = session['status'] as String? ?? 'upcoming';

    return GestureDetector(
      onTap: onDetailsTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя часть: аватар + информация + статус
            Row(
              children: [
                // Аватар клиента
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getStatusBorderColor(status),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      session['clientImage'] as String? ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session['clientName'] as String,
                        style: AppTextStyles.h3.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${session['date']} в ${session['time']}',
                            style: AppTextStyles.body2.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Статус бейдж
                _buildStatusBadge(status),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.inputBorder),
            const SizedBox(height: 12),

            // Формат и заметки
            Row(
              children: [
                // Иконка формата
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getFormatColor(
                      session['format'] as String,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getFormatIcon(session['format'] as String),
                    color: _getFormatColor(session['format'] as String),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    session['notes'] as String? ?? 'Консультация',
                    style: AppTextStyles.body2.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // ✅ Дополнительная информация для прошедших сессий
            if (status == 'past') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Время сессии прошло. Отметьте статус.',
                        style: AppTextStyles.body3.copyWith(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ✅ Кнопка действий для идущей сессии
            if (status == 'in_progress') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.2),
                      AppColors.success.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Сессия идёт',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 14,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 12,
            color: _getStatusTextColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: AppTextStyles.body3.copyWith(
              fontSize: 11,
              color: _getStatusTextColor(status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ОБНОВЛЕНО: Цвета и иконки для статусов
  Color _getStatusColor(String status) {
    switch (status) {
      case 'soon':
        return const Color(0xFFFFF4E0); // Жёлтый
      case 'today':
        return const Color(0xFFE3F2FD); // Синий
      case 'in_progress':
        return const Color(0xFFE8F5E9); // Зелёный
      case 'past':
        return const Color(0xFFFFE8E8); // Красный
      case 'upcoming':
      default:
        return const Color(0xFFF5F5F5); // Серый
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'soon':
        return const Color(0xFFD4A747);
      case 'today':
        return const Color(0xFF1976D2);
      case 'in_progress':
        return const Color(0xFF4CAF50);
      case 'past':
        return AppColors.error;
      case 'upcoming':
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'soon':
        return Icons.notifications_active;
      case 'today':
        return Icons.event;
      case 'in_progress':
        return Icons.play_circle_filled;
      case 'past':
        return Icons.warning_amber_rounded;
      case 'upcoming':
      default:
        return Icons.schedule;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'soon':
        return 'Скоро';
      case 'today':
        return 'Сегодня';
      case 'in_progress':
        return 'Идёт';
      case 'past':
        return 'Прошло';
      case 'upcoming':
      default:
        return 'Запланировано';
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'soon':
        return const Color(0xFFD4A747);
      case 'today':
        return const Color(0xFF1976D2);
      case 'in_progress':
        return const Color(0xFF4CAF50);
      case 'past':
        return AppColors.error;
      default:
        return AppColors.primary.withOpacity(0.3);
    }
  }

  IconData _getFormatIcon(String format) {
    switch (format.toLowerCase()) {
      case 'video':
        return Icons.videocam;
      case 'chat':
        return Icons.chat_bubble;
      case 'audio':
        return Icons.phone;
      default:
        return Icons.help_outline;
    }
  }

  Color _getFormatColor(String format) {
    switch (format.toLowerCase()) {
      case 'video':
        return const Color(0xFF4CAF50);
      case 'chat':
        return const Color(0xFF2196F3);
      case 'audio':
        return const Color(0xFFFF9800);
      default:
        return AppColors.textSecondary;
    }
  }
}
