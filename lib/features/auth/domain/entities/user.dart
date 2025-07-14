import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? bio;
  final String? photoUrl;
  final String? gender;
  final DateTime? birthdate;
  final String? goal;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final String? role;
  final bool isAdmin;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.bio,
    this.photoUrl,
    this.gender,
    this.birthdate,
    this.goal,
    required this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.role,
    this.isAdmin = false,
  });

  String get fullName => '$firstName $lastName';

  User copyWith({
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
    return User(
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

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phone,
        bio,
        photoUrl,
        gender,
        birthdate,
        goal,
        createdAt,
        updatedAt,
        isEmailVerified,
        role,
        isAdmin,
      ];
}
