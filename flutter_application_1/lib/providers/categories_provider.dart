// ============================================================
// CategoriesProvider: Estado global de las categorías (Riverpod)
// ============================================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/providers/api_provider.dart';
import 'package:flutter_application_1/providers/repositories.dart';
import 'package:flutter_application_1/providers/tasks_provider.dart';

// Provider del repositorio de categorías
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(categoryServiceProvider));
});

// Provider asíncrono de la lista de categorías
final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier,
    List<CategoryModel>>(CategoriesNotifier.new);

// Provider derivado: cuenta cuántas tareas tiene cada categoría
final categoryTaskCountsProvider = Provider<Map<String, int>>((ref) {
  final categories = ref.watch(categoriesProvider).value ?? [];
  final tasks = ref.watch(tasksProvider).value ?? [];
  final repo = ref.read(categoryRepositoryProvider);

  return {
    for (final cat in categories) cat.id: repo.taskCount(cat.id, tasks),
  };
});

class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  late CategoryRepository _repository;

  @override
  Future<List<CategoryModel>> build() async {
    _repository = ref.read(categoryRepositoryProvider);
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

  Future<void> create(CategoryModel category) async {
    await _mutate(() async {
      await _repository.create(category);
    });
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _mutate(() async {
      await _repository.update(category);
    });
  }

  Future<void> delete(String id) async {
    await _mutate(() async {
      await _repository.delete(id);
    });
  }

  // Mutación segura: guarda estado anterior, ejecuta, y refresca
  Future<void> _mutate(Future<void> Function() action) async {
    final previous = state;
    try {
      await action();
      await _repository.fetchAll();
      state = AsyncValue.data(_repository.getAll());
    } catch (e, st) {
      state = previous.hasValue
          ? previous
          : await AsyncValue.guard(() async {
              await _repository.fetchAll();
              return _repository.getAll();
            });
      Error.throwWithStackTrace(e, st);
    }
  }
}
