import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/report_model.dart';
import '../P_ReportsScreen/ClientHistoryScreen.dart';

/// Экран со списком клиентов на выбранную дату
class DatePatientsScreen extends StatelessWidget {
  final String date; // YYYY-MM-DD
  final String formattedDate; // "26 ноября 2025"
  final Map<int, List<ReportModel>> clientsMap; // clientId -> List<ReportModel>

  const DatePatientsScreen({
    super.key,
    required this.date,
    required this.formattedDate,
    required this.clientsMap,
  });

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
        title: Text(
          formattedDate,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: clientsMap.length,
        itemBuilder: (context, index) {
          final clientId = clientsMap.keys.toList()[index];
          final reports = clientsMap[clientId]!;
          final firstReport = reports.first;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildClientCard(
              context,
              clientId: clientId,
              clientName: firstReport.clientName,
              clientAvatarUrl: firstReport.clientAvatarUrl,
              reportsCount: reports.length,
              reports: reports,
            ),
          );
        },
      ),
    );
  }

  /// Карточка клиента
  Widget _buildClientCard(
    BuildContext context, {
    required int clientId,
    required String clientName,
    String? clientAvatarUrl,
    required int reportsCount,
    required List<ReportModel> reports,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ClientHistoryScreen(clientId: clientId, clientName: clientName),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Аватар клиента
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              backgroundImage: clientAvatarUrl != null
                  ? NetworkImage(clientAvatarUrl)
                  : null,
              child: clientAvatarUrl == null
                  ? Text(
                      clientName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Информация о клиенте
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$reportsCount ${_getReportWord(reportsCount)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // Показываем статусы отчётов
                  if (reports.any((r) => !r.isCompleted)) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${reports.where((r) => !r.isCompleted).length} незавершённых',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Стрелка
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

  /// Склонение слова "отчёт"
  String _getReportWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'отчёт';
    } else if ([2, 3, 4].contains(count % 10) &&
        ![12, 13, 14].contains(count % 100)) {
      return 'отчёта';
    } else {
      return 'отчётов';
    }
  }
}
