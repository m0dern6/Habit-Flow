import '../../domain/entities/leaderboard_entry.dart';

class LeaderboardModel extends LeaderboardEntry {
  const LeaderboardModel({
    required super.userId,
    required super.userName,
    super.profileImageUrl,
    required super.totalStreak,
    required super.totalHabits,
    required super.completedToday,
    required super.rank,
  });

  factory LeaderboardModel.fromFirestore(
      Map<String, dynamic> userData, int rank) {
    return LeaderboardModel(
      userId: userData['id'] ?? '',
      userName:
          '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim(),
      profileImageUrl: userData['profileImageUrl'],
      totalStreak: (userData['totalStreak'] ?? 0) as int,
      totalHabits: (userData['totalHabits'] ?? 0) as int,
      completedToday: (userData['completedToday'] ?? 0) as int,
      rank: rank,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'profileImageUrl': profileImageUrl,
      'totalStreak': totalStreak,
      'totalHabits': totalHabits,
      'completedToday': completedToday,
      'rank': rank,
    };
  }
}
