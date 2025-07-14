import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final AdminRole role;
  final List<AdminPermission> permissions;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  const AdminUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.permissions,
    required this.createdAt,
    this.lastLoginAt,
    required this.isActive,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        role,
        permissions,
        createdAt,
        lastLoginAt,
        isActive,
      ];
}

enum AdminRole {
  superAdmin,
  admin,
  moderator,
  analyst,
}

enum AdminPermission {
  // User management
  viewUsers,
  editUsers,
  deleteUsers,
  banUsers,

  // Content management
  viewHabits,
  editHabits,
  deleteHabits,

  // Analytics
  viewAnalytics,
  exportData,

  // Admin management
  viewAdmins,
  editAdmins,
  deleteAdmins,

  // System
  viewSystemLogs,
  manageSettings,
  performBackups,
}

extension AdminRoleExtension on AdminRole {
  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.admin:
        return 'Admin';
      case AdminRole.moderator:
        return 'Moderator';
      case AdminRole.analyst:
        return 'Analyst';
    }
  }

  List<AdminPermission> get defaultPermissions {
    switch (this) {
      case AdminRole.superAdmin:
        return AdminPermission.values;
      case AdminRole.admin:
        return [
          AdminPermission.viewUsers,
          AdminPermission.editUsers,
          AdminPermission.deleteUsers,
          AdminPermission.banUsers,
          AdminPermission.viewHabits,
          AdminPermission.editHabits,
          AdminPermission.deleteHabits,
          AdminPermission.viewAnalytics,
          AdminPermission.exportData,
          AdminPermission.viewAdmins,
        ];
      case AdminRole.moderator:
        return [
          AdminPermission.viewUsers,
          AdminPermission.editUsers,
          AdminPermission.banUsers,
          AdminPermission.viewHabits,
          AdminPermission.editHabits,
          AdminPermission.viewAnalytics,
        ];
      case AdminRole.analyst:
        return [
          AdminPermission.viewUsers,
          AdminPermission.viewHabits,
          AdminPermission.viewAnalytics,
          AdminPermission.exportData,
        ];
    }
  }
}
