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

  ChatProvider(ChatService chatService); // TODO: Получать из AuthProvider

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
    } catch (e) {
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
      final chat = await _service.getOrCreateChat(psychologistId);

      final index = _chats.indexWhere((c) => c.id == chat.id);
      if (index != -1) {
        _chats[index] = chat;
      } else {
        _chats.insert(0, chat);
      }

      notifyListeners();
      return chat;
    } catch (e) {
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
      _messages = await _service.getChatMessages(chatRoomId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Отправить текстовое сообщение
  Future<bool> sendMessage(int chatRoomId, String text) async {
    try {
      final message = await _service.sendMessage(chatRoomId, text);
      _messages.add(message);
      _updateChatLastMessage(chatRoomId, message);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ НОВЫЙ: Загрузить файл/картинку
  Future<bool> uploadFile(
    int chatRoomId,
    String filePath,
    String messageType,
  ) async {
    try {
      final message = await _service.uploadFile(
        chatRoomId,
        filePath,
        messageType,
      );

      _messages.add(message);
      _updateChatLastMessage(chatRoomId, message);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ НОВЫЙ: Загрузить голосовое сообщение
  Future<bool> uploadVoice(
    int chatRoomId,
    String audioPath,
    int durationSeconds,
  ) async {
    try {
      final message = await _service.uploadVoice(
        chatRoomId,
        audioPath,
        durationSeconds,
      );

      _messages.add(message);
      _updateChatLastMessage(chatRoomId, message);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// ✅ НОВЫЙ: Получить Zvonda URL
  Future<String?> getZvondaUrl(int chatRoomId) async {
    try {
      return await _service.getZvondaUrl(chatRoomId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Отметить сообщения как прочитанные
  Future<void> markAsRead(int chatRoomId) async {
    try {
      await _service.markMessagesAsRead(chatRoomId);

      final index = _chats.indexWhere((c) => c.id == chatRoomId);
      if (index != -1) {
        _chats[index] = _chats[index].copyWith(unreadCount: 0);
      }

      notifyListeners();
    } catch (e) {
      print('Failed to mark as read: $e');
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
