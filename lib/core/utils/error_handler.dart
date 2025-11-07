
class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }
    
    final message = error.toString();
    
    // Remove "Exception: " prefix
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }
    
    // Network errors
    if (message.contains('SocketException') || 
        message.contains('Failed host lookup')) {
      return 'Нет подключения к интернету';
    }
    
    if (message.contains('Connection timeout')) {
      return 'Время ожидания истекло';
    }
    
    return 'Произошла ошибка. Попробуйте позже';
  }
}