class AppConstants {
  // ВАЖНО: Замените на реальный IP/домен вашего бэкенда
  //static const String baseUrl = 'http://10.0.2.2:8080'; // Android Emulator
  static const String baseUrl = 'http://localhost:8080'; // iOS Simulator
  // static const String baseUrl = 'http://192.168.1.X:8080'; // Real Device

  static const int connectTimeout = 30000; // 30 секунд
  static const int receiveTimeout = 30000;
}

class ApiEndpoints {
  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String sendCode = '/api/auth/send-code';
  static const String verifyCode = '/api/auth/verify-code';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';

  // User
  static const String userMe = '/api/users/me';
  static const String userPassword = '/api/users/me/password';
  static const String userAvatar = '/api/users/me/avatar';
}
