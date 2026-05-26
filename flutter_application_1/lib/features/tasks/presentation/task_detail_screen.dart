import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/constants/app_spacing.dart';
import 'package:flutter_application_1/core/utils/app_snackbar.dart';
import 'package:flutter_application_1/core/utils/haptic_utils.dart';
import 'package:flutter_application_1/core/widgets/app_primary_button.dart';
import 'package:flutter_application_1/models/task_enums.dart';
import 'package:flutter_application_1/providers/categories_provider.dart';
import 'package:flutter_application_1/providers/tasks_provider.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  Color _priorityColor(TaskPriority priority) => switch (priority) {
        TaskPriority.low => AppColors.priorityLow,
        TaskPriority.medium => AppColors.priorityMedium,
        TaskPriority.high => AppColors.priorityHigh,
        TaskPriority.urgent => AppColors.priorityUrgent,
      };

  Color _statusColor(TaskStatus status) => switch (status) {
        TaskStatus.pending => AppColors.textSecondary,
        TaskStatus.inProgress => AppColors.warning,
        TaskStatus.completed => AppColors.success,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.read(taskRepositoryProvider).getById(taskId);
    final category = task != null
        ? ref.read(categoryRepositoryProvider).getById(task.categoryId)
        : null;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Tarea no encontrada')),
      );
    }

    final dateFormat = DateFormat('d MMMM yyyy', 'es');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/tasks/$taskId/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: AppSpacing.xl),
            _DetailRow(
              icon: Icons.flag_outlined,
              label: 'Prioridad',
              child: _Badge(
                label: task.priority.label,
                color: _priorityColor(task.priority),
              ),
            ),
            _DetailRow(
              icon: Icons.circle_outlined,
              label: 'Estado',
              child: _Badge(
                label: task.status.label,
                color: _statusColor(task.status),
              ),
            ),
            if (category != null)
              _DetailRow(
                icon: Icons.folder_outlined,
                label: 'Categoría',
                child: Row(
                  children: [
                    Icon(category.icon, size: 18, color: category.color),
                    const SizedBox(width: AppSpacing.sm),
                    Text(category.name),
                  ],
                ),
              ),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha límite',
              child: Text(dateFormat.format(task.dueDate)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                task.description.isEmpty ? 'Sin descripción' : task.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: task.description.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      height: 1.6,
                    ),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.xxxl),
            if (task.status != TaskStatus.completed)
              AppPrimaryButton(
                label: 'Completar tarea',
                onPressed: () async {
                  await HapticUtils.success();
                  await ref.read(tasksProvider.notifier).complete(taskId);
                  if (context.mounted) {
                    AppSnackbar.show(
                      context,
                      message: 'Tarea completada',
                      isSuccess: true,
                    );
                    context.pop();
                  }
                },
              ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text('Eliminar tarea'),
                      content:
                          const Text('¿Estás seguro de eliminar esta tarea?'),
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
                  if (confirm == true && context.mounted) {
                    await HapticUtils.heavy();
                    await ref.read(tasksProvider.notifier).delete(taskId);
                    if (context.mounted) {
                      AppSnackbar.show(context, message: 'Tarea eliminada');
                      context.pop();
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger),
                label: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.danger),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
