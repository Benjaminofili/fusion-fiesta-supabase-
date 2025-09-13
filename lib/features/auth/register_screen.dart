import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusion_fiesta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  String _selectedRole = 'Student';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _roles = ['Student', 'Organizer', 'Admin'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _toggleAgreeToTerms(bool? value) {
    if (value != null) {
      setState(() {
        _agreeToTerms = value;
      });
    }
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the terms and conditions')),
        );
        return;
      }

      // Map UI roles to service roles
      String role;
      if (_selectedRole == 'Student') {
        role = AppConstants.roleParticipant;
      } else if (_selectedRole == 'Organizer' || _selectedRole == 'Admin') {
        role = AppConstants.roleStaff;
      } else {
        role = AppConstants.roleVisitor;
      }

      // Dispatch RegisterEvent to AuthBloc
      context.read<AuthBloc>().add(
        RegisterEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: role,
        ),
      );
    }
  }

  void _onLoginPressed() {
    Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthAuthenticated) {
                      Navigator.pushReplacementNamed(context, AppConstants.verifyEmailRoute);
                    } else if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                      ),

                      // Header with animation
                      Center(
                        child: SizedBox(
                          height: 150,
                          child: Lottie.asset(
                            AppConstants.registerAnimation,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ).animate()
                          .fade(duration: 600.ms, curve: Curves.easeIn)
                          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack),

                      const SizedBox(height: 16),

                      // Welcome text
                      Text(
                        'Create Account',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                          .fade(duration: 400.ms, delay: 200.ms)
                          .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                      const SizedBox(height: 8),

                      Text(
                        'Sign up to join FusionFiesta',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                          .fade(duration: 400.ms, delay: 300.ms)
                          .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                      const SizedBox(height: 30),

                      // Registration form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Full Name field
                            _buildTextField(
                              controller: _nameController,
                              labelText: 'Full Name',
                              hintText: 'Enter your full name',
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ).animate()
                                .fade(duration: 400.ms, delay: 400.ms)
                                .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                            const SizedBox(height: 16),

                            // Email field
                            _buildTextField(
                              controller: _emailController,
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ).animate()
                                .fade(duration: 400.ms, delay: 500.ms)
                                .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                            const SizedBox(height: 16),

                            // Password field
                            _buildTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ).animate()
                                .fade(duration: 400.ms, delay: 600.ms)
                                .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                            const SizedBox(height: 16),

                            // Confirm Password field
                            _buildTextField(
                              controller: _confirmPasswordController,
                              labelText: 'Confirm Password',
                              hintText: 'Confirm your password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: _toggleConfirmPasswordVisibility,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ).animate()
                                .fade(duration: 400.ms, delay: 700.ms)
                                .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                            const SizedBox(height: 16),

                            // Role selection
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: InputDecoration(
                                labelText: 'Role',
                                prefixIcon: Icon(_getRoleIcon(_selectedRole), color: theme.colorScheme.primary),
                                filled: true,
                                fillColor: isDarkMode ? theme.colorScheme.surface : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                              items: _roles.map((role) {
                                return DropdownMenuItem<String>(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedRole = value;
                                  });
                                }
                              },
                            ).animate()
                                .fade(duration: 400.ms, delay: 800.ms)
                                .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                            const SizedBox(height: 16),

                            // Terms and conditions
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: _toggleAgreeToTerms,
                                  activeColor: theme.colorScheme.primary,
                                ),
                                Expanded(
                                  child: Text(
                                    'I agree to the Terms and Conditions',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onBackground,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate()
                                .fade(duration: 400.ms, delay: 900.ms)
                                .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                            const SizedBox(height: 20),

                            // Register button
                            ElevatedButton(
                              onPressed: _onRegisterPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Register',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ).animate()
                                .fade(duration: 400.ms, delay: 1000.ms)
                                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack),

                            const SizedBox(height: 20),

                            // Or continue with
                            Row(
                              children: [
                                Expanded(child: Divider(color: theme.colorScheme.onBackground.withOpacity(0.3))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Or continue with',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: theme.colorScheme.onBackground.withOpacity(0.3))),
                              ],
                            ).animate()
                                .fade(duration: 400.ms, delay: 1100.ms),

                            const SizedBox(height: 20),

                            // Social login buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  icon: FontAwesomeIcons.google,
                                  color: const Color(0xFFDB4437),
                                  onPressed: () {
                                    // TODO: Implement Google registration
                                  },
                                ),
                                const SizedBox(width: 20),
                                _buildSocialButton(
                                  icon: FontAwesomeIcons.facebook,
                                  color: const Color(0xFF4267B2),
                                  onPressed: () {
                                    // TODO: Implement Facebook registration
                                  },
                                ),
                                const SizedBox(width: 20),
                                _buildSocialButton(
                                  icon: FontAwesomeIcons.apple,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  onPressed: () {
                                    // TODO: Implement Apple registration
                                  },
                                ),
                              ],
                            ).animate()
                                .fade(duration: 400.ms, delay: 1200.ms)
                                .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                            const SizedBox(height: 30),

                            // Already have an account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: _onLoginPressed,
                                  child: Text(
                                    'Login',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate()
                                .fade(duration: 400.ms, delay: 1300.ms),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Student':
        return Icons.school;
      case 'Organizer':
        return Icons.event;
      case 'Admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDarkMode ? theme.colorScheme.surface : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isDarkMode ? theme.colorScheme.surface : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: FaIcon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}