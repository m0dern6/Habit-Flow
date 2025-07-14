import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  final List<Map<String, dynamic>> _habits = [
    {
      'id': '1',
      'title': 'Morning Meditation',
      'description': '10 minutes of mindfulness',
      'icon': Icons.self_improvement,
      'color': AppColors.primary,
      'streak': 7,
      'completed': true,
      'category': 'Mindfulness',
    },
    {
      'id': '2',
      'title': 'Daily Exercise',
      'description': '30 minutes workout',
      'icon': Icons.fitness_center,
      'color': AppColors.accent,
      'streak': 12,
      'completed': false,
      'category': 'Fitness',
    },
    {
      'id': '3',
      'title': 'Read for 20 mins',
      'description': 'Read personal development book',
      'icon': Icons.book,
      'color': AppColors.success,
      'streak': 3,
      'completed': true,
      'category': 'Learning',
    },
    {
      'id': '4',
      'title': 'Drink Water',
      'description': '8 glasses of water daily',
      'icon': Icons.local_drink,
      'color': Colors.lightBlue,
      'streak': 5,
      'completed': false,
      'category': 'Health',
    },
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
              child: _buildHabitsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Habits',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Build better habits, one day at a time',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          NeumorphicButton(
            onPressed: () {
              // TODO: Show statistics
            },
            child: const Icon(
              Icons.analytics,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        final habit = _habits[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildHabitCard(habit),
        );
      },
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> habit) {
    return NeumorphicCard(
      child: InkWell(
        onTap: () {
          context.push('/habits/edit/${habit['id']}');
        },
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
                      color: habit['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      habit['icon'],
                      color: habit['color'],
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
                                habit['title'],
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
                                color: habit['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                habit['category'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: habit['color'],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          habit['description'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        habit['completed'] = !habit['completed'];
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: habit['completed']
                            ? AppColors.success
                            : Colors.transparent,
                        border: Border.all(
                          color: habit['completed']
                              ? AppColors.success
                              : AppColors.textSecondary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: habit['completed']
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 20,
                    color: habit['streak'] > 0
                        ? Colors.orange
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${habit['streak']} day streak',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: habit['streak'] > 0
                          ? Colors.orange
                          : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  _buildProgressIndicator(habit['streak']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int streak) {
    return Row(
      children: List.generate(7, (index) {
        return Container(
          margin: const EdgeInsets.only(left: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: index < streak
                ? AppColors.success
                : AppColors.textSecondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: () {
        context.push('/habits/add');
      },
      backgroundColor: AppColors.primary,
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
