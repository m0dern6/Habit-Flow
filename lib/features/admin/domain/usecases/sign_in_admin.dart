import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/admin_user.dart';
import '../repositories/admin_repository.dart';

class SignInAdmin implements UseCase<AdminUser, SignInAdminParams> {
  final AdminRepository repository;

  SignInAdmin(this.repository);

  @override
  Future<Either<Failure, AdminUser>> call(SignInAdminParams params) async {
    return await repository.signInAdmin(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInAdminParams extends Equatable {
  final String email;
  final String password;

  const SignInAdminParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
