import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetUserProfileRequested extends ProfileEvent {
  final String userId;
  final String? userEmail; // Optional email for creating default profile
  final String? userName; // Optional name for creating default profile

  const GetUserProfileRequested({
    required this.userId,
    this.userEmail,
    this.userName,
  });

  @override
  List<Object?> get props => [userId, userEmail, userName];
}

class UpdateUserProfileRequested extends ProfileEvent {
  final UserProfile profile;

  const UpdateUserProfileRequested({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class CreateUserProfileRequested extends ProfileEvent {
  final UserProfile profile;

  const CreateUserProfileRequested({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class UploadProfileImageRequested extends ProfileEvent {
  final String userId;
  final String imagePath;

  const UploadProfileImageRequested({
    required this.userId,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [userId, imagePath];
}

class DeleteUserProfileRequested extends ProfileEvent {
  final String userId;

  const DeleteUserProfileRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ClearProfileMessage extends ProfileEvent {
  const ClearProfileMessage();
}
