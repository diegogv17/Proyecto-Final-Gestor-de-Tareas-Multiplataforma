// ============================================================
// Proveedores de servicios (Riverpod)
// ============================================================
// Riverpod es el manejador de estado de la aplicación.
// Estos "providers" son fábricas de singletons que inyectan
// las dependencias (ApiService, AuthService, etc.) donde se
// necesiten, siguiendo el patrón de Inyección de Dependencias.
// ============================================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/category_service.dart';
import 'package:flutter_application_1/services/task_service.dart';

// Provider del cliente HTTP (se inicializa en main.dart con override)
final apiServiceProvider = Provider<ApiService>((ref) {
  throw StateError('ApiService no inicializado. Usa override en main().');
});

// Provider del servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiServiceProvider));
});

// Provider del servicio de tareas
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.watch(apiServiceProvider));
});

// Provider del servicio de categorías
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.watch(apiServiceProvider));
});
