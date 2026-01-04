import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final firstName = state.user?.firstName ?? '';
        final userName = firstName.isEmpty ? 'User' : firstName;
        final currentHour = DateTime.now().hour;

        String greeting = 'Good Morning';
        IconData greetingIcon = Icons.wb_sunny;
        Color iconColor = colorScheme.primary;

        if (currentHour >= 5 && currentHour < 12) {
          greeting = 'Good Morning';
          greetingIcon = Icons.wb_sunny;
          iconColor = colorScheme.primary;
        } else if (currentHour >= 12 && currentHour < 17) {
          greeting = 'Good Afternoon';
          greetingIcon = Icons.wb_sunny_outlined;
          iconColor = colorScheme.secondary;
        } else if (currentHour >= 17 && currentHour < 21) {
          greeting = 'Good Evening';
          greetingIcon = Icons.wb_twilight;
          iconColor = colorScheme.tertiary;
        } else {
          greeting = 'Good Night';
          greetingIcon = Icons.nightlight_round;
          iconColor = colorScheme.onSurfaceVariant;
        }

        return NeumorphicCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  greetingIcon,
                  size: 32,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      userName,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              NeumorphicButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderRadius: BorderRadius.circular(12),
                onPressed: () => context.push('/leaderboard'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.leaderboard,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Leaderboard',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
