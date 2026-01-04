import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final userId = context.read<AuthBloc>().state.user?.id ?? '';
        return GetIt.instance<LeaderboardBloc>()
          ..add(LoadLeaderboard(currentUserId: userId));
      },
      child: const LeaderboardView(),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: NeumorphicButton(
          onPressed: () => context.pop(),
          child: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
        ),
        title: Text(
          'Leaderboard',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NeumorphicButton(
              onPressed: () {
                final userId = context.read<AuthBloc>().state.user?.id ?? '';
                context.read<LeaderboardBloc>().add(
                      RefreshLeaderboard(currentUserId: userId),
                    );
              },
              child: Icon(
                Icons.refresh,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          print(
              'LeaderboardView: Building with status: ${state.status}, entries: ${state.leaderboard.length}');

          if (state.status == LeaderboardStatus.loading) {
            print('LeaderboardView: Showing loading indicator');
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (state.status == LeaderboardStatus.error) {
            print('LeaderboardView: Showing error: ${state.message}');
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
                    state.message ?? 'Failed to load leaderboard',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  NeumorphicButton(
                    onPressed: () {
                      final userId =
                          context.read<AuthBloc>().state.user?.id ?? '';
                      context.read<LeaderboardBloc>().add(
                            LoadLeaderboard(currentUserId: userId),
                          );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text(
                        'Retry',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.leaderboard.isEmpty) {
            print('LeaderboardView: Leaderboard is empty, showing empty state');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start tracking habits to appear on the leaderboard!',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          print(
              'LeaderboardView: Showing leaderboard with ${state.leaderboard.length} entries');

          return Column(
            children: [
              // Top 3 podium - only show if we have at least 1 user
              if (state.leaderboard.isNotEmpty)
                _buildPodium(state.leaderboard, colorScheme, textTheme),

              // Rest of the leaderboard (after top 3)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.leaderboard.length > 3
                      ? state.leaderboard.length - 3
                      : 0, // Only show list if there are more than 3 users
                  itemBuilder: (context, index) {
                    final entry = state.leaderboard[index + 3];
                    final currentUserId =
                        context.read<AuthBloc>().state.user?.id ?? '';
                    final isCurrentUser = entry.userId == currentUserId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildLeaderboardItem(
                        entry,
                        isCurrentUser,
                        colorScheme,
                        textTheme,
                      ),
                    );
                  },
                ),
              ),

              // Current user rank at bottom
              if (state.userRank != null && state.userRank!.rank > 3)
                _buildUserRankFooter(state.userRank!, colorScheme, textTheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> leaderboard,
      ColorScheme colorScheme, TextTheme textTheme) {
    final top1 = leaderboard[0];
    final top2 = leaderboard.length > 1 ? leaderboard[1] : null;
    final top3 = leaderboard.length > 2 ? leaderboard[2] : null;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2nd place
          if (top2 != null)
            Expanded(
              child: _buildPodiumItem(
                top2,
                2,
                colorScheme,
                textTheme,
                height: 140,
                iconSize: 50,
              ),
            ),
          const SizedBox(width: 12),
          // 1st place
          Expanded(
            child: _buildPodiumItem(
              top1,
              1,
              colorScheme,
              textTheme,
              height: 180,
              iconSize: 70,
            ),
          ),
          const SizedBox(width: 12),
          // 3rd place
          if (top3 != null)
            Expanded(
              child: _buildPodiumItem(
                top3,
                3,
                colorScheme,
                textTheme,
                height: 120,
                iconSize: 45,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    LeaderboardEntry entry,
    int rank,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required double height,
    required double iconSize,
  }) {
    Color getRankColor() {
      switch (rank) {
        case 1:
          return colorScheme.primary;
        case 2:
          return colorScheme.secondary;
        case 3:
          return colorScheme.tertiary;
        default:
          return colorScheme.primary;
      }
    }

    IconData getRankIcon() {
      switch (rank) {
        case 1:
          return Icons.emoji_events;
        case 2:
          return Icons.workspace_premium;
        case 3:
          return Icons.military_tech;
        default:
          return Icons.star;
      }
    }

    return Column(
      children: [
        // Avatar with rank badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: getRankColor().withOpacity(0.2),
                border: Border.all(
                  color: getRankColor(),
                  width: 3,
                ),
              ),
              child: Center(
                child: Icon(
                  getRankIcon(),
                  size: iconSize * 0.5,
                  color: getRankColor(),
                ),
              ),
            ),
            Positioned(
              bottom: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: getRankColor(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: getRankColor().withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.userName,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Podium
        NeumorphicCard(
          child: Container(
            height: height,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: colorScheme.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.totalStreak}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.totalHabits} habits',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    LeaderboardEntry entry,
    bool isCurrentUser,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return NeumorphicCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: isCurrentUser
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary,
                  width: 2,
                ),
              )
            : null,
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '#${entry.rank}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.userName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.totalHabits} habits • ${entry.completedToday} completed today',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Streak
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.totalStreak}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Text(
                  'streak',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRankFooter(
      LeaderboardEntry userRank, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your Position',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _buildLeaderboardItem(userRank, true, colorScheme, textTheme),
        ],
      ),
    );
  }
}
