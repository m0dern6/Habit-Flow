import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to update leaderboard stats in Firestore
/// This should be called whenever user completes/uncompletes habits
class LeaderboardUpdateService {
  final FirebaseFirestore _firestore;

  LeaderboardUpdateService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Update leaderboard stats for a specific user
  /// Call this after habit completion/uncompletion
  Future<void> updateUserStats(String userId) async {
    try {
      print('LeaderboardUpdateService: Updating stats for user $userId');

      // Get user's habits
      final habitsSnapshot = await _firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .get();

      print(
          'LeaderboardUpdateService: Found ${habitsSnapshot.docs.length} habits');

      if (habitsSnapshot.docs.isEmpty) {
        // User has no habits, set stats to 0
        await _firestore.collection('leaderboard_stats').doc(userId).set({
          'userId': userId,
          'totalStreak': 0,
          'totalHabits': 0,
          'completedToday': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print('LeaderboardUpdateService: Set stats to 0 (no habits)');
        return;
      }

      // Calculate total streak using the same logic as HabitRemoteDataSource
      int totalStreak = 0;
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      for (final habitDoc in habitsSnapshot.docs) {
        final habitId = habitDoc.id;

        // Get completed entries for this habit, sorted by date descending
        final entriesSnapshot = await _firestore
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

        print(
            'LeaderboardUpdateService: Habit $habitId has streak of $streak days');
        totalStreak += streak;
      }

      // Calculate completed today
      final todayStr =
          '${todayDate.year}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}';

      final completedTodaySnapshot = await _firestore
          .collection('habit_entries')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: todayStr)
          .where('completed', isEqualTo: true)
          .get();

      print(
          'LeaderboardUpdateService: Total streak: $totalStreak, Completed today: ${completedTodaySnapshot.docs.length}');

      // Update or create leaderboard stats document
      await _firestore.collection('leaderboard_stats').doc(userId).set({
        'userId': userId,
        'totalStreak': totalStreak,
        'totalHabits': habitsSnapshot.docs.length,
        'completedToday': completedTodaySnapshot.docs.length,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('LeaderboardUpdateService: Successfully updated stats');
    } catch (e) {
      print('Error updating leaderboard stats: $e');
      // Don't throw - this is a background operation
    }
  }

  /// Batch update all users' stats
  /// Useful for initial setup or maintenance
  Future<void> updateAllUsersStats() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        await updateUserStats(userDoc.id);
      }
    } catch (e) {
      print('Error updating all leaderboard stats: $e');
    }
  }
}
