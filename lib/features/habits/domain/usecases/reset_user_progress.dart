import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/habit_repository.dart';

class ResetUserProgress implements UseCase<void, ResetUserProgressParams> {
  final HabitRepository repository;

  ResetUserProgress(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetUserProgressParams params) {
    return repository.resetUserProgress(params.userId);
  }
}

class ResetUserProgressParams {
  final String userId;

  ResetUserProgressParams({required this.userId});
}
