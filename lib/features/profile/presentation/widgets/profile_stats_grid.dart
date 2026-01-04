import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../habits/presentation/bloc/habit_bloc.dart';
import '../../../habits/presentation/bloc/habit_state.dart';

class ProfileStatsGrid extends StatelessWidget {
  const ProfileStatsGrid({super.key});

  int _calculateAchievements(HabitState state) {
    int count = 0;

    // Check for streak achievements
    state.habitStreaks.forEach((habitId, streak) {
      if (streak >= 7) count++; // 7-Day Streak
      if (streak >= 30) count++; // 30-Day Champion
      if (streak >= 100) count++; // 100-Day Legend
    });

    // Check for completion achievements
    final totalHabits = state.habits.length;
    if (totalHabits >= 5) count++; // Habit Collector
    if (totalHabits >= 10) count++; // Habit Enthusiast
    if (totalHabits >= 20) count++; // Habit Master

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final statusColors =
            Theme.of(context).extension<StatusColors>() ?? StatusColors.light;
        final totalHabits = state.habits.length;
        final totalStreaks =
            state.habitStreaks.values.fold(0, (sum, streak) => sum + streak);
        final longestStreak = state.habitStreaks.values.isEmpty
            ? 0
            : state.habitStreaks.values.reduce((a, b) => a > b ? a : b);
        final averageStreak =
            totalHabits > 0 ? (totalStreaks / totalHabits).round() : 0;
        final achievementsCount = _calculateAchievements(state);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildStatCard(context, 'Total Habits', totalHabits.toString(),
                Icons.track_changes_rounded, colorScheme.primary, null),
            _buildStatCard(
                context,
                'Longest Streak',
                '$longestStreak Days',
                Icons.local_fire_department_rounded,
                statusColors.warning,
                null),
            _buildStatCard(context, 'Avg. Streak', '$averageStreak Days',
                Icons.trending_up_rounded, statusColors.success, null),
            _buildStatCard(
                context,
                'Achievements',
                '$achievementsCount Unlocked',
                Icons.emoji_events_rounded,
                colorScheme.secondary,
                () => _showAchievementsDialog(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color, VoidCallback? onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return NeumorphicCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementsDialog(BuildContext context, HabitState state) {
    final achievements = _generateAchievements(context, state);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Achievements',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (achievements.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Complete habits to unlock achievements!',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...achievements.map((achievement) => _buildAchievementItem(
                      context,
                      achievement['title']!,
                      achievement['description']!,
                      achievement['icon']! as IconData,
                      achievement['color']! as Color,
                      achievement['unlocked']! as bool,
                      achievement['progress']! as double,
                      achievement['current']! as int,
                      achievement['target']! as int,
                    )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateAchievements(
      BuildContext context, HabitState state) {
    final List<Map<String, dynamic>> achievements = [];

    // Streak achievements with progress
    final streakAchievements = [
      {'threshold': 7, 'title': '7-Day Streak', 'color': Colors.orange},
      {'threshold': 30, 'title': '30-Day Champion', 'color': Colors.amber},
      {'threshold': 100, 'title': '100-Day Legend', 'color': Colors.deepPurple},
    ];

    // Find max streak for progress tracking
    final maxStreak = state.habitStreaks.values.isEmpty
        ? 0
        : state.habitStreaks.values.reduce((a, b) => a > b ? a : b);

    for (var achievement in streakAchievements) {
      final threshold = achievement['threshold'] as int;
      final unlockedHabits = state.habitStreaks.entries
          .where((entry) => entry.value >= threshold)
          .toList();

      if (unlockedHabits.isNotEmpty) {
        // Achievement unlocked - show all unlocked habits
        for (var entry in unlockedHabits) {
          try {
            final habit = state.habits.firstWhere((h) => h.id == entry.key);
            achievements.add({
              'title': achievement['title'],
              'description': '${habit.title} - ${entry.value} days',
              'icon': Icons.local_fire_department,
              'color': achievement['color'],
              'unlocked': true,
              'progress': 1.0,
              'current': entry.value,
              'target': threshold,
            });
          } catch (e) {
            // Habit not found
          }
        }
      } else {
        // Show progress towards this achievement
        achievements.add({
          'title': achievement['title'],
          'description': 'Reach $threshold days streak',
          'icon': Icons.local_fire_department,
          'color': achievement['color'],
          'unlocked': false,
          'progress': maxStreak / threshold,
          'current': maxStreak,
          'target': threshold,
        });
      }
    }

    // Habit count achievements with progress
    final totalHabits = state.habits.length;
    final habitAchievements = [
      {'threshold': 5, 'title': 'Habit Collector', 'desc': 'Create 5 habits'},
      {
        'threshold': 10,
        'title': 'Habit Enthusiast',
        'desc': 'Create 10 habits'
      },
      {'threshold': 20, 'title': 'Habit Master', 'desc': 'Create 20 habits'},
    ];

    for (var achievement in habitAchievements) {
      final threshold = achievement['threshold'] as int;
      final unlocked = totalHabits >= threshold;
      achievements.add({
        'title': achievement['title'],
        'description': achievement['desc'],
        'icon': Icons.collections,
        'color': Theme.of(context).colorScheme.primary,
        'unlocked': unlocked,
        'progress': (totalHabits / threshold).clamp(0.0, 1.0),
        'current': totalHabits,
        'target': threshold,
      });
    }

    return achievements;
  }

  Widget _buildAchievementItem(
      BuildContext context,
      String title,
      String description,
      IconData icon,
      Color color,
      bool unlocked,
      double progress,
      int current,
      int target) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unlocked
              ? color.withOpacity(0.1)
              : colorScheme.onSurfaceVariant.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unlocked
                ? color.withOpacity(0.3)
                : colorScheme.onSurfaceVariant.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? color.withOpacity(0.2)
                        : colorScheme.onSurfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: unlocked ? color : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: unlocked
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: textTheme.bodySmall?.copyWith(
                          color: unlocked
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (unlocked)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
            if (!unlocked) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor:
                      colorScheme.onSurfaceVariant.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$current / $target',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
