import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfile
    implements UseCase<UserProfile, UpdateUserProfileParams> {
  final ProfileRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(
      UpdateUserProfileParams params) async {
    return await repository.updateUserProfile(params.profile);
  }
}

class UpdateUserProfileParams extends Equatable {
  final UserProfile profile;

  const UpdateUserProfileParams({required this.profile});

  @override
  List<Object> get props => [profile];
}
