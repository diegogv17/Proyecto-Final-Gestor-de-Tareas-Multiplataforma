import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/constants/app_spacing.dart';
import 'package:flutter_application_1/core/utils/haptic_utils.dart';
import 'package:flutter_application_1/core/widgets/app_primary_button.dart';
import 'package:flutter_application_1/core/widgets/app_text_field.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:uuid/uuid.dart';

class CategoryFormSheet extends StatefulWidget {
  const CategoryFormSheet({
    super.key,
    this.category,
    this.taskCount = 0,
    required this.onSave,
    this.onDelete,
  });

  final CategoryModel? category;
  final int taskCount;
  final Future<void> Function(CategoryModel) onSave;
  final VoidCallback? onDelete;

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late Color _selectedColor;
  late IconData _selectedIcon;
  bool _isSaving = false;

  static const _colors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF84CC16),
  ];

  static const _icons = [
    Icons.code_rounded,
    Icons.palette_outlined,
    Icons.trending_up_rounded,
    Icons.person_outline_rounded,
    Icons.work_outline_rounded,
    Icons.school_outlined,
    Icons.fitness_center_outlined,
    Icons.shopping_bag_outlined,
    Icons.home_outlined,
    Icons.lightbulb_outline_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.category?.name ?? '';
    _selectedColor = widget.category?.color ?? _colors.first;
    _selectedIcon = widget.category?.icon ?? _icons.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    await HapticUtils.light();

    final model = CategoryModel(
      id: widget.category?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon,
    );

    try {
      await widget.onSave(model);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xxxl),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  widget.category != null ? 'Editar categoría' : 'Nueva categoría',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Nombre',
                  controller: _nameController,
                  placeholder: 'Nombre de la categoría',
                  icon: Icons.label_outline_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: _colors.map((color) {
                    final isSelected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () async {
                        await HapticUtils.selection();
                        setState(() => _selectedColor = color);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppColors.textPrimary, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Icono',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _icons.map((icon) {
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () async {
                        await HapticUtils.selection();
                        setState(() => _selectedIcon = icon);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: 0.2)
                              : AppColors.chipInactive,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(
                            color: isSelected ? _selectedColor : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 20,
                          color: isSelected ? _selectedColor : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                AppPrimaryButton(
                  label: widget.category != null ? 'Guardar' : 'Crear categoría',
                  state: _isSaving ? AppButtonState.loading : AppButtonState.idle,
                  onPressed: _save,
                ),
                if (widget.category != null && widget.onDelete != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : widget.onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: widget.taskCount > 0
                            ? AppColors.textSecondary
                            : AppColors.danger,
                      ),
                      label: Text(
                        widget.taskCount > 0
                            ? 'No se puede eliminar (tiene tareas)'
                            : 'Eliminar categoría',
                        style: TextStyle(
                          color: widget.taskCount > 0
                              ? AppColors.textSecondary
                              : AppColors.danger,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: widget.taskCount > 0
                              ? AppColors.border
                              : AppColors.danger.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
