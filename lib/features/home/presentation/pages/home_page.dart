import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../habits/presentation/bloc/habit_bloc.dart';
import '../../../habits/presentation/bloc/habit_event.dart';
import '../../../habits/presentation/bloc/habit_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentQuoteIndex = 0;

  final List<Map<String, String>> _motivationalQuotes = [
    {
      'quote': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs'
    },
    {'quote': 'Your habits define your future.', 'author': 'WellnessFlow'},
    {'quote': 'Small progress is still progress.', 'author': 'Anonymous'},
    {
      'quote': 'Success is the sum of small efforts repeated daily.',
      'author': 'Robert Collier'
    },
  ];

  @override
  void initState() {
    super.initState();
    _startQuoteRotation();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      final userId = authState.user!.id;
      context.read<HabitBloc>().add(LoadUserHabits(userId: userId));
      context.read<HabitBloc>().add(LoadHabitStreaks(userId: userId));
    }
  }

  void _startQuoteRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _currentQuoteIndex =
              (_currentQuoteIndex + 1) % _motivationalQuotes.length;
        });
        _startQuoteRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom status bar space with gradient
          Container(
            height: statusBarHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  AppColors.background,
                ],
              ),
            ),
          ),
          // Main content
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout based on screen width
                if (constraints.maxWidth > 1200) {
                  return _buildDesktopLayout();
                } else if (constraints.maxWidth > 800) {
                  return _buildTabletLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          _buildMotivationalQuote(),
          const SizedBox(height: 24),
          _buildStatsOverview(),
          const SizedBox(height: 24),
          _buildTodaysHabits(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildRecentAchievements(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildMotivationalQuote(),
                    const SizedBox(height: 32),
                    _buildTodaysHabits(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildStatsOverview(),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    _buildRecentAchievements(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildMotivationalQuote(),
                    const SizedBox(height: 40),
                    _buildTodaysHabits(),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildStatsOverview(),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    _buildRecentAchievements(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final firstName = state.user?.firstName ?? '';
        // Extract first name, handle edge cases
        final userName = firstName.isEmpty ? 'User' : firstName;
        final currentHour = DateTime.now().hour;
        String greeting = 'Good Morning';

        if (currentHour >= 12 && currentHour < 17) {
          greeting = 'Good Afternoon';
        } else if (currentHour >= 17) {
          greeting = 'Good Evening';
        }

        return NeumorphicCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.emoji_emotions,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, $userName!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                NeumorphicButton(
                  onPressed: () => context.push('/profile'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotivationalQuote() {
    return NeumorphicCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.format_quote,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _motivationalQuotes[_currentQuoteIndex]['quote']!,
                key: ValueKey(_currentQuoteIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '— ${_motivationalQuotes[_currentQuoteIndex]['author']}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        final totalHabits = state.habits.length;
        final totalStreaks =
            state.habitStreaks.values.fold(0, (sum, streak) => sum + streak);
        final averageStreak =
            totalHabits > 0 ? (totalStreaks / totalHabits).round() : 0;

        // Calculate today's completion
        final today = DateTime.now();
        final todayEntries = state.habitEntries.where((entry) =>
            entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day);
        final completedToday =
            todayEntries.where((entry) => entry.completed).length;

        return NeumorphicCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.analytics,
                      size: 24,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Today\'s Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatItem('Total Habits', totalHabits.toString(),
                    Icons.track_changes),
                const SizedBox(height: 16),
                _buildStatItem('Completed Today',
                    '$completedToday/$totalHabits', Icons.check_circle),
                const SizedBox(height: 16),
                _buildStatItem(
                    'Average Streak', '$averageStreak days', Icons.trending_up),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: NeumorphicButton(
                    onPressed: () => context.push('/analytics'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'View Analytics',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysHabits() {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        if (state.status == HabitStatus.loading) {
          return const NeumorphicCard(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state.habits.isEmpty) {
          return NeumorphicCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.track_changes,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No habits yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start building better habits today!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeumorphicButton(
                    onPressed: () => context.push('/habits/add'),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text(
                        'Add Your First Habit',
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

        return NeumorphicCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.today,
                      size: 24,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Today\'s Habits',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    NeumorphicButton(
                      onPressed: () => context.push('/habits'),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_forward,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...state.habits.take(3).map((habit) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildHabitCard(habit, state),
                    )),
                if (state.habits.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: TextButton(
                        onPressed: () => context.push('/habits'),
                        child: Text(
                          'View all ${state.habits.length} habits',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitCard(dynamic habit, HabitState state) {
    final today = DateTime.now();
    final streak = state.habitStreaks[habit.id] ?? 0;

    // Check if habit is completed today
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
      depth: 2,
      child: InkWell(
        onTap: () => _toggleHabitCompletion(habit.id, today, !isCompleted),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${streak} day streak • ${habit.category}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleHabitCompletion(String habitId, DateTime date, bool completed) {
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
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

  Widget _buildQuickActions() {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Add New Habit',
              Icons.add_circle,
              AppColors.primary,
              () => context.push('/habits/add'),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'View All Habits',
              Icons.list,
              AppColors.accent,
              () => context.push('/habits'),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Analytics',
              Icons.analytics,
              AppColors.success,
              () => context.push('/analytics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: NeumorphicButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAchievements() {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        final achievements = _generateAchievements(state);

        return NeumorphicCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.military_tech,
                      size: 24,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Achievements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (achievements.isEmpty)
                  const Text(
                    'Complete habits to unlock achievements!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  ...achievements.map((achievement) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAchievementItem(achievement),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _generateAchievements(HabitState state) {
    final achievements = <Map<String, dynamic>>[];

    // Check for streak achievements
    state.habitStreaks.forEach((habitId, streak) {
      try {
        final habit = state.habits.firstWhere((h) => h.id == habitId);

        // Add achievements based on streak
        if (streak >= 7) {
          achievements.add({
            'title': '7-Day Streak!',
            'description': '${habit.title} - Week warrior',
            'icon': Icons.local_fire_department,
            'color': Colors.orange,
          });
        }
        if (streak >= 30) {
          achievements.add({
            'title': '30-Day Champion!',
            'description': '${habit.title} - Month master',
            'icon': Icons.star,
            'color': Colors.amber,
          });
        }
        if (streak >= 100) {
          achievements.add({
            'title': '100-Day Legend!',
            'description': '${habit.title} - Century crusher',
            'icon': Icons.emoji_events,
            'color': Colors.deepPurple,
          });
        }
      } catch (e) {
        // Habit not found, skip this streak
      }
    });

    // Check for completion achievements
    final totalHabits = state.habits.length;
    if (totalHabits >= 5) {
      achievements.add({
        'title': 'Habit Collector',
        'description': 'Created $totalHabits habits',
        'icon': Icons.collections,
        'color': AppColors.primary,
      });
    }

    return achievements.take(3).toList();
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            achievement['icon'],
            color: achievement['color'],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  achievement['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
