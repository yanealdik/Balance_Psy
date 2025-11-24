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
      print('❌ Get chats error: ${e.response?.statusCode}');
      print('❌ Error data: ${e.response?.data}');
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
      print('❌ Create chat error: ${e.response?.statusCode}');
      print('❌ Error data: ${e.response?.data}');
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
      print('❌ Get messages error: ${e.response?.statusCode}');
      print('❌ Error data: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to load messages');
    }
  }

  /// ✅ ИСПРАВЛЕНО: Отправить текстовое сообщение
  Future<MessageModel> sendMessage(int chatRoomId, String text) async {
    try {
      print('🔵 Sending message to chat: $chatRoomId');
      print('📝 Message text: $text');

      // ✅ ИСПРАВЛЕНО: Правильная структура данных
      final requestData = {
        'chatRoomId': chatRoomId,
        'text': text,
        'messageType': 'text', // ✅ ВАЖНО: маленькими буквами!
      };

      print('📦 Request data: $requestData');

      final response = await _dio.post(
        '/api/chats/messages',
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('✅ Message sent: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.data['success'] == true) {
        return MessageModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to send message');
    } on DioException catch (e) {
      print('❌ Send message error: ${e.response?.statusCode}');
      print('❌ Error data: ${e.response?.data}');
      print('❌ Error message: ${e.message}');

      // Пробуем извлечь детальное сообщение
      String errorMsg = 'Failed to send message';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMsg = e.response!.data['message'] ?? errorMsg;
        }
      }
      throw Exception(errorMsg);
    }
  }

  /// ✅ ИСПРАВЛЕНО: Загрузить файл/картинку
  Future<MessageModel> uploadFile(
    int chatRoomId,
    String filePath,
    String messageType,
  ) async {
    try {
      print('🔵 Uploading file to chat: $chatRoomId');
      print('📁 File path: $filePath');
      print('📎 Message type: $messageType');

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileSize = await file.length();
      print('📊 File size: ${fileSize / 1024 / 1024} MB');

      final fileName = filePath.split('/').last;
      print('📄 File name: $fileName');

      // ✅ ИСПРАВЛЕНО: Правильное создание FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'messageType': messageType.toLowerCase(), // ✅ 'image' или 'file'
      });

      print('📦 Uploading with FormData...');

      final response = await _dio.post(
        '/api/chats/$chatRoomId/upload',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) {
            return status! < 500; // Принимаем все статусы < 500
          },
        ),
      );

      print('✅ Upload response: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data['success'] == true) {
          return MessageModel.fromJson(response.data['data']);
        }
      }

      throw Exception(response.data['message'] ?? 'Failed to upload file');
    } on DioException catch (e) {
      print('❌ Upload file error: ${e.response?.statusCode}');
      print('❌ Error data: ${e.response?.data}');
      print('❌ Error message: ${e.message}');

      String errorMsg = 'Failed to upload file';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMsg = e.response!.data['message'] ?? errorMsg;
        }
      }
      throw Exception(errorMsg);
    } catch (e) {
      print('❌ Unexpected upload error: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  /// ✅ ИСПРАВЛЕНО: Загрузить голосовое сообщение
  Future<MessageModel> uploadVoice(
    int chatRoomId,
    String audioPath,
    int durationSeconds,
  ) async {
    try {
      print('🔵 Uploading voice to chat: $chatRoomId (${durationSeconds}s)');
      print('🎤 Audio path: $audioPath');

      final file = File(audioPath);
      if (!await file.exists()) {
        print('❌ Voice file does not exist!');
        throw Exception('Voice file does not exist');
      }

      final fileSize = await file.length();
      print('📊 Voice file size: ${fileSize / 1024} KB');

      if (fileSize == 0) {
        print('❌ Voice file is empty!');
        throw Exception('Voice file is empty');
      }

      final fileName = audioPath.split('/').last;
      print('📄 Voice file name: $fileName');

      // ✅ ИСПРАВЛЕНО: Правильное создание FormData для голосового
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioPath, filename: fileName),
        'duration': durationSeconds,
      });

      print('📦 Uploading voice with FormData...');
      print('⏱️ Duration: $durationSeconds seconds');

      final response = await _dio.post(
        '/api/chats/$chatRoomId/voice',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      print('✅ Voice upload response: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data['success'] == true) {
          return MessageModel.fromJson(response.data['data']);
        }
      }

      throw Exception(response.data['message'] ?? 'Failed to upload voice');
    } on DioException catch (e) {
      print('❌ Upload voice DioException: ${e.response?.statusCode}');
      print('❌ Error data: ${e.response?.data}');
      print('❌ Error message: ${e.message}');
      print('❌ Error type: ${e.type}');

      String errorMsg = 'Failed to upload voice';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMsg = e.response!.data['message'] ?? errorMsg;
        }
      }
      throw Exception(errorMsg);
    } catch (e) {
      print('❌ Unexpected voice upload error: $e');
      print('❌ Error type: ${e.runtimeType}');
      throw Exception('Failed to upload voice: $e');
    }
  }

  /// ✅ ИСПРАВЛЕНО: Получить Zvonda URL
  Future<String> getZvondaUrl(int chatRoomId) async {
    try {
      print('🔵 Getting Zvonda URL for chat: $chatRoomId');

      final response = await _dio.get('/api/chats/$chatRoomId/zvonda-url');

      print('✅ Zvonda URL response: ${response.statusCode}');

      if (response.data['success'] == true) {
        final zvondaUrl = response.data['data']['zvondaUrl'] as String;
        print('🎥 Zvonda URL: $zvondaUrl');
        return zvondaUrl;
      }
      throw Exception('Failed to get Zvonda URL');
    } on DioException catch (e) {
      print('❌ Get Zvonda URL error: ${e.response?.statusCode}');
      print('❌ Error data: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get Zvonda URL',
      );
    }
  }

  /// Отметить сообщения как прочитанные
  Future<void> markMessagesAsRead(int chatRoomId) async {
    try {
      print('✅ Marking messages as read in chat: $chatRoomId');
      await _dio.put('/api/chats/$chatRoomId/read');
      print('✅ Messages marked as read');
    } on DioException catch (e) {
      print('❌ Mark as read error: ${e.response?.statusCode}');
      print('❌ Error data: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to mark as read');
    }
  }
}
