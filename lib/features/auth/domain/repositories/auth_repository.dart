import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  Future<Either<Failure, User?>> getCurrentUser();

  Stream<User?> get authStateChanges;

  Future<Either<Failure, void>> updateProfile({
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phone,
    String? bio,
    String? gender,
    DateTime? birthdate,
    String? goal,
  });

  Future<Either<Failure, void>> deleteAccount();
}
