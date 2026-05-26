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
import 'package:flutter_application_1/features/categories/widgets/category_form_sheet.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/providers/categories_provider.dart';
import 'package:flutter_application_1/services/api_service.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final taskCounts = ref.watch(categoryTaskCountsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Categorías'),
      ),
      body: categoriesAsync.when(
        loading: () => const SkeletonLoader(),
        error: (_, __) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Error al cargar',
          subtitle: 'Verifica la conexión con el backend',
          action: TextButton(
            onPressed: () => ref.read(categoriesProvider.notifier).refresh(),
            child: const Text('Reintentar'),
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return EmptyState(
              icon: Icons.folder_outlined,
              title: 'Sin categorías',
              subtitle: 'Crea tu primera categoría',
              action: TextButton(
                onPressed: () => _showForm(context, ref),
                child: const Text('Crear categoría'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final count = taskCounts[category.id] ?? 0;

              return _CategoryCard(
                category: category,
                taskCount: count,
                index: index,
                onTap: () => _showForm(
                  context,
                  ref,
                  category: category,
                  taskCount: count,
                ),
                onDelete: () => _confirmDelete(
                  context,
                  ref,
                  category: category,
                  taskCount: count,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticUtils.medium();
          _showForm(context, ref);
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showForm(
    BuildContext context,
    WidgetRef ref, {
    CategoryModel? category,
    int taskCount = 0,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CategoryFormSheet(
        category: category,
        taskCount: taskCount,
        onSave: (model) async {
          try {
            if (category != null) {
              await ref.read(categoriesProvider.notifier).updateCategory(model);
              if (context.mounted) {
                Navigator.pop(context);
                AppSnackbar.show(
                  context,
                  message: 'Categoría actualizada',
                  isSuccess: true,
                );
              }
            } else {
              await ref.read(categoriesProvider.notifier).create(model);
              if (context.mounted) {
                Navigator.pop(context);
                AppSnackbar.show(
                  context,
                  message: 'Categoría creada',
                  isSuccess: true,
                );
              }
            }
          } on ApiException catch (e) {
            if (context.mounted) {
              AppSnackbar.show(context, message: e.message, isError: true);
            }
            rethrow;
          }
        },
        onDelete: category == null
            ? null
            : () => _confirmDelete(
                  context,
                  ref,
                  category: category,
                  taskCount: taskCount,
                  closeSheetFirst: true,
                ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref, {
    required CategoryModel category,
    required int taskCount,
    bool closeSheetFirst = false,
  }) async {
    if (taskCount > 0) {
      AppSnackbar.show(
        context,
        message:
            'No se puede eliminar: tiene $taskCount ${taskCount == 1 ? 'tarea' : 'tareas'} asociadas',
        isError: true,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Eliminar "${category.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    if (closeSheetFirst) Navigator.pop(context);

    try {
      await HapticUtils.medium();
      await ref.read(categoriesProvider.notifier).delete(category.id);
      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: 'Categoría eliminada',
          isSuccess: true,
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        AppSnackbar.show(context, message: e.message, isError: true);
      }
    }
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.taskCount,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  final CategoryModel category;
  final int taskCount;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$taskCount ${taskCount == 1 ? 'tarea' : 'tareas'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: taskCount > 0
                    ? AppColors.textSecondary.withValues(alpha: 0.4)
                    : AppColors.danger,
              ),
              tooltip: taskCount > 0
                  ? 'Tiene tareas asociadas'
                  : 'Eliminar categoría',
              onPressed: onDelete,
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
