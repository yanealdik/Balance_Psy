import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/report_provider.dart';
import '../../models/report_model.dart';

/// Экран истории сессий с конкретным клиентом
class ClientHistoryScreen extends StatefulWidget {
  final String clientName;
  final int clientId;

  const ClientHistoryScreen({
    super.key,
    required this.clientName,
    required this.clientId,
  });

  @override
  State<ClientHistoryScreen> createState() => _ClientHistoryScreenState();
}

class _ClientHistoryScreenState extends State<ClientHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClientHistory();
    });
  }

  Future<void> _loadClientHistory() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    await provider.getClientHistory(widget.clientId);
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
              'История сессий',
              style: AppTextStyles.h2.copyWith(fontSize: 20),
            ),
            Text(
              widget.clientName,
              style: AppTextStyles.body2.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = provider.reports;

          if (reports.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadClientHistory,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildReportCard(report),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_outlined,
              size: 56,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Нет истории',
            style: AppTextStyles.h3.copyWith(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'История сессий с этим клиентом пуста',
            style: AppTextStyles.body2.copyWith(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    return GestureDetector(
      onTap: () => _showReportDetails(report),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с датой и форматом
            Row(
              children: [
                // Иконка формата
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getFormatColor(
                      report.sessionFormat,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getFormatIcon(report.sessionFormat),
                    color: _getFormatColor(report.sessionFormat),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(report.sessionDate),
                        style: AppTextStyles.h3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getFormatColor(
                                report.sessionFormat,
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getFormatText(report.sessionFormat),
                              style: AppTextStyles.body3.copyWith(
                                fontSize: 11,
                                color: _getFormatColor(report.sessionFormat),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: report.isCompleted
                                  ? AppColors.success.withOpacity(0.15)
                                  : AppColors.warning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  report.isCompleted
                                      ? Icons.check_circle
                                      : Icons.schedule,
                                  size: 12,
                                  color: report.isCompleted
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  report.isCompleted ? 'Завершён' : 'В работе',
                                  style: AppTextStyles.body3.copyWith(
                                    fontSize: 11,
                                    color: report.isCompleted
                                        ? AppColors.success
                                        : AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.inputBorder),
            const SizedBox(height: 12),

            // Тема сеанса
            Text(
              report.sessionTheme,
              style: AppTextStyles.h3.copyWith(fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Описание (превью)
            Text(
              report.sessionDescription,
              style: AppTextStyles.body2.copyWith(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetails(ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Заголовок
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.description,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Детали отчёта',
                            style: AppTextStyles.h2.copyWith(fontSize: 22),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Дата и формат
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Дата сеанса',
                      value: _formatDate(report.sessionDate),
                    ),

                    const SizedBox(height: 16),

                    _buildDetailRow(
                      icon: _getFormatIcon(report.sessionFormat),
                      label: 'Формат',
                      value: _getFormatText(report.sessionFormat),
                      valueColor: _getFormatColor(report.sessionFormat),
                    ),

                    const SizedBox(height: 16),

                    _buildDetailRow(
                      icon: report.isCompleted
                          ? Icons.check_circle
                          : Icons.schedule,
                      label: 'Статус',
                      value: report.isCompleted ? 'Завершён' : 'В работе',
                      valueColor: report.isCompleted
                          ? AppColors.success
                          : AppColors.warning,
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: AppColors.inputBorder),
                    const SizedBox(height: 24),

                    // Тема сеанса
                    _buildSection(
                      title: 'Тема сеанса',
                      content: report.sessionTheme,
                    ),

                    const SizedBox(height: 20),

                    // Описание
                    _buildSection(
                      title: 'Описание сеанса',
                      content: report.sessionDescription,
                    ),

                    const SizedBox(height: 20),

                    // Рекомендации
                    if (report.recommendations != null &&
                        report.recommendations!.isNotEmpty)
                      _buildSection(
                        title: 'Рекомендации',
                        content: report.recommendations!,
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text('$label: ', style: AppTextStyles.body2.copyWith(fontSize: 14)),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            fontSize: 14,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Text(
            content,
            style: AppTextStyles.body1.copyWith(fontSize: 14, height: 1.6),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        return 'Сегодня, ${DateFormat('HH:mm').format(date)}';
      } else if (dateOnly == yesterday) {
        return 'Вчера, ${DateFormat('HH:mm').format(date)}';
      } else {
        return DateFormat('d MMMM yyyy, HH:mm', 'ru').format(date);
      }
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

  Color _getFormatColor(String format) {
    switch (format.toUpperCase()) {
      case 'VIDEO':
        return const Color(0xFF00BCD4); // cyan
      case 'CHAT':
        return const Color(0xFF4CAF50); // green
      case 'AUDIO':
        return const Color(0xFFFF9800); // orange
      default:
        return AppColors.textSecondary;
    }
  }

  String _getFormatText(String format) {
    switch (format.toUpperCase()) {
      case 'VIDEO':
        return 'Видеозвонок';
      case 'CHAT':
        return 'Чат';
      case 'AUDIO':
        return 'Аудиозвонок';
      default:
        return format;
    }
  }
}
