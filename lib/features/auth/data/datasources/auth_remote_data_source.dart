import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/account_deletion_status_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({required String email});

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phone,
    String? bio,
    String? gender,
    DateTime? birthdate,
    String? goal,
  });

  Future<void> deleteAccount();

  Future<AccountDeletionStatusModel> scheduleAccountDeletion({
    required Duration gracePeriod,
  });

  Future<AccountDeletionStatusModel> cancelScheduledDeletion();

  Future<AccountDeletionStatusModel> getAccountDeletionStatus();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Failed to sign in');
      }

      // Get additional user data from Firestore
      final userDoc =
          await firestore.collection('users').doc(credential.user!.uid).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // Create a new user document if it doesn't exist
        final userModel = UserModel.fromFirebaseUser(credential.user!);
        await firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());
        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Authentication failed');
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Failed to create account');
      }

      // Update display name with full name
      final fullName = '$firstName $lastName'.trim();
      await credential.user!.updateDisplayName(fullName);

      // Create user document in Firestore
      final userModel = UserModel.fromFirebaseUser(
        credential.user!,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Failed to create account');
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(message: 'Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final userCredential =
          await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException(message: 'Failed to sign in with Google');
      }

      final user = userCredential.user!;

      // Check if user document exists in Firestore
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // Create a new user document for Google sign-in
        final displayNameParts = user.displayName?.split(' ') ?? ['', ''];
        final firstName =
            displayNameParts.isNotEmpty ? displayNameParts[0] : '';
        final lastName = displayNameParts.length > 1
            ? displayNameParts.sublist(1).join(' ')
            : '';

        final userModel = UserModel.fromFirebaseUser(
          user,
          firstName: firstName,
          lastName: lastName,
          createdAt: DateTime.now(),
        );

        await firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toFirestore());

        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Google sign-in failed');
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Failed to send reset email');
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        return UserModel.fromFirebaseUser(user);
      }
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      try {
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        } else {
          return UserModel.fromFirebaseUser(user);
        }
      } catch (e) {
        return UserModel.fromFirebaseUser(user);
      }
    });
  }

  @override
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phone,
    String? bio,
    String? gender,
    DateTime? birthdate,
    String? goal,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const AuthException(message: 'No user logged in');

      // Update display name with full name if firstName or lastName provided
      if (firstName != null || lastName != null) {
        // Get current values from Firestore to build complete name
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        String currentFirstName = firstName ?? '';
        String currentLastName = lastName ?? '';

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          currentFirstName = firstName ?? data['firstName'] ?? '';
          currentLastName = lastName ?? data['lastName'] ?? '';
        }

        final fullName = '$currentFirstName $currentLastName'.trim();
        await user.updateDisplayName(fullName);
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore document
      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (phone != null) updateData['phone'] = phone;
      if (bio != null) updateData['bio'] = bio;
      if (gender != null) updateData['gender'] = gender;
      if (birthdate != null)
        updateData['birthdate'] = Timestamp.fromDate(birthdate);
      if (goal != null) updateData['goal'] = goal;
      updateData['updatedAt'] = Timestamp.now();

      await firestore.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const AuthException(message: 'No user logged in');

      // Delete user document from Firestore
      await firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<AccountDeletionStatusModel> scheduleAccountDeletion({
    required Duration gracePeriod,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const AuthException(message: 'No user logged in');

      final now = DateTime.now();
      final executeAt = now.add(gracePeriod);

      await firestore.collection('users').doc(user.uid).set({
        'deletionStatus': 'pending',
        'deletionScheduledAt': Timestamp.fromDate(now),
        'deletionExecuteAt': Timestamp.fromDate(executeAt),
        'deletionCancelledAt': FieldValue.delete(),
      }, SetOptions(merge: true));

      final updatedDoc =
          await firestore.collection('users').doc(user.uid).get();
      return AccountDeletionStatusModel.fromFirestore(
          updatedDoc.data() as Map<String, dynamic>?);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<AccountDeletionStatusModel> cancelScheduledDeletion() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const AuthException(message: 'No user logged in');

      await firestore.collection('users').doc(user.uid).set({
        'deletionStatus': 'cancelled',
        'deletionScheduledAt': FieldValue.delete(),
        'deletionExecuteAt': FieldValue.delete(),
        'deletionCancelledAt': Timestamp.now(),
      }, SetOptions(merge: true));

      final updatedDoc =
          await firestore.collection('users').doc(user.uid).get();
      return AccountDeletionStatusModel.fromFirestore(
          updatedDoc.data() as Map<String, dynamic>?);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<AccountDeletionStatusModel> getAccountDeletionStatus() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const AuthException(message: 'No user logged in');

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      return AccountDeletionStatusModel.fromFirestore(
          userDoc.data() as Map<String, dynamic>?);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }
}
