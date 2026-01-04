import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/neumorphic_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_grid.dart';
import '../widgets/profile_settings_actions.dart';
import '../widgets/account_actions_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Container(height: statusBarHeight),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfileHeader(),
                  const SizedBox(height: 32),
                  const NeumorphicSection(
                    title: 'Your Statistics',
                    icon: Icons.bar_chart_rounded,
                    child: ProfileStatsGrid(),
                  ),
                  const SizedBox(height: 32),
                  const NeumorphicSection(
                    title: 'Settings',
                    icon: Icons.settings_rounded,
                    child: ProfileSettingsActions(),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
