import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_user.dart';

class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.role,
    required super.permissions,
    required super.createdAt,
    super.lastLoginAt,
    required super.isActive,
  });

  factory AdminUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AdminUserModel(
      id: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      role: AdminRole.values.firstWhere(
        (role) => role.name == data['role'],
        orElse: () => AdminRole.analyst,
      ),
      permissions: (data['permissions'] as List<dynamic>?)
              ?.map((p) => AdminPermission.values.firstWhere(
                    (perm) => perm.name == p,
                    orElse: () => AdminPermission.viewUsers,
                  ))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  factory AdminUserModel.fromEntity(AdminUser admin) {
    return AdminUserModel(
      id: admin.id,
      email: admin.email,
      firstName: admin.firstName,
      lastName: admin.lastName,
      role: admin.role,
      permissions: admin.permissions,
      createdAt: admin.createdAt,
      lastLoginAt: admin.lastLoginAt,
      isActive: admin.isActive,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
      'permissions': permissions.map((p) => p.name).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isActive': isActive,
    };
  }

  AdminUserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    AdminRole? role,
    List<AdminPermission>? permissions,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
