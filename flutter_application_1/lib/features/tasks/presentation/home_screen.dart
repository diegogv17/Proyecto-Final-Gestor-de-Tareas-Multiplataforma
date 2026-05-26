import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/constants/app_spacing.dart';
import 'package:flutter_application_1/core/utils/app_snackbar.dart';
import 'package:flutter_application_1/core/utils/haptic_utils.dart';
import 'package:flutter_application_1/core/widgets/empty_state.dart';
import 'package:flutter_application_1/core/widgets/skeleton_loader.dart';
import 'package:flutter_application_1/features/tasks/widgets/filter_chips.dart';
import 'package:flutter_application_1/features/tasks/widgets/task_card.dart';
import 'package:flutter_application_1/models/task_enums.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/categories_provider.dart';
import 'package:flutter_application_1/providers/tasks_provider.dart';
import 'package:flutter_application_1/routes/app_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final selectedFilter = ref.watch(taskFilterProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    // Precarga categorías para el formulario de tareas y chips en tarjetas.
    ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              user?.name ?? 'Usuario',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            tooltip: 'Categorías',
            onPressed: () => context.push(AppRoutes.categories),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surface,
              child: Text(
                user?.avatarInitials ?? '?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          FilterChips(
            selected: selectedFilter,
            onSelected: (filter) =>
                ref.read(taskFilterProvider.notifier).setFilter(filter),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: tasksAsync.when(
              loading: () => const SkeletonLoader(),
              error: (_, __) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Error al cargar',
                subtitle: 'Intenta de nuevo más tarde',
                action: TextButton(
                  onPressed: () => ref.read(tasksProvider.notifier).refresh(),
                  child: const Text('Reintentar'),
                ),
              ),
              data: (_) {
                if (filteredTasks.isEmpty) {
                  return EmptyState(
                    icon: Icons.task_alt_outlined,
                    title: 'Sin tareas',
                    subtitle: selectedFilter == TaskFilter.all
                        ? 'Crea tu primera tarea con el botón +'
                        : 'No hay tareas en este filtro',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.textPrimary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async {
                    await HapticUtils.light();
                    await ref.read(tasksProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final category = categoryRepo.getById(task.categoryId);

                      return TaskCard(
                        task: task,
                        category: category,
                        index: index,
                        onTap: () => context.push('/tasks/${task.id}'),
                        onComplete: () async {
                          await ref
                              .read(tasksProvider.notifier)
                              .complete(task.id);
                          if (context.mounted) {
                            AppSnackbar.show(
                              context,
                              message: 'Tarea completada',
                              isSuccess: true,
                            );
                          }
                        },
                        onDelete: () async {
                          await ref
                              .read(tasksProvider.notifier)
                              .delete(task.id);
                          if (context.mounted) {
                            AppSnackbar.show(
                              context,
                              message: 'Tarea eliminada',
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await HapticUtils.medium();
          final categories =
              ref.read(categoriesProvider).value ?? [];
          if (categories.isEmpty && context.mounted) {
            AppSnackbar.show(
              context,
              message:
                  'Crea al menos una categoría antes de añadir tareas',
              isError: true,
            );
            context.push(AppRoutes.categories);
            return;
          }
          if (context.mounted) context.push(AppRoutes.taskCreate);
        },
        child: const Icon(Icons.add_rounded, size: 28),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }
}
