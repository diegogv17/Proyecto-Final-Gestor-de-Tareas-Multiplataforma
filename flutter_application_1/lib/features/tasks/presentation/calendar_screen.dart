import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/constants/app_spacing.dart';
import 'package:flutter_application_1/models/task_model.dart';
import 'package:flutter_application_1/providers/tasks_provider.dart';
import 'package:flutter_application_1/features/tasks/widgets/task_card.dart';
import 'package:flutter_application_1/providers/categories_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);

    final tasks = tasksAsync.value ?? [];
    final events = _groupTasksByDay(tasks);

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) => setState(() => _calendarFormat = format),
          onDaySelected: (selected, focused) =>
              setState(() { _selectedDay = selected; _focusedDay = focused; }),
          onPageChanged: (focused) => _focusedDay = focused,
          eventLoader: (day) => events[day] ?? [],
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            leftChevronIcon: Icon(Icons.chevron_left,
                color: Theme.of(context).colorScheme.onSurface),
            rightChevronIcon: Icon(Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface),
            titleTextStyle: Theme.of(context).textTheme.titleMedium!,
            formatButtonTextStyle:
                Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
            formatButtonDecoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle:
                const TextStyle(color: AppColors.background, fontWeight: FontWeight.w700),
            todayDecoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            defaultTextStyle:
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ) ?? const TextStyle(),
            weekendTextStyle:
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ) ?? const TextStyle(),
            outsideTextStyle:
                Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3),
                    ) ?? const TextStyle(),
            markerDecoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;
              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    events.length > 3 ? 3 : events.length,
                    (i) => Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildDayTasks(tasks, categoryRepo),
        ),
      ],
    );
  }

  Map<DateTime, List<TaskModel>> _groupTasksByDay(List<TaskModel> tasks) {
    final map = <DateTime, List<TaskModel>>{};
    for (final task in tasks) {
      final day = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      map.putIfAbsent(day, () => []).add(task);
    }
    return map;
  }

  Widget _buildDayTasks(List<TaskModel> tasks, categoryRepo) {
    final dayTasks = _groupTasksByDay(tasks)[
            DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] ??
        [];

    if (dayTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined,
                size: 48,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin tareas para este día',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: dayTasks.length,
      itemBuilder: (context, index) {
        final task = dayTasks[index];
        final category = categoryRepo.getById(task.categoryId);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: TaskCard(
            task: task,
            category: category,
            index: index,
            onTap: () {},
            onComplete: () {},
            onDelete: () {},
          ),
        );
      },
    );
  }
}
