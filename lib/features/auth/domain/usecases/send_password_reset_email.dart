import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetEmail
    implements UseCase<void, SendPasswordResetEmailParams> {
  final AuthRepository repository;

  SendPasswordResetEmail(this.repository);

  @override
  Future<Either<Failure, void>> call(
      SendPasswordResetEmailParams params) async {
    return await repository.sendPasswordResetEmail(email: params.email);
  }
}

class SendPasswordResetEmailParams extends Equatable {
  final String email;

  const SendPasswordResetEmailParams({required this.email});

  @override
  List<Object> get props => [email];
}
