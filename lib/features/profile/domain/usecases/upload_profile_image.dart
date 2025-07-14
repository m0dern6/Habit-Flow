import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UploadProfileImage implements UseCase<String, UploadProfileImageParams> {
  final ProfileRepository repository;

  UploadProfileImage(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadProfileImageParams params) async {
    return await repository.uploadProfileImage(params.userId, params.imagePath);
  }
}

class UploadProfileImageParams extends Equatable {
  final String userId;
  final String imagePath;

  const UploadProfileImageParams({
    required this.userId,
    required this.imagePath,
  });

  @override
  List<Object> get props => [userId, imagePath];
}
