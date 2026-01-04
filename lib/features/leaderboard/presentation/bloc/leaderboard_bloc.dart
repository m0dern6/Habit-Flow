import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/usecases/get_leaderboard.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboard getLeaderboard;

  LeaderboardBloc({required this.getLeaderboard})
      : super(const LeaderboardState()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    print(
        'LeaderboardBloc: Loading leaderboard for user ${event.currentUserId}');
    emit(state.copyWith(status: LeaderboardStatus.loading));

    final result = await getLeaderboard();

    print('LeaderboardBloc: Got result from usecase');

    result.fold(
      (failure) {
        print('LeaderboardBloc: Error - $failure');
        emit(state.copyWith(
          status: LeaderboardStatus.error,
          message: failure.toString(),
        ));
      },
      (leaderboard) {
        print('LeaderboardBloc: Success - ${leaderboard.length} entries');

        // Find current user's rank
        final userRank = leaderboard.firstWhere(
          (entry) => entry.userId == event.currentUserId,
          orElse: () => leaderboard.isNotEmpty
              ? leaderboard.last
              : const LeaderboardEntry(
                  userId: '',
                  userName: '',
                  totalStreak: 0,
                  totalHabits: 0,
                  completedToday: 0,
                  rank: 0,
                ),
        );

        print('LeaderboardBloc: Emitting loaded state');
        emit(state.copyWith(
          status: LeaderboardStatus.loaded,
          leaderboard: leaderboard,
          userRank: userRank,
        ));
      },
    );
  }

  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    // Don't show loading state on refresh
    final result = await getLeaderboard();

    result.fold(
      (failure) => emit(state.copyWith(
        status: LeaderboardStatus.error,
        message: failure.toString(),
      )),
      (leaderboard) {
        final userRank = leaderboard.firstWhere(
          (entry) => entry.userId == event.currentUserId,
          orElse: () => leaderboard.isNotEmpty
              ? leaderboard.last
              : const LeaderboardEntry(
                  userId: '',
                  userName: '',
                  totalStreak: 0,
                  totalHabits: 0,
                  completedToday: 0,
                  rank: 0,
                ),
        );

        emit(state.copyWith(
          status: LeaderboardStatus.loaded,
          leaderboard: leaderboard,
          userRank: userRank,
        ));
      },
    );
  }
}
