import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/core/constants/api_constants.dart';

// ============================================================
// ApiException: Error personalizado para la comunicación HTTP
// ============================================================
class ApiException implements Exception {
  ApiException({required this.message, this.statusCode});

  final String message;    // Mensaje descriptivo del error
  final int? statusCode;   // Código HTTP (401, 500, etc.)

  @override
  String toString() => message;
}

// ============================================================
// ApiService: Capa de comunicación HTTP con el backend
// ============================================================
// Utiliza Dio (cliente HTTP) para realizar peticiones GET, POST,
// PUT y DELETE. También maneja el token JWT de forma automática
// mediante interceptors y FlutterSecureStorage.
// ============================================================
class ApiService {
  ApiService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  late final Dio _dio;                     // Cliente HTTP
  final FlutterSecureStorage _secureStorage; // Almacenamiento seguro para el token
  bool _initialized = false;

  // Inicializa el cliente HTTP con la URL base y los interceptors
  Future<void> initialize() async {
    if (_initialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,              // URL del backend
        connectTimeout: ApiConstants.connectionTimeout, // Timeout de conexión
        receiveTimeout: ApiConstants.receiveTimeout,   // Timeout de recepción
        contentType: Headers.jsonContentType,        // Formato JSON
        headers: {'Accept': 'application/json'},
      ),
    );

    // Interceptor para agregar el token JWT automáticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lee el token almacenado en el dispositivo
          final token = await _secureStorage.read(key: StorageKeys.authToken);
          if (token != null) {
            // Agrega el header Authorization: Bearer <token>
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) => handler.next(error),
      ),
    );

    _initialized = true;
  }

  // Petición GET: obtiene datos del servidor
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Petición POST: envía datos al servidor (crear recursos)
  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Petición PUT: actualiza un recurso existente
  Future<T> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Petición DELETE: elimina un recurso
  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Manejo centralizado de errores HTTP
  ApiException _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(message: 'Tiempo de espera agotado');
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        message:
            'No se pudo conectar al servidor. Verifica que el backend esté activo.',
      );
    }

    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (statusCode == 401) {
        return ApiException(
          message: 'Sesión expirada. Inicia sesión de nuevo.',
          statusCode: 401,
        );
      }

      if (data is Map) {
        final msg = data['error'] ?? data['message'];
        if (msg != null) {
          return ApiException(message: msg.toString(), statusCode: statusCode);
        }
      }

      return ApiException(
        message: 'Error del servidor ($statusCode)',
        statusCode: statusCode,
      );
    }

    return ApiException(message: error.message ?? 'Error desconocido');
  }

  // GESTIÓN DEL TOKEN JWT
  Future<void> setToken(String token) async {
    await _secureStorage.write(key: StorageKeys.authToken, value: token);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: StorageKeys.authToken);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: StorageKeys.authToken);
  }
}
