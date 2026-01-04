import 'package:equatable/equatable.dart';
import '../../domain/entities/leaderboard_entry.dart';

enum LeaderboardStatus { initial, loading, loaded, error }

class LeaderboardState extends Equatable {
  final LeaderboardStatus status;
  final List<LeaderboardEntry> leaderboard;
  final LeaderboardEntry? userRank;
  final String? message;

  const LeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.leaderboard = const [],
    this.userRank,
    this.message,
  });

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    List<LeaderboardEntry>? leaderboard,
    LeaderboardEntry? userRank,
    String? message,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      leaderboard: leaderboard ?? this.leaderboard,
      userRank: userRank ?? this.userRank,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, leaderboard, userRank, message];
}
