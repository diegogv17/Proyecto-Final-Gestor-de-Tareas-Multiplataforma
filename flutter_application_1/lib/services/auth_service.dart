// ============================================================
// AuthService: Servicio de autenticación (Login, Register, Perfil)
// ============================================================
// Esta capa se comunica con el backend para operaciones de auth.
// Cada método llama a la API y transforma la respuesta JSON en
// objetos de Dart (UserModel y token).
// ============================================================
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/core/constants/api_constants.dart';

class AuthService {
  AuthService(this._api);

  final ApiService _api; // Cliente HTTP inyectado

  // Iniciar sesión: POST /api/auth/login
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    return _api.post(
      '${ApiConstants.authPath}/login',
      data: {'email': email, 'password': password},
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return (
          token: map['token'] as String,
          user: UserModel.fromJson(map['user'] as Map<String, dynamic>),
        );
      },
    );
  }

  // Registrar usuario: POST /api/auth/register
  Future<({String token, UserModel user})> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return _api.post(
      '${ApiConstants.authPath}/register',
      data: {'email': email, 'password': password, 'name': name},
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return (
          token: map['token'] as String,
          user: UserModel.fromJson(map['user'] as Map<String, dynamic>),
        );
      },
    );
  }

  // Obtener perfil del usuario autenticado: GET /api/auth/me
  Future<UserModel> getCurrentUser() async {
    return _api.get(
      '${ApiConstants.authPath}/me',
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return UserModel.fromJson(map['user'] as Map<String, dynamic>);
      },
    );
  }
}
