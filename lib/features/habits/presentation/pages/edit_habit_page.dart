import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
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
  bool _isUpdating = false;
  bool _isDeleting = false;

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
    {'icon': Icons.bedtime, 'label': 'Sleep'},
    {'icon': Icons.music_note, 'label': 'Music'},
    {'icon': Icons.palette, 'label': 'Art'},
    {'icon': Icons.attach_money, 'label': 'Money'},
    {'icon': Icons.phone, 'label': 'Social'},
  ];

  final List<Color> _colors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.success,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
  ];

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

      // Convert full day names to short day names
      _selectedDays = _habit!.reminderDays.map((day) {
        final dayLower = day.toLowerCase();
        if (dayLower.startsWith('mon')) return 'Mon';
        if (dayLower.startsWith('tue')) return 'Tue';
        if (dayLower.startsWith('wed')) return 'Wed';
        if (dayLower.startsWith('thu')) return 'Thu';
        if (dayLower.startsWith('fri')) return 'Fri';
        if (dayLower.startsWith('sat')) return 'Sat';
        if (dayLower.startsWith('sun')) return 'Sun';
        return day; // fallback
      }).toList();

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
    // Build map from actual icons list to ensure accuracy
    final iconMap = <String, IconData>{};
    for (var iconData in _icons) {
      final icon = iconData['icon'] as IconData;
      iconMap[icon.codePoint.toString()] = icon;
    }

    print('🔍 Looking up icon code: $iconCode');
    final icon = iconMap[iconCode] ?? Icons.favorite;
    print(
        '🔍 Found icon: ${icon.codePoint}, matched: ${iconMap.containsKey(iconCode)}');
    print('🔍 Selected icon will be: ${icon.codePoint}');
    return icon;
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
    return color.value.toRadixString(16).padLeft(8, '0');
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
              child: BlocListener<HabitBloc, HabitState>(
                listener: (context, state) {
                  if (state.status == HabitStatus.loaded) {
                    if (_isDeleting) {
                      // Habit was deleted
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Habit deleted successfully!'),
                          backgroundColor: statusColors.success,
                        ),
                      );
                      context.pop();
                    } else if (_isUpdating) {
                      // Habit was updated
                      setState(() {
                        _isUpdating = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Habit updated successfully!'),
                          backgroundColor: statusColors.success,
                        ),
                      );
                      context.pop();
                    }
                  } else if (state.status == HabitStatus.error) {
                    setState(() {
                      _isUpdating = false;
                      _isDeleting = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isDeleting
                            ? (state.message ?? 'Failed to delete habit')
                            : (state.message ?? 'Failed to update habit')),
                        backgroundColor: colorScheme.error,
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

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          NeumorphicButton(
            onPressed: () => context.pop(),
            child: Icon(
              Icons.arrow_back,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Habit',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Update your habit details',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
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
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary.withOpacity(0.5)
                            : colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      category,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Icon',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
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
                final iconFromList = iconData['icon'] as IconData;
                final isSelected =
                    _selectedIcon.codePoint == iconFromList.codePoint;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconData['icon'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary.withOpacity(0.4)
                            : colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      iconData['icon'],
                      size: 24,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((color) {
                final isSelected = _selectedColor.value == color.value;

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
                            ? colorScheme.onSurface.withOpacity(0.2)
                            : colorScheme.outlineVariant,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.1),
                          blurRadius: isSelected ? 10 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: colorScheme.onPrimary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
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
                      color: isSelected
                          ? colorScheme.primary.withOpacity(0.14)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary.withOpacity(0.6)
                            : colorScheme.outlineVariant,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        day.substring(0, 1),
                        style: textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
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
            onPressed: _isUpdating ? null : _updateHabit,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isUpdating
                    ? AppColors.primary.withOpacity(0.6)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
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
      setState(() {
        _isUpdating = true;
      });

      // Convert short day names to full lowercase names
      final fullDayNames = _selectedDays.map((day) {
        switch (day) {
          case 'Mon':
            return 'monday';
          case 'Tue':
            return 'tuesday';
          case 'Wed':
            return 'wednesday';
          case 'Thu':
            return 'thursday';
          case 'Fri':
            return 'friday';
          case 'Sat':
            return 'saturday';
          case 'Sun':
            return 'sunday';
          default:
            return day.toLowerCase();
        }
      }).toList();

      final updatedHabit = _habit!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        iconCode: _getIconName(_selectedIcon),
        color: _getColorName(_selectedColor),
        reminderDays: fullDayNames,
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
              setState(() {
                _isDeleting = true;
              });
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
