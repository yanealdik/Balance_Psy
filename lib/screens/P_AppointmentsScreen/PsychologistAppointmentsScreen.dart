import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';
import 'AppointmentDetailScreen.dart';

class PsychologistAppointmentsScreen extends StatefulWidget {
  const PsychologistAppointmentsScreen({super.key});

  @override
  State<PsychologistAppointmentsScreen> createState() =>
      _PsychologistAppointmentsScreenState();
}

class _PsychologistAppointmentsScreenState
    extends State<PsychologistAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all'; // all, pending, confirmed, completed

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    await provider.loadPsychologistAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Мои записи',
          style: AppTextStyles.h2.copyWith(fontSize: 24),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.button.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTextStyles.button.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.all(4),
              onTap: (index) {
                setState(() {
                  switch (index) {
                    case 0:
                      _selectedFilter = 'all';
                      break;
                    case 1:
                      _selectedFilter = 'pending';
                      break;
                    case 2:
                      _selectedFilter = 'confirmed';
                      break;
                    case 3:
                      _selectedFilter = 'completed';
                      break;
                  }
                });
              },
              tabs: const [
                Tab(text: 'Все'),
                Tab(text: 'Ожидают'),
                Tab(text: 'Подтверждены'),
                Tab(text: 'Завершены'),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = _filterAppointments(provider.appointments);

          if (appointments.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadAppointments,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildAppointmentCard(appointment),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<AppointmentModel> _filterAppointments(List<AppointmentModel> all) {
    switch (_selectedFilter) {
      case 'pending':
        return all.where((a) => a.status == 'PENDING').toList();
      case 'confirmed':
        return all.where((a) => a.status == 'CONFIRMED').toList();
      case 'completed':
        return all.where((a) => a.status == 'COMPLETED').toList();
      default:
        return all;
    }
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return GestureDetector(
      onTap: () => _navigateToDetail(appointment),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusBorderColor(appointment.status),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статус + дата
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: appointment.statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(appointment.status),
                        size: 14,
                        color: appointment.statusTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        appointment.statusDisplayName,
                        style: AppTextStyles.body2.copyWith(
                          fontSize: 12,
                          color: appointment.statusTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(appointment.appointmentDate),
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Клиент
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(
                    appointment.clientAvatarUrl ??
                        'https://i.pravatar.cc/150?img=25',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.clientName,
                        style: AppTextStyles.h3.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appointment.startTime} - ${appointment.endTime}',
                        style: AppTextStyles.body2.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Формат
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getFormatColor(appointment.format).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getFormatIcon(appointment.format),
                        size: 14,
                        color: _getFormatColor(appointment.format),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        appointment.formatDisplayName,
                        style: AppTextStyles.body2.copyWith(
                          fontSize: 12,
                          color: _getFormatColor(appointment.format),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_selectedFilter) {
      case 'pending':
        message = 'Нет ожидающих записей';
        icon = Icons.hourglass_empty;
        break;
      case 'confirmed':
        message = 'Нет подтверждённых записей';
        icon = Icons.event_available;
        break;
      case 'completed':
        message = 'Нет завершённых записей';
        icon = Icons.check_circle_outline;
        break;
      default:
        message = 'Нет записей';
        icon = Icons.event_busy;
    }

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
              icon,
              size: 56,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: AppTextStyles.h3.copyWith(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(AppointmentModel appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(appointment: appointment),
      ),
    ).then((_) => _loadAppointments());
  }

  // ✅ Helper methods
  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFD4A747);
      case 'CONFIRMED':
        return const Color(0xFF1976D2);
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELLED':
        return const Color(0xFFF44336);
      default:
        return AppColors.inputBorder;
    }
  }

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
        return const Color(0xFF00BCD4); // cyan
      case 'CHAT':
        return const Color(0xFF4CAF50); // green
      case 'AUDIO':
        return const Color(0xFFFF9800); // orange
      default:
        return AppColors.textSecondary;
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
        'янв',
        'фев',
        'мар',
        'апр',
        'мая',
        'июн',
        'июл',
        'авг',
        'сен',
        'окт',
        'ноя',
        'дек',
      ];

      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return dateStr;
    }
  }
}
