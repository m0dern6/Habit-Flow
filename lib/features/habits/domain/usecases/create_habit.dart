import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class CreateHabit implements UseCase<Habit, CreateHabitParams> {
  final HabitRepository repository;

  CreateHabit(this.repository);

  @override
  Future<Either<Failure, Habit>> call(CreateHabitParams params) async {
    return await repository.createHabit(params.habit);
  }
}

class CreateHabitParams {
  final Habit habit;

  CreateHabitParams({required this.habit});
}
