import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/account_deletion_status.dart';
import '../repositories/auth_repository.dart';

class GetAccountDeletionStatus
    implements UseCase<AccountDeletionStatus, NoParams> {
  final AuthRepository repository;

  GetAccountDeletionStatus(this.repository);

  @override
  Future<Either<Failure, AccountDeletionStatus>> call(NoParams params) {
    return repository.getAccountDeletionStatus();
  }
}
