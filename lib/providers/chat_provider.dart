import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _service = ChatService();

  List<ChatModel> _chats = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentUserId;

  ChatProvider(ChatService chatService);

  void setCurrentUserId(int userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  List<ChatModel> get chats => _chats;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get currentUserId => _currentUserId;

  int get totalUnreadCount {
    return _chats.fold(0, (sum, chat) => sum + (chat.unreadCount ?? 0));
  }

  /// Загрузить список чатов
  Future<void> loadChats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _chats = await _service.getUserChats();
      _errorMessage = null;
      print('✅ Loaded ${_chats.length} chats');
    } catch (e) {
      print('❌ Load chats error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _chats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Получить или создать чат с психологом
  Future<ChatModel?> getOrCreateChat(int psychologistId) async {
    try {
      print(
        '🔵 Provider: Getting/creating chat with psychologist $psychologistId',
      );
      final chat = await _service.getOrCreateChat(psychologistId);

      final index = _chats.indexWhere((c) => c.id == chat.id);
      if (index != -1) {
        _chats[index] = chat;
      } else {
        _chats.insert(0, chat);
      }

      print('✅ Provider: Chat ready, ID: ${chat.id}');
      notifyListeners();
      return chat;
    } catch (e) {
      print('❌ Provider: Get/create chat error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Загрузить сообщения чата
  Future<void> loadMessages(int chatRoomId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔵 Provider: Loading messages for chat $chatRoomId');
      _messages = await _service.getChatMessages(chatRoomId);
      _errorMessage = null;
      print('✅ Provider: Loaded ${_messages.length} messages');
    } catch (e) {
      print('❌ Provider: Load messages error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ ИСПРАВЛЕНО: Отправить текстовое сообщение
  Future<bool> sendMessage(int chatRoomId, String text) async {
    try {
      print('🔵 Provider: Sending message to chat $chatRoomId');
      print('📝 Provider: Message text: "$text"');

      if (text.trim().isEmpty) {
        print('❌ Provider: Message text is empty');
        _errorMessage = 'Сообщение не может быть пустым';
        notifyListeners();
        return false;
      }

      final message = await _service.sendMessage(chatRoomId, text);

      print('✅ Provider: Message sent successfully, ID: ${message.id}');
      _messages.add(message);
      _updateChatLastMessage(chatRoomId, message);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Provider: Send message error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ ИСПРАВЛЕНО: Загрузить файл/картинку
  Future<bool> uploadFile(
    int chatRoomId,
    String filePath,
    String messageType,
  ) async {
    try {
      print('🔵 Provider: Uploading file to chat $chatRoomId');
      print('📁 Provider: File path: $filePath');
      print('📎 Provider: Message type: $messageType');

      final message = await _service.uploadFile(
        chatRoomId,
        filePath,
        messageType,
      );

      print('✅ Provider: File uploaded successfully, ID: ${message.id}');
      _messages.add(message);
      _updateChatLastMessage(chatRoomId, message);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Provider: Upload file error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ ИСПРАВЛЕНО: Загрузить голосовое сообщение
  Future<bool> uploadVoice(
    int chatRoomId,
    String audioPath,
    int durationSeconds,
  ) async {
    try {
      print('🔵 Provider: Uploading voice to chat $chatRoomId');
      print('🎤 Provider: Audio path: $audioPath');
      print('⏱️ Provider: Duration: ${durationSeconds}s');

      if (durationSeconds < 1) {
        print('❌ Provider: Voice duration too short');
        _errorMessage = 'Голосовое сообщение слишком короткое';
        notifyListeners();
        return false;
      }

      final message = await _service.uploadVoice(
        chatRoomId,
        audioPath,
        durationSeconds,
      );

      print('✅ Provider: Voice uploaded successfully, ID: ${message.id}');
      _messages.add(message);
      _updateChatLastMessage(chatRoomId, message);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Provider: Upload voice error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ ИСПРАВЛЕНО: Получить Zvonda URL
  Future<String?> getZvondaUrl(int chatRoomId) async {
    try {
      print('🔵 Provider: Getting Zvonda URL for chat $chatRoomId');
      final url = await _service.getZvondaUrl(chatRoomId);
      print('✅ Provider: Zvonda URL obtained');
      return url;
    } catch (e) {
      print('❌ Provider: Get Zvonda URL error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Отметить сообщения как прочитанные
  Future<void> markAsRead(int chatRoomId) async {
    try {
      print('🔵 Provider: Marking messages as read in chat $chatRoomId');
      await _service.markMessagesAsRead(chatRoomId);

      final index = _chats.indexWhere((c) => c.id == chatRoomId);
      if (index != -1) {
        _chats[index] = _chats[index].copyWith(unreadCount: 0);
      }

      print('✅ Provider: Messages marked as read');
      notifyListeners();
    } catch (e) {
      print('❌ Provider: Mark as read error: $e');
    }
  }

  /// Обновить последнее сообщение в чате
  void _updateChatLastMessage(int chatRoomId, MessageModel message) {
    final index = _chats.indexWhere((c) => c.id == chatRoomId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(
        lastMessage: _getMessagePreview(message),
        lastMessageTime: message.createdAt,
      );

      final chat = _chats.removeAt(index);
      _chats.insert(0, chat);
    }
  }

  String _getMessagePreview(MessageModel message) {
    switch (message.type.toLowerCase()) {
      case 'text':
        return message.text;
      case 'voice':
        return '🎤 Голосовое сообщение';
      case 'image':
        return '🖼️ Изображение';
      case 'file':
        return '📎 ${message.attachmentName ?? "Файл"}';
      default:
        return 'Сообщение';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
