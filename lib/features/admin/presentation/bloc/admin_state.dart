import 'package:demo_app/features/admin/domain/entities/admin_user.dart';
import 'package:demo_app/features/admin/domain/entities/analytics.dart';
import 'package:demo_app/features/admin/domain/entities/user_management.dart';
import 'package:equatable/equatable.dart';

enum AdminStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AdminState extends Equatable {
  final AdminStatus status;
  final AdminUser? currentAdmin;
  final List<UserManagement> users;
  final List<AdminUser> admins;
  final UserAnalytics? userAnalytics;
  final HabitAnalytics? habitAnalytics;
  final SystemAnalytics? systemAnalytics;
  final String? message;
  final String? errorMessage;
  final bool isLoading;

  const AdminState({
    this.status = AdminStatus.initial,
    this.currentAdmin,
    this.users = const [],
    this.admins = const [],
    this.userAnalytics,
    this.habitAnalytics,
    this.systemAnalytics,
    this.message,
    this.errorMessage,
    this.isLoading = false,
  });

  AdminState copyWith({
    AdminStatus? status,
    AdminUser? currentAdmin,
    List<UserManagement>? users,
    List<AdminUser>? admins,
    UserAnalytics? userAnalytics,
    HabitAnalytics? habitAnalytics,
    SystemAnalytics? systemAnalytics,
    String? message,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AdminState(
      status: status ?? this.status,
      currentAdmin: currentAdmin ?? this.currentAdmin,
      users: users ?? this.users,
      admins: admins ?? this.admins,
      userAnalytics: userAnalytics ?? this.userAnalytics,
      habitAnalytics: habitAnalytics ?? this.habitAnalytics,
      systemAnalytics: systemAnalytics ?? this.systemAnalytics,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  AdminState clearMessage() {
    return copyWith(
      message: null,
      errorMessage: null,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentAdmin,
        users,
        admins,
        userAnalytics,
        habitAnalytics,
        systemAnalytics,
        message,
        errorMessage,
        isLoading,
      ];
}
