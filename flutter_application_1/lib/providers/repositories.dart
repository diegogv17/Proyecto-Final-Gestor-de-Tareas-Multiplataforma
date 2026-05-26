import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/models/task_enums.dart';
import 'package:flutter_application_1/models/task_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/category_service.dart';
import 'package:flutter_application_1/services/task_service.dart';

class AuthRepository {
  AuthRepository(this._authService, this._apiService);

  final AuthService _authService;
  final ApiService _apiService;

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<UserModel?> restoreSession() async {
    final token = await _apiService.getToken();
    if (token == null) return null;

    try {
      _currentUser = await _authService.getCurrentUser();
      return _currentUser;
    } catch (_) {
      await _apiService.clearToken();
      _currentUser = null;
      return null;
    }
  }

  Future<UserModel> login(String email, String password) async {
    final result = await _authService.login(email: email, password: password);
    await _apiService.setToken(result.token);
    _currentUser = result.user;
    return _currentUser!;
  }

  Future<UserModel> register(
    String email,
    String password, {
    required String name,
  }) async {
    final result = await _authService.register(
      email: email,
      password: password,
      name: name,
    );
    await _apiService.setToken(result.token);
    _currentUser = result.user;
    return _currentUser!;
  }

  Future<void> logout() async {
    await _apiService.clearToken();
    _currentUser = null;
  }
}

class TaskRepository {
  TaskRepository(this._taskService);

  final TaskService _taskService;
  List<TaskModel> _cache = [];

  List<TaskModel> getAll() => List.unmodifiable(_cache);

  TaskModel? getById(String id) {
    try {
      return _cache.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchAll() async {
    _cache = await _taskService.getAll();
  }

  Future<TaskModel?> fetchById(String id) async {
    final task = await _taskService.getById(id);
    final index = _cache.indexWhere((t) => t.id == id);
    if (index >= 0) {
      _cache[index] = task;
    } else {
      _cache.add(task);
    }
    return task;
  }

  Future<TaskModel> create(TaskModel task) async {
    final created = await _taskService.create(task);
    _cache.insert(0, created);
    return created;
  }

  Future<TaskModel> update(TaskModel task) async {
    final updated = await _taskService.update(task);
    final index = _cache.indexWhere((t) => t.id == task.id);
    if (index != -1) _cache[index] = updated;
    return updated;
  }

  Future<void> delete(String id) async {
    await _taskService.delete(id);
    _cache.removeWhere((t) => t.id == id);
  }

  Future<TaskModel> complete(String id) async {
    final task = getById(id);
    if (task == null) throw Exception('Tarea no encontrada');
    return update(task.copyWith(status: TaskStatus.completed));
  }
}

class CategoryRepository {
  CategoryRepository(this._categoryService);

  final CategoryService _categoryService;
  List<CategoryModel> _cache = [];

  List<CategoryModel> getAll() => List.unmodifiable(_cache);

  CategoryModel? getById(String id) {
    try {
      return _cache.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  int taskCount(String categoryId, List<TaskModel> tasks) =>
      tasks.where((t) => t.categoryId == categoryId).length;

  Future<void> fetchAll() async {
    _cache = await _categoryService.getAll();
  }

  Future<CategoryModel> create(CategoryModel category) async {
    final created = await _categoryService.create(category);
    _cache.add(created);
    return created;
  }

  Future<CategoryModel> update(CategoryModel category) async {
    final updated = await _categoryService.update(category);
    final index = _cache.indexWhere((c) => c.id == category.id);
    if (index != -1) _cache[index] = updated;
    return updated;
  }

  Future<void> delete(String id) async {
    await _categoryService.delete(id);
    _cache.removeWhere((c) => c.id == id);
  }
}
