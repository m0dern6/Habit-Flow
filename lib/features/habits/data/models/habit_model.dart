import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/habit.dart';

class HabitModel extends Habit {
  const HabitModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.category,
    required super.iconCode,
    required super.color,
    required super.createdAt,
    super.targetTime,
    super.targetDuration,
    super.isActive,
    super.reminderDays,
    super.reminderTime,
  });

  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HabitModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      iconCode: data['iconCode'] ?? '',
      color: data['color'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      targetTime: data['targetTime'] != null
          ? (data['targetTime'] as Timestamp).toDate()
          : null,
      targetDuration: data['targetDuration'] ?? 0,
      isActive: data['isActive'] ?? true,
      reminderDays: List<String>.from(data['reminderDays'] ?? []),
      reminderTime: data['reminderTime'] != null
          ? (data['reminderTime'] as Timestamp).toDate()
          : null,
    );
  }

  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      userId: habit.userId,
      title: habit.title,
      description: habit.description,
      category: habit.category,
      iconCode: habit.iconCode,
      color: habit.color,
      createdAt: habit.createdAt,
      targetTime: habit.targetTime,
      targetDuration: habit.targetDuration,
      isActive: habit.isActive,
      reminderDays: habit.reminderDays,
      reminderTime: habit.reminderTime,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'iconCode': iconCode,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetTime': targetTime != null ? Timestamp.fromDate(targetTime!) : null,
      'targetDuration': targetDuration,
      'isActive': isActive,
      'reminderDays': reminderDays,
      'reminderTime':
          reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
    };
  }
}
