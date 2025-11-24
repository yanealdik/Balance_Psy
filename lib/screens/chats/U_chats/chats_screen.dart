import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/auth_provider.dart';
import '../Message/message_screen.dart';
import 'package:intl/intl.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String selectedFilter = 'Все';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundLight,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Мои чаты',
                    style: AppTextStyles.h2.copyWith(fontSize: 28),
                  ),
                  // Кнопка поиска
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Статистика
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'Активных',
                        value: '${provider.chats.length}',
                        icon: Icons.people,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Непрочитано',
                        value: '${provider.totalUnreadCount}',
                        icon: Icons.mark_chat_unread,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Фильтры
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Все',
                      isSelected: selectedFilter == 'Все',
                      onTap: () => setState(() => selectedFilter = 'Все'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Непрочитанные',
                      isSelected: selectedFilter == 'Непрочитанные',
                      onTap: () => setState(() => selectedFilter = 'Непрочитанные'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Онлайн',
                      isSelected: selectedFilter == 'Онлайн',
                      onTap: () => setState(() => selectedFilter = 'Онлайн'),
                    ),
                  ],
                ),
              ),
            ),

            // Список чатов
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
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
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.loadChats(),
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredChats = _getFilteredChats(provider.chats);

                  if (filteredChats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Нет чатов',
                            style: AppTextStyles.h3.copyWith(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Начните общение с психологом',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadChats(),
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ChatItem(
                            chat: chat,
                            onTap: () async {
                              // Открываем чат
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessageScreen(
                                    chatRoomId: chat.id,
                                    partnerName: chat.partnerName,
                                    partnerImage: chat.partnerImage,
                                    isOnline: chat.isPartnerOnline,
                                  ),
                                ),
                              );
                              
                              // Обновляем список после возврата
                              if (mounted) {
                                provider.loadChats();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _getFilteredChats(List chats) {
    switch (selectedFilter) {
      case 'Непрочитанные':
        return chats.where((c) => (c.unreadCount ?? 0) > 0).toList();
      case 'Онлайн':
        return chats.where((c) => c.isPartnerOnline).toList();
      default:
        return chats;
    }
  }
}

// Карточка статистики
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: AppTextStyles.h3.copyWith(fontSize: 20)),
                  Text(label, style: AppTextStyles.body2.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Фильтр-чип
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            fontSize: 13,
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Элемент чата
class _ChatItem extends StatelessWidget {
  final dynamic chat;
  final VoidCallback onTap;

  const _ChatItem({
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = (chat.unreadCount ?? 0) > 0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: hasUnread
              ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: hasUnread
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.shadow,
              blurRadius: hasUnread ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Аватар
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                    image: chat.partnerImage != null
                        ? DecorationImage(
                            image: NetworkImage(chat.partnerImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: chat.partnerImage == null
                      ? Center(
                          child: Text(
                            chat.partnerName[0].toUpperCase(),
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 24,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                if (chat.isPartnerOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                        border: Border.all(
                          color: AppColors.cardBackground,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.partnerName,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 16,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: AppTextStyles.body2.copyWith(
                          fontSize: 12,
                          color: hasUnread
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage ?? 'Начните общение',
                          style: AppTextStyles.body2.copyWith(
                            fontSize: 14,
                            color: hasUnread
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount != null && chat.unreadCount! > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          height: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${chat.unreadCount}',
                              style: AppTextStyles.body2.copyWith(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE', 'ru').format(time);
    } else {
      return DateFormat('dd.MM').format(time);
    }
  }
}