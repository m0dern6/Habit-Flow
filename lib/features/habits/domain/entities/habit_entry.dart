import 'package:equatable/equatable.dart';

class HabitEntry extends Equatable {
  final String id;
  final String habitId;
  final String userId;
  final DateTime date;
  final bool completed;
  final int duration; // in minutes
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;

  const HabitEntry({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.completed,
    this.duration = 0,
    this.notes,
    required this.createdAt,
    this.completedAt,
  });

  HabitEntry copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? date,
    bool? completed,
    int? duration,
    String? notes,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        habitId,
        userId,
        date,
        completed,
        duration,
        notes,
        createdAt,
        completedAt,
      ];
}
