import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/neumorphic_button.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionItem(
                context,
                'Add Habit',
                Icons.add_task_rounded,
                colorScheme.primary,
                () => context.push('/habits/add'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionItem(
                context,
                'My Habits',
                Icons.view_list_rounded,
                colorScheme.secondary,
                () => context.push('/habits'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionItem(
                context,
                'Progress',
                Icons.insights_rounded,
                colorScheme.tertiary,
                () => context.push('/analytics'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionItem(
                context,
                'Settings',
                Icons.settings_rounded,
                colorScheme.onSurfaceVariant,
                () => context.push('/profile'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return NeumorphicButton(
      padding: const EdgeInsets.all(16),
      onPressed: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 12),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
