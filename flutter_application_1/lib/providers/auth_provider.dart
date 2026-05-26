import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/providers/api_provider.dart';
import 'package:flutter_application_1/providers/repositories.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authServiceProvider),
    ref.watch(apiServiceProvider),
  );
});

final authStateProvider =
    NotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);

class AuthNotifier extends Notifier<UserModel?> {
  late AuthRepository _repository;

  @override
  UserModel? build() {
    _repository = ref.read(authRepositoryProvider);
    return _repository.currentUser;
  }

  Future<void> restoreSession() async {
    final user = await _repository.restoreSession();
    state = user;
  }

  Future<void> login(String email, String password) async {
    state = await _repository.login(email, password);
  }

  Future<void> register(
    String email,
    String password, {
    required String name,
  }) async {
    state = await _repository.register(email, password, name: name);
  }

  void logout() {
    _repository.logout();
    state = null;
  }
}
