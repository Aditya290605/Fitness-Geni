import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/theme/app_colors.dart';

/// Signup screen - User registration UI
/// No actual authentication logic in MVP v1
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validate name
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    return null;
  }

  /// Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppConstants.errorInvalidEmail;
    }
    return null;
  }

  /// Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    if (value.length < 6) {
      return AppConstants.errorPasswordTooShort;
    }
    return null;
  }

  /// Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    if (value != _passwordController.text) {
      return AppConstants.errorPasswordMismatch;
    }
    return null;
  }

  /// Handle signup button press
  /// No actual authentication - just navigate to main screen for MVP v1
  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      // In MVP v1, just navigate to main screen
      // No actual authentication logic
      context.go(AppConstants.routeMain);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Branding
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.signupSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Name Field
                CustomTextField(
                  labelText: AppConstants.name,
                  hintText: 'Enter your name',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: _validateName,
                ),

                const SizedBox(height: 16),

                // Email Field
                CustomTextField(
                  labelText: AppConstants.email,
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: _validateEmail,
                ),

                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  labelText: AppConstants.password,
                  hintText: 'Create a password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: _validatePassword,
                ),

                const SizedBox(height: 16),

                // Confirm Password Field
                CustomTextField(
                  labelText: AppConstants.confirmPassword,
                  hintText: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: _validateConfirmPassword,
                ),

                const SizedBox(height: 32),

                // Signup Button
                CustomButton(
                  text: AppConstants.signup,
                  onPressed: _handleSignup,
                ),

                const SizedBox(height: 24),

                // Login Link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppConstants.alreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          AppConstants.login,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
