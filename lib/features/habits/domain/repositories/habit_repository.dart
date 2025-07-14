import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/habit.dart';
import '../entities/habit_entry.dart';

abstract class HabitRepository {
  Future<Either<Failure, List<Habit>>> getUserHabits(String userId);
  Future<Either<Failure, Habit>> getHabit(String habitId);
  Future<Either<Failure, Habit>> createHabit(Habit habit);
  Future<Either<Failure, Habit>> updateHabit(Habit habit);
  Future<Either<Failure, void>> deleteHabit(String habitId);

  Future<Either<Failure, List<HabitEntry>>> getHabitEntries(
      String habitId, DateTime startDate, DateTime endDate);
  Future<Either<Failure, HabitEntry?>> getHabitEntryForDate(
      String habitId, DateTime date);
  Future<Either<Failure, HabitEntry>> createHabitEntry(HabitEntry entry);
  Future<Either<Failure, HabitEntry>> updateHabitEntry(HabitEntry entry);
  Future<Either<Failure, void>> deleteHabitEntry(String entryId);

  Future<Either<Failure, Map<String, int>>> getHabitStreaks(String userId);
  Future<Either<Failure, Map<String, double>>> getHabitCompletionRates(
      String userId, DateTime startDate, DateTime endDate);

  Stream<List<Habit>> watchUserHabits(String userId);
  Stream<List<HabitEntry>> watchHabitEntries(
      String habitId, DateTime startDate, DateTime endDate);
}
