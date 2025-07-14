import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/neumorphism_style.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_text_field.dart';
import '../../../../core/utils/form_validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  Email _email = const Email.pure();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    setState(() {
      _email = Email.dirty(_emailController.text);
    });
  }

  void _onSendResetEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthPasswordResetRequested(email: _emailController.text),
          );
    }
  }

  String? _getEmailError() {
    if (_email.displayError == EmailValidationError.empty) {
      return AppStrings.fieldRequired;
    } else if (_email.displayError == EmailValidationError.invalid) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/sign-in'),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Failed to send reset email'),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.message == 'Password reset email sent') {
            setState(() {
              _emailSent = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset email sent successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceContainerHighest,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: NeumorphismStyle.createNeumorphism(
                        color: theme.colorScheme.surface,
                        depth: 12,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.email_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      AppStrings.resetPassword,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _emailSent
                          ? 'We\'ve sent you a password reset link. Please check your email and follow the instructions.'
                          : 'Enter your email address and we\'ll send you a link to reset your password.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 48),

                    if (!_emailSent) ...[
                      // Email Field
                      NeumorphicTextField(
                        controller: _emailController,
                        labelText: AppStrings.email,
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => _onEmailChanged(),
                        validator: (_) => _getEmailError(),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),

                      const SizedBox(height: 32),

                      // Send Reset Email Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return NeumorphicButton(
                            onPressed: state.status == AuthStatus.loading
                                ? null
                                : _onSendResetEmail,
                            color: AppColors.primary,
                            child: state.status == AuthStatus.loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Send Reset Email',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ] else ...[
                      // Success Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: NeumorphismStyle.createNeumorphism(
                          color: theme.colorScheme.surface,
                          depth: 16,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(60)),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 60,
                            color: AppColors.success,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Back to Sign In Button
                      NeumorphicButton(
                        onPressed: () => context.go('/sign-in'),
                        color: AppColors.primary,
                        child: Text(
                          'Back to Sign In',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Resend Email Button
                      NeumorphicButton(
                        onPressed: () {
                          setState(() {
                            _emailSent = false;
                          });
                        },
                        color: theme.colorScheme.surface,
                        child: Text(
                          'Resend Email',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
