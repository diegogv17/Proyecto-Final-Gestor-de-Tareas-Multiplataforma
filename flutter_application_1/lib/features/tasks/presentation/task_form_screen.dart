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
import 'package:flutter_application_1/core/widgets/app_text_field.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/models/task_enums.dart';
import 'package:flutter_application_1/models/task_model.dart';
import 'package:flutter_application_1/providers/categories_provider.dart';
import 'package:flutter_application_1/providers/tasks_provider.dart';
import 'package:flutter_application_1/routes/app_router.dart';
import 'package:uuid/uuid.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  final String? taskId;

  bool get isEditing => taskId != null;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  TaskStatus _status = TaskStatus.pending;
  TaskPriority _priority = TaskPriority.medium;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  String? _categoryId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTask());
    }
  }

  Future<void> _loadTask() async {
    final cached = ref.read(taskRepositoryProvider).getById(widget.taskId!);
    final task = cached ??
        await ref.read(taskRepositoryProvider).fetchById(widget.taskId!);
    if (task == null || !mounted) return;

    _titleController.text = task.title;
    _descriptionController.text = task.description;
    setState(() {
      _status = task.status;
      _priority = task.priority;
      _dueDate = task.dueDate;
      _categoryId = task.categoryId;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    await HapticUtils.selection();
    if (!mounted) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.textPrimary,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      AppSnackbar.show(context,
          message: 'Selecciona una categoría', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    await HapticUtils.light();

    final task = TaskModel(
      id: widget.taskId ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _status,
      priority: _priority,
      categoryId: _categoryId!,
      dueDate: _dueDate,
      createdAt: widget.isEditing
          ? ref.read(taskRepositoryProvider).getById(widget.taskId!)!.createdAt
          : DateTime.now(),
    );

    try {
      if (widget.isEditing) {
        await ref.read(tasksProvider.notifier).updateTask(task);
      } else {
        await ref.read(tasksProvider.notifier).create(task);
      }
      if (mounted) {
        AppSnackbar.show(
          context,
          message: widget.isEditing ? 'Tarea actualizada' : 'Tarea creada',
          isSuccess: true,
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _ensureDefaultCategory(List<CategoryModel> categories) {
    if (_categoryId != null || categories.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _categoryId == null) {
        setState(() => _categoryId = categories.first.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.value ?? [];
    _ensureDefaultCategory(categories);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isEditing ? 'Editar tarea' : 'Nueva tarea'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxxl,
          ),
          children: [
            AppTextField(
              label: 'Título',
              controller: _titleController,
              placeholder: 'Nombre de la tarea',
              icon: Icons.title_rounded,
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              textInputAction: TextInputAction.next,
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Descripción',
              controller: _descriptionController,
              placeholder: 'Detalles de la tarea...',
              icon: Icons.notes_rounded,
              maxLines: 4,
            ).animate().fadeIn(delay: 50.ms),
            const SizedBox(height: AppSpacing.lg),
            _DropdownField<TaskStatus>(
              label: 'Estado',
              value: _status,
              items: TaskStatus.values,
              labelBuilder: (s) => s.label,
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DropdownField<TaskPriority>(
              label: 'Prioridad',
              value: _priority,
              items: TaskPriority.values,
              labelBuilder: (p) => p.label,
              onChanged: (v) => setState(() => _priority = v!),
            ),
            const SizedBox(height: AppSpacing.lg),
            categoriesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => _CategoryEmptyHint(
                message: 'No se pudieron cargar las categorías',
                onRetry: () =>
                    ref.read(categoriesProvider.notifier).refresh(),
              ),
              data: (_) => _CategorySelector(
                categories: categories,
                selectedId: _categoryId,
                onSelected: (id) => setState(() => _categoryId = id),
                onCreateCategory: () => context.push(AppRoutes.categories),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DateField(
              label: 'Fecha límite',
              date: _dueDate,
              onTap: _pickDate,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            AppPrimaryButton(
              label: widget.isEditing ? 'Guardar cambios' : 'Crear tarea',
              state: _isSaving ? AppButtonState.loading : AppButtonState.idle,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(labelBuilder(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          dropdownColor: AppColors.surface,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.tune_rounded, size: 20),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('d MMMM yyyy', 'es');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(format.format(date)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryEmptyHint extends StatelessWidget {
  const _CategoryEmptyHint({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    required this.onCreateCategory,
  });

  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final VoidCallback onCreateCategory;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categoría *',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CategoryEmptyHint(
            message:
                'Cada tarea debe tener una categoría. Crea al menos una antes de continuar.',
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onCreateCategory,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Ir a categorías'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría *',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Selecciona la categoría de esta tarea',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: categories.map((cat) {
            final isSelected = cat.id == selectedId;
            return GestureDetector(
              onTap: () => onSelected(cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cat.color.withValues(alpha: 0.2)
                      : AppColors.chipInactive,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? cat.color : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 16, color: cat.color),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      cat.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? cat.color
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
