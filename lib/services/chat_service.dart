import 'package:dio/dio.dart';
import 'dart:io';
import '../core/api/api_client.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final Dio _dio = ApiClient.instance;

  /// Получить все чаты пользователя
  Future<List<ChatModel>> getUserChats() async {
    try {
      print('🔵 Fetching user chats...');
      final response = await _dio.get('/api/chats');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ChatModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load chats');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load chats');
    }
  }

  /// Получить или создать чат с психологом
  Future<ChatModel> getOrCreateChat(int psychologistId) async {
    try {
      print('🔵 Getting/creating chat with psychologist: $psychologistId');
      final response = await _dio.post(
        '/api/chats/psychologist/$psychologistId',
      );

      if (response.data['success'] == true) {
        return ChatModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to create chat');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create chat');
    }
  }

  /// Получить сообщения чата
  Future<List<MessageModel>> getChatMessages(int chatRoomId) async {
    try {
      print('🔵 Fetching messages for chat: $chatRoomId');
      final response = await _dio.get('/api/chats/$chatRoomId/messages');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => MessageModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load messages');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load messages');
    }
  }

  /// Отправить текстовое сообщение
  Future<MessageModel> sendMessage(int chatRoomId, String text) async {
    try {
      print('🔵 Sending message to chat: $chatRoomId');

      final response = await _dio.post(
        '/api/chats/messages',
        data: {'chatRoomId': chatRoomId, 'text': text, 'messageType': 'text'},
      );

      if (response.data['success'] == true) {
        return MessageModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to send message');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to send message');
    }
  }

  /// Загрузить файл
  Future<MessageModel> uploadFile(
    int chatRoomId,
    String filePath,
    String messageType,
  ) async {
    try {
      print('🔵 Uploading file to chat: $chatRoomId');

      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'messageType': messageType,
      });

      final response = await _dio.post(
        '/api/chats/$chatRoomId/upload',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.data['success'] == true) {
        return MessageModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to upload file');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to upload file');
    }
  }

  /// Отметить сообщения как прочитанные
  Future<void> markMessagesAsRead(int chatRoomId) async {
    try {
      await _dio.put('/api/chats/$chatRoomId/read');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to mark as read');
    }
  }
}
