import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../habits/presentation/bloc/habit_bloc.dart';
import '../../../habits/presentation/bloc/habit_state.dart';

class AchievementsPreview extends StatelessWidget {
  const AchievementsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        final achievements = _generateAchievements(state, colorScheme);

        if (achievements.isEmpty) {
          return NeumorphicCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.lock_rounded,
                    size: 24, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Build a 7-day streak to unlock your first achievement!',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: achievements
              .take(2)
              .map((achievement) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAchievementItem(context, achievement),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildAchievementItem(
      BuildContext context, Map<String, dynamic> achievement) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return NeumorphicCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (achievement['color'] as Color)
                    .withAlpha((255 * 0.15).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement['icon'] as IconData,
                color: achievement['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['title'] as String,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement['description'] as String,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateAchievements(
      HabitState state, ColorScheme colorScheme) {
    final achievements = <Map<String, dynamic>>[];

    for (final habit in state.habits) {
      final streak = state.habitStreaks[habit.id] ?? 0;

      if (streak >= 7) {
        achievements.add({
          'title': '7-Day Streak!',
          'description': '${habit.title} - Week warrior',
          'icon': Icons.local_fire_department_rounded,
          'color': colorScheme.secondary,
        });
      }
      if (streak >= 30) {
        achievements.add({
          'title': '30-Day Champion!',
          'description': '${habit.title} - Month master',
          'icon': Icons.star_rounded,
          'color': colorScheme.tertiary,
        });
      }
    }

    return achievements;
  }
}
