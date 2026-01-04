import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final String userId;
  final String userName;
  final String? profileImageUrl;
  final int totalStreak;
  final int totalHabits;
  final int completedToday;
  final int rank;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.profileImageUrl,
    required this.totalStreak,
    required this.totalHabits,
    required this.completedToday,
    required this.rank,
  });

  @override
  List<Object?> get props => [
        userId,
        userName,
        profileImageUrl,
        totalStreak,
        totalHabits,
        completedToday,
        rank,
      ];
}
