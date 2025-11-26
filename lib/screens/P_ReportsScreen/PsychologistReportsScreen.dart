import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../providers/report_provider.dart';
import '../../models/report_model.dart';
import '../P_AppointmentsScreen/DatePatientsScreen.dart';

/// Экран отчётов психолога с группировкой по датам
class PsychologistReportsScreen extends StatefulWidget {
  const PsychologistReportsScreen({super.key});

  @override
  State<PsychologistReportsScreen> createState() =>
      _PsychologistReportsScreenState();
}

class _PsychologistReportsScreenState extends State<PsychologistReportsScreen> {
  String _selectedFilter = 'all'; // all, incomplete, week, month

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    await provider.loadReportsGroupedByDate();
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
          'Отчёты',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Все отчёты')),
              const PopupMenuItem(
                value: 'incomplete',
                child: Text('Незавершённые'),
              ),
              const PopupMenuItem(value: 'week', child: Text('За неделю')),
              const PopupMenuItem(value: 'month', child: Text('За месяц')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReports,
        color: AppColors.primary,
        child: Consumer<ReportProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadReports,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }

            final groupedReports = provider.groupedReports;

            // Применяем фильтры
            final filteredGrouped = _applyFilters(
              groupedReports,
              provider.reports,
            );

            if (filteredGrouped.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getEmptyMessage(),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Получаем все отчёты для статистики
            final allReports = filteredGrouped.values
                .expand((list) => list)
                .toList();
            final totalReports = allReports.length;
            final weekReports = _calculateWeekReports(allReports);

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredGrouped.length + 1, // +1 для статистики
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Статистика вверху
                  return Column(
                    children: [
                      _buildStats(totalReports, weekReports),
                      const SizedBox(height: 24),
                    ],
                  );
                }

                final dateKey = filteredGrouped.keys.toList()[index - 1];
                final reportsForDate = filteredGrouped[dateKey]!;

                // Группируем по клиентам
                final clientsMap = _groupByClients(reportsForDate);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildDateCard(dateKey, clientsMap.length, clientsMap),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Применить фильтры
  Map<String, List<ReportModel>> _applyFilters(
    Map<String, List<ReportModel>> grouped,
    List<ReportModel> allReports,
  ) {
    if (_selectedFilter == 'all') {
      return grouped;
    }

    if (_selectedFilter == 'incomplete') {
      // Фильтр незавершённых
      final filtered = <String, List<ReportModel>>{};
      for (var entry in grouped.entries) {
        final incompleteReports = entry.value
            .where((r) => !r.isCompleted)
            .toList();
        if (incompleteReports.isNotEmpty) {
          filtered[entry.key] = incompleteReports;
        }
      }
      return filtered;
    }

    if (_selectedFilter == 'week') {
      // Фильтр за неделю
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final filtered = <String, List<ReportModel>>{};

      for (var entry in grouped.entries) {
        try {
          final date = DateTime.parse(entry.key);
          if (date.isAfter(weekAgo)) {
            filtered[entry.key] = entry.value;
          }
        } catch (e) {
          // Игнорируем ошибки парсинга
        }
      }
      return filtered;
    }

    if (_selectedFilter == 'month') {
      // Фильтр за месяц
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));
      final filtered = <String, List<ReportModel>>{};

      for (var entry in grouped.entries) {
        try {
          final date = DateTime.parse(entry.key);
          if (date.isAfter(monthAgo)) {
            filtered[entry.key] = entry.value;
          }
        } catch (e) {
          // Игнорируем ошибки парсинга
        }
      }
      return filtered;
    }

    return grouped;
  }

  /// Сообщение для пустого состояния
  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 'incomplete':
        return 'Нет незавершённых отчётов';
      case 'week':
        return 'Нет отчётов за неделю';
      case 'month':
        return 'Нет отчётов за месяц';
      default:
        return 'Нет отчётов';
    }
  }

  /// Группировать отчёты по клиентам
  Map<int, List<ReportModel>> _groupByClients(List<ReportModel> reports) {
    final Map<int, List<ReportModel>> grouped = {};

    for (var report in reports) {
      if (!grouped.containsKey(report.clientId)) {
        grouped[report.clientId] = [];
      }
      grouped[report.clientId]!.add(report);
    }

    return grouped;
  }

  /// Подсчитать отчёты за неделю
  int _calculateWeekReports(List<ReportModel> reports) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    return reports.where((report) {
      try {
        final date = DateTime.parse(report.sessionDate);
        return date.isAfter(weekAgo);
      } catch (e) {
        return false;
      }
    }).length;
  }

  /// Статистика
  Widget _buildStats(int total, int week) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Всего', total.toString()),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildStatItem('За неделю', week.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Карточка даты с отчётами
  Widget _buildDateCard(
    String dateKey,
    int clientsCount,
    Map<int, List<ReportModel>> clientsMap,
  ) {
    // Парсим дату
    DateTime? date;
    try {
      date = DateTime.parse(dateKey);
    } catch (e) {
      date = null;
    }

    final formattedDate = date != null
        ? DateFormat('d MMMM yyyy', 'ru').format(date)
        : dateKey;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DatePatientsScreen(
              date: dateKey,
              formattedDate: formattedDate,
              clientsMap: clientsMap,
            ),
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
            // Иконка календаря
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$clientsCount ${_getClientWord(clientsCount)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
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

  /// Склонение слова "клиент"
  String _getClientWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'клиент';
    } else if ([2, 3, 4].contains(count % 10) &&
        ![12, 13, 14].contains(count % 100)) {
      return 'клиента';
    } else {
      return 'клиентов';
    }
  }
}
