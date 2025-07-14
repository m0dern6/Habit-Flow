import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      final profileModel = await remoteDataSource.getUserProfile(userId);
      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to get user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> createUserProfile(
      UserProfile profile) async {
    try {
      final profileModel = UserProfileModel.fromEntity(profile);
      final createdModel =
          await remoteDataSource.createUserProfile(profileModel);
      return Right(createdModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to create user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
      UserProfile profile) async {
    try {
      final profileModel = UserProfileModel.fromEntity(profile);
      final updatedModel =
          await remoteDataSource.updateUserProfile(profileModel);
      return Right(updatedModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to update user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserProfile(String userId) async {
    try {
      await remoteDataSource.deleteUserProfile(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to delete user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(
      String userId, String imagePath) async {
    try {
      final photoUrl =
          await remoteDataSource.uploadProfileImage(userId, imagePath);
      return Right(photoUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to upload profile picture: ${e.toString()}'));
    }
  }
}
