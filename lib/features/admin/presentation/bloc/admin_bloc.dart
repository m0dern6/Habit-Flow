import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/usecases/sign_in_admin.dart';
import '../../domain/usecases/user_management.dart';
import '../../domain/usecases/analytics.dart';
import '../../data/models/admin_user_model.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final SignInAdmin signInAdmin;
  final GetAllUsers getAllUsers;
  final BanUser banUser;
  final UnbanUser unbanUser;
  final DeleteUser deleteUser;
  final GetUserAnalytics getUserAnalytics;
  final GetHabitAnalytics getHabitAnalytics;
  final GetSystemAnalytics getSystemAnalytics;
  final ExportUsersData exportUsersData;
  final ExportHabitsData exportHabitsData;

  AdminBloc({
    required this.signInAdmin,
    required this.getAllUsers,
    required this.banUser,
    required this.unbanUser,
    required this.deleteUser,
    required this.getUserAnalytics,
    required this.getHabitAnalytics,
    required this.getSystemAnalytics,
    required this.exportUsersData,
    required this.exportHabitsData,
  }) : super(const AdminState()) {
    on<AdminSignInRequested>(_onAdminSignInRequested);
    on<AdminSignOutRequested>(_onAdminSignOutRequested);
    on<AdminAutoAuthenticateRequested>(_onAdminAutoAuthenticateRequested);
    on<LoadAllUsersRequested>(_onLoadAllUsersRequested);
    on<BanUserRequested>(_onBanUserRequested);
    on<UnbanUserRequested>(_onUnbanUserRequested);
    on<DeleteUserRequested>(_onDeleteUserRequested);
    on<LoadUserAnalyticsRequested>(_onLoadUserAnalyticsRequested);
    on<LoadHabitAnalyticsRequested>(_onLoadHabitAnalyticsRequested);
    on<LoadSystemAnalyticsRequested>(_onLoadSystemAnalyticsRequested);
    on<LoadAllAnalyticsRequested>(_onLoadAllAnalyticsRequested);
    on<ExportUsersDataRequested>(_onExportUsersDataRequested);
    on<ExportHabitsDataRequested>(_onExportHabitsDataRequested);
    on<ClearAdminMessage>(_onClearAdminMessage);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onAdminSignInRequested(
    AdminSignInRequested event,
    Emitter<AdminState> emit,
  ) async {
    print('🔐 AdminBloc: Admin sign-in requested for email: ${event.email}');
    emit(state.copyWith(status: AdminStatus.loading));

    final result = await signInAdmin(
      SignInAdminParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) {
        final errorMessage = failure is AuthFailure
            ? failure.message
            : failure is NetworkFailure
                ? failure.message
                : failure is ServerFailure
                    ? failure.message
                    : failure is UnknownFailure
                        ? failure.message
                        : 'Admin authentication failed';
        print('❌ AdminBloc: Admin sign-in failed: $errorMessage');
        emit(state.copyWith(
          status: AdminStatus.error,
          errorMessage: errorMessage,
        ));
      },
      (admin) {
        print('✅ AdminBloc: Admin sign-in successful for admin: ${admin.id}');
        emit(state.copyWith(
          status: AdminStatus.authenticated,
          currentAdmin: admin,
          message: 'Successfully signed in as admin',
        ));
      },
    );
  }

  Future<void> _onAdminSignOutRequested(
    AdminSignOutRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(
      status: AdminStatus.unauthenticated,
      currentAdmin: null,
      users: [],
      admins: [],
      userAnalytics: null,
      habitAnalytics: null,
      systemAnalytics: null,
      message: 'Successfully signed out',
    ));
  }

  Future<void> _onAdminAutoAuthenticateRequested(
    AdminAutoAuthenticateRequested event,
    Emitter<AdminState> emit,
  ) async {
    print('🔐 AdminBloc: Auto-authenticating admin user from current session');
    emit(state.copyWith(status: AdminStatus.loading));

    try {
      // Get current Firebase user and check if they have admin privileges
      final firebaseAuth = sl<FirebaseAuth>();
      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        emit(state.copyWith(
          status: AdminStatus.unauthenticated,
          errorMessage: 'No authenticated user found',
        ));
        return;
      }

      // Get user data from Firestore to check admin role
      final firestore = sl<FirebaseFirestore>();
      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        emit(state.copyWith(
          status: AdminStatus.unauthenticated,
          errorMessage: 'User not found in database',
        ));
        return;
      }

      final userData = userDoc.data()!;
      final role = userData['role'] as String?;
      final isAdmin = userData['isAdmin'] as bool?;

      // Check if user has admin privileges
      if (role != 'admin' && isAdmin != true) {
        emit(state.copyWith(
          status: AdminStatus.unauthenticated,
          errorMessage: 'Access denied: Admin privileges required',
        ));
        return;
      }

      // Create AdminUser from current user data
      final adminUser = AdminUserModel(
        id: currentUser.uid,
        email: userData['email'] ?? currentUser.email ?? '',
        firstName: userData['firstName'] ?? 'Admin',
        lastName: userData['lastName'] ?? 'User',
        role: AdminRole.admin,
        permissions: AdminRole.admin.defaultPermissions,
        isActive: true,
        createdAt: userData['createdAt']?.toDate() ?? DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      print(
          '✅ AdminBloc: Auto-authentication successful for admin: ${adminUser.id}');
      emit(state.copyWith(
        status: AdminStatus.authenticated,
        currentAdmin: adminUser,
        message: 'Admin session restored',
      ));
    } catch (e) {
      print('❌ AdminBloc: Auto-authentication failed: ${e.toString()}');
      emit(state.copyWith(
        status: AdminStatus.unauthenticated,
        errorMessage: 'Failed to restore admin session: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadAllUsersRequested(
    LoadAllUsersRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await getAllUsers(
      GetAllUsersParams(
        limit: event.limit,
        lastUserId: event.lastUserId,
        searchQuery: event.searchQuery,
      ),
    );

    result.fold(
      (failure) {
        final errorMessage = _getFailureMessage(failure);
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
      },
      (users) {
        emit(state.copyWith(
          isLoading: false,
          users: users,
        ));
      },
    );
  }

  Future<void> _onBanUserRequested(
    BanUserRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await banUser(BanUserParams(userId: event.userId));

    result.fold(
      (failure) {
        final errorMessage = _getFailureMessage(failure);
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
      },
      (_) {
        // Update the user in the current list
        final updatedUsers = state.users.map((user) {
          if (user.id == event.userId) {
            return user.copyWith(isActive: false);
          }
          return user;
        }).toList();

        emit(state.copyWith(
          isLoading: false,
          users: updatedUsers,
          message: 'User has been banned successfully',
        ));
      },
    );
  }

  Future<void> _onUnbanUserRequested(
    UnbanUserRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await unbanUser(UnbanUserParams(userId: event.userId));

    result.fold(
      (failure) {
        final errorMessage = _getFailureMessage(failure);
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
      },
      (_) {
        // Update the user in the current list
        final updatedUsers = state.users.map((user) {
          if (user.id == event.userId) {
            return user.copyWith(isActive: true);
          }
          return user;
        }).toList();

        emit(state.copyWith(
          isLoading: false,
          users: updatedUsers,
          message: 'User has been unbanned successfully',
        ));
      },
    );
  }

  Future<void> _onDeleteUserRequested(
    DeleteUserRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await deleteUser(DeleteUserParams(userId: event.userId));

    result.fold(
      (failure) {
        final errorMessage = _getFailureMessage(failure);
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
      },
      (_) {
        // Remove the user from the current list
        final updatedUsers =
            state.users.where((user) => user.id != event.userId).toList();

        emit(state.copyWith(
          isLoading: false,
          users: updatedUsers,
          message: 'User has been deleted successfully',
        ));
      },
    );
  }

  Future<void> _onLoadUserAnalyticsRequested(
    LoadUserAnalyticsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await getUserAnalytics(
      GetAnalyticsParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) {
        final errorMessage = _getFailureMessage(failure);
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
      },
      (analytics) {
        emit(state.copyWith(
          isLoading: false,
          userAnalytics: analytics,
        ));
      },
    );
  }

  Future<void> _onLoadHabitAnalyticsRequested(
    LoadHabitAnalyticsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await getHabitAnalytics(
      GetAnalyticsParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) {
        final errorMessage = _getFailureMessage(failure);
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
      },
      (analytics) {
        emit(state.copyWith(
          isLoading: false,
          habitAnalytics: analytics,
        ));
      },
    );
  }

  Future<void> _onLoadSystemAnalyticsRequested(
    LoadSystemAnalyticsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await getSystemAnalytics(
      GetAnalyticsParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) {
        final errorMessage = _getFailureMessage(failure);
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
      },
      (analytics) {
        emit(state.copyWith(
          isLoading: false,
          systemAnalytics: analytics,
        ));
      },
    );
  }

  Future<void> _onLoadAllAnalyticsRequested(
    LoadAllAnalyticsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // Load all analytics in parallel
    final results = await Future.wait([
      getUserAnalytics(GetAnalyticsParams(
        startDate: event.startDate,
        endDate: event.endDate,
      )),
      getHabitAnalytics(GetAnalyticsParams(
        startDate: event.startDate,
        endDate: event.endDate,
      )),
      getSystemAnalytics(GetAnalyticsParams(
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    ]);

    emit(state.copyWith(
      isLoading: false,
      userAnalytics: results[0].fold(
        (failure) => null,
        (analytics) => analytics as UserAnalytics,
      ),
      habitAnalytics: results[1].fold(
        (failure) => null,
        (analytics) => analytics as HabitAnalytics,
      ),
      systemAnalytics: results[2].fold(
        (failure) => null,
        (analytics) => analytics as SystemAnalytics,
      ),
    ));
  }

  Future<void> _onExportUsersDataRequested(
    ExportUsersDataRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await exportUsersData(
      ExportDataParams(
        startDate: event.startDate,
        endDate: event.endDate,
        format: event.format,
      ),
    );

    result.fold(
      (failure) {
        final errorMessage = _getFailureMessage(failure);
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
      },
      (downloadUrl) {
        emit(state.copyWith(
          isLoading: false,
          message:
              'Users data exported successfully. Download URL: $downloadUrl',
        ));
      },
    );
  }

  Future<void> _onExportHabitsDataRequested(
    ExportHabitsDataRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await exportHabitsData(
      ExportDataParams(
        startDate: event.startDate,
        endDate: event.endDate,
        format: event.format,
      ),
    );

    result.fold(
      (failure) {
        final errorMessage = _getFailureMessage(failure);
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
      },
      (downloadUrl) {
        emit(state.copyWith(
          isLoading: false,
          message:
              'Habits data exported successfully. Download URL: $downloadUrl',
        ));
      },
    );
  }

  Future<void> _onClearAdminMessage(
    ClearAdminMessage event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.clearMessage());
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<AdminState> emit,
  ) async {
    // Refresh all data
    add(const LoadAllUsersRequested(limit: 20));
    add(const LoadAllAnalyticsRequested());
  }

  String _getFailureMessage(Failure failure) {
    if (failure is AuthFailure)
      return failure.message ?? 'Authentication failed';
    if (failure is NetworkFailure) return failure.message ?? 'Network error';
    if (failure is ServerFailure) return failure.message ?? 'Server error';
    if (failure is UnknownFailure) return failure.message ?? 'Unknown error';
    return 'An error occurred';
  }
}
