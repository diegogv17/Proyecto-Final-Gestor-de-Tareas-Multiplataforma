// ============================================================
// AuthProvider: Estado global de autenticación (Riverpod)
// ============================================================
// Riverpod gestiona el estado del usuario autenticado en toda la
// aplicación. AuthNotifier expone métodos para login, registro,
// cierre de sesión y restauración de sesión desde el token local.
// Cualquier widget puede escuchar authStateProvider para reaccionar
// a cambios en la autenticación (ej: redireccionar al login).
// ============================================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/providers/api_provider.dart';
import 'package:flutter_application_1/providers/repositories.dart';

// Provider del repositorio de autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authServiceProvider),
    ref.watch(apiServiceProvider),
  );
});

// Provider del estado de autenticación (UserModel? = null si no ha iniciado sesión)
final authStateProvider =
    NotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);

// Notifier que maneja la lógica de autenticación
class AuthNotifier extends Notifier<UserModel?> {
  late AuthRepository _repository;

  @override
  UserModel? build() {
    _repository = ref.read(authRepositoryProvider);
    return _repository.currentUser;
  }

  // Restaura la sesión al iniciar la app (lee token guardado)
  Future<void> restoreSession() async {
    final user = await _repository.restoreSession();
    state = user;
  }

  // Inicia sesión con email y contraseña
  Future<void> login(String email, String password) async {
    state = await _repository.login(email, password);
  }

  // Registra un nuevo usuario
  Future<void> register(
    String email,
    String password, {
    required String name,
  }) async {
    state = await _repository.register(email, password, name: name);
  }

  // Cierra sesión (elimina token y limpia el estado)
  void logout() {
    _repository.logout();
    state = null;
  }
}
