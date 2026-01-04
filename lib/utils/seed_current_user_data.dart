import 'package:cloud_firestore/cloud_firestore.dart';

/// One-time utility to seed the current user with sample habits and progress
/// Run this once, then comment out or delete
class SeedUserData {
  static Future<void> seedForUser(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    final now = DateTime.now();
    final startDate = DateTime(2025, 11, 1); // November 1, 2025
    final daysToSeed = now.difference(startDate).inDays + 1;

    print('🌱 Seeding data for user: $userId');
    print(
        '📅 Date range: ${startDate.toString().split(' ')[0]} to ${now.toString().split(' ')[0]}');
    print('📊 Days to populate: $daysToSeed');

    // Create realistic habits
    final habits = [
      {
        'userId': userId,
        'title': 'Morning 5km Run',
        'description': 'Start the day with energy and fitness',
        'category': 'Fitness',
        'iconCode': '0xe531', // directions_run
        'color': '#2196F3',
        'targetDuration': 30,
        'isActive': true,
        'createdAt': Timestamp.fromDate(startDate),
      },
      {
        'userId': userId,
        'title': 'Read 30 Pages',
        'description': 'Daily reading for personal growth',
        'category': 'Growth',
        'iconCode': '0xe865', // menu_book
        'color': '#4CAF50',
        'targetDuration': 45,
        'isActive': true,
        'createdAt': Timestamp.fromDate(startDate),
      },
      {
        'userId': userId,
        'title': 'Meditation 15min',
        'description': 'Mindfulness and mental clarity',
        'category': 'Health',
        'iconCode': '0xe3bf', // self_improvement
        'color': '#9C27B0',
        'targetDuration': 15,
        'isActive': true,
        'createdAt': Timestamp.fromDate(startDate),
      },
      {
        'userId': userId,
        'title': 'Drink 2L Water',
        'description': 'Stay hydrated throughout the day',
        'category': 'Health',
        'iconCode': '0xe8e0', // local_drink
        'color': '#03A9F4',
        'targetDuration': 0,
        'isActive': true,
        'createdAt': Timestamp.fromDate(startDate),
      },
      {
        'userId': userId,
        'title': 'Learn Coding',
        'description': 'Practice algorithms and projects',
        'category': 'Growth',
        'iconCode': '0xe30c', // code
        'color': '#FF9800',
        'targetDuration': 60,
        'isActive': true,
        'createdAt': Timestamp.fromDate(startDate),
      },
      {
        'userId': userId,
        'title': 'No Social Media',
        'description': 'Focus time without distractions',
        'category': 'Productivity',
        'iconCode': '0xe037', // phone_disabled
        'color': '#F44336',
        'targetDuration': 0,
        'isActive': true,
        'createdAt': Timestamp.fromDate(startDate),
      },
    ];

    // Add habits to batch
    final habitIds = <String>[];
    for (var habit in habits) {
      final habitRef = firestore.collection('habits').doc();
      habitIds.add(habitRef.id);
      batch.set(habitRef, habit);
    }

    print('✅ Created ${habits.length} habits');

    // Create daily entries with realistic completion pattern
    int entryCount = 0;
    for (int habitIndex = 0; habitIndex < habits.length; habitIndex++) {
      final habitId = habitIds[habitIndex];

      for (int day = 0; day < daysToSeed; day++) {
        final currentDate = startDate.add(Duration(days: day));

        // Realistic completion pattern: ~75% success rate
        // More likely to complete on weekdays, build streaks with occasional misses
        final isWeekend = currentDate.weekday >= 6;
        final weekSuccess = (day + habitIndex) % 4 != 0; // 75% success
        final weekendSuccess = (day + habitIndex) % 3 != 0; // ~66% on weekends
        final isCompleted = isWeekend ? weekendSuccess : weekSuccess;

        if (isCompleted || day % 7 == 0) {
          // Create entry if completed OR once a week
          final entryRef = firestore.collection('habit_entries').doc();
          batch.set(entryRef, {
            'habitId': habitId,
            'userId': userId,
            'date': Timestamp.fromDate(currentDate),
            'completed': isCompleted,
            'createdAt': Timestamp.fromDate(currentDate),
            'completedAt': isCompleted ? Timestamp.fromDate(currentDate) : null,
          });
          entryCount++;
        }
      }
    }

    print('✅ Created $entryCount habit entries');

    // Commit all changes
    await batch.commit();
    print('🎉 Successfully seeded database!');
    print('📱 Your app should now show populated data');
  }
}
