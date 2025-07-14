import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/admin_user.dart';
import '../models/admin_user_model.dart';
import '../models/user_management_model.dart';

abstract class AdminRemoteDataSource {
  Future<AdminUserModel> signInAdmin({
    required String email,
    required String password,
  });

  Future<List<AdminUserModel>> getAllAdmins();
  Future<AdminUserModel> createAdmin(AdminUserModel admin);
  Future<AdminUserModel> updateAdmin(AdminUserModel admin);
  Future<void> deleteAdmin(String adminId);

  Future<List<UserManagementModel>> getAllUsers({
    int? limit,
    String? lastUserId,
    String? searchQuery,
  });

  Future<UserManagementModel> getUserDetails(String userId);
  Future<void> updateUserRole(String userId, String role);
  Future<void> banUser(String userId);
  Future<void> unbanUser(String userId);
  Future<void> deleteUser(String userId);

  Future<Map<String, dynamic>> getUserAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Map<String, dynamic>> getHabitAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Map<String, dynamic>> getSystemAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<String> exportUsersData({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  });

  Future<String> exportHabitsData({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  AdminRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<AdminUserModel> signInAdmin({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthException(message: 'Authentication failed');
      }

      // Check if user has admin role in Firestore
      final userDoc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await firebaseAuth.signOut();
        throw const AuthException(message: 'User not found in database');
      }

      final userData = userDoc.data()!;
      final role = userData['role'] as String?;
      final isAdmin = userData['isAdmin'] as bool?;

      // Check if user has admin privileges
      if (role != 'admin' && isAdmin != true) {
        await firebaseAuth.signOut();
        throw const AuthException(
          message: 'Access denied: Admin privileges required',
        );
      }

      // Create AdminUser from user data
      return AdminUserModel(
        id: userCredential.user!.uid,
        email: userData['email'] ?? email,
        firstName: userData['firstName'] ?? 'Admin',
        lastName: userData['lastName'] ?? 'User',
        role:
            AdminRole.admin, // Set role as admin since user passed admin check
        permissions: AdminRole
            .admin.defaultPermissions, // Admin has all admin permissions
        isActive: true,
        createdAt: userData['createdAt']?.toDate() ?? DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = 'Authentication failed: ${e.message}';
      }
      throw AuthException(message: message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<List<AdminUserModel>> getAllAdmins() async {
    try {
      final querySnapshot = await firestore
          .collection('admins')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AdminUserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AdminUserModel> createAdmin(AdminUserModel admin) async {
    try {
      final docRef =
          await firestore.collection('admins').add(admin.toFirestore());

      final doc = await docRef.get();
      return AdminUserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AdminUserModel> updateAdmin(AdminUserModel admin) async {
    try {
      await firestore
          .collection('admins')
          .doc(admin.id)
          .update(admin.toFirestore());

      final doc = await firestore.collection('admins').doc(admin.id).get();
      return AdminUserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteAdmin(String adminId) async {
    try {
      // Soft delete by setting isActive to false
      await firestore
          .collection('admins')
          .doc(adminId)
          .update({'isActive': false});
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<UserManagementModel>> getAllUsers({
    int? limit,
    String? lastUserId,
    String? searchQuery,
  }) async {
    try {
      Query query =
          firestore.collection('users').orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastUserId != null) {
        final lastDoc =
            await firestore.collection('users').doc(lastUserId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final querySnapshot = await query.get();

      // Get basic user data
      final users = querySnapshot.docs
          .map((doc) => UserManagementModel.fromUserDoc(doc))
          .toList();

      // TODO: Enhance with habit statistics
      // For now, return users with basic data
      return users;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserManagementModel> getUserDetails(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw const ServerException(message: 'User not found');
      }

      // Get user's habit statistics
      final habitsQuery = await firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .get();

      final habitStats = {
        'totalHabits': habitsQuery.docs.length,
        'activeHabits': habitsQuery.docs
            .where((doc) => (doc.data()['isActive'] ?? true) == true)
            .length,
        'averageCompletionRate': 0.0, // TODO: Calculate from habit entries
        'streakCount': 0, // TODO: Calculate streaks
      };

      return UserManagementModel.fromFirestore(userDoc, habitStats);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> banUser(String userId) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'isActive': false,
        'bannedAt': Timestamp.now(),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unbanUser(String userId) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'isActive': true,
        'bannedAt': FieldValue.delete(),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      // Start a batch write to delete user and related data
      final batch = firestore.batch();

      // Delete user document
      batch.delete(firestore.collection('users').doc(userId));

      // Delete user's habits
      final habitsQuery = await firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .get();

      for (final habitDoc in habitsQuery.docs) {
        batch.delete(habitDoc.reference);
      }

      // Delete user's habit entries
      final entriesQuery = await firestore
          .collection('habit_entries')
          .where('userId', isEqualTo: userId)
          .get();

      for (final entryDoc in entriesQuery.docs) {
        batch.delete(entryDoc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getUserAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final now = DateTime.now();
      final start = startDate ?? now.subtract(const Duration(days: 30));
      final end = endDate ?? now;

      // Get total users
      final totalUsersQuery = await firestore.collection('users').get();
      final totalUsers = totalUsersQuery.docs.length;

      // Get active users (users with recent activity)
      final activeUsersQuery = await firestore
          .collection('users')
          .where('lastLoginAt',
              isGreaterThan:
                  Timestamp.fromDate(now.subtract(const Duration(days: 7))))
          .get();
      final activeUsers = activeUsersQuery.docs.length;

      // Get new users in date range
      final newUsersQuery = await firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final newUsers = newUsersQuery.docs.length;

      return {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'newUsersInPeriod': newUsers,
        'userGrowthData': [], // TODO: Calculate daily growth
        'usersByCountry': <String, int>{}, // TODO: If you track country data
        'averageSessionDuration': 0.0, // TODO: If you track session data
        'totalSessions': 0, // TODO: If you track session data
      };
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getHabitAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get total habits
      final totalHabitsQuery = await firestore.collection('habits').get();
      final totalHabits = totalHabitsQuery.docs.length;

      // Get active habits
      final activeHabitsQuery = await firestore
          .collection('habits')
          .where('isActive', isEqualTo: true)
          .get();
      final activeHabits = activeHabitsQuery.docs.length;

      // Get today's completed habits
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final completedTodayQuery = await firestore
          .collection('habit_entries')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('completed', isEqualTo: true)
          .get();

      final completedToday = completedTodayQuery.docs.length;

      return {
        'totalHabits': totalHabits,
        'activeHabits': activeHabits,
        'completedHabitsToday': completedToday,
        'averageCompletionRate': 0.0, // TODO: Calculate from entries
        'habitsByCategory': <Map<String, dynamic>>[], // TODO: Group by category
        'completionTrends': <Map<String, dynamic>>[], // TODO: Calculate trends
        'popularHabits': <String, int>{}, // TODO: Find most popular habits
      };
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // This would typically come from monitoring services
      // For now, return mock data
      return {
        'totalApiCalls': 10000,
        'averageResponseTime': 250.0,
        'errorCount': 15,
        'uptime': 99.9,
        'apiEndpointUsage': <String, int>{
          '/api/users': 3000,
          '/api/habits': 2500,
          '/api/analytics': 1000,
        },
        'performanceMetrics': <Map<String, dynamic>>[],
      };
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> exportUsersData({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  }) async {
    try {
      // This would generate and return a download URL
      // For now, return a mock URL
      return 'https://example.com/exports/users_${DateTime.now().millisecondsSinceEpoch}.$format';
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> exportHabitsData({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  }) async {
    try {
      // This would generate and return a download URL
      // For now, return a mock URL
      return 'https://example.com/exports/habits_${DateTime.now().millisecondsSinceEpoch}.$format';
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
