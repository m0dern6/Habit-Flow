import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../models/leaderboard_model.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<LeaderboardEntry>> getLeaderboard();
  Future<LeaderboardEntry> getUserRank(String userId);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final FirebaseFirestore firestore;

  LeaderboardRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      print('LeaderboardRemoteDataSource: Starting getLeaderboard()');

      // Query the pre-computed leaderboard stats
      final statsSnapshot = await firestore
          .collection('leaderboard_stats')
          .orderBy('totalStreak', descending: true)
          .limit(100) // Top 100 users
          .get();

      print(
          'LeaderboardRemoteDataSource: Found ${statsSnapshot.docs.length} stat documents');

      // If no pre-computed stats exist, initialize them for all users
      if (statsSnapshot.docs.isEmpty) {
        print('LeaderboardRemoteDataSource: Stats empty, initializing...');
        await _initializeAllUsersStats();

        // Retry fetching after initialization
        print(
            'LeaderboardRemoteDataSource: Retrying fetch after initialization');
        final retrySnapshot = await firestore
            .collection('leaderboard_stats')
            .orderBy('totalStreak', descending: true)
            .limit(100)
            .get();

        print(
            'LeaderboardRemoteDataSource: Retry found ${retrySnapshot.docs.length} documents');

        if (retrySnapshot.docs.isEmpty) {
          print(
              'LeaderboardRemoteDataSource: Still empty after initialization');
          return [];
        }

        return _buildLeaderboardFromStats(retrySnapshot.docs);
      }

      final result = await _buildLeaderboardFromStats(statsSnapshot.docs);
      print(
          'LeaderboardRemoteDataSource: Built leaderboard with ${result.length} entries');
      return result;
    } catch (e) {
      print('LeaderboardRemoteDataSource: Error in getLeaderboard: $e');
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }

  Future<List<LeaderboardEntry>> _buildLeaderboardFromStats(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> statsDocs) async {
    print(
        'LeaderboardRemoteDataSource: Building leaderboard from ${statsDocs.length} stat docs');
    final leaderboard = <LeaderboardEntry>[];
    int rank = 1;

    for (final statDoc in statsDocs) {
      final statData = statDoc.data();
      final userId = statDoc.id;

      // Get user profile info
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('LeaderboardRemoteDataSource: User $userId not found, skipping');
        continue;
      }

      final userData = userDoc.data()!;

      leaderboard.add(LeaderboardModel(
        userId: userId,
        userName: '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
            .trim(),
        profileImageUrl: userData['profileImageUrl'],
        totalStreak: statData['totalStreak'] ?? 0,
        totalHabits: statData['totalHabits'] ?? 0,
        completedToday: statData['completedToday'] ?? 0,
        rank: rank++,
      ));
    }

    print(
        'LeaderboardRemoteDataSource: Returning ${leaderboard.length} leaderboard entries');
    return leaderboard;
  }

  Future<void> _initializeAllUsersStats() async {
    try {
      final usersSnapshot = await firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        await _updateUserStats(userDoc.id);
      }

      print('Initialized stats for ${usersSnapshot.docs.length} users');
    } catch (e) {
      print('Error initializing leaderboard stats: $e');
    }
  }

  Future<void> _updateUserStats(String userId) async {
    try {
      print('_updateUserStats: Updating stats for user $userId');

      // Get user's habits
      final habitsSnapshot = await firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .get();

      print('_updateUserStats: Found ${habitsSnapshot.docs.length} habits');

      if (habitsSnapshot.docs.isEmpty) {
        // User has no habits, set stats to 0
        await firestore.collection('leaderboard_stats').doc(userId).set({
          'userId': userId,
          'totalStreak': 0,
          'totalHabits': 0,
          'completedToday': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        return;
      }

      // Calculate total streak using the same logic as HabitRemoteDataSource
      int totalStreak = 0;
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      for (final habitDoc in habitsSnapshot.docs) {
        final habitId = habitDoc.id;

        // Get completed entries for this habit, sorted by date descending
        final entriesSnapshot = await firestore
            .collection('habit_entries')
            .where('habitId', isEqualTo: habitId)
            .where('completed', isEqualTo: true)
            .orderBy('date', descending: true)
            .limit(365)
            .get();

        if (entriesSnapshot.docs.isEmpty) {
          continue;
        }

        // Calculate streak
        int streak = 0;
        DateTime? previousDate;

        for (final entryDoc in entriesSnapshot.docs) {
          final entryData = entryDoc.data();
          final dateStr = entryData['date'] as String;

          // Parse date string (format: YYYY-MM-DD)
          final parts = dateStr.split('-');
          final entryDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );

          if (streak == 0) {
            // First entry - check if it's today or yesterday (grace period)
            final daysDiff = todayDate.difference(entryDate).inDays;
            if (daysDiff <= 1) {
              streak = 1;
              previousDate = entryDate;
            } else {
              break; // Streak is broken
            }
          } else {
            // Check if this entry is consecutive with previous
            final daysDiff = previousDate!.difference(entryDate).inDays;
            if (daysDiff == 1) {
              streak++;
              previousDate = entryDate;
            } else {
              break; // Streak is broken
            }
          }
        }

        print('_updateUserStats: Habit $habitId has streak of $streak days');
        totalStreak += streak;
      }

      // Calculate completed today
      final todayStr =
          '${todayDate.year}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}';

      final completedTodaySnapshot = await firestore
          .collection('habit_entries')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: todayStr)
          .where('completed', isEqualTo: true)
          .get();

      print(
          '_updateUserStats: Total streak: $totalStreak, Completed today: ${completedTodaySnapshot.docs.length}');

      // Update or create leaderboard stats document
      await firestore.collection('leaderboard_stats').doc(userId).set({
        'userId': userId,
        'totalStreak': totalStreak,
        'totalHabits': habitsSnapshot.docs.length,
        'completedToday': completedTodaySnapshot.docs.length,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('_updateUserStats: Successfully updated stats');
    } catch (e) {
      print('Error updating user stats for $userId: $e');
    }
  }

  @override
  Future<LeaderboardEntry> getUserRank(String userId) async {
    try {
      // Get user's stats
      final userStatDoc =
          await firestore.collection('leaderboard_stats').doc(userId).get();

      if (!userStatDoc.exists) {
        return LeaderboardModel(
          userId: userId,
          userName: 'Unknown',
          totalStreak: 0,
          totalHabits: 0,
          completedToday: 0,
          rank: 0,
        );
      }

      final userStatData = userStatDoc.data()!;
      final userStreak = userStatData['totalStreak'] ?? 0;

      // Count how many users have better streak
      final betterUsersSnapshot = await firestore
          .collection('leaderboard_stats')
          .where('totalStreak', isGreaterThan: userStreak)
          .get();

      final rank = betterUsersSnapshot.docs.length + 1;

      // Get user profile
      final userDoc = await firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};

      return LeaderboardModel(
        userId: userId,
        userName: '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
            .trim(),
        profileImageUrl: userData['profileImageUrl'],
        totalStreak: userStreak,
        totalHabits: userStatData['totalHabits'] ?? 0,
        completedToday: userStatData['completedToday'] ?? 0,
        rank: rank,
      );
    } catch (e) {
      throw Exception('Failed to fetch user rank: $e');
    }
  }
}
