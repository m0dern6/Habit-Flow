import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/neumorphic_card.dart';
import '../../../../../core/widgets/neumorphic_section.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _dailyReminder = true;
  bool _streakAlerts = true;
  bool _achievements = true;
  bool _systemUpdates = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            NeumorphicSection(
              title: 'Habit Alerts',
              icon: Icons.notifications_active_rounded,
              child: NeumorphicCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _buildToggleItem(
                        context,
                        'Daily Reminder',
                        'Remind me to check habits',
                        _dailyReminder,
                        (v) => setState(() => _dailyReminder = v)),
                    _buildToggleItem(
                        context,
                        'Streak Alerts',
                        'Notify when streak is at risk',
                        _streakAlerts,
                        (v) => setState(() => _streakAlerts = v)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            NeumorphicSection(
              title: 'App Activity',
              icon: Icons.auto_awesome_rounded,
              child: NeumorphicCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _buildToggleItem(
                        context,
                        'Achievements',
                        'When I unlock new badges',
                        _achievements,
                        (v) => setState(() => _achievements = v)),
                    _buildToggleItem(
                        context,
                        'System Updates',
                        'New features and news',
                        _systemUpdates,
                        (v) => setState(() => _systemUpdates = v)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(BuildContext context, String title, String subtitle,
      bool value, ValueChanged<bool> onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
      ),
    );
  }
}
