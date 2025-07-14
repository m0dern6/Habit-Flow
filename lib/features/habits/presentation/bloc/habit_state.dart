import 'package:equatable/equatable.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';

enum HabitStatus {
  initial,
  loading,
  loaded,
  error,
}

class HabitState extends Equatable {
  final HabitStatus status;
  final List<Habit> habits;
  final List<HabitEntry> habitEntries;
  final Map<String, int> habitStreaks;
  final Map<String, double> completionRates;
  final String? message;

  const HabitState({
    this.status = HabitStatus.initial,
    this.habits = const [],
    this.habitEntries = const [],
    this.habitStreaks = const {},
    this.completionRates = const {},
    this.message,
  });

  HabitState copyWith({
    HabitStatus? status,
    List<Habit>? habits,
    List<HabitEntry>? habitEntries,
    Map<String, int>? habitStreaks,
    Map<String, double>? completionRates,
    String? message,
  }) {
    return HabitState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      habitEntries: habitEntries ?? this.habitEntries,
      habitStreaks: habitStreaks ?? this.habitStreaks,
      completionRates: completionRates ?? this.completionRates,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        habits,
        habitEntries,
        habitStreaks,
        completionRates,
        message,
      ];
}
