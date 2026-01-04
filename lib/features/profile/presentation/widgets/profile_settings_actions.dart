import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ProfileSettingsActions extends StatelessWidget {
  const ProfileSettingsActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildActionItem(
          context,
          'Settings',
          'All preferences & account',
          Icons.settings_rounded,
          () => context.push('/profile/settings'),
        ),
        _buildActionItem(
          context,
          'Edit Profile',
          'Update your details',
          Icons.person_outline_rounded,
          () => context.push('/profile/edit'),
        ),
        _buildActionItem(
          context,
          'Help & Support',
          'FAQs and contact',
          Icons.help_outline_rounded,
          () => context.push('/profile/help'),
        ),
        _buildActionItem(
          context,
          'Sign Out',
          'Exit your account',
          Icons.logout_rounded,
          color: Theme.of(context).colorScheme.error,
          () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sign Out'),
              content: const Text(
                  'Are you sure you want to sign out of Habit Flow?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Use root context to dispatch sign out
                    context.read<AuthBloc>().add(AuthSignOutRequested());
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String title, String subtitle,
      IconData icon, VoidCallback onTap,
      {Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final iconColor = color ?? colorScheme.primary;
    final textColor = color ?? colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}
