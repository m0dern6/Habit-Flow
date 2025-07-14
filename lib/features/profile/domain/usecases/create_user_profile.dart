import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class CreateUserProfile
    implements UseCase<UserProfile, CreateUserProfileParams> {
  final ProfileRepository repository;

  CreateUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(
      CreateUserProfileParams params) async {
    return await repository.createUserProfile(params.profile);
  }
}

class CreateUserProfileParams extends Equatable {
  final UserProfile profile;

  const CreateUserProfileParams({required this.profile});

  @override
  List<Object> get props => [profile];
}
