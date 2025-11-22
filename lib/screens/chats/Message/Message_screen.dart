import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/psychologist/psychologist_avatar.dart';

/// Экран переписки с психологом
class MessageScreen extends StatefulWidget {
  final String psychologistName;
  final String? psychologistImage;
  final String psychologistStatus;

  const MessageScreen({
    super.key,
    required this.psychologistName,
    required this.psychologistImage,
    required this.psychologistStatus,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Здравствуйте! Как ваше настроение сегодня?',
      'isMe': false,
      'time': '14:23',
    },
    {
      'text': 'Здравствуйте! Чувствую себя немного уставшим',
      'isMe': true,
      'time': '14:25',
    },
    {
      'text':
          'Понимаю. Давайте обсудим, что вас беспокоит. Вы можете рассказать подробнее?',
      'isMe': false,
      'time': '14:26',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      });
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _launchZvondaSession() async {
    final Uri url = Uri.parse('https://zvonda.kz');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть Zvonda.kz'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Аватар
            SizedBox(
              width: 40,
              height: 40,
              child: buildPsychologistAvatar(
                widget.psychologistImage,
                widget.psychologistName,
                radius: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Имя и статус
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.psychologistName,
                    style: AppTextStyles.h3.copyWith(fontSize: 16),
                  ),
                  Text(
                    widget.psychologistStatus,
                    style: AppTextStyles.body2.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Кнопка видеозвонка через Zvonda
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.primary),
            onPressed: _launchZvondaSession,
            tooltip: 'Начать сеанс на Zvonda.kz',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Баннер Zvonda
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.videocam, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Видеосеансы проходят через Zvonda.kz',
                    style: AppTextStyles.body2.copyWith(fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: _launchZvondaSession,
                  child: Text(
                    'Подключиться',
                    style: AppTextStyles.body2.copyWith(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Список сообщений
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                  message['text'],
                  message['isMe'],
                  message['time'],
                );
              },
            ),
          ),

          // Поле ввода
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Кнопка прикрепления
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.attach_file,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        // TODO: Прикрепить файл
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Поле ввода
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Написать сообщение...',
                          hintStyle: AppTextStyles.body2.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Кнопка отправки
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: AppColors.textWhite,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // Аватар психолога
            SizedBox(
              width: 40,
              height: 40,
              child: buildPsychologistAvatar(
                widget.psychologistImage,
                widget.psychologistName,
                radius: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Сообщение
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.body1.copyWith(
                      fontSize: 15,
                      color: isMe ? AppColors.textWhite : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: AppTextStyles.body2.copyWith(
                      fontSize: 11,
                      color: isMe
                          ? AppColors.textWhite.withOpacity(0.7)
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
