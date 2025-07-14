import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_text_field.dart';
import '../../../../core/utils/form_validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Name _firstName = const Name.pure();
  Name _lastName = const Name.pure();
  Email _email = const Email.pure();
  Password _password = const Password.pure();
  ConfirmPassword _confirmPassword = const ConfirmPassword.pure();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onFirstNameChanged() {
    setState(() {
      _firstName = Name.dirty(_firstNameController.text);
    });
  }

  void _onLastNameChanged() {
    setState(() {
      _lastName = Name.dirty(_lastNameController.text);
    });
  }

  void _onEmailChanged() {
    setState(() {
      _email = Email.dirty(_emailController.text);
    });
  }

  void _onPasswordChanged() {
    setState(() {
      _password = Password.dirty(_passwordController.text);
      _confirmPassword = ConfirmPassword.dirty(
        originalPassword: _passwordController.text,
        value: _confirmPasswordController.text,
      );
    });
  }

  void _onConfirmPasswordChanged() {
    setState(() {
      _confirmPassword = ConfirmPassword.dirty(
        originalPassword: _passwordController.text,
        value: _confirmPasswordController.text,
      );
    });
  }

  void _onSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  String? _getFirstNameError() {
    if (_firstName.displayError == NameValidationError.empty) {
      return AppStrings.nameRequired;
    } else if (_firstName.displayError == NameValidationError.tooLong) {
      return AppStrings.nameTooLong;
    }
    return null;
  }

  String? _getLastNameError() {
    if (_lastName.displayError == NameValidationError.empty) {
      return AppStrings.nameRequired;
    } else if (_lastName.displayError == NameValidationError.tooLong) {
      return AppStrings.nameTooLong;
    }
    return null;
  }

  String? _getEmailError() {
    if (_email.displayError == EmailValidationError.empty) {
      return AppStrings.emailRequired;
    } else if (_email.displayError == EmailValidationError.invalid) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  String? _getPasswordError() {
    if (_password.displayError == PasswordValidationError.empty) {
      return AppStrings.passwordRequired;
    } else if (_password.displayError == PasswordValidationError.tooShort) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  String? _getConfirmPasswordError() {
    if (_confirmPassword.displayError == ConfirmPasswordValidationError.empty) {
      return AppStrings.confirmPasswordRequired;
    } else if (_confirmPassword.displayError ==
        ConfirmPasswordValidationError.noMatch) {
      return AppStrings.passwordMismatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/home');
          } else if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? AppStrings.unknownError),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Header
                  Text(
                    AppStrings.createAccount,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    AppStrings.signUpSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // First Name Field
                  NeumorphicTextField(
                    controller: _firstNameController,
                    labelText: AppStrings.firstName,
                    keyboardType: TextInputType.name,
                    onChanged: (_) => _onFirstNameChanged(),
                    validator: (_) => _getFirstNameError(),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),

                  const SizedBox(height: 16),

                  // Last Name Field
                  NeumorphicTextField(
                    controller: _lastNameController,
                    labelText: AppStrings.lastName,
                    keyboardType: TextInputType.name,
                    onChanged: (_) => _onLastNameChanged(),
                    validator: (_) => _getLastNameError(),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  NeumorphicTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => _onEmailChanged(),
                    validator: (_) => _getEmailError(),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  NeumorphicTextField(
                    controller: _passwordController,
                    labelText: AppStrings.password,
                    obscureText: _obscurePassword,
                    onChanged: (_) => _onPasswordChanged(),
                    validator: (_) => _getPasswordError(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  NeumorphicTextField(
                    controller: _confirmPasswordController,
                    labelText: AppStrings.confirmPassword,
                    obscureText: _obscureConfirmPassword,
                    onChanged: (_) => _onConfirmPasswordChanged(),
                    validator: (_) => _getConfirmPasswordError(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sign Up Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return NeumorphicButton(
                        onPressed: state.status == AuthStatus.loading
                            ? null
                            : _onSignUp,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: state.status == AuthStatus.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textPrimary,
                                  ),
                                )
                              : Text(
                                  AppStrings.signUp,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // OR Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Google Sign-In Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return NeumorphicButton(
                        onPressed: state.status == AuthStatus.loading
                            ? null
                            : () {
                                context
                                    .read<AuthBloc>()
                                    .add(AuthGoogleSignInRequested());
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: state.status == AuthStatus.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textPrimary,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png',
                                      height: 24,
                                      width: 24,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'G',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/sign-in'),
                        child: Text(
                          AppStrings.signIn,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
