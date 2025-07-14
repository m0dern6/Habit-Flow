import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.userId,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phone,
    super.bio,
    super.photoUrl,
    super.gender,
    super.birthdate,
    super.goal,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      id: doc.id, // This will be the userId since we're using users collection
      userId: doc.id, // Same as id in the users collection
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      bio: data['bio'],
      photoUrl: data['photoUrl'],
      gender: data['gender'],
      birthdate: data['birthdate'] != null
          ? (data['birthdate'] as Timestamp).toDate()
          : null,
      goal: data['goal'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      userId: profile.userId,
      firstName: profile.firstName,
      lastName: profile.lastName,
      email: profile.email,
      phone: profile.phone,
      bio: profile.bio,
      photoUrl: profile.photoUrl,
      gender: profile.gender,
      birthdate: profile.birthdate,
      goal: profile.goal,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'bio': bio,
      'photoUrl': photoUrl,
      'gender': gender,
      'birthdate': birthdate != null ? Timestamp.fromDate(birthdate!) : null,
      'goal': goal,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      bio: bio,
      photoUrl: photoUrl,
      gender: gender,
      birthdate: birthdate,
      goal: goal,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  UserProfileModel copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? bio,
    String? photoUrl,
    String? gender,
    DateTime? birthdate,
    String? goal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
