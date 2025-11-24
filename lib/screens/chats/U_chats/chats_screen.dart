import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/psychologist/chats/filter_chip_widget.dart';
import '../../../widgets/psychologist/chats/client_chat_item_widget.dart';
import '../../../widgets/psychologist/chats/chat_stat_card_widget.dart';
import '../Message/Message_screen.dart';

/// Экран чатов для пользователя - список психологов
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String selectedFilter = 'Все';

  final List<Map<String, dynamic>> clientChats = [
    {
      'name': 'Алина Касымова',
      'lastMessage': 'Спасибо за сессию!',
      'time': '14:23',
      'unreadCount': 0,
      'isOnline': true,
      'image': 'https://i.pravatar.cc/150?img=5',
      'hasUnread': false,
    },
    {
      'name': 'Дмитрий Петров',
      'lastMessage': 'Когда следующая встреча?',
      'time': '13:45',
      'unreadCount': 2,
      'isOnline': false,
      'image': 'https://i.pravatar.cc/150?img=12',
      'hasUnread': true,
    },
    {
      'name': 'Айгерим Нурланова',
      'lastMessage': 'Я чувствую себя намного лучше',
      'time': '12:10',
      'unreadCount': 0,
      'isOnline': true,
      'image': 'https://i.pravatar.cc/150?img=9',
      'hasUnread': false,
    },
    {
      'name': 'Максим Волков',
      'lastMessage': 'Можно перенести на завтра?',
      'time': '11:30',
      'unreadCount': 1,
      'isOnline': false,
      'image': 'https://i.pravatar.cc/150?img=13',
      'hasUnread': true,
    },
    {
      'name': 'Сауле Ахметова',
      'lastMessage': 'Добрый день!',
      'time': 'Вчера',
      'unreadCount': 0,
      'isOnline': false,
      'image': 'https://i.pravatar.cc/150?img=10',
      'hasUnread': false,
    },
  ];

  List<Map<String, dynamic>> get filteredChats {
    switch (selectedFilter) {
      case 'Непрочитанные':
        return clientChats.where((c) => c['hasUnread']).toList();
      case 'Онлайн':
        return clientChats.where((c) => c['isOnline']).toList();
      default:
        return clientChats;
    }
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
                    'Мои психологи',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  ChatStatCardWidget(
                    label: 'Активных',
                    value: '${clientChats.length}',
                    icon: Icons.people,
                  ),
                  const SizedBox(width: 12),
                  ChatStatCardWidget(
                    label: 'Непрочитано',
                    value: '${clientChats.where((c) => c['hasUnread']).length}',
                    icon: Icons.mark_chat_unread,
                  ),
                ],
              ),
            ),

            // Фильтры
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChipWidget(
                      label: 'Все',
                      isSelected: selectedFilter == 'Все',
                      onTap: () {
                        setState(() {
                          selectedFilter = 'Все';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'Непрочитанные',
                      isSelected: selectedFilter == 'Непрочитанные',
                      onTap: () {
                        setState(() {
                          selectedFilter = 'Непрочитанные';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'Онлайн',
                      isSelected: selectedFilter == 'Онлайн',
                      onTap: () {
                        setState(() {
                          selectedFilter = 'Онлайн';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Список чатов с клиентами
            Expanded(
              child: filteredChats.isEmpty
                  ? Center(
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
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ClientChatItemWidget(
                            chat: filteredChats[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessageScreen(
                                    psychologistName:
                                        filteredChats[index]['name'],
                                    psychologistImage:
                                        filteredChats[index]['image'],
                                    psychologistStatus:
                                        filteredChats[index]['isOnline']
                                        ? 'онлайн'
                                        : 'не в сети',
                                  ),
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
}
