import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neumorphism_style.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/habit_entry.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Fitness',
    'Mindfulness',
    'Learning',
    'Health',
    'Productivity'
  ];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      final userId = authState.user!.id;
      print('Loading habits for user: $userId'); // Debug print
      context.read<HabitBloc>().add(LoadUserHabits(userId: userId));
      context.read<HabitBloc>().add(LoadHabitStreaks(userId: userId));
    } else {
      print('User not authenticated: ${authState.status}'); // Debug print
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildHeader(),
                if (constraints.maxWidth > 600) _buildCategoryFilters(),
                Expanded(
                  child: constraints.maxWidth > 1200
                      ? _buildDesktopLayout()
                      : constraints.maxWidth > 600
                          ? _buildTabletLayout()
                          : _buildMobileLayout(),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildCategoryFilters(),
        Expanded(child: _buildHabitsList()),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          final filteredHabits = _getFilteredHabits(state.habits);

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredHabits.length,
            itemBuilder: (context, index) {
              return _buildHabitCard(filteredHabits[index], state);
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          final filteredHabits = _getFilteredHabits(state.habits);

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: filteredHabits.length,
            itemBuilder: (context, index) {
              return _buildHabitCard(filteredHabits[index], state);
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(
            Icons.track_changes,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Habits',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                BlocBuilder<HabitBloc, HabitState>(
                  builder: (context, state) {
                    return Text(
                      '${state.habits.length} active habits',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          NeumorphicButton(
            onPressed: () => context.push('/analytics'),
            child: const Icon(
              Icons.analytics,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: isSelected
                    ? NeumorphismStyle.createNeumorphism(
                        depth: 2,
                        isPressed: true,
                      )
                    : NeumorphismStyle.createNeumorphism(
                        depth: 2,
                      ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHabitsList() {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        if (state.status == HabitStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == HabitStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    state.message ?? 'Unknown error occurred',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                NeumorphicButton(
                  onPressed: _loadHabits,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Retry',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final filteredHabits = _getFilteredHabits(state.habits);

        if (filteredHabits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.track_changes,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedCategory == 'All'
                      ? 'No habits yet'
                      : 'No $_selectedCategory habits',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedCategory == 'All'
                      ? 'Start building better habits today!'
                      : 'Try a different category or create a new habit',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                NeumorphicButton(
                  onPressed: () => context.push('/habits/add'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Add New Habit',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: filteredHabits.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildHabitCard(filteredHabits[index], state),
            );
          },
        );
      },
    );
  }

  List<dynamic> _getFilteredHabits(List<dynamic> habits) {
    if (_selectedCategory == 'All') {
      return habits;
    }
    return habits
        .where((habit) => habit.category == _selectedCategory)
        .toList();
  }

  Widget _buildHabitCard(dynamic habit, HabitState state) {
    final streak = state.habitStreaks[habit.id] ?? 0;
    final today = DateTime.now();

    // Check if habit is completed today
    HabitEntry? todayEntry;
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
      child: InkWell(
        onTap: () => context.push('/habits/edit/${habit.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(habit.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(habit.category),
                      color: _getCategoryColor(habit.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                habit.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(habit.category)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                habit.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getCategoryColor(habit.category),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          habit.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatChip(
                      'Streak',
                      '$streak days',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatChip(
                      'Today',
                      isCompleted ? 'Done' : 'Pending',
                      isCompleted ? Icons.check_circle : Icons.schedule,
                      isCompleted ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  NeumorphicButton(
                    onPressed: () =>
                        _toggleHabitCompletion(habit.id, today, !isCompleted),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fitness':
        return AppColors.accent;
      case 'mindfulness':
        return AppColors.primary;
      case 'learning':
        return AppColors.success;
      case 'health':
        return Colors.lightBlue;
      case 'productivity':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fitness':
        return Icons.fitness_center;
      case 'mindfulness':
        return Icons.self_improvement;
      case 'learning':
        return Icons.book;
      case 'health':
        return Icons.local_drink;
      case 'productivity':
        return Icons.work;
      default:
        return Icons.track_changes;
    }
  }

  Widget _buildAddButton() {
    return NeumorphicButton(
      onPressed: () => context.push('/habits/add'),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: const Icon(
          Icons.add,
          color: AppColors.primary,
          size: 28,
        ),
      ),
    );
  }
}
