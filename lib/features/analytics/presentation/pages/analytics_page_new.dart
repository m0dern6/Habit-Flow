import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../habits/presentation/bloc/habit_bloc.dart';
import '../../../habits/presentation/bloc/habit_event.dart';
import '../../../habits/presentation/bloc/habit_state.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedPeriod = 'This Week';
  final List<String> _periods = [
    'This Week',
    'This Month',
    'This Year',
    'All Time'
  ];

  @override
  void initState() {
    super.initState();
    // Load entries for the initial period
    _loadEntriesForPeriod();
  }

  void _loadEntriesForPeriod() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user == null) {
      print('⚠️ Cannot load entries - user is null');
      return;
    }

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final todayEndOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Determine date range based on selected period
    DateTime startDate;
    switch (_selectedPeriod) {
      case 'This Week':
        // Start from Sunday of current week
        final daysFromSunday =
            todayMidnight.weekday % 7; // 0 = Sunday, 1 = Monday, etc.
        startDate = todayMidnight.subtract(Duration(days: daysFromSunday));
        break;
      case 'This Month':
        startDate = DateTime(todayMidnight.year, todayMidnight.month, 1);
        break;
      case 'This Year':
        startDate = DateTime(todayMidnight.year, 1, 1);
        break;
      case 'All Time':
      default:
        // Load last 365 days for "All Time" to keep it reasonable
        startDate = todayMidnight.subtract(const Duration(days: 365));
        break;
    }

    print('🔄 Loading entries for period: $_selectedPeriod');
    print('Date range: $startDate to $todayEndOfDay');
    print('User ID: ${authState.user!.id}');

    // Load entries for all user habits in this period
    context.read<HabitBloc>().add(LoadUserHabitEntries(
          userId: authState.user!.id,
          startDate: startDate,
          endDate: todayEndOfDay,
        ));
  }

  /// Calculate expected vs completed check-ins for active habits in the selected period
  (int expectedCheckIns, int completedCheckIns) _calculateCompletionStats(
      HabitState state) {
    final now = DateTime.now();
    // Set today to end of day to include all entries created today
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final todayMidnight = DateTime(now.year, now.month, now.day);

    print('═══════════════════════════════════════════════════════');
    print('ANALYTICS CALCULATION - Period: $_selectedPeriod');
    print('Today: $todayMidnight (end: $today)');
    print('Total habits: ${state.habits.length}');
    print('Total entries loaded: ${state.habitEntries.length}');

    // Determine the date range based on selected period
    DateTime startDate;
    switch (_selectedPeriod) {
      case 'This Week':
        // Start from Sunday of current week
        final daysFromSunday =
            todayMidnight.weekday % 7; // 0 = Sunday, 1 = Monday, etc.
        startDate = todayMidnight.subtract(Duration(days: daysFromSunday));
        break;
      case 'This Month':
        startDate = DateTime(todayMidnight.year, todayMidnight.month, 1);
        break;
      case 'This Year':
        startDate = DateTime(todayMidnight.year, 1, 1);
        break;
      case 'All Time':
      default:
        // For "All Time", use the earliest habit creation date or a reasonable default
        if (state.habits.isEmpty) {
          startDate = todayMidnight;
        } else {
          startDate = state.habits
              .map((h) => h.createdAt)
              .reduce((a, b) => a.isBefore(b) ? a : b);
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
        }
        break;
    }

    print('Date range: $startDate to $todayMidnight');
    print('Days in period: ${todayMidnight.difference(startDate).inDays + 1}');

    int expectedCheckIns = 0;
    int completedCheckIns = 0;

    // For each active habit, calculate expected check-ins
    for (final habit in state.habits) {
      print('\n--- Habit: ${habit.title} ---');
      print('Active: ${habit.isActive}');

      if (!habit.isActive) {
        print('Skipping inactive habit');
        continue;
      }

      // Determine the habit's start date (when it was created or the period start, whichever is later)
      final habitStartDate = DateTime(
        habit.createdAt.year,
        habit.createdAt.month,
        habit.createdAt.day,
      );
      final effectiveStartDate =
          habitStartDate.isAfter(startDate) ? habitStartDate : startDate;

      print('Habit created: $habitStartDate');
      print('Effective start: $effectiveStartDate');

      // Count the number of days from effective start to today (inclusive)
      final daysSinceStart =
          todayMidnight.difference(effectiveStartDate).inDays + 1;

      print('Days since start: $daysSinceStart');

      if (daysSinceStart <= 0) {
        print('No days to track yet');
        continue;
      }

      // Calculate expected check-ins based on reminder days
      // If no reminder days are set, assume daily
      int expectedForThisHabit = 0;
      if (habit.reminderDays.isEmpty) {
        // Daily habit
        expectedForThisHabit = daysSinceStart;
        print('Daily habit - expected: $expectedForThisHabit');
      } else {
        // Count how many times each reminder day occurs in the period
        final reminderDaysLower =
            habit.reminderDays.map((d) => d.toLowerCase()).toSet();
        print('Reminder days: ${habit.reminderDays}');

        for (int i = 0; i < daysSinceStart; i++) {
          final checkDate = effectiveStartDate.add(Duration(days: i));
          final weekdayName = [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
            'sunday'
          ][checkDate.weekday - 1];

          if (reminderDaysLower.contains(weekdayName)) {
            expectedForThisHabit++;
          }
        }
        print('Scheduled days in period - expected: $expectedForThisHabit');
      }
      expectedCheckIns += expectedForThisHabit;

      // Count completed check-ins for this habit in the period
      // Normalize entry dates to midnight for proper comparison
      final habitEntries = state.habitEntries.where((entry) {
        final entryDateMidnight =
            DateTime(entry.date.year, entry.date.month, entry.date.day);
        return entry.habitId == habit.id &&
            !entryDateMidnight.isBefore(effectiveStartDate) &&
            !entryDateMidnight.isAfter(todayMidnight);
      }).toList();

      final habitCompletedEntries =
          habitEntries.where((entry) => entry.completed).length;

      print('Total entries for this habit in period: ${habitEntries.length}');
      print('Completed entries: $habitCompletedEntries');
      if (habitEntries.isNotEmpty) {
        print(
            'Entry dates: ${habitEntries.map((e) => '${e.date.month}/${e.date.day} ${e.date.hour}:${e.date.minute.toString().padLeft(2, "0")} (${e.completed ? "✓" : "✗"})').join(", ")}');
      }

      completedCheckIns += habitCompletedEntries;
    }

    print('\n═══ FINAL RESULTS ═══');
    print('Total expected check-ins: $expectedCheckIns');
    print('Total completed check-ins: $completedCheckIns');
    print(
        'Completion rate: ${expectedCheckIns > 0 ? ((completedCheckIns / expectedCheckIns * 100).round()) : 0}%');
    print('═══════════════════════════════════════════════════════\n');

    return (expectedCheckIns, completedCheckIns);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors =
        Theme.of(context).extension<StatusColors>() ?? StatusColors.light;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme, textTheme),
            Expanded(
              child: BlocBuilder<HabitBloc, HabitState>(
                builder: (context, state) {
                  if (state.status == HabitStatus.loading) {
                    return Center(
                      child:
                          CircularProgressIndicator(color: colorScheme.primary),
                    );
                  }

                  if (state.habits.isEmpty) {
                    return _buildEmptyState(colorScheme, textTheme);
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildOverviewCards(
                            state, colorScheme, textTheme, statusColors),
                        const SizedBox(height: 24),
                        _buildProgressChart(state, colorScheme, textTheme),
                        const SizedBox(height: 24),
                        _buildHabitBreakdown(state, colorScheme, textTheme),
                        const SizedBox(height: 24),
                        _buildStreakAnalysis(state, colorScheme, textTheme),
                        const SizedBox(height: 24),
                        _buildWeeklyHeatmap(state, colorScheme, textTheme),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.analytics,
            size: 32,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Track your progress and insights',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withAlpha((255 * 0.3).round()),
              ),
            ),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
                // Reload entries for the new period
                _loadEntriesForPeriod();
              },
              items: _periods.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(
                    period,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              underline: Container(),
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No Data Yet',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking habits to see analytics',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            NeumorphicButton(
              onPressed: () => context.go('/habits/add'),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'Add Habit',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(HabitState state, ColorScheme colorScheme,
      TextTheme textTheme, StatusColors statusColors) {
    final totalHabits = state.habits.length;

    // Calculate completion rate based on the period selected
    final (expectedCheckIns, completedCheckIns) =
        _calculateCompletionStats(state);
    final completionRate = expectedCheckIns > 0
        ? (completedCheckIns / expectedCheckIns * 100).round()
        : 0;

    print('Display - Completion Rate: $completionRate%');

    final avgStreak = state.habitStreaks.isNotEmpty
        ? (state.habitStreaks.values.reduce((a, b) => a + b) /
                state.habitStreaks.length)
            .round()
        : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Habits',
            totalHabits.toString(),
            Icons.track_changes,
            colorScheme.primary,
            colorScheme,
            textTheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completion Rate',
            '$completionRate%',
            Icons.trending_up,
            statusColors.success,
            colorScheme,
            textTheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg Streak',
            '$avgStreak days',
            Icons.local_fire_department,
            colorScheme.secondary,
            colorScheme,
            textTheme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      ColorScheme colorScheme, TextTheme textTheme) {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(
      HabitState state, ColorScheme colorScheme, TextTheme textTheme) {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion Trends',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildCompletionChart(state, colorScheme, textTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionChart(
      HabitState state, ColorScheme colorScheme, TextTheme textTheme) {
    // Generate data for the current week (Sunday to Saturday)
    final List<Map<String, dynamic>> chartData = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final totalHabits = state.habits.length;

    // Calculate the start of this week (Sunday)
    // weekday: Monday = 1, Tuesday = 2, ..., Sunday = 7
    final daysFromSunday =
        today.weekday % 7; // Convert to days from Sunday (0-6)
    final weekStart = today.subtract(Duration(days: daysFromSunday));

    // Generate 7 days starting from Sunday
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);

      // Count completed habits for this date
      final completedEntries = state.habitEntries.where((entry) {
        final entryDate =
            DateTime(entry.date.year, entry.date.month, entry.date.day);
        return entryDate.isAtSameMomentAs(dateOnly) && entry.completed;
      }).length;

      // Only show percentage if there are habits to track
      final percentage =
          totalHabits > 0 ? (completedEntries / totalHabits) : 0.0;

      chartData.add({
        'day': DateFormat('E').format(date),
        'percentage': percentage,
        'completed': completedEntries,
        'total': totalHabits,
      });
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: chartData.map((data) {
        final percentage = data['percentage'] as double;
        // Minimum height of 10 for visibility, max based on percentage
        final height = percentage > 0
            ? (percentage * 150 + 10).clamp(10.0, 170.0)
            : 10.0; // Show small bar when no data

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: height,
                decoration: BoxDecoration(
                  color: percentage > 0
                      ? colorScheme.primary.withAlpha((255 * 0.7).round())
                      : colorScheme.onSurfaceVariant
                          .withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['day'],
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHabitBreakdown(
      HabitState state, ColorScheme colorScheme, TextTheme textTheme) {
    final Map<String, int> categoryCount = {};
    for (final habit in state.habits) {
      categoryCount[habit.category] = (categoryCount[habit.category] ?? 0) + 1;
    }

    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habits by Category',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ...categoryCount.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCategoryRow(
                    entry.key,
                    entry.value,
                    state.habits.length,
                    colorScheme,
                    textTheme,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String category, int count, int total,
      ColorScheme colorScheme, TextTheme textTheme) {
    final percentage = (count / total * 100).round();
    final colors = {
      'Health': colorScheme.secondary,
      'Fitness': colorScheme.primary,
      'Mindfulness': colorScheme.tertiary,
      'Productivity': colorScheme.primaryContainer,
      'Learning': colorScheme.secondaryContainer,
      'Social': colorScheme.tertiaryContainer,
      'Other': colorScheme.onSurfaceVariant,
    };
    final color = colors[category] ?? colors['Other']!;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            category,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          '$count ($percentage%)',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakAnalysis(
      HabitState state, ColorScheme colorScheme, TextTheme textTheme) {
    final sortedStreaks = state.habitStreaks.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Streaks',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            if (sortedStreaks.isEmpty)
              Text(
                'No streaks yet. Complete habits to build streaks!',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...sortedStreaks.take(5).map((entry) {
                try {
                  final habit =
                      state.habits.firstWhere((h) => h.id == entry.key);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildStreakItem(
                        habit.title, entry.value, colorScheme, textTheme),
                  );
                } catch (e) {
                  return const SizedBox.shrink();
                }
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem(String habitTitle, int streak,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Icon(
          Icons.local_fire_department,
          color: streak >= 7
              ? colorScheme.secondary
              : colorScheme.onSurfaceVariant,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            habitTitle,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$streak days',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyHeatmap(
      HabitState state, ColorScheme colorScheme, TextTheme textTheme) {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Heatmap',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildHeatmapGrid(state, colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid(
      HabitState state, ColorScheme colorScheme, TextTheme textTheme) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<List<Widget>> weeks = [];
    final totalHabits = state.habits.length;

    // Calculate the start of this week (Sunday)
    final daysFromSunday = today.weekday % 7;
    final thisWeekStart = today.subtract(Duration(days: daysFromSunday));

    // Generate last 7 weeks, starting from 6 weeks ago
    for (int week = 6; week >= 0; week--) {
      final List<Widget> days = [];
      final weekStart = thisWeekStart.subtract(Duration(days: week * 7));

      // Generate 7 days for this week (Sunday to Saturday)
      for (int day = 0; day < 7; day++) {
        final date = weekStart.add(Duration(days: day));
        final dateOnly = DateTime(date.year, date.month, date.day);

        // Count completed habits for this specific date
        final completedCount = state.habitEntries.where((entry) {
          final entryDate =
              DateTime(entry.date.year, entry.date.month, entry.date.day);
          return entryDate.isAtSameMomentAs(dateOnly) && entry.completed;
        }).length;

        // Calculate intensity based on completion percentage
        final intensity = totalHabits > 0 && completedCount > 0
            ? (completedCount / totalHabits).clamp(0.0, 1.0)
            : 0.0;

        days.add(
          GestureDetector(
            onTap: () {
              _showDayDetails(
                  context, date, completedCount, totalHabits, state);
            },
            child: Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: intensity > 0
                    ? colorScheme.primary
                        .withAlpha((255 * (intensity * 0.7 + 0.2)).round())
                    : colorScheme.onSurfaceVariant
                        .withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }
      weeks.add(days);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => Text(
                    day,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        ...weeks.map((week) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: week,
            )),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Less',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            ...List.generate(5, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: colorScheme.primary
                      .withAlpha((255 * ((index + 1) * 0.2)).round()),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
            const SizedBox(width: 8),
            Text(
              'More',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDayDetails(BuildContext context, DateTime date, int completedCount,
      int totalHabits, HabitState state) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final completedHabits = state.habitEntries.where((entry) {
      final entryDate =
          DateTime(entry.date.year, entry.date.month, entry.date.day);
      return entryDate.isAtSameMomentAs(dateOnly) && entry.completed;
    }).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          DateFormat('MMM d, yyyy').format(date),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed: $completedCount / $totalHabits habits',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            if (completedHabits.isEmpty)
              Text(
                'No habits completed on this day',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              ...completedHabits.map((entry) {
                try {
                  final habit =
                      state.habits.firstWhere((h) => h.id == entry.habitId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            habit.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  return const SizedBox.shrink();
                }
              }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
