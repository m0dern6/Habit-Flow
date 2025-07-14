import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);
  Future<UserProfileModel> createUserProfile(UserProfileModel profile);
  Future<void> deleteUserProfile(String userId);
  Future<String> uploadProfileImage(String userId, String imagePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw ServerException(message: 'User profile not found');
      }

      return UserProfileModel.fromFirestore(userDoc);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
          message: 'Failed to get user profile: ${e.toString()}');
    }
  }

  @override
  Future<UserProfileModel> createUserProfile(UserProfileModel profile) async {
    try {
      final profileData = profile.toFirestore();
      await firestore
          .collection('users')
          .doc(profile.userId)
          .set(profileData, SetOptions(merge: true));

      final doc = await firestore.collection('users').doc(profile.userId).get();
      return UserProfileModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(
          message: 'Failed to create user profile: ${e.toString()}');
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(profile.userId)
          .update(updatedProfile.toFirestore());

      final doc = await firestore.collection('users').doc(profile.userId).get();

      return UserProfileModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(
          message: 'Failed to update user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    try {
      // Since we're using the users collection, we just need to clear profile fields
      // but keep the essential auth fields
      final updateData = <String, dynamic>{
        'phone': FieldValue.delete(),
        'bio': FieldValue.delete(),
        'gender': FieldValue.delete(),
        'birthdate': FieldValue.delete(),
        'goal': FieldValue.delete(),
        'updatedAt': Timestamp.now(),
      };

      await firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw ServerException(
          message: 'Failed to delete user profile: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      final ref = storage.ref().child('profile_images').child('$userId.jpg');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw ServerException(
          message: 'Failed to upload profile image: ${e.toString()}');
    }
  }
}
