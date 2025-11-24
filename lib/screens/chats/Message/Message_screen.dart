import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:async';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../providers/chat_provider.dart';
import '../../../models/message_model.dart';
import '../../../widgets/psychologist/psychologist_avatar.dart';

class MessageScreen extends StatefulWidget {
  final int? chatRoomId; // ✅ Теперь nullable
  final int? psychologistId; // ✅ Добавлено для создания чата
  final String partnerName;
  final String? partnerImage;
  final bool isOnline;

  const MessageScreen({
    super.key,
    this.chatRoomId, // ✅ Может быть null
    this.psychologistId, // ✅ Для создания нового чата
    required this.partnerName,
    this.partnerImage,
    this.isOnline = false,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  String? _recordingPath;

  int? _activeChatRoomId; // ✅ Хранит актуальный ID чата
  bool _isInitializing = true; // ✅ Флаг инициализации

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  // ✅ НОВЫЙ МЕТОД: Инициализация чата
  Future<void> _initializeChat() async {
    setState(() => _isInitializing = true);

    try {
      if (widget.chatRoomId != null) {
        // Чат уже существует
        _activeChatRoomId = widget.chatRoomId;
        await _loadMessages();
      } else if (widget.psychologistId != null) {
        // Создаём новый чат
        final chat = await context.read<ChatProvider>().getOrCreateChat(
          widget.psychologistId!,
        );

        if (chat != null) {
          _activeChatRoomId = chat.id;
          await _loadMessages();
        } else {
          _showError('Не удалось создать чат');
        }
      } else {
        _showError('Не указан ID чата или психолога');
      }
    } catch (e) {
      print('❌ Chat initialization error: $e');
      _showError('Ошибка инициализации чата');
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_activeChatRoomId == null) return;

    await context.read<ChatProvider>().loadMessages(_activeChatRoomId!);
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

  // ✅ Отправка текста
  Future<void> _sendTextMessage() async {
    if (_messageController.text.trim().isEmpty || _activeChatRoomId == null)
      return;

    final text = _messageController.text;
    _messageController.clear();

    final success = await context.read<ChatProvider>().sendMessage(
      _activeChatRoomId!,
      text,
    );

    if (success) {
      _scrollToBottom();
    } else {
      _showError('Не удалось отправить сообщение');
    }
  }

  // ✅ Выбор и отправка картинки
  Future<void> _pickAndSendImage() async {
    if (_activeChatRoomId == null) return;

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      final success = await context.read<ChatProvider>().uploadFile(
        _activeChatRoomId!,
        image.path,
        'image',
      );

      if (success) {
        _scrollToBottom();
      } else {
        _showError('Не удалось отправить изображение');
      }
    }
  }

  // ✅ Выбор и отправка файла
  Future<void> _pickAndSendFile() async {
    if (_activeChatRoomId == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final success = await context.read<ChatProvider>().uploadFile(
        _activeChatRoomId!,
        result.files.single.path!,
        'file',
      );

      if (success) {
        _scrollToBottom();
      } else {
        _showError('Не удалось отправить файл');
      }
    }
  }

  // ✅ Запись голосового
  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final path =
          '${Directory.systemTemp.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
        _recordingPath = path;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });
      });
    } else {
      _showError('Нет разрешения на запись аудио');
    }
  }

  Future<void> _stopRecording() async {
    if (_activeChatRoomId == null) return;

    await _audioRecorder.stop();
    _recordingTimer?.cancel();

    setState(() {
      _isRecording = false;
    });

    if (_recordingPath != null && _recordingDuration >= 1) {
      final success = await context.read<ChatProvider>().uploadVoice(
        _activeChatRoomId!,
        _recordingPath!,
        _recordingDuration,
      );

      if (success) {
        _scrollToBottom();
      } else {
        _showError('Не удалось отправить голосовое');
      }
    }

    setState(() {
      _recordingPath = null;
      _recordingDuration = 0;
    });
  }

  // ✅ Открыть Zvonda
  Future<void> _openZvondaSession() async {
    if (_activeChatRoomId == null) return;

    final zvondaUrl = await context.read<ChatProvider>().getZvondaUrl(
      _activeChatRoomId!,
    );

    if (zvondaUrl != null) {
      final Uri url = Uri.parse(zvondaUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        _showError('Не удалось открыть Zvonda.kz');
      }
    } else {
      _showError('Ссылка на видеосессию недоступна');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Показываем загрузку пока инициализируется чат
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildZvondaBanner(),
          Expanded(child: _buildMessagesList()),
          if (_isRecording) _buildRecordingPanel(),
          if (!_isRecording) _buildInputPanel(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: buildPsychologistAvatar(
              widget.partnerImage,
              widget.partnerName,
              radius: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.partnerName,
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                ),
                Text(
                  widget.isOnline ? 'онлайн' : 'не в сети',
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 12,
                    color: widget.isOnline
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: AppColors.primary),
          onPressed: _openZvondaSession,
          tooltip: 'Начать видеосессию',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildZvondaBanner() {
    return Container(
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
            onPressed: _openZvondaSession,
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
    );
  }

  Widget _buildMessagesList() {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (provider.messages.isEmpty) {
          return Center(
            child: Text(
              'Начните общение',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: provider.messages.length,
          itemBuilder: (context, index) {
            final message = provider.messages[index];
            final isMe = message.senderId == provider.currentUserId;
            return _buildMessageBubble(message, isMe);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            SizedBox(
              width: 40,
              height: 40,
              child: buildPsychologistAvatar(
                message.senderImage,
                message.senderName,
                radius: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
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
              child: _buildMessageContent(message, isMe),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageContent(MessageModel message, bool isMe) {
    final textColor = isMe ? AppColors.textWhite : AppColors.textPrimary;

    switch (message.type.toLowerCase()) {
      case 'voice':
        return _VoiceMessagePlayer(
          url: message.attachmentUrl ?? '',
          duration: message.voiceDuration ?? 0,
          isMe: isMe,
        );

      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.attachmentUrl ?? '',
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
            const SizedBox(height: 4),
            _buildMessageTime(message, isMe),
          ],
        );

      case 'file':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_file, color: textColor, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.attachmentName ?? 'Файл',
                    style: AppTextStyles.body2.copyWith(
                      color: textColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildMessageTime(message, isMe),
          ],
        );

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTextStyles.body1.copyWith(
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            _buildMessageTime(message, isMe),
          ],
        );
    }
  }

  Widget _buildMessageTime(MessageModel message, bool isMe) {
    final time = TimeOfDay.fromDateTime(message.createdAt).format(context);
    return Text(
      time,
      style: AppTextStyles.body2.copyWith(
        fontSize: 11,
        color: isMe
            ? AppColors.textWhite.withOpacity(0.7)
            : AppColors.textTertiary,
      ),
    );
  }

  Widget _buildRecordingPanel() {
    return Container(
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
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatDuration(_recordingDuration),
              style: AppTextStyles.h3.copyWith(fontSize: 16),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.error),
              onPressed: () {
                _audioRecorder.stop();
                _recordingTimer?.cancel();
                setState(() {
                  _isRecording = false;
                  _recordingPath = null;
                  _recordingDuration = 0;
                });
              },
            ),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 24),
                onPressed: _stopRecording,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
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
            PopupMenuButton<String>(
              icon: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.attach_file,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              onSelected: (value) {
                if (value == 'image') {
                  _pickAndSendImage();
                } else if (value == 'file') {
                  _pickAndSendFile();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'image',
                  child: Row(
                    children: [
                      Icon(Icons.image, size: 20),
                      SizedBox(width: 12),
                      Text('Изображение'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'file',
                  child: Row(
                    children: [
                      Icon(Icons.description, size: 20),
                      SizedBox(width: 12),
                      Text('Файл'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
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
                  onSubmitted: (_) => _sendTextMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onLongPress: _startRecording,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _messageController.text.isEmpty
                      ? AppColors.background
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _messageController.text.isEmpty ? Icons.mic : Icons.send,
                    color: _messageController.text.isEmpty
                        ? AppColors.textSecondary
                        : Colors.white,
                    size: 20,
                  ),
                  onPressed: _messageController.text.isEmpty
                      ? null
                      : _sendTextMessage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _VoiceMessagePlayer extends StatefulWidget {
  final String url;
  final int duration;
  final bool isMe;

  const _VoiceMessagePlayer({
    required this.url,
    required this.duration,
    required this.isMe,
  });

  @override
  State<_VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<_VoiceMessagePlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isMe ? Colors.white : AppColors.primary;
    final textColor = widget.isMe ? Colors.white : AppColors.textPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: iconColor,
            size: 32,
          ),
          onPressed: _togglePlayPause,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: widget.duration > 0
                    ? _currentPosition.inSeconds / widget.duration
                    : 0,
                backgroundColor: iconColor.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation(iconColor),
              ),
              const SizedBox(height: 4),
              Text(
                '${_currentPosition.inSeconds}s / ${widget.duration}s',
                style: AppTextStyles.body2.copyWith(
                  fontSize: 11,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
