import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/account_deletion_status.dart';
import '../repositories/auth_repository.dart';

class ScheduleAccountDeletion
    implements UseCase<AccountDeletionStatus, ScheduleAccountDeletionParams> {
  final AuthRepository repository;

  ScheduleAccountDeletion(this.repository);

  @override
  Future<Either<Failure, AccountDeletionStatus>> call(
      ScheduleAccountDeletionParams params) {
    return repository.scheduleAccountDeletion(gracePeriod: params.gracePeriod);
  }
}

class ScheduleAccountDeletionParams {
  final Duration gracePeriod;

  const ScheduleAccountDeletionParams({
    this.gracePeriod = const Duration(days: 7),
  });
}
