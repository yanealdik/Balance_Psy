import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/psychologist/reports/stat_card_widget.dart';
import '../../providers/report_provider.dart';
import '../../models/report_model.dart';
import 'ClientHistoryScreen.dart';

/// Экран отчетов психолога с иерархической структурой:
/// Дата → Клиенты → История посещений
class PsychologistReportsScreen extends StatefulWidget {
  const PsychologistReportsScreen({super.key});

  @override
  State<PsychologistReportsScreen> createState() =>
      _PsychologistReportsScreenState();
}

class _PsychologistReportsScreenState extends State<PsychologistReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
  }

  Future<void> _loadReports() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    await provider.loadReportsGroupedByDate();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundLight,
      child: SafeArea(
        child: Consumer<ReportProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final groupedReports = provider.groupedReports;
            final allReports = provider.reports;

            // Статистика
            final totalReports = allReports.length;
            final weekReports = _calculateWeekReports(allReports);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Text(
                    'Мои отчеты',
                    style: AppTextStyles.h2.copyWith(fontSize: 28),
                  ),
                ),

                // Статистика
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCardWidget(
                          number: totalReports.toString(),
                          label: 'всего отчетов',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCardWidget(
                          number: weekReports.toString(),
                          label: 'за эту неделю',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Заголовок секции
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'По датам',
                    style: AppTextStyles.h3.copyWith(fontSize: 22),
                  ),
                ),

                const SizedBox(height: 16),

                // Список дат
                Expanded(
                  child: groupedReports.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadReports,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: groupedReports.length,
                            itemBuilder: (context, index) {
                              final dateKey = groupedReports.keys
                                  .toList()[index];
                              final reportsForDate = groupedReports[dateKey]!;

                              // Группируем по клиентам
                              final clientsMap = _groupByClients(
                                reportsForDate,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildDateCard(
                                  dateKey,
                                  clientsMap.length,
                                  clientsMap,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
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
              Icons.description_outlined,
              size: 56,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Нет отчётов',
            style: AppTextStyles.h3.copyWith(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Отчёты появятся после завершения сессий',
            style: AppTextStyles.body2.copyWith(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // Карточка даты
  Widget _buildDateCard(
    String dateKey,
    int patientCount,
    Map<String, List<ReportModel>> clientsMap,
  ) {
    final date = DateTime.parse(dateKey);

    return GestureDetector(
      onTap: () => _navigateToDateDetails(date, clientsMap),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            // Иконка календаря
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDateString(date),
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$patientCount ${_getPatientsWord(patientCount)}',
                    style: AppTextStyles.body2.copyWith(fontSize: 14),
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

  // Переход к экрану с клиентами за конкретную дату
  void _navigateToDateDetails(
    DateTime date,
    Map<String, List<ReportModel>> clientsMap,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _DatePatientsScreen(date: date, clientsMap: clientsMap),
      ),
    );
  }

  // Группировка отчётов по клиентам
  Map<String, List<ReportModel>> _groupByClients(List<ReportModel> reports) {
    final Map<String, List<ReportModel>> grouped = {};

    for (var report in reports) {
      if (!grouped.containsKey(report.clientName)) {
        grouped[report.clientName] = [];
      }
      grouped[report.clientName]!.add(report);
    }

    return grouped;
  }

  int _calculateWeekReports(List<ReportModel> reports) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return reports.where((report) {
      try {
        final reportDate = DateTime.parse(report.sessionDate);
        return reportDate.isAfter(weekAgo) && reportDate.isBefore(now);
      } catch (e) {
        return false;
      }
    }).length;
  }

  String _getPatientsWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'пациент';
    } else if ([2, 3, 4].contains(count % 10) &&
        ![12, 13, 14].contains(count % 100)) {
      return 'пациента';
    } else {
      return 'пациентов';
    }
  }

  String _getDateString(DateTime date) {
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
  }
}

// Экран пациентов за конкретную дату
class _DatePatientsScreen extends StatelessWidget {
  final DateTime date;
  final Map<String, List<ReportModel>> clientsMap;

  const _DatePatientsScreen({required this.date, required this.clientsMap});

  @override
  Widget build(BuildContext context) {
    final clientNames = clientsMap.keys.toList();

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
          _getDateString(date),
          style: AppTextStyles.h2.copyWith(fontSize: 24),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: clientNames.length,
        itemBuilder: (context, index) {
          final clientName = clientNames[index];
          final reports = clientsMap[clientName]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => _navigateToClientHistory(
                context,
                clientName,
                reports.first.clientId,
              ),
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        reports.first.clientAvatarUrl ??
                            'https://i.pravatar.cc/150?img=60',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clientName,
                            style: AppTextStyles.h3.copyWith(fontSize: 17),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reports.length} ${_getSessionWord(reports.length)} • ${reports.first.sessionTheme}',
                            style: AppTextStyles.body2.copyWith(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
            ),
          );
        },
      ),
    );
  }

  void _navigateToClientHistory(
    BuildContext context,
    String clientName,
    int clientId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ClientHistoryScreen(clientName: clientName, clientId: clientId),
      ),
    );
  }

  String _getSessionWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'сеанс';
    } else if ([2, 3, 4].contains(count % 10) &&
        ![12, 13, 14].contains(count % 100)) {
      return 'сеанса';
    } else {
      return 'сеансов';
    }
  }

  String _getDateString(DateTime date) {
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
  }
}
