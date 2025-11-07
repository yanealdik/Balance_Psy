import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _emailKey = 'user_email';

  // Сохранить токен
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Получить токен
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Удалить токен
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Сохранить email
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  // Получить email
  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  // Очистить всё
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Проверить наличие токена
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
