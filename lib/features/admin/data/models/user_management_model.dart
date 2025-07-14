import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_management.dart';

class UserManagementModel extends UserManagement {
  const UserManagementModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.photoUrl,
    required super.createdAt,
    super.lastLoginAt,
    required super.isActive,
    required super.isEmailVerified,
    required super.totalHabits,
    required super.activeHabits,
    required super.averageCompletionRate,
    required super.streakCount,
  });

  factory UserManagementModel.fromFirestore(
    DocumentSnapshot userDoc,
    Map<String, dynamic> habitStats,
  ) {
    final data = userDoc.data() as Map<String, dynamic>;

    return UserManagementModel(
      id: userDoc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      isEmailVerified: data['isEmailVerified'] ?? false,
      totalHabits: habitStats['totalHabits'] ?? 0,
      activeHabits: habitStats['activeHabits'] ?? 0,
      averageCompletionRate:
          (habitStats['averageCompletionRate'] ?? 0.0).toDouble(),
      streakCount: habitStats['streakCount'] ?? 0,
    );
  }

  factory UserManagementModel.fromUserDoc(DocumentSnapshot userDoc) {
    final data = userDoc.data() as Map<String, dynamic>;

    return UserManagementModel(
      id: userDoc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      isEmailVerified: data['isEmailVerified'] ?? false,
      totalHabits: 0, // These will be calculated separately
      activeHabits: 0,
      averageCompletionRate: 0.0,
      streakCount: 0,
    );
  }

  UserManagementModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    bool? isEmailVerified,
    int? totalHabits,
    int? activeHabits,
    double? averageCompletionRate,
    int? streakCount,
  }) {
    return UserManagementModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      totalHabits: totalHabits ?? this.totalHabits,
      activeHabits: activeHabits ?? this.activeHabits,
      averageCompletionRate:
          averageCompletionRate ?? this.averageCompletionRate,
      streakCount: streakCount ?? this.streakCount,
    );
  }
}
