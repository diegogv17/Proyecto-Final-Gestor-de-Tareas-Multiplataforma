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
import 'package:flutter_application_1/features/tasks/presentation/calendar_screen.dart';
import 'package:flutter_application_1/features/tasks/widgets/filter_chips.dart';
import 'package:flutter_application_1/features/tasks/widgets/task_card.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/task_enums.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/categories_provider.dart';
import 'package:flutter_application_1/providers/tasks_provider.dart';
import 'package:flutter_application_1/routes/app_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0;
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final selectedFilter = ref.watch(taskFilterProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Buscar tareas...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).update(value),
              )
            : Column(
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
            icon: Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded),
            tooltip: _showSearch ? 'Cerrar búsqueda' : 'Buscar',
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).update('');
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Cambiar tema',
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            tooltip: 'Categorías',
            onPressed: () => context.push(AppRoutes.categories),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                side: BorderSide(color: AppColors.border),
              ),
              color: AppColors.surface,
              onSelected: (value) async {
                if (value == 'logout') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content:
                          const Text('¿Estás seguro de que quieres cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            'Cerrar sesión',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.auth);
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'profile',
                  enabled: false,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.background,
                        child: Text(
                          user?.avatarInitials ?? '?',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Usuario',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
                      SizedBox(width: AppSpacing.sm),
                      Text('Cerrar sesión',
                          style: TextStyle(color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
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
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildTaskList(
            context,
            tasksAsync,
            filteredTasks,
            selectedFilter,
            categoryRepo,
          ),
          const CalendarScreen(),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton(
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
            ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack)
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (index) =>
            setState(() => _currentTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task_alt_rounded),
            label: 'Tareas',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendario',
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    AsyncValue<List> tasksAsync,
    List filteredTasks,
    TaskFilter selectedFilter,
    categoryRepo,
  ) {
    return Column(
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
                onPressed: () =>
                    ref.read(tasksProvider.notifier).refresh(),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final category =
                        categoryRepo.getById(task.categoryId);

                    return TaskCard(
                      task: task,
                      category: category,
                      index: index,
                      onTap: () =>
                          context.push('/tasks/${task.id}'),
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
    );
  }
}
