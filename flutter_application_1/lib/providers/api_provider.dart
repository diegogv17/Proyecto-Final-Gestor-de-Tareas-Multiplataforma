import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/category_service.dart';
import 'package:flutter_application_1/services/task_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  throw StateError('ApiService no inicializado. Usa override en main().');
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiServiceProvider));
});

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.watch(apiServiceProvider));
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.watch(apiServiceProvider));
});
