import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../habits/presentation/bloc/habit_bloc.dart';
import '../../../habits/presentation/bloc/habit_event.dart';
import '../../../habits/presentation/bloc/habit_state.dart';

class TodaysHabitsList extends StatefulWidget {
  const TodaysHabitsList({super.key});

  @override
  State<TodaysHabitsList> createState() => _TodaysHabitsListState();
}

class _TodaysHabitsListState extends State<TodaysHabitsList> {
  final Set<String> _togglingHabits = <String>{};

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<HabitBloc, HabitState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        if (_togglingHabits.isNotEmpty) {
          setState(() => _togglingHabits.clear());
        }
      },
      child: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          if (state.status == HabitStatus.loading) {
            return const NeumorphicCard(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.habits.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              ...state.habits.take(3).map((habit) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildHabitItem(context, habit, state),
                  )),
              if (state.habits.length > 3)
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => context.push('/habits'),
                    child: Text(
                      'View all ${state.habits.length} habits',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return NeumorphicCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Bring your habits to life!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Small steps lead to big changes.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          NeumorphicButton(
            onPressed: () => context.push('/habits/add'),
            child: Text(
              'Create My First Habit',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitItem(
      BuildContext context, dynamic habit, HabitState state) {
    final today = DateTime.now();
    final streak = state.habitStreaks[habit.id] ?? 0;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isToggling = _togglingHabits.contains(habit.id);

    dynamic todayEntry;
    try {
      todayEntry = state.habitEntries.firstWhere(
        (entry) =>
            entry.habitId == habit.id &&
            entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day,
      );
    } catch (e) {
      todayEntry = null;
    }

    final isCompleted = todayEntry?.completed ?? false;

    return NeumorphicCard(
      depth: isCompleted ? -2 : 4,
      onTap: () => _toggleCompletion(context, habit.id, today, !isCompleted),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? colorScheme.secondaryContainer.withOpacity(0.24)
                    : colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: isToggling
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    )
                  : Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_off_rounded,
                      color: isCompleted
                          ? colorScheme.secondary
                          : colorScheme.primary,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          size: 14,
                          color: streak > 0
                              ? colorScheme.secondary
                              : colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '$streak day streak',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${habit.category}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCompletion(
      BuildContext context, String habitId, DateTime date, bool completed) {
    debugPrint(
        'Toggle completion triggered: habitId=$habitId, completed=$completed');
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      setState(() => _togglingHabits.add(habitId));
      context.read<HabitBloc>().add(
            ToggleHabitCompletion(
              habitId: habitId,
              date: date,
              completed: completed,
              userId: authState.user!.id,
            ),
          );
    }
  }
}
