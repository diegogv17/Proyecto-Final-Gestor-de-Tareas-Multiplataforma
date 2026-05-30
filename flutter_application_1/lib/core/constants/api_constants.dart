// ============================================================
// ApiConstants: Configuración de la conexión al backend
// ============================================================
// Define la URL base del servidor y las rutas de cada recurso.
// También establece los tiempos de espera para las peticiones HTTP.
// ============================================================
class ApiConstants {
  // 10.0.2.2 es la IP del host local desde el emulador de Android
  // El puerto 5100 debe coincidir con el puerto del backend en .env
  static const String baseUrl = 'http://10.0.2.2:5100/api';

  // Rutas de la API (deben coincidir con las rutas del backend)
  static const String authPath = '/auth';         // Autenticación
  static const String tasksPath = '/tasks';         // Tareas
  static const String categoriesPath = '/categories'; // Categorías

  // Tiempo máximo de espera para conectar y recibir datos
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

// StorageKeys: Claves para almacenamiento seguro local
class StorageKeys {
  // Clave para guardar el token JWT en el dispositivo
  static const String authToken = 'auth_token';
}
