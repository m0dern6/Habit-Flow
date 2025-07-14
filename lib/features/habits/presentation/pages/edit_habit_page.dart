import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/neumorphic_text_field.dart';
import '../../domain/entities/habit.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';

class EditHabitPage extends StatefulWidget {
  final String habitId;

  const EditHabitPage({
    super.key,
    required this.habitId,
  });

  @override
  State<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Health';
  IconData _selectedIcon = Icons.favorite;
  Color _selectedColor = AppColors.primary;
  List<String> _selectedDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  TimeOfDay? _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  Habit? _habit;
  bool _isLoading = true;

  final List<String> _categories = [
    'Health',
    'Fitness',
    'Mindfulness',
    'Learning',
    'Productivity',
    'Social',
    'Creative',
    'Finance'
  ];

  final List<Map<String, dynamic>> _icons = [
    {'icon': Icons.favorite, 'label': 'Health'},
    {'icon': Icons.fitness_center, 'label': 'Fitness'},
    {'icon': Icons.self_improvement, 'label': 'Mindfulness'},
    {'icon': Icons.book, 'label': 'Learning'},
    {'icon': Icons.work, 'label': 'Work'},
    {'icon': Icons.local_drink, 'label': 'Drink'},
    {'icon': Icons.restaurant, 'label': 'Food'},
    {'icon': Icons.music_note, 'label': 'Music'},
    {'icon': Icons.palette, 'label': 'Art'},
    {'icon': Icons.code, 'label': 'Code'},
  ];

  final Map<Color, String> _colors = {
    AppColors.primary: 'Primary',
    AppColors.accent: 'Accent',
    AppColors.success: 'Success',
    Colors.orange: 'Orange',
    Colors.purple: 'Purple',
    Colors.pink: 'Pink',
    Colors.teal: 'Teal',
    Colors.indigo: 'Indigo',
  };

  @override
  void initState() {
    super.initState();
    _loadHabitData();
  }

  void _loadHabitData() {
    final habitState = context.read<HabitBloc>().state;
    try {
      _habit =
          habitState.habits.firstWhere((habit) => habit.id == widget.habitId);

      // Populate form with habit data
      _titleController.text = _habit!.title;
      _descriptionController.text = _habit!.description;
      _selectedCategory = _habit!.category;
      _selectedIcon = _getIconFromName(_habit!.iconCode);
      _selectedColor = _getColorFromName(_habit!.color);
      _selectedDays = List<String>.from(_habit!.reminderDays);
      if (_habit!.reminderTime != null) {
        _reminderTime = TimeOfDay(
          hour: _habit!.reminderTime!.hour,
          minute: _habit!.reminderTime!.minute,
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Habit not found, go back
      context.pop();
    }
  }

  IconData _getIconFromName(String iconCode) {
    // Use a constant map for icon lookup to avoid tree shaking issues
    const iconMap = {
      '58720': Icons.favorite,
      '58722': Icons.star,
      '58731': Icons.home,
      '58732': Icons.work,
      '58738': Icons.school,
      '58740': Icons.fitness_center,
      '58742': Icons.local_dining,
      '58744': Icons.directions_run,
      '58746': Icons.book,
      '58748': Icons.music_note,
      '58750': Icons.palette,
      '58752': Icons.camera_alt,
      '58754': Icons.games,
      '58756': Icons.shopping_cart,
      '58758': Icons.card_giftcard,
      '58760': Icons.pets,
      '58762': Icons.eco,
      '58764': Icons.self_improvement,
      '58766': Icons.psychology,
      '58768': Icons.emoji_events,
      '58770': Icons.track_changes,
      '58772': Icons.timer,
      '58774': Icons.calendar_today,
      '58776': Icons.schedule,
      '58778': Icons.alarm,
      '58780': Icons.notifications,
      '58782': Icons.health_and_safety,
      '58784': Icons.restaurant,
      '58786': Icons.water_drop,
      '58788': Icons.bedtime,
      '58790': Icons.sunny,
    };

    return iconMap[iconCode] ?? Icons.favorite;
  }

  Color _getColorFromName(String colorString) {
    try {
      final colorValue = int.parse(colorString, radix: 16);
      return Color(colorValue);
    } catch (e) {
      return AppColors.primary;
    }
  }

  String _getIconName(IconData icon) {
    return icon.codePoint.toString();
  }

  String _getColorName(Color color) {
    return color.value.toRadixString(16);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: BlocListener<HabitBloc, HabitState>(
                listener: (context, state) {
                  if (state.status == HabitStatus.loaded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Habit updated successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    context.pop();
                  } else if (state.status == HabitStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(state.message ?? 'Failed to update habit'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInfo(),
                        const SizedBox(height: 24),
                        _buildCategorySelection(),
                        const SizedBox(height: 24),
                        _buildIconSelection(),
                        const SizedBox(height: 24),
                        _buildColorSelection(),
                        const SizedBox(height: 24),
                        _buildSchedule(),
                        const SizedBox(height: 24),
                        _buildReminder(),
                        const SizedBox(height: 32),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
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
          NeumorphicButton(
            onPressed: () => context.pop(),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Habit',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Update your habit details',
                  style: TextStyle(
                    fontSize: 14,
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

  Widget _buildBasicInfo() {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _titleController,
              labelText: 'Habit Title',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a habit title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _descriptionController,
              labelText: 'Description (Optional)',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.surface,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelection() {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Icon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _icons.length,
              itemBuilder: (context, index) {
                final iconData = _icons[index];
                final isSelected = _selectedIcon == iconData['icon'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconData['icon'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      iconData['icon'],
                      size: 24,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelection() {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.keys.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedule() {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: daysOfWeek.map((day) {
                final isSelected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDays.remove(day);
                      } else {
                        _selectedDays.add(day);
                      }
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.surface,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day.substring(0, 1),
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminder() {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reminder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: _reminderTime != null,
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        _reminderTime = const TimeOfDay(hour: 9, minute: 0);
                      } else {
                        _reminderTime = null;
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Enable reminder',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (_reminderTime != null) ...[
              const SizedBox(height: 16),
              NeumorphicButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime!,
                  );
                  if (time != null) {
                    setState(() {
                      _reminderTime = time;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        _reminderTime!.format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: NeumorphicButton(
            onPressed: _updateHabit,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Update Habit',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: NeumorphicButton(
            onPressed: _deleteHabit,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Delete Habit',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updateHabit() {
    if (_formKey.currentState!.validate() && _selectedDays.isNotEmpty) {
      final updatedHabit = _habit!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        iconCode: _getIconName(_selectedIcon),
        color: _getColorName(_selectedColor),
        reminderDays: _selectedDays,
        reminderTime: _reminderTime != null
            ? DateTime(2000, 1, 1, _reminderTime!.hour, _reminderTime!.minute)
            : null,
      );

      context.read<HabitBloc>().add(
            UpdateHabitRequested(habit: updatedHabit),
          );
    } else if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _deleteHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text(
            'Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HabitBloc>().add(
                    DeleteHabitRequested(habitId: _habit!.id),
                  );
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
