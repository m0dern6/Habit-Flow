import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final String? message;
  final String? uploadProgress;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.message,
    this.uploadProgress,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? message,
    String? uploadProgress,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      message: message ?? this.message,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  List<Object?> get props => [status, profile, message, uploadProgress];
}
