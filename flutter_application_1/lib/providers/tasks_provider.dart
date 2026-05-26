import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/task_enums.dart';
import 'package:flutter_application_1/models/task_model.dart';
import 'package:flutter_application_1/providers/api_provider.dart';
import 'package:flutter_application_1/providers/repositories.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(taskServiceProvider));
});

final taskFilterProvider =
    NotifierProvider<TaskFilterNotifier, TaskFilter>(TaskFilterNotifier.new);

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.all;

  void setFilter(TaskFilter filter) => state = filter;
}

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final filter = ref.watch(taskFilterProvider);

  return switch (filter) {
    TaskFilter.all => tasks,
    TaskFilter.pending =>
      tasks.where((t) => t.status == TaskStatus.pending).toList(),
    TaskFilter.inProgress =>
      tasks.where((t) => t.status == TaskStatus.inProgress).toList(),
    TaskFilter.completed =>
      tasks.where((t) => t.status == TaskStatus.completed).toList(),
  };
});

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  late TaskRepository _repository;

  @override
  Future<List<TaskModel>> build() async {
    _repository = ref.read(taskRepositoryProvider);
    await _repository.fetchAll();
    return _repository.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.fetchAll();
      return _repository.getAll();
    });
  }

  Future<void> create(TaskModel task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.create(task);
      return _repository.getAll();
    });
  }

  Future<void> updateTask(TaskModel task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.update(task);
      return _repository.getAll();
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(id);
      return _repository.getAll();
    });
  }

  Future<void> complete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.complete(id);
      return _repository.getAll();
    });
  }
}
