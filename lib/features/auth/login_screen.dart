import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusion_fiesta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleRememberMe(bool? value) {
    if (value != null) {
      setState(() {
        _rememberMe = value;
      });
    }
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _onForgotPasswordPressed() {
    Navigator.pushNamed(context, AppConstants.forgotPasswordRoute);
  }

  void _onRegisterPressed() {
    Navigator.pushNamed(context, AppConstants.registerRoute);
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
              height: size.height - MediaQuery.of(context).padding.top,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthAuthenticated) {
                      Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
                    } else if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // Header with animation
                      Center(
                        child: SizedBox(
                          height: 180,
                          child: Lottie.asset(
                            AppConstants.loginAnimation,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ).animate()
                          .fade(duration: 600.ms, curve: Curves.easeIn)
                          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack),

                      const SizedBox(height: 24),

                      // Welcome text
                      Text(
                        'Welcome Back!',
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
                        'Sign in to continue to FusionFiesta',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                          .fade(duration: 400.ms, delay: 300.ms)
                          .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                      const SizedBox(height: 40),

                      // Login form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                .fade(duration: 400.ms, delay: 400.ms)
                                .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                            const SizedBox(height: 20),

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
                                .fade(duration: 400.ms, delay: 500.ms)
                                .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                            const SizedBox(height: 16),

                            // Remember me
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: _toggleRememberMe,
                                      activeColor: theme.colorScheme.primary,
                                    ),
                                    Text(
                                      'Remember me',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onBackground,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: _onForgotPasswordPressed,
                                  child: Text(
                                    'Forgot Password?',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate()
                                .fade(duration: 400.ms, delay: 600.ms)
                                .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                            const SizedBox(height: 20),

                            // Login button
                            ElevatedButton(
                              onPressed: _onLoginPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Login',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ).animate()
                                .fade(duration: 400.ms, delay: 700.ms)
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
                                .fade(duration: 400.ms, delay: 800.ms),

                            const SizedBox(height: 20),

                            // Social login buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  icon: FontAwesomeIcons.google,
                                  color: const Color(0xFFDB4437),
                                  onPressed: () {
                                    // TODO: Implement Google login
                                  },
                                ),
                                const SizedBox(width: 20),
                                _buildSocialButton(
                                  icon: FontAwesomeIcons.facebook,
                                  color: const Color(0xFF4267B2),
                                  onPressed: () {
                                    // TODO: Implement Facebook login
                                  },
                                ),
                                const SizedBox(width: 20),
                                _buildSocialButton(
                                  icon: FontAwesomeIcons.apple,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  onPressed: () {
                                    // TODO: Implement Apple login
                                  },
                                ),
                              ],
                            ).animate()
                                .fade(duration: 400.ms, delay: 900.ms)
                                .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                            const Spacer(),

                            // Don't have an account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account? ',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: _onRegisterPressed,
                                  child: Text(
                                    'Register',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate()
                                .fade(duration: 400.ms, delay: 1000.ms),

                            const SizedBox(height: 16),
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