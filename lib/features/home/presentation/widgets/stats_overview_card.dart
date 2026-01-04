import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../habits/presentation/bloc/habit_bloc.dart';
import '../../../habits/presentation/bloc/habit_state.dart';
import '../../../../core/theme/app_theme.dart';

class StatsOverviewCard extends StatelessWidget {
  const StatsOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors =
        Theme.of(context).extension<StatusColors>() ?? StatusColors.light;

    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        final habitIds = state.habits.map((habit) => habit.id).toSet();
        final totalHabits = habitIds.length;
        final totalStreaks =
            state.habitStreaks.values.fold(0, (sum, streak) => sum + streak);
        final averageStreak =
            totalHabits > 0 ? (totalStreaks / totalHabits).round() : 0;

        final today = DateTime.now();
        final todayEntries = state.habitEntries.where((entry) =>
            habitIds.contains(entry.habitId) &&
            entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day);
        final completedToday =
            todayEntries.where((entry) => entry.completed).length;

        return NeumorphicCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem(context, 'Total Habits', totalHabits.toString(),
                  Icons.track_changes_rounded, colorScheme.primary),
              const SizedBox(height: 16),
              _buildStatItem(
                  context,
                  'Completed Today',
                  '$completedToday/$totalHabits',
                  Icons.check_circle_rounded,
                  statusColors.success),
              const SizedBox(height: 16),
              _buildStatItem(context, 'Average Streak', '$averageStreak days',
                  Icons.trending_up_rounded, statusColors.warning),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: NeumorphicButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: () => context.push('/analytics'),
                  child: Text(
                    'Full Analytics',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color iconColor) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
