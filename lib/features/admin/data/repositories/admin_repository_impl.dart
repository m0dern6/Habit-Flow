import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/network_info.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/entities/user_management.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';
import '../models/admin_user_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AdminRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AdminUser>> signInAdmin({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final admin = await remoteDataSource.signInAdmin(
          email: email,
          password: password,
        );
        return Right(admin);
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<AdminUser>>> getAllAdmins() async {
    if (await networkInfo.isConnected) {
      try {
        final admins = await remoteDataSource.getAllAdmins();
        return Right(admins);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> createAdmin(AdminUser admin) async {
    if (await networkInfo.isConnected) {
      try {
        final adminModel = AdminUserModel.fromEntity(admin);
        final createdAdmin = await remoteDataSource.createAdmin(adminModel);
        return Right(createdAdmin);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> updateAdmin(AdminUser admin) async {
    if (await networkInfo.isConnected) {
      try {
        final adminModel = AdminUserModel.fromEntity(admin);
        final updatedAdmin = await remoteDataSource.updateAdmin(adminModel);
        return Right(updatedAdmin);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAdmin(String adminId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAdmin(adminId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<UserManagement>>> getAllUsers({
    int? limit,
    String? lastUserId,
    String? searchQuery,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final users = await remoteDataSource.getAllUsers(
          limit: limit,
          lastUserId: lastUserId,
          searchQuery: searchQuery,
        );
        return Right(users);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserManagement>> getUserDetails(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getUserDetails(userId);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRole(
      String userId, String role) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateUserRole(userId, role);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> banUser(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.banUser(userId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> unbanUser(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.unbanUser(userId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteUser(userId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserAnalytics>> getUserAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final data = await remoteDataSource.getUserAnalytics(
          startDate: startDate,
          endDate: endDate,
        );

        final analytics = UserAnalytics(
          totalUsers: data['totalUsers'] ?? 0,
          activeUsers: data['activeUsers'] ?? 0,
          newUsersToday: data['newUsersToday'] ?? 0,
          newUsersThisWeek: data['newUsersThisWeek'] ?? 0,
          newUsersThisMonth: data['newUsersThisMonth'] ?? 0,
          userGrowthData: [], // TODO: Parse from data
          usersByCountry: Map<String, int>.from(data['usersByCountry'] ?? {}),
          averageSessionDuration:
              (data['averageSessionDuration'] ?? 0.0).toDouble(),
          totalSessions: data['totalSessions'] ?? 0,
        );

        return Right(analytics);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, HabitAnalytics>> getHabitAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final data = await remoteDataSource.getHabitAnalytics(
          startDate: startDate,
          endDate: endDate,
        );

        final analytics = HabitAnalytics(
          totalHabits: data['totalHabits'] ?? 0,
          activeHabits: data['activeHabits'] ?? 0,
          completedHabitsToday: data['completedHabitsToday'] ?? 0,
          averageCompletionRate:
              (data['averageCompletionRate'] ?? 0.0).toDouble(),
          habitsByCategory: [], // TODO: Parse from data
          completionTrends: [], // TODO: Parse from data
          popularHabits: Map<String, int>.from(data['popularHabits'] ?? {}),
        );

        return Right(analytics);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, SystemAnalytics>> getSystemAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final data = await remoteDataSource.getSystemAnalytics(
          startDate: startDate,
          endDate: endDate,
        );

        final analytics = SystemAnalytics(
          totalApiCalls: data['totalApiCalls'] ?? 0,
          averageResponseTime: (data['averageResponseTime'] ?? 0.0).toDouble(),
          errorCount: data['errorCount'] ?? 0,
          uptime: (data['uptime'] ?? 0.0).toDouble(),
          apiEndpointUsage:
              Map<String, int>.from(data['apiEndpointUsage'] ?? {}),
          performanceMetrics: [], // TODO: Parse from data
        );

        return Right(analytics);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> exportUsersData({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final url = await remoteDataSource.exportUsersData(
          startDate: startDate,
          endDate: endDate,
          format: format,
        );
        return Right(url);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> exportHabitsData({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final url = await remoteDataSource.exportHabitsData(
          startDate: startDate,
          endDate: endDate,
          format: format,
        );
        return Right(url);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> sendNotificationToAllUsers({
    required String title,
    required String message,
  }) async {
    // TODO: Implement notification sending
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSystemHealth() async {
    // TODO: Implement system health check
    return const Right({
      'status': 'healthy',
      'uptime': '99.9%',
      'lastCheck': 'now',
    });
  }
}
