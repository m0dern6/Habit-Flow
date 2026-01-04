import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeaderboard extends LeaderboardEvent {
  final String currentUserId;

  const LoadLeaderboard({required this.currentUserId});

  @override
  List<Object?> get props => [currentUserId];
}

class RefreshLeaderboard extends LeaderboardEvent {
  final String currentUserId;

  const RefreshLeaderboard({required this.currentUserId});

  @override
  List<Object?> get props => [currentUserId];
}
