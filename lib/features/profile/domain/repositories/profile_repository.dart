import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);
  Future<Either<Failure, UserProfile>> createUserProfile(UserProfile profile);
  Future<Either<Failure, void>> deleteUserProfile(String userId);
  Future<Either<Failure, String>> uploadProfileImage(
      String userId, String imagePath);
}
