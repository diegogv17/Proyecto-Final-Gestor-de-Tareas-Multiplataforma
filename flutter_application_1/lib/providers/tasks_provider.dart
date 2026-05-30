// ============================================================
// TasksProvider: Estado global de las tareas (Riverpod)
// ============================================================
// Gestiona la lista de tareas, el filtro activo y la búsqueda.
// filteredTasksProvider combina filtro + búsqueda en tiempo real.
// TasksNotifier maneja operaciones CRUD usando AsyncNotifier para
// estados de carga/error/datos de forma reactiva.
// ============================================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/task_enums.dart';
import 'package:flutter_application_1/models/task_model.dart';
import 'package:flutter_application_1/providers/api_provider.dart';
import 'package:flutter_application_1/providers/repositories.dart';

// Provider del repositorio de tareas
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(taskServiceProvider));
});

// Provider del filtro de tareas (Todas, Pendientes, En progreso, Completadas)
final taskFilterProvider =
    NotifierProvider<TaskFilterNotifier, TaskFilter>(TaskFilterNotifier.new);

// Provider del texto de búsqueda (para el buscador en tiempo real)
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.all;

  void setFilter(TaskFilter filter) => state = filter;
}

// Provider asíncrono que obtiene las tareas desde el backend
final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);

// Provider derivado: combina filtro + búsqueda de texto
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final filter = ref.watch(taskFilterProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  // Aplica filtro por estado
  var result = switch (filter) {
    TaskFilter.all => tasks,
    TaskFilter.pending =>
      tasks.where((t) => t.status == TaskStatus.pending).toList(),
    TaskFilter.inProgress =>
      tasks.where((t) => t.status == TaskStatus.inProgress).toList(),
    TaskFilter.completed =>
      tasks.where((t) => t.status == TaskStatus.completed).toList(),
  };

  // Aplica filtro por texto (título o descripción)
  if (query.isNotEmpty) {
    result = result
        .where((t) =>
            t.title.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query))
        .toList();
  }

  return result;
});

// AsyncNotifier que maneja el estado de carga/error/datos de las tareas
class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  late TaskRepository _repository;

  @override
  Future<List<TaskModel>> build() async {
    _repository = ref.read(taskRepositoryProvider);
    await _repository.fetchAll();
    return _repository.getAll();
  }

  // Refresca la lista desde el backend
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.fetchAll();
      return _repository.getAll();
    });
  }

  // Crea una nueva tarea
  Future<void> create(TaskModel task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.create(task);
      return _repository.getAll();
    });
  }

  // Actualiza una tarea existente
  Future<void> updateTask(TaskModel task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.update(task);
      return _repository.getAll();
    });
  }

  // Elimina una tarea
  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(id);
      return _repository.getAll();
    });
  }

  // Marca tarea como completada
  Future<void> complete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.complete(id);
      return _repository.getAll();
    });
  }
}
