import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_remote_data_source.dart';
import '../models/habit_model.dart';
import '../models/habit_entry_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitRemoteDataSource remoteDataSource;

  HabitRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Habit>>> getUserHabits(String userId) async {
    try {
      final habits = await remoteDataSource.getUserHabits(userId);
      return Right(habits);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> getHabit(String habitId) async {
    try {
      final habit = await remoteDataSource.getHabit(habitId);
      return Right(habit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> createHabit(Habit habit) async {
    try {
      final habitModel = HabitModel.fromEntity(habit);
      final createdHabit = await remoteDataSource.createHabit(habitModel);
      return Right(createdHabit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> updateHabit(Habit habit) async {
    try {
      final habitModel = HabitModel.fromEntity(habit);
      final updatedHabit = await remoteDataSource.updateHabit(habitModel);
      return Right(updatedHabit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String habitId) async {
    try {
      await remoteDataSource.deleteHabit(habitId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HabitEntry>>> getHabitEntries(
      String habitId, DateTime startDate, DateTime endDate) async {
    try {
      final entries =
          await remoteDataSource.getHabitEntries(habitId, startDate, endDate);
      return Right(entries);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HabitEntry?>> getHabitEntryForDate(
      String habitId, DateTime date) async {
    try {
      final entry = await remoteDataSource.getHabitEntryForDate(habitId, date);
      return Right(entry);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HabitEntry>> createHabitEntry(HabitEntry entry) async {
    try {
      final entryModel = HabitEntryModel.fromEntity(entry);
      final createdEntry = await remoteDataSource.createHabitEntry(entryModel);
      return Right(createdEntry);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HabitEntry>> updateHabitEntry(HabitEntry entry) async {
    try {
      final entryModel = HabitEntryModel.fromEntity(entry);
      final updatedEntry = await remoteDataSource.updateHabitEntry(entryModel);
      return Right(updatedEntry);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabitEntry(String entryId) async {
    try {
      await remoteDataSource.deleteHabitEntry(entryId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getHabitStreaks(
      String userId) async {
    try {
      final streaks = await remoteDataSource.getHabitStreaks(userId);
      return Right(streaks);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getHabitCompletionRates(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final rates = await remoteDataSource.getHabitCompletionRates(
          userId, startDate, endDate);
      return Right(rates);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Habit>> watchUserHabits(String userId) {
    return remoteDataSource.watchUserHabits(userId);
  }

  @override
  Stream<List<HabitEntry>> watchHabitEntries(
      String habitId, DateTime startDate, DateTime endDate) {
    return remoteDataSource.watchHabitEntries(habitId, startDate, endDate);
  }
}
