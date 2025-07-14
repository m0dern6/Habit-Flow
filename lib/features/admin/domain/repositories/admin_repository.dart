import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_user.dart';
import '../entities/analytics.dart';
import '../entities/user_management.dart';

abstract class AdminRepository {
  // Admin user management
  Future<Either<Failure, AdminUser>> signInAdmin({
    required String email,
    required String password,
  });

  Future<Either<Failure, List<AdminUser>>> getAllAdmins();
  Future<Either<Failure, AdminUser>> createAdmin(AdminUser admin);
  Future<Either<Failure, AdminUser>> updateAdmin(AdminUser admin);
  Future<Either<Failure, void>> deleteAdmin(String adminId);

  // User management
  Future<Either<Failure, List<UserManagement>>> getAllUsers({
    int? limit,
    String? lastUserId,
    String? searchQuery,
  });

  Future<Either<Failure, UserManagement>> getUserDetails(String userId);
  Future<Either<Failure, void>> updateUserRole(String userId, String role);
  Future<Either<Failure, void>> banUser(String userId);
  Future<Either<Failure, void>> unbanUser(String userId);
  Future<Either<Failure, void>> deleteUser(String userId);

  // Analytics
  Future<Either<Failure, UserAnalytics>> getUserAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, HabitAnalytics>> getHabitAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, SystemAnalytics>> getSystemAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Data export
  Future<Either<Failure, String>> exportUsersData({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  });

  Future<Either<Failure, String>> exportHabitsData({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  });

  // System operations
  Future<Either<Failure, void>> sendNotificationToAllUsers({
    required String title,
    required String message,
  });

  Future<Either<Failure, Map<String, dynamic>>> getSystemHealth();
}
