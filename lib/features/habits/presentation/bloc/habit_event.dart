import 'package:equatable/equatable.dart';
import '../../domain/entities/habit.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserHabits extends HabitEvent {
  final String userId;

  const LoadUserHabits({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CreateHabitRequested extends HabitEvent {
  final Habit habit;

  const CreateHabitRequested({required this.habit});

  @override
  List<Object?> get props => [habit];
}

class UpdateHabitRequested extends HabitEvent {
  final Habit habit;

  const UpdateHabitRequested({required this.habit});

  @override
  List<Object?> get props => [habit];
}

class DeleteHabitRequested extends HabitEvent {
  final String habitId;

  const DeleteHabitRequested({required this.habitId});

  @override
  List<Object?> get props => [habitId];
}

class ToggleHabitCompletion extends HabitEvent {
  final String habitId;
  final DateTime date;
  final bool completed;
  final String userId;

  const ToggleHabitCompletion({
    required this.habitId,
    required this.date,
    required this.completed,
    required this.userId,
  });

  @override
  List<Object?> get props => [habitId, date, completed, userId];
}

class LoadHabitEntries extends HabitEvent {
  final String habitId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadHabitEntries({
    required this.habitId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [habitId, startDate, endDate];
}

class LoadHabitStreaks extends HabitEvent {
  final String userId;

  const LoadHabitStreaks({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadUserHabitEntries extends HabitEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadUserHabitEntries({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}
