import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../habits/presentation/bloc/habit_bloc.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: BlocBuilder<HabitBloc, HabitState>(
                builder: (context, state) {
                  if (state.status == HabitStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.habits.isEmpty) {
                    return _buildEmptyState();
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildOverviewCards(state),
                        const SizedBox(height: 24),
                        _buildProgressChart(state),
                        const SizedBox(height: 24),
                        _buildHabitBreakdown(state),
                        const SizedBox(height: 24),
                        _buildStreakAnalysis(state),
                        const SizedBox(height: 24),
                        _buildWeeklyHeatmap(state),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(
            Icons.analytics,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Track your progress and insights',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
              },
              items: _periods.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(
                    period,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Data Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start tracking habits to see analytics',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            NeumorphicButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'Go Back',
                  style: TextStyle(
                    color: AppColors.primary,
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

  Widget _buildOverviewCards(HabitState state) {
    final totalHabits = state.habits.length;
    final totalEntries = state.habitEntries.length;
    final completedEntries =
        state.habitEntries.where((entry) => entry.completed).length;
    final completionRate =
        totalEntries > 0 ? (completedEntries / totalEntries * 100).round() : 0;
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
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completion Rate',
            '$completionRate%',
            Icons.trending_up,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg Streak',
            '$avgStreak days',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(HabitState state) {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completion Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildCompletionChart(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionChart(HabitState state) {
    // Generate last 7 days data
    final List<Map<String, dynamic>> chartData = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayEntries = state.habitEntries.where((entry) =>
          entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day);

      final completedCount =
          dayEntries.where((entry) => entry.completed).length;
      final totalCount = dayEntries.length;
      final percentage = totalCount > 0 ? (completedCount / totalCount) : 0.0;

      chartData.add({
        'day': DateFormat('E').format(date),
        'percentage': percentage,
        'completed': completedCount,
        'total': totalCount,
      });
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: chartData.map((data) {
        final height = (data['percentage'] as double) * 160 + 20;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['day'],
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHabitBreakdown(HabitState state) {
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
            const Text(
              'Habits by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ...categoryCount.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCategoryRow(
                      entry.key, entry.value, state.habits.length),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String category, int count, int total) {
    final percentage = (count / total * 100).round();
    final colors = {
      'Health': AppColors.success,
      'Productivity': AppColors.primary,
      'Fitness': Colors.orange,
      'Learning': Colors.purple,
      'Mindfulness': Colors.blue,
      'Social': Colors.pink,
    };
    final color = colors[category] ?? AppColors.accent;

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
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '$count ($percentage%)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakAnalysis(HabitState state) {
    final sortedStreaks = state.habitStreaks.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Streaks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            if (sortedStreaks.isEmpty)
              const Text(
                'No streaks yet. Complete habits to build streaks!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              )
            else
              ...sortedStreaks.take(5).map((entry) {
                try {
                  final habit =
                      state.habits.firstWhere((h) => h.id == entry.key);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildStreakItem(habit.title, entry.value),
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

  Widget _buildStreakItem(String habitTitle, int streak) {
    return Row(
      children: [
        Icon(
          Icons.local_fire_department,
          color: streak >= 7 ? Colors.orange : AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            habitTitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$streak days',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyHeatmap(HabitState state) {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Heatmap',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildHeatmapGrid(state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid(HabitState state) {
    final now = DateTime.now();
    final List<List<Widget>> weeks = [];

    // Generate last 7 weeks
    for (int week = 6; week >= 0; week--) {
      final List<Widget> days = [];
      for (int day = 0; day < 7; day++) {
        final date = now.subtract(Duration(days: week * 7 + (6 - day)));
        final dayEntries = state.habitEntries.where((entry) =>
            entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day);

        final completedCount =
            dayEntries.where((entry) => entry.completed).length;
        final intensity =
            completedCount > 0 ? (completedCount / 5).clamp(0.0, 1.0) : 0.0;

        days.add(
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(intensity * 0.8 + 0.1),
              borderRadius: BorderRadius.circular(2),
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
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
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
            const Text(
              'Less',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            ...List.generate(5, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity((index + 1) * 0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
            const SizedBox(width: 8),
            const Text(
              'More',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
