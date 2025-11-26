import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../models/appointment_model.dart';
import '../../../widgets/custom_button.dart';
import '../../P_ReportsScreen/CreateReportScreen.dart';
import '../../P_AppointmentsScreen/AppointmentsScreen.dart';
import '../../P_ReportsScreen/PsychologistReportsScreen.dart';

/// Главный экран психолога
class PHomeScreen extends StatefulWidget {
  const PHomeScreen({super.key});

  @override
  State<PHomeScreen> createState() => _PHomeScreenState();
}

class _PHomeScreenState extends State<PHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appointmentProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    await Future.wait([
      appointmentProvider.loadPsychologistAppointments(),
      reportProvider.loadIncompleteReports(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Моя практика',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              // TODO: Переход к уведомлениям
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: Consumer<AppointmentProvider>(
          builder: (context, appointmentProvider, _) {
            if (appointmentProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final pendingRequests = appointmentProvider.pendingAppointments;
            final upcomingSessions = appointmentProvider.confirmedAppointments;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Быстрые действия
                _buildQuickActions(),

                const SizedBox(height: 24),

                // Статистика
                Consumer<ReportProvider>(
                  builder: (context, reportProvider, _) {
                    return _buildStats(
                      appointmentProvider.appointments.length,
                      reportProvider.reports
                          .where((r) => !r.isCompleted)
                          .length,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Заявки на подтверждение
                if (pendingRequests.isNotEmpty) ...[
                  _buildSectionHeader('Заявки', pendingRequests.length),
                  const SizedBox(height: 16),
                  ...pendingRequests.map(
                    (request) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildRequestCard(request),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Ближайшие сессии
                _buildSectionHeader('Расписание', upcomingSessions.length),
                const SizedBox(height: 16),

                if (upcomingSessions.isEmpty)
                  _buildEmptyState('Нет предстоящих сессий')
                else
                  ...upcomingSessions.map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSessionCard(session),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.add_circle_outline,
            label: 'Новая запись',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentScreen(),
                ),
              );

              if (result == true) {
                _loadData();
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.description_outlined,
            label: 'Отчёты',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PsychologistReportsScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Статистика
  Widget _buildStats(int totalAppointments, int incompleteReports) {
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
          _buildStatItem('Записи', totalAppointments.toString()),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildStatItem(
            'Отчёты',
            incompleteReports.toString(),
            subtitle: 'незавершённых',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {String? subtitle}) {
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
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
      ],
    );
  }

  /// Заголовок секции
  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  /// Карточка заявки
  Widget _buildRequestCard(AppointmentModel request) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: request.clientAvatarUrl != null
                    ? NetworkImage(request.clientAvatarUrl!)
                    : null,
                child: request.clientAvatarUrl == null
                    ? Text(
                        request.clientName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.clientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.appointmentDate} • ${request.startTime}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (request.issueDescription != null &&
              request.issueDescription!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              request.issueDescription!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleReject(request.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Отклонить'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _handleAccept(request.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Подтвердить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Карточка сессии
  Widget _buildSessionCard(AppointmentModel session) {
    return GestureDetector(
      onTap: () => _showSessionActions(session),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: session.status == 'IN_PROGRESS'
                ? AppColors.primary.withOpacity(0.5)
                : Colors.transparent,
            width: 2,
          ),
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
            CircleAvatar(
              radius: 28,
              backgroundImage: session.clientAvatarUrl != null
                  ? NetworkImage(session.clientAvatarUrl!)
                  : null,
              child: session.clientAvatarUrl == null
                  ? Text(
                      session.clientName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.clientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.startTime} - ${session.endTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Статус
            if (session.status == 'IN_PROGRESS')
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'В работе',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
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

  /// Пустое состояние
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
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

  /// Показать действия для сессии
  void _showSessionActions(AppointmentModel session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          SessionActionsSheet(session: session, onActionCompleted: _loadData),
    );
  }

  /// Подтвердить заявку
  Future<void> _handleAccept(int requestId) async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);

    final success = await provider.confirmAppointment(requestId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заявка подтверждена'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Ошибка подтверждения'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Отклонить заявку
  Future<void> _handleReject(int requestId) async {
    // Показываем диалог для ввода причины
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _RejectReasonDialog(),
    );

    if (reason == null || reason.isEmpty) return;

    final provider = Provider.of<AppointmentProvider>(context, listen: false);

    final success = await provider.rejectAppointment(requestId, reason);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заявка отклонена'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Ошибка отклонения'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

/// Bottom sheet с действиями для сессии
class SessionActionsSheet extends StatelessWidget {
  final AppointmentModel session;
  final VoidCallback onActionCompleted;

  const SessionActionsSheet({
    super.key,
    required this.session,
    required this.onActionCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Хендл
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Информация о клиенте
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: session.clientAvatarUrl != null
                        ? NetworkImage(session.clientAvatarUrl!)
                        : null,
                    child: session.clientAvatarUrl == null
                        ? Text(
                            session.clientName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.clientName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${session.appointmentDate} • ${session.startTime}-${session.endTime}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Действия
            if (session.status == 'CONFIRMED') ...[
              _buildActionButton(
                context,
                icon: Icons.play_arrow,
                label: 'Начать сессию',
                color: AppColors.primary,
                onTap: () => _startSession(context),
              ),
              _buildActionButton(
                context,
                icon: Icons.cancel_outlined,
                label: 'Отменить',
                color: AppColors.error,
                onTap: () => _cancelSession(context),
              ),
            ],

            if (session.status == 'IN_PROGRESS') ...[
              _buildActionButton(
                context,
                icon: Icons.check_circle_outline,
                label: 'Завершить сессию',
                color: AppColors.success,
                onTap: () => _completeSession(context),
              ),
              _buildActionButton(
                context,
                icon: Icons.person_off_outlined,
                label: 'Клиент не пришёл',
                color: AppColors.warning,
                onTap: () => _markAsNoShow(context),
              ),
            ],

            // Общие действия
            _buildActionButton(
              context,
              icon: Icons.chat_bubble_outline,
              label: 'Открыть чат',
              onTap: () {
                Navigator.pop(context);
                // TODO: Переход к чату
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Функция чата в разработке'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.textPrimary),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startSession(BuildContext context) async {
    Navigator.pop(context);

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.startSession(session.id);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сессия началась'),
          backgroundColor: AppColors.success,
        ),
      );
      onActionCompleted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Ошибка'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _completeSession(BuildContext context) async {
    Navigator.pop(context);

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.completeSession(session.id);

    if (!context.mounted) return;

    if (success) {
      // Предлагаем создать отчёт
      final createReport = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Сессия завершена'),
          content: const Text('Хотите создать отчёт о сессии?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Позже'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Создать'),
            ),
          ],
        ),
      );

      if (createReport == true && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateReportScreen(
              appointmentId: session.id,
              clientName: session.clientName,
            ),
          ),
        );
      }

      onActionCompleted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Ошибка'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _cancelSession(BuildContext context) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _RejectReasonDialog(title: 'Причина отмены'),
    );

    if (reason == null || reason.isEmpty) return;

    Navigator.pop(context);

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.cancelAppointment(session.id, reason);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сессия отменена'),
          backgroundColor: AppColors.success,
        ),
      );
      onActionCompleted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Ошибка'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _markAsNoShow(BuildContext context) async {
    Navigator.pop(context);

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.markAsNoShow(session.id);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Отмечено как "Клиент не явился"'),
          backgroundColor: AppColors.success,
        ),
      );
      onActionCompleted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Ошибка'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

/// Диалог ввода причины отклонения/отмены
class _RejectReasonDialog extends StatefulWidget {
  final String title;

  const _RejectReasonDialog({this.title = 'Причина отклонения'});

  @override
  State<_RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<_RejectReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Введите причину...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Подтвердить'),
        ),
      ],
    );
  }
}
