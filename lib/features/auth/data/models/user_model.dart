import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.bio,
    super.photoUrl,
    super.gender,
    super.birthdate,
    super.goal,
    required super.createdAt,
    super.updatedAt,
    super.isEmailVerified,
    super.role,
    super.isAdmin,
  });

  factory UserModel.fromFirebaseUser(
    firebase_auth.User firebaseUser, {
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    String? gender,
    DateTime? birthdate,
    String? goal,
    DateTime? createdAt,
    String? role,
    bool? isAdmin,
  }) {
    // Parse display name if provided
    String fName = firstName ?? '';
    String lName = lastName ?? '';

    if (firstName == null &&
        lastName == null &&
        firebaseUser.displayName != null) {
      final nameParts = firebaseUser.displayName!.split(' ');
      fName = nameParts.isNotEmpty ? nameParts.first : '';
      lName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }

    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      firstName: fName,
      lastName: lName,
      phone: phone,
      bio: bio,
      photoUrl: firebaseUser.photoURL,
      gender: gender,
      birthdate: birthdate,
      goal: goal,
      createdAt: createdAt ?? DateTime.now(),
      isEmailVerified: firebaseUser.emailVerified,
      role: role,
      isAdmin: isAdmin ?? false,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'],
      bio: data['bio'],
      photoUrl: data['photoUrl'],
      gender: data['gender'],
      birthdate: data['birthdate'] != null
          ? (data['birthdate'] as Timestamp).toDate()
          : null,
      goal: data['goal'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      role: data['role'],
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      bio: json['bio'],
      photoUrl: json['photoUrl'],
      gender: json['gender'],
      birthdate:
          json['birthdate'] != null ? DateTime.parse(json['birthdate']) : null,
      goal: json['goal'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'bio': bio,
      'photoUrl': photoUrl,
      'gender': gender,
      'birthdate': birthdate?.toIso8601String(),
      'goal': goal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'role': role,
      'isAdmin': isAdmin,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'bio': bio,
      'photoUrl': photoUrl,
      'gender': gender,
      'birthdate': birthdate != null ? Timestamp.fromDate(birthdate!) : null,
      'goal': goal,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isEmailVerified': isEmailVerified,
      'role': role,
      'isAdmin': isAdmin,
    };
  }

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    String? photoUrl,
    String? gender,
    DateTime? birthdate,
    String? goal,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    String? role,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
