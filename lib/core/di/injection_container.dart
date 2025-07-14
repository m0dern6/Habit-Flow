import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/network_info.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/send_password_reset_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_with_email_and_password.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Habits
import '../../features/habits/data/datasources/habit_remote_data_source.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/domain/usecases/get_user_habits.dart';
import '../../features/habits/domain/usecases/create_habit.dart';
import '../../features/habits/domain/usecases/update_habit.dart';
import '../../features/habits/domain/usecases/create_habit_entry.dart';
import '../../features/habits/domain/usecases/get_habit_entry_for_date.dart';
import '../../features/habits/presentation/bloc/habit_bloc.dart';

// Profile
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/update_user_profile.dart';
import '../../features/profile/domain/usecases/create_user_profile.dart';
import '../../features/profile/domain/usecases/upload_profile_image.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

// Admin
import '../../features/admin/data/datasources/admin_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/sign_in_admin.dart';
import '../../features/admin/domain/usecases/user_management.dart';
import '../../features/admin/domain/usecases/analytics.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // External dependencies
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(sl<Connectivity>()),
  );

  // Auth Feature
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentUser(sl<AuthRepository>()));
  sl.registerLazySingleton(
      () => SignInWithEmailAndPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(
      () => SignUpWithEmailAndPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SendPasswordResetEmail(sl<AuthRepository>()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmailAndPassword: sl<SignInWithEmailAndPassword>(),
      signUpWithEmailAndPassword: sl<SignUpWithEmailAndPassword>(),
      signInWithGoogle: sl<SignInWithGoogle>(),
      signOut: sl<SignOut>(),
      getCurrentUser: sl<GetCurrentUser>(),
      sendPasswordResetEmail: sl<SendPasswordResetEmail>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // Habits Feature
  // Data sources
  sl.registerLazySingleton<HabitRemoteDataSource>(
    () => HabitRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(
      remoteDataSource: sl<HabitRemoteDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserHabits(sl<HabitRepository>()));
  sl.registerLazySingleton(() => CreateHabit(sl<HabitRepository>()));
  sl.registerLazySingleton(() => UpdateHabit(sl<HabitRepository>()));
  sl.registerLazySingleton(() => CreateHabitEntry(sl<HabitRepository>()));
  sl.registerLazySingleton(() => GetHabitEntryForDate(sl<HabitRepository>()));

  // BLoC
  sl.registerFactory(
    () => HabitBloc(
      getUserHabits: sl<GetUserHabits>(),
      createHabit: sl<CreateHabit>(),
      updateHabit: sl<UpdateHabit>(),
      createHabitEntry: sl<CreateHabitEntry>(),
      getHabitEntryForDate: sl<GetHabitEntryForDate>(),
      habitRepository: sl<HabitRepository>(),
    ),
  );

  // Profile Feature
  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      storage: sl<FirebaseStorage>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl<ProfileRemoteDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfile(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => CreateUserProfile(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UploadProfileImage(sl<ProfileRepository>()));

  // BLoC
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl<GetUserProfile>(),
      updateUserProfile: sl<UpdateUserProfile>(),
      createUserProfile: sl<CreateUserProfile>(),
      uploadProfileImage: sl<UploadProfileImage>(),
    ),
  );

  // Admin Feature
  // Data sources
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      firebaseAuth: sl<FirebaseAuth>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(
      remoteDataSource: sl<AdminRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInAdmin(sl<AdminRepository>()));
  sl.registerLazySingleton(() => GetAllUsers(sl<AdminRepository>()));
  sl.registerLazySingleton(() => BanUser(sl<AdminRepository>()));
  sl.registerLazySingleton(() => UnbanUser(sl<AdminRepository>()));
  sl.registerLazySingleton(() => DeleteUser(sl<AdminRepository>()));
  sl.registerLazySingleton(() => GetUserAnalytics(sl<AdminRepository>()));
  sl.registerLazySingleton(() => GetHabitAnalytics(sl<AdminRepository>()));
  sl.registerLazySingleton(() => GetSystemAnalytics(sl<AdminRepository>()));
  sl.registerLazySingleton(() => ExportUsersData(sl<AdminRepository>()));
  sl.registerLazySingleton(() => ExportHabitsData(sl<AdminRepository>()));

  // BLoC
  sl.registerFactory(
    () => AdminBloc(
      signInAdmin: sl<SignInAdmin>(),
      getAllUsers: sl<GetAllUsers>(),
      banUser: sl<BanUser>(),
      unbanUser: sl<UnbanUser>(),
      deleteUser: sl<DeleteUser>(),
      getUserAnalytics: sl<GetUserAnalytics>(),
      getHabitAnalytics: sl<GetHabitAnalytics>(),
      getSystemAnalytics: sl<GetSystemAnalytics>(),
      exportUsersData: sl<ExportUsersData>(),
      exportHabitsData: sl<ExportHabitsData>(),
    ),
  );
}
