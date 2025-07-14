import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/neumorphism_style.dart';

class MainNavigationPage extends StatelessWidget {
  final Widget child;

  const MainNavigationPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: NeumorphismStyle.createNeumorphism(
          color: theme.colorScheme.surface,
          depth: 8,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: AppStrings.home,
                    isSelected: currentLocation.startsWith('/home'),
                    onTap: () => context.go('/home'),
                  ),
                  _NavItem(
                    icon: Icons.track_changes_rounded,
                    label: AppStrings.habits,
                    isSelected: currentLocation.startsWith('/habits'),
                    onTap: () => context.go('/habits'),
                  ),
                  _NavItem(
                    icon: Icons.analytics_rounded,
                    label: AppStrings.analytics,
                    isSelected: currentLocation.startsWith('/analytics'),
                    onTap: () => context.go('/analytics'),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: AppStrings.profile,
                    isSelected: currentLocation.startsWith('/profile'),
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
            ),
            // Add space for system navigation bar
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: isSelected
            ? NeumorphismStyle.createPressedNeumorphism(
                color: theme.colorScheme.surface,
                depth: 4,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
