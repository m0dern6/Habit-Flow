import 'package:dartz/dartz.dart';
import 'package:demo_app/core/errors/failures.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

class UpdateUserRole implements UseCase<void, UpdateUserRoleParams> {
  final AdminRepository repository;

  UpdateUserRole(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserRoleParams params) async {
    return await repository.updateUserRole(params.userId, params.role);
  }
}

class UpdateUserRoleParams extends Equatable {
  final String userId;
  final String role;

  const UpdateUserRoleParams({
    required this.userId,
    required this.role,
  });

  @override
  List<Object> get props => [userId, role];
}
