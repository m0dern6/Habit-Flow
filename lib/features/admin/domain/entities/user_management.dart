import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user.dart';

class UserManagement extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final bool isEmailVerified;
  final int totalHabits;
  final int activeHabits;
  final double averageCompletionRate;
  final int streakCount;

  const UserManagement({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    required this.isActive,
    required this.isEmailVerified,
    required this.totalHabits,
    required this.activeHabits,
    required this.averageCompletionRate,
    required this.streakCount,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserManagement.fromUser(User user) {
    return UserManagement(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      lastLoginAt: null, // This would need to be tracked separately
      isActive: true, // Assume active if user exists
      isEmailVerified: user.isEmailVerified,
      totalHabits: 0, // These would be calculated from habits
      activeHabits: 0,
      averageCompletionRate: 0.0,
      streakCount: 0,
    );
  }

  UserManagement copyWith({
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
    return UserManagement(
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

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phone,
        photoUrl,
        createdAt,
        lastLoginAt,
        isActive,
        isEmailVerified,
        totalHabits,
        activeHabits,
        averageCompletionRate,
        streakCount,
      ];
}
