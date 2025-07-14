import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit_entry.dart';
import '../repositories/habit_repository.dart';

class CreateHabitEntry implements UseCase<HabitEntry, CreateHabitEntryParams> {
  final HabitRepository repository;

  CreateHabitEntry(this.repository);

  @override
  Future<Either<Failure, HabitEntry>> call(
      CreateHabitEntryParams params) async {
    return await repository.createHabitEntry(params.entry);
  }
}

class CreateHabitEntryParams {
  final HabitEntry entry;

  CreateHabitEntryParams({required this.entry});
}
