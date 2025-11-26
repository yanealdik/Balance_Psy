import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/psychologist/schedule/calendar_header.dart';
import '../../widgets/psychologist/schedule/mini_calendar_widget.dart';
import '../../widgets/psychologist/schedule/appointment_card_widget.dart';
import '../../widgets/psychologist/schedule/full_calendar_modal.dart';
import '../../providers/appointment_provider.dart';
import '../P_AppointmentsScreen/AppointmentsScreen.dart';

class PsychologistScheduleScreen extends StatefulWidget {
  const PsychologistScheduleScreen({super.key});

  @override
  State<PsychologistScheduleScreen> createState() =>
      _PsychologistScheduleScreenState();
}

class _PsychologistScheduleScreenState
    extends State<PsychologistScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime displayedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    // ✅ Загружаем реальные записи при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  Future<void> _loadAppointments() async {
    final appointmentProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );
    await appointmentProvider.loadPsychologistAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    // ✅ Получаем реальные данные из provider
    final allAppointments = appointmentProvider.appointments;

    // ✅ Фильтруем записи на выбранную дату
    final todayAppointments = allAppointments.where((appointment) {
      try {
        final appointmentDate = DateTime.parse(appointment.appointmentDate);
        return appointmentDate.year == selectedDate.year &&
            appointmentDate.month == selectedDate.month &&
            appointmentDate.day == selectedDate.day;
      } catch (e) {
        return false;
      }
    }).toList();

    // ✅ Получаем все даты с записями для подсветки в календаре
    final appointmentDates = allAppointments
        .map((apt) {
          try {
            return DateTime.parse(apt.appointmentDate);
          } catch (e) {
            return null;
          }
        })
        .where((date) => date != null)
        .cast<DateTime>()
        .toList();

    return Material(
      color: AppColors.backgroundLight,
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Text(
                    'Расписание приёмов',
                    style: AppTextStyles.h2.copyWith(fontSize: 28),
                  ),
                ),

                // Календарь
                CalendarHeader(
                  displayedMonth: displayedMonth,
                  onTap: () => _showFullCalendar(appointmentDates),
                  child: MiniCalendarWidget(
                    selectedDate: selectedDate,
                    onDateSelected: (date) =>
                        setState(() => selectedDate = date),
                  ),
                ),

                const SizedBox(height: 32),

                // Заголовок секции
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Приёмы на ${_getDateString(selectedDate)}',
                        style: AppTextStyles.h3.copyWith(fontSize: 22),
                      ),
                      GestureDetector(
                        onTap: () => _showAllAppointments(allAppointments),
                        child: Row(
                          children: [
                            Text(
                              'Все',
                              style: AppTextStyles.body1.copyWith(
                                fontSize: 15,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ Список приёмов с индикатором загрузки
                Expanded(
                  child: appointmentProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : todayAppointments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Нет приёмов на эту дату',
                                style: AppTextStyles.body1.copyWith(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadAppointments,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: todayAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment = todayAppointments[index];

                              // ✅ Преобразуем AppointmentModel в формат для карточки
                              final appointmentData = {
                                'name': appointment.clientName,
                                'image':
                                    appointment.clientAvatarUrl ??
                                    'https://i.pravatar.cc/150?img=60',
                                'date': DateTime.parse(
                                  appointment.appointmentDate,
                                ),
                                'time': appointment.startTime,
                                'status': _getStatusText(appointment.status),
                                'statusColor': _getStatusColor(
                                  appointment.status,
                                ),
                                'statusTextColor': _getStatusTextColor(
                                  appointment.status,
                                ),
                              };

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: AppointmentCardWidget(
                                  appointment: appointmentData,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Плавающая кнопка добавления
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _openCreateAppointmentScreen,
              backgroundColor: AppColors.primary,
              elevation: 4,
              child: const Icon(
                Icons.add,
                color: AppColors.textWhite,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCreateAppointmentScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppointmentScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Запись успешно создана!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showFullCalendar(List<DateTime> appointmentDates) {
    showFullCalendarModal(
      context: context,
      selectedDate: selectedDate,
      displayedMonth: displayedMonth,
      allAppointments: appointmentDates.map((date) => {'date': date}).toList(),
      onDateSelected: (date) {
        setState(() => selectedDate = date);
      },
      onMonthChanged: (month) {
        setState(() => displayedMonth = month);
      },
    );
  }

  void _showAllAppointments(List<dynamic> appointments) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AllAppointmentsScreen(
          appointments: appointments,
          onDelete: (index) async {
            final appointment = appointments[index];
            final appointmentProvider = Provider.of<AppointmentProvider>(
              context,
              listen: false,
            );

            await appointmentProvider.cancelAppointment(
              appointment.id,
              'Удалено психологом',
            );
          },
        ),
      ),
    );
  }

  // ✅ Вспомогательные методы
  String _getDateString(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'сегодня';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1) {
      return 'завтра';
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
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Ожидается';
      case 'CONFIRMED':
        return 'Подтверждено';
      case 'COMPLETED':
        return 'Завершено';
      case 'CANCELLED':
        return 'Отменено';
      case 'NO_SHOW':
        return 'Не явился';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFFFF4E0);
      case 'CONFIRMED':
        return const Color(0xFFE3F2FD);
      case 'COMPLETED':
        return const Color(0xFFE8F5E9);
      case 'CANCELLED':
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
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELLED':
        return AppColors.error;
      default:
        return const Color(0xFF757575);
    }
  }
}

class _AllAppointmentsScreen extends StatelessWidget {
  final List<dynamic> appointments;
  final Function(int) onDelete;

  const _AllAppointmentsScreen({
    required this.appointments,
    required this.onDelete,
  });

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
          'Все приёмы',
          style: AppTextStyles.h2.copyWith(fontSize: 24),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];

          final appointmentData = {
            'name': appointment.clientName,
            'image':
                appointment.clientAvatarUrl ??
                'https://i.pravatar.cc/150?img=60',
            'date': DateTime.parse(appointment.appointmentDate),
            'time': appointment.startTime,
            'status': _getStatusText(appointment.status),
            'statusColor': _getStatusColor(appointment.status),
            'statusTextColor': _getStatusTextColor(appointment.status),
          };

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Dismissible(
              key: Key('appointment_${appointment.id}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                if (appointment.status == 'COMPLETED' ||
                    appointment.status == 'CANCELLED') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Нельзя удалить завершенную или отмененную запись',
                      ),
                    ),
                  );
                  return false;
                }
                return true;
              },
              onDismissed: (_) {
                onDelete(index);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Приём отменен')));
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: AppointmentCardWidget(appointment: appointmentData),
            ),
          );
        },
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Ожидается';
      case 'CONFIRMED':
        return 'Подтверждено';
      case 'COMPLETED':
        return 'Завершено';
      case 'CANCELLED':
        return 'Отменено';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFFFF4E0);
      case 'CONFIRMED':
        return const Color(0xFFE3F2FD);
      case 'COMPLETED':
        return const Color(0xFFE8F5E9);
      case 'CANCELLED':
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
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELLED':
        return AppColors.error;
      default:
        return const Color(0xFF757575);
    }
  }
}
