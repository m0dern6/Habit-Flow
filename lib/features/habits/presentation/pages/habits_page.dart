import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
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
  final Set<String> _togglingHabits = <String>{};

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
      context.read<HabitBloc>().add(LoadUserHabits(userId: userId));
      context.read<HabitBloc>().add(LoadHabitStreaks(userId: userId));
    } else {
      debugPrint('HabitsPage: user not authenticated: ${authState.status}');
    }
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
        child: BlocListener<HabitBloc, HabitState>(
          listenWhen: (prev, curr) => prev != curr,
          listener: (context, state) {
            if (_togglingHabits.isNotEmpty) {
              setState(() => _togglingHabits.clear());
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildHeader(colorScheme, textTheme),
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
      ),
      floatingActionButton: _buildAddButton(colorScheme),
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

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.track_changes,
            size: 32,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Habits',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                BlocBuilder<HabitBloc, HabitState>(
                  builder: (context, state) {
                    return Text(
                      '${state.habits.length} active habits',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          NeumorphicButton(
            onPressed: () => context.push('/analytics'),
            child: Icon(
              Icons.analytics,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final baseColor = colorScheme.surface;
    final selectedColor = colorScheme.surfaceContainerHighest;
    final shadowColor = colorScheme.shadow.withOpacity(0.12);
    final highlightShadow = colorScheme.onSurface.withOpacity(0.08);

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
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : baseColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: isSelected ? 10 : 8,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: highlightShadow,
                      blurRadius: isSelected ? 6 : 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary.withOpacity(0.4)
                        : colorScheme.outlineVariant,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  category,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
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
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        if (state.status == HabitStatus.loading) {
          return Center(
              child: CircularProgressIndicator(color: colorScheme.primary));
        }

        if (state.status == HabitStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    state.message ?? 'Unknown error occurred',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                NeumorphicButton(
                  onPressed: _loadHabits,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Text(
                      'Retry',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
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
                Icon(
                  Icons.track_changes,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedCategory == 'All'
                      ? 'No habits yet'
                      : 'No $_selectedCategory habits',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedCategory == 'All'
                      ? 'Start building better habits today!'
                      : 'Try a different category or create a new habit',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                NeumorphicButton(
                  onPressed: () => context.push('/habits/add'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Text(
                      'Add New Habit',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
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
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: 80, // Add bottom padding to prevent FAB overlap
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors =
        Theme.of(context).extension<StatusColors>() ?? StatusColors.light;
    final categoryColor = _getCategoryColor(context, habit.category);

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
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(habit.category),
                      color: categoryColor,
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
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                habit.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          habit.description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
                      context,
                      'Streak',
                      '$streak days',
                      Icons.local_fire_department,
                      statusColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatChip(
                      context,
                      'Today',
                      isCompleted ? 'Done' : 'Pending',
                      isCompleted ? Icons.check_circle : Icons.schedule,
                      isCompleted ? statusColors.success : statusColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  NeumorphicButton(
                    onPressed: () =>
                        _toggleHabitCompletion(habit.id, today, !isCompleted),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: _togglingHabits.contains(habit.id)
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    statusColors.success),
                              ),
                            )
                          : Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isCompleted
                                  ? statusColors.success
                                  : colorScheme.onSurfaceVariant,
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

  Widget _buildStatChip(BuildContext context, String label, String value,
      IconData icon, Color color) {
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
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleHabitCompletion(String habitId, DateTime date, bool completed) {
    debugPrint(
        'HabitsPage: Toggle habit completion: habitId=$habitId, completed=$completed');
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

  Color _getCategoryColor(BuildContext context, String category) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors =
        Theme.of(context).extension<StatusColors>() ?? StatusColors.light;

    switch (category.toLowerCase()) {
      case 'fitness':
        return colorScheme.secondary;
      case 'mindfulness':
        return colorScheme.primary;
      case 'learning':
        return statusColors.info;
      case 'health':
        return colorScheme.secondaryContainer;
      case 'productivity':
        return statusColors.warning;
      default:
        return colorScheme.onSurfaceVariant;
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

  Widget _buildAddButton(ColorScheme colorScheme) {
    return NeumorphicButton(
      onPressed: () => context.push('/habits/add'),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Icon(
          Icons.add,
          color: colorScheme.primary,
          size: 28,
        ),
      ),
    );
  }
}
