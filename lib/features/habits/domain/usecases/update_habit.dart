import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class UpdateHabit implements UseCase<Habit, UpdateHabitParams> {
  final HabitRepository repository;

  UpdateHabit(this.repository);

  @override
  Future<Either<Failure, Habit>> call(UpdateHabitParams params) async {
    return await repository.updateHabit(params.habit);
  }
}

class UpdateHabitParams {
  final Habit habit;

  UpdateHabitParams({required this.habit});
}
