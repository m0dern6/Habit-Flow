import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/create_user_profile.dart';
import '../../domain/usecases/upload_profile_image.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateUserProfile updateUserProfile;
  final CreateUserProfile createUserProfile;
  final UploadProfileImage uploadProfileImage;

  ProfileBloc({
    required this.getUserProfile,
    required this.updateUserProfile,
    required this.createUserProfile,
    required this.uploadProfileImage,
  }) : super(const ProfileState()) {
    on<GetUserProfileRequested>(_onGetUserProfileRequested);
    on<UpdateUserProfileRequested>(_onUpdateUserProfileRequested);
    on<CreateUserProfileRequested>(_onCreateUserProfileRequested);
    on<UploadProfileImageRequested>(_onUploadProfileImageRequested);
    on<DeleteUserProfileRequested>(_onDeleteUserProfileRequested);
    on<ClearProfileMessage>(_onClearProfileMessage);
  }

  Future<void> _onGetUserProfileRequested(
    GetUserProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result =
        await getUserProfile(GetUserProfileParams(userId: event.userId));

    result.fold(
      (failure) {
        // If profile not found, it means user data doesn't exist in users collection
        // This shouldn't normally happen with our new structure, but handle gracefully
        emit(state.copyWith(
          status: ProfileStatus.error,
          message: 'User profile not found. Please sign out and sign in again.',
        ));
      },
      (profile) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
      )),
    );
  }

  Future<void> _onUpdateUserProfileRequested(
    UpdateUserProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await updateUserProfile(
        UpdateUserProfileParams(profile: event.profile));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.error,
        message: failure.toString(),
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        message: 'Profile updated successfully',
      )),
    );
  }

  Future<void> _onCreateUserProfileRequested(
    CreateUserProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await createUserProfile(
        CreateUserProfileParams(profile: event.profile));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.error,
        message: failure.toString(),
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        message: 'Profile created successfully',
      )),
    );
  }

  Future<void> _onUploadProfileImageRequested(
    UploadProfileImageRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, uploadProgress: '0%'));

    final result = await uploadProfileImage(UploadProfileImageParams(
      userId: event.userId,
      imagePath: event.imagePath,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.error,
        message: failure.toString(),
      )),
      (photoUrl) {
        // Update the current profile with the new photo URL
        if (state.profile != null) {
          final updatedProfile = state.profile!.copyWith(
            photoUrl: photoUrl,
            updatedAt: DateTime.now(),
          );

          // Now update the profile in Firestore
          add(UpdateUserProfileRequested(profile: updatedProfile));
        } else {
          emit(state.copyWith(
            status: ProfileStatus.loaded,
            message: 'Profile image uploaded successfully',
          ));
        }
      },
    );
  }

  Future<void> _onDeleteUserProfileRequested(
    DeleteUserProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    // TODO: Implement delete profile use case
    emit(state.copyWith(
      status: ProfileStatus.error,
      message: 'Delete profile not implemented yet',
    ));
  }

  void _onClearProfileMessage(
    ClearProfileMessage event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(message: null));
  }
}
