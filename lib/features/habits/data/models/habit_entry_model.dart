import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/habit_entry.dart';

class HabitEntryModel extends HabitEntry {
  const HabitEntryModel({
    required super.id,
    required super.habitId,
    required super.userId,
    required super.date,
    required super.completed,
    super.duration,
    super.notes,
    required super.createdAt,
    super.completedAt,
  });

  factory HabitEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HabitEntryModel(
      id: doc.id,
      habitId: data['habitId'] ?? '',
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      completed: data['completed'] ?? false,
      duration: data['duration'] ?? 0,
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory HabitEntryModel.fromEntity(HabitEntry entry) {
    return HabitEntryModel(
      id: entry.id,
      habitId: entry.habitId,
      userId: entry.userId,
      date: entry.date,
      completed: entry.completed,
      duration: entry.duration,
      notes: entry.notes,
      createdAt: entry.createdAt,
      completedAt: entry.completedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'habitId': habitId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'completed': completed,
      'duration': duration,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
