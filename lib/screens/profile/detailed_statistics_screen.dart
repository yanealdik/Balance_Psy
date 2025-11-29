import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/psychologist_statistics_model.dart';
import '../../../widgets/psychologist/profile/detailed_psychologist_stats_widget.dart';

/// Экран с детальной статистикой психолога
class DetailedStatisticsScreen extends StatelessWidget {
  final PsychologistStatistics statistics;

  const DetailedStatisticsScreen({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Детальная статистика',
          style: AppTextStyles.h3.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: DetailedPsychologistStatsWidget(stats: statistics)),
    );
  }
}
