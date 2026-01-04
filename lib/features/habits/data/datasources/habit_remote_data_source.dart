import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/habit_model.dart';
import '../models/habit_entry_model.dart';

abstract class HabitRemoteDataSource {
  Future<List<HabitModel>> getUserHabits(String userId);
  Future<HabitModel> getHabit(String habitId);
  Future<HabitModel> createHabit(HabitModel habit);
  Future<HabitModel> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String habitId);
  Future<void> resetUserProgress(String userId);

  Future<List<HabitEntryModel>> getHabitEntries(
      String habitId, DateTime startDate, DateTime endDate);
  Future<List<HabitEntryModel>> getUserHabitEntries(
      String userId, DateTime startDate, DateTime endDate);
  Future<HabitEntryModel?> getHabitEntryForDate(String habitId, DateTime date);
  Future<HabitEntryModel> createHabitEntry(HabitEntryModel entry);
  Future<HabitEntryModel> updateHabitEntry(HabitEntryModel entry);
  Future<void> deleteHabitEntry(String entryId);

  Future<Map<String, int>> getHabitStreaks(String userId);
  Future<Map<String, double>> getHabitCompletionRates(
      String userId, DateTime startDate, DateTime endDate);

  Stream<List<HabitModel>> watchUserHabits(String userId);
  Stream<List<HabitEntryModel>> watchHabitEntries(
      String habitId, DateTime startDate, DateTime endDate);
}

class HabitRemoteDataSourceImpl implements HabitRemoteDataSource {
  final FirebaseFirestore firestore;

  HabitRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<HabitModel>> getUserHabits(String userId) async {
    try {
      print('Attempting to fetch habits for user: $userId'); // Debug

      // Check if userId is valid
      if (userId.isEmpty) {
        throw ServerException(message: 'User ID is empty');
      }

      // First check if we can access Firestore at all with a simple query
      final collectionRef = firestore.collection('habits');
      print('Collection reference created'); // Debug

      try {
        // Try a simple query first
        final querySnapshot = await collectionRef
            .where('userId', isEqualTo: userId)
            .limit(100) // Add limit to prevent large data fetches
            .get();

        print(
            'Query executed, found ${querySnapshot.docs.length} documents'); // Debug

        final habits = <HabitModel>[];

        for (final doc in querySnapshot.docs) {
          try {
            print('Processing document: ${doc.id}'); // Debug
            final habit = HabitModel.fromFirestore(doc);
            if (habit.isActive) {
              habits.add(habit);
            }
          } catch (docError) {
            print('Error processing document ${doc.id}: $docError');
            // Continue processing other documents
            continue;
          }
        }

        print('Filtered to ${habits.length} active habits'); // Debug

        // Sort in Dart instead of Firestore to avoid index requirements
        habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return habits;
      } on FirebaseException catch (e) {
        print('Firebase error: ${e.code} - ${e.message}');
        if (e.code == 'permission-denied') {
          throw ServerException(
              message:
                  'Permission denied. Please check Firestore security rules.');
        } else if (e.code == 'failed-precondition') {
          throw ServerException(
              message:
                  'Missing index. Please create required Firestore indexes.');
        } else {
          throw ServerException(message: 'Firebase error: ${e.message}');
        }
      }
    } catch (e) {
      print('Error in getUserHabits: $e'); // Debug

      if (e is ServerException) {
        rethrow;
      }

      // Add more detailed error information
      throw ServerException(message: 'Failed to fetch habits: ${e.toString()}');
    }
  }

  @override
  Future<HabitModel> getHabit(String habitId) async {
    try {
      final doc = await firestore.collection('habits').doc(habitId).get();
      if (!doc.exists) {
        throw const ServerException(message: 'Habit not found');
      }
      return HabitModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      final docRef =
          await firestore.collection('habits').add(habit.toFirestore());
      final doc = await docRef.get();
      return HabitModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<HabitModel> updateHabit(HabitModel habit) async {
    try {
      await firestore
          .collection('habits')
          .doc(habit.id)
          .update(habit.toFirestore());
      final doc = await firestore.collection('habits').doc(habit.id).get();
      return HabitModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      // Soft delete by setting isActive to false
      await firestore
          .collection('habits')
          .doc(habitId)
          .update({'isActive': false});
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resetUserProgress(String userId) async {
    try {
      const batchSize = 400;

      // Delete all habit entry documents for the user
      QuerySnapshot<Map<String, dynamic>> entryBatch;
      do {
        entryBatch = await firestore
            .collection('habit_entries')
            .where('userId', isEqualTo: userId)
            .limit(batchSize)
            .get();

        if (entryBatch.docs.isEmpty) break;

        final writeBatch = firestore.batch();
        for (final doc in entryBatch.docs) {
          writeBatch.delete(doc.reference);
        }

        await writeBatch.commit();
      } while (entryBatch.docs.length == batchSize);

      // Deactivate all habits for the user so they disappear from lists
      QuerySnapshot<Map<String, dynamic>> habitBatch;
      do {
        habitBatch = await firestore
            .collection('habits')
            .where('userId', isEqualTo: userId)
            .limit(batchSize)
            .get();

        if (habitBatch.docs.isEmpty) break;

        final writeBatch = firestore.batch();
        for (final doc in habitBatch.docs) {
          writeBatch.update(doc.reference, {'isActive': false});
        }

        await writeBatch.commit();
      } while (habitBatch.docs.length == batchSize);
    } catch (e) {
      throw ServerException(
          message: 'Failed to reset progress: ${e.toString()}');
    }
  }

  @override
  Future<List<HabitEntryModel>> getHabitEntries(
      String habitId, DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await firestore
          .collection('habit_entries')
          .where('habitId', isEqualTo: habitId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final entries = querySnapshot.docs
          .map((doc) => HabitEntryModel.fromFirestore(doc))
          .toList();

      // Sort in Dart to avoid index requirements
      entries.sort((a, b) => b.date.compareTo(a.date));

      return entries;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<HabitEntryModel>> getUserHabitEntries(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await firestore
          .collection('habit_entries')
          .where('userId', isEqualTo: userId)
          .get();

      final entries = querySnapshot.docs
          .map((doc) => HabitEntryModel.fromFirestore(doc))
          .where((entry) =>
              entry.date
                  .isAfter(startDate.subtract(const Duration(seconds: 1))) &&
              entry.date.isBefore(endDate.add(const Duration(seconds: 1))))
          .toList();

      return entries;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<HabitEntryModel?> getHabitEntryForDate(
      String habitId, DateTime date) async {
    try {
      // Simplified query to avoid composite index issues
      final querySnapshot = await firestore
          .collection('habit_entries')
          .where('habitId', isEqualTo: habitId)
          .get();

      // Filter by date in Dart to avoid index requirements
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      for (final doc in querySnapshot.docs) {
        final entry = HabitEntryModel.fromFirestore(doc);
        if (entry.date
                .isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
            entry.date.isBefore(endOfDay.add(const Duration(seconds: 1)))) {
          return entry;
        }
      }

      return null;
    } catch (e) {
      print('Error in getHabitEntryForDate: $e');
      return null; // Return null instead of throwing to prevent blocking
    }
  }

  @override
  Future<HabitEntryModel> createHabitEntry(HabitEntryModel entry) async {
    try {
      final docRef =
          await firestore.collection('habit_entries').add(entry.toFirestore());
      final doc = await docRef.get();
      return HabitEntryModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<HabitEntryModel> updateHabitEntry(HabitEntryModel entry) async {
    try {
      await firestore
          .collection('habit_entries')
          .doc(entry.id)
          .update(entry.toFirestore());
      final doc =
          await firestore.collection('habit_entries').doc(entry.id).get();
      return HabitEntryModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteHabitEntry(String entryId) async {
    try {
      await firestore.collection('habit_entries').doc(entryId).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, int>> getHabitStreaks(String userId) async {
    try {
      print('Calculating habit streaks for user: $userId');

      // Get all user habits
      final habitsSnapshot = await firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, int> streaks = {};
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      for (final habitDoc in habitsSnapshot.docs) {
        try {
          final habitData = habitDoc.data();
          final isActive = habitData['isActive'] ?? true;

          if (!isActive) continue; // Skip inactive habits

          final habitId = habitDoc.id;
          print('Calculating streak for habit: $habitId');

          // Get all completed entries for this habit
          final entriesSnapshot = await firestore
              .collection('habit_entries')
              .where('habitId', isEqualTo: habitId)
              .where('completed', isEqualTo: true)
              .orderBy('date', descending: true)
              .limit(90)
              .get();

          print(
              'Found ${entriesSnapshot.docs.length} completed entries for habit $habitId');

          // Debug: Print first few entries if any
          if (entriesSnapshot.docs.isNotEmpty) {
            for (int i = 0; i < entriesSnapshot.docs.length && i < 3; i++) {
              final entryData = entriesSnapshot.docs[i].data();
              final timestamp = entryData['date'] as Timestamp;
              final completed = entryData['completed'] ?? false;
              print(
                  '  Entry $i: date=${timestamp.toDate()}, completed=$completed');
            }
          }

          if (entriesSnapshot.docs.isEmpty) {
            streaks[habitId] = 0;
            continue;
          }

          // Calculate streak by checking consecutive days
          int streak = 0;
          DateTime? lastDate;

          for (final doc in entriesSnapshot.docs) {
            final entryData = doc.data();
            final timestamp = entryData['date'] as Timestamp;
            final entryDate = timestamp.toDate();
            final normalizedDate =
                DateTime(entryDate.year, entryDate.month, entryDate.day);

            if (lastDate == null) {
              // First entry - check if it's today or yesterday
              // (streak continues if you completed yesterday but not yet today)
              final daysDiff = todayDate.difference(normalizedDate).inDays;
              if (daysDiff <= 1) {
                streak = 1;
                lastDate = normalizedDate;
              } else {
                // Most recent completion is too old
                break;
              }
            } else {
              // Check if this entry is consecutive with the last one
              final daysDiff = lastDate.difference(normalizedDate).inDays;
              if (daysDiff == 1) {
                streak++;
                lastDate = normalizedDate;
              } else {
                // Gap found, streak broken
                break;
              }
            }
          }

          print('Habit $habitId streak: $streak days');

          streaks[habitId] = streak;
        } catch (habitError) {
          print(
              'Error calculating streak for habit ${habitDoc.id}: $habitError');
          streaks[habitDoc.id] = 0;
        }
      }

      print('Calculated streaks for ${streaks.length} habits');
      return streaks;
    } catch (e) {
      print('Error in getHabitStreaks: $e');
      return <String, int>{};
    }
  }

  @override
  Future<Map<String, double>> getHabitCompletionRates(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      print('Calculating completion rates for user: $userId');

      // Simplified query to avoid composite index issues
      final habitsSnapshot = await firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, double> completionRates = {};

      for (final habitDoc in habitsSnapshot.docs) {
        try {
          final habitData = habitDoc.data();
          final isActive = habitData['isActive'] ?? true;

          if (!isActive) continue; // Skip inactive habits

          final habitId = habitDoc.id;

          // For now, return 0.0 to avoid complex queries
          // This can be improved later with better indexing
          completionRates[habitId] = 0.0;

          // TODO: Implement proper completion rate calculation when indexes are set up
          /*
          final entries = await getHabitEntries(habitId, startDate, endDate);
          final completedDays = entries.where((entry) => entry.completed).length;
          completionRates[habitId] =
              totalDays > 0 ? (completedDays / totalDays) * 100 : 0.0;
          */
        } catch (habitError) {
          print(
              'Error calculating completion rate for habit ${habitDoc.id}: $habitError');
          completionRates[habitDoc.id] = 0.0;
        }
      }

      print('Calculated completion rates for ${completionRates.length} habits');
      return completionRates;
    } catch (e) {
      print('Error in getHabitCompletionRates: $e');
      // Return empty map instead of throwing to prevent blocking habits list
      return <String, double>{};
    }
  }

  @override
  Stream<List<HabitModel>> watchUserHabits(String userId) {
    return firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final habits =
          snapshot.docs.map((doc) => HabitModel.fromFirestore(doc)).toList();
      // Sort in Dart to avoid index requirements
      habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return habits;
    });
  }

  @override
  Stream<List<HabitEntryModel>> watchHabitEntries(
      String habitId, DateTime startDate, DateTime endDate) {
    return firestore
        .collection('habit_entries')
        .where('habitId', isEqualTo: habitId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs
          .map((doc) => HabitEntryModel.fromFirestore(doc))
          .toList();
      // Sort in Dart to avoid index requirements
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    });
  }
}
