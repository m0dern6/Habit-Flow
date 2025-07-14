import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_management.dart';
import '../repositories/admin_repository.dart';

class GetAllUsers implements UseCase<List<UserManagement>, GetAllUsersParams> {
  final AdminRepository repository;

  GetAllUsers(this.repository);

  @override
  Future<Either<Failure, List<UserManagement>>> call(
      GetAllUsersParams params) async {
    return await repository.getAllUsers(
      limit: params.limit,
      lastUserId: params.lastUserId,
      searchQuery: params.searchQuery,
    );
  }
}

class GetAllUsersParams extends Equatable {
  final int? limit;
  final String? lastUserId;
  final String? searchQuery;

  const GetAllUsersParams({
    this.limit,
    this.lastUserId,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [limit, lastUserId, searchQuery];
}

class BanUser implements UseCase<void, BanUserParams> {
  final AdminRepository repository;

  BanUser(this.repository);

  @override
  Future<Either<Failure, void>> call(BanUserParams params) async {
    return await repository.banUser(params.userId);
  }
}

class BanUserParams extends Equatable {
  final String userId;

  const BanUserParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UnbanUser implements UseCase<void, UnbanUserParams> {
  final AdminRepository repository;

  UnbanUser(this.repository);

  @override
  Future<Either<Failure, void>> call(UnbanUserParams params) async {
    return await repository.unbanUser(params.userId);
  }
}

class UnbanUserParams extends Equatable {
  final String userId;

  const UnbanUserParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

class DeleteUser implements UseCase<void, DeleteUserParams> {
  final AdminRepository repository;

  DeleteUser(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteUserParams params) async {
    return await repository.deleteUser(params.userId);
  }
}

class DeleteUserParams extends Equatable {
  final String userId;

  const DeleteUserParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
