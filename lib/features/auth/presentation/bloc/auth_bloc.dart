import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset_email.dart';
import '../../domain/usecases/sign_in_with_email_and_password.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email_and_password.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailAndPassword signInWithEmailAndPassword;
  final SignUpWithEmailAndPassword signUpWithEmailAndPassword;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final SendPasswordResetEmail sendPasswordResetEmail;
  final AuthRepository authRepository;

  late StreamSubscription _authSubscription;

  AuthBloc({
    required this.signInWithEmailAndPassword,
    required this.signUpWithEmailAndPassword,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
    required this.sendPasswordResetEmail,
    required this.authRepository,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthUserChanged>(_onAuthUserChanged);

    // Listen to auth state changes
    _authSubscription = authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user: user)),
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await getCurrentUser(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        message: failure.toString(),
      )),
      (user) => emit(state.copyWith(
        status: user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: user,
      )),
    );
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 AuthBloc: Sign-in requested for email: ${event.email}');
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await signInWithEmailAndPassword(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) {
        final errorMessage = failure is AuthFailure
            ? failure.message
            : failure is NetworkFailure
                ? failure.message
                : failure is ServerFailure
                    ? failure.message
                    : failure is UnknownFailure
                        ? failure.message
                        : 'An error occurred';
        print('❌ AuthBloc: Sign-in failed: $errorMessage');
        emit(state.copyWith(
          status: AuthStatus.error,
          message: errorMessage,
        ));
      },
      (user) {
        print('✅ AuthBloc: Sign-in successful for user: ${user.id}');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          message: 'Successfully signed in',
        ));
      },
    );
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('📝 AuthBloc: Sign-up requested for email: ${event.email}');
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await signUpWithEmailAndPassword(
      SignUpParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      ),
    );

    result.fold(
      (failure) {
        final errorMessage = failure is AuthFailure
            ? failure.message
            : failure is NetworkFailure
                ? failure.message
                : failure is ServerFailure
                    ? failure.message
                    : failure is UnknownFailure
                        ? failure.message
                        : 'An error occurred';
        print('❌ AuthBloc: Sign-up failed: $errorMessage');
        emit(state.copyWith(
          status: AuthStatus.error,
          message: errorMessage,
        ));
      },
      (user) {
        print('✅ AuthBloc: Sign-up successful for user: ${user.id}');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          message: 'Successfully signed up',
        ));
      },
    );
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔍 AuthBloc: Google sign-in requested');
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await signInWithGoogle(NoParams());

    result.fold(
      (failure) {
        final errorMessage = failure is AuthFailure
            ? failure.message
            : failure is NetworkFailure
                ? failure.message
                : failure is ServerFailure
                    ? failure.message
                    : failure is UnknownFailure
                        ? failure.message
                        : 'Google sign-in failed';
        print('❌ AuthBloc: Google sign-in failed: $errorMessage');
        emit(state.copyWith(
          status: AuthStatus.error,
          message: errorMessage,
        ));
      },
      (user) {
        print('✅ AuthBloc: Google sign-in successful for user: ${user.id}');
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          message: 'Successfully signed in with Google',
        ));
      },
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await signOut(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        message: failure.toString(),
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        message: 'Successfully signed out',
      )),
    );
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await sendPasswordResetEmail(
      SendPasswordResetEmailParams(email: event.email),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        message: failure.toString(),
      )),
      (_) => emit(state.copyWith(
        status: state.status,
        message: 'Password reset email sent',
      )),
    );
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: event.user,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ));
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
