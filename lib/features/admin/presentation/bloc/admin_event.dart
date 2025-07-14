import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

// Authentication Events
class AdminSignInRequested extends AdminEvent {
  final String email;
  final String password;

  const AdminSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AdminSignOutRequested extends AdminEvent {}

class AdminAutoAuthenticateRequested extends AdminEvent {
  const AdminAutoAuthenticateRequested();
}

// User Management Events
class LoadAllUsersRequested extends AdminEvent {
  final int? limit;
  final String? lastUserId;
  final String? searchQuery;

  const LoadAllUsersRequested({
    this.limit,
    this.lastUserId,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [limit, lastUserId, searchQuery];
}

class BanUserRequested extends AdminEvent {
  final String userId;

  const BanUserRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UnbanUserRequested extends AdminEvent {
  final String userId;

  const UnbanUserRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class DeleteUserRequested extends AdminEvent {
  final String userId;

  const DeleteUserRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

// Analytics Events
class LoadUserAnalyticsRequested extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadUserAnalyticsRequested({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadHabitAnalyticsRequested extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadHabitAnalyticsRequested({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadSystemAnalyticsRequested extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadSystemAnalyticsRequested({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadAllAnalyticsRequested extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadAllAnalyticsRequested({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

// Export Events
class ExportUsersDataRequested extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String format;

  const ExportUsersDataRequested({
    this.startDate,
    this.endDate,
    this.format = 'csv',
  });

  @override
  List<Object?> get props => [startDate, endDate, format];
}

class ExportHabitsDataRequested extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String format;

  const ExportHabitsDataRequested({
    this.startDate,
    this.endDate,
    this.format = 'csv',
  });

  @override
  List<Object?> get props => [startDate, endDate, format];
}

// Admin Management Events
class LoadAllAdminsRequested extends AdminEvent {}

// Clear Events
class ClearAdminMessage extends AdminEvent {}

class RefreshDashboard extends AdminEvent {}
