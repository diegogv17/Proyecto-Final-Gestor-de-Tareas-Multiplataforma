// ============================================================
// Repositories: Capa de caché y lógica de negocio
// ============================================================
// Los repositorios actúan como una capa intermedia entre los
// providers (Riverpod) y los servicios HTTP. Mantienen una
// caché en memoria de los datos para evitar peticiones
// innecesarias al backend y centralizar la lógica de negocio.
// ============================================================
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/models/task_enums.dart';
import 'package:flutter_application_1/models/task_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/category_service.dart';
import 'package:flutter_application_1/services/task_service.dart';

// ============================================================
// AuthRepository: Autenticación con sesión persistente
// ============================================================
class AuthRepository {
  AuthRepository(this._authService, this._apiService);

  final AuthService _authService;
  final ApiService _apiService;

  UserModel? _currentUser; // Usuario en sesión (caché en memoria)

  UserModel? get currentUser => _currentUser;

  // Restaura la sesión desde el token guardado en el dispositivo
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

  // Inicia sesión: guarda el token y el usuario en caché
  Future<UserModel> login(String email, String password) async {
    final result = await _authService.login(email: email, password: password);
    await _apiService.setToken(result.token);
    _currentUser = result.user;
    return _currentUser!;
  }

  // Registra: guarda el token y el usuario en caché
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

  // Cierra sesión: elimina el token y limpia la caché
  Future<void> logout() async {
    await _apiService.clearToken();
    _currentUser = null;
  }
}

// ============================================================
// TaskRepository: Caché de tareas en memoria
// ============================================================
class TaskRepository {
  TaskRepository(this._taskService);

  final TaskService _taskService;
  List<TaskModel> _cache = []; // Caché local de tareas

  List<TaskModel> getAll() => List.unmodifiable(_cache);

  TaskModel? getById(String id) {
    try {
      return _cache.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // Obtiene todas las tareas desde el backend
  Future<void> fetchAll() async {
    _cache = await _taskService.getAll();
  }

  // Obtiene una tarea por ID y actualiza la caché
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

  // Crea una tarea en el backend y la agrega a la caché
  Future<TaskModel> create(TaskModel task) async {
    final created = await _taskService.create(task);
    _cache.insert(0, created); // La nueva tarea va al inicio
    return created;
  }

  // Actualiza una tarea en el backend y en la caché
  Future<TaskModel> update(TaskModel task) async {
    final updated = await _taskService.update(task);
    final index = _cache.indexWhere((t) => t.id == task.id);
    if (index != -1) _cache[index] = updated;
    return updated;
  }

  // Elimina una tarea del backend y de la caché
  Future<void> delete(String id) async {
    await _taskService.delete(id);
    _cache.removeWhere((t) => t.id == id);
  }

  // Marca tarea como completada
  Future<TaskModel> complete(String id) async {
    final task = getById(id);
    if (task == null) throw Exception('Tarea no encontrada');
    return update(task.copyWith(status: TaskStatus.completed));
  }
}

// ============================================================
// CategoryRepository: Caché de categorías en memoria
// ============================================================
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

  // Cuenta cuántas tareas pertenecen a una categoría
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
