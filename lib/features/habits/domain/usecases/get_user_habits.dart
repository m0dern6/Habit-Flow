import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class GetUserHabits implements UseCase<List<Habit>, GetUserHabitsParams> {
  final HabitRepository repository;

  GetUserHabits(this.repository);

  @override
  Future<Either<Failure, List<Habit>>> call(GetUserHabitsParams params) async {
    return await repository.getUserHabits(params.userId);
  }
}

class GetUserHabitsParams {
  final String userId;

  GetUserHabitsParams({required this.userId});
}
