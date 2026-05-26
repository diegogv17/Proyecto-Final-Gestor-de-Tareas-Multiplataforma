class ApiConstants {
  /// Android emulator: http://10.0.2.2:3000/api
  /// Dispositivo físico: IP de tu PC, ej. http://192.168.1.100:3000/api
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String authPath = '/auth';
  static const String tasksPath = '/tasks';
  static const String categoriesPath = '/categories';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

class StorageKeys {
  static const String authToken = 'auth_token';
}
