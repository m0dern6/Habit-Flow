import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit_entry.dart';
import '../repositories/habit_repository.dart';

class GetHabitEntryForDate
    implements UseCase<HabitEntry?, GetHabitEntryForDateParams> {
  final HabitRepository repository;

  GetHabitEntryForDate(this.repository);

  @override
  Future<Either<Failure, HabitEntry?>> call(
      GetHabitEntryForDateParams params) async {
    return await repository.getHabitEntryForDate(params.habitId, params.date);
  }
}

class GetHabitEntryForDateParams {
  final String habitId;
  final DateTime date;

  GetHabitEntryForDateParams({
    required this.habitId,
    required this.date,
  });
}
