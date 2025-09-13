import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fusion_fiesta/core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Forgot Password',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _emailSent ? _buildSuccessView(theme) : _buildFormView(theme),
        ),
      ),
    );
  }
  
  Widget _buildFormView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Icon(
          Icons.lock_reset,
          size: 80,
          color: theme.colorScheme.primary,
        ).animate()
          .fade(duration: 600.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms),
        
        const SizedBox(height: 24),
        
        Text(
          'Forgot Your Password?',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ).animate()
          .fade(duration: 600.ms, delay: 200.ms),
        
        const SizedBox(height: 16),
        
        Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ).animate()
          .fade(duration: 600.ms, delay: 400.ms),
        
        const SizedBox(height: 40),
        
        // Form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
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
                .fade(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms),
              
              const SizedBox(height: 32),
              
              // Reset Password Button
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Text(
                        'RESET PASSWORD',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ).animate()
                .fade(duration: 600.ms, delay: 800.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Back to Login
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Back to Login',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ).animate()
          .fade(duration: 600.ms, delay: 1000.ms),
      ],
    );
  }
  
  Widget _buildSuccessView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Icon
        Icon(
          Icons.check_circle_outline,
          size: 100,
          color: Colors.green,
        ).animate()
          .fade(duration: 600.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms),
        
        const SizedBox(height: 32),
        
        Text(
          'Email Sent!',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ).animate()
          .fade(duration: 600.ms, delay: 200.ms),
        
        const SizedBox(height: 16),
        
        Text(
          'We\'ve sent a password reset link to:\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onBackground,
          ),
        ).animate()
          .fade(duration: 600.ms, delay: 400.ms),
        
        const SizedBox(height: 16),
        
        Text(
          'Please check your email and follow the instructions to reset your password.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ).animate()
          .fade(duration: 600.ms, delay: 600.ms),
        
        const SizedBox(height: 40),
        
        // Didn't receive email
        Text(
          'Didn\'t receive the email?',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ).animate()
          .fade(duration: 600.ms, delay: 800.ms),
        
        const SizedBox(height: 8),
        
        // Resend Email Button
        TextButton(
          onPressed: () {
            setState(() {
              _isLoading = true;
            });
            
            // Simulate API call
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                _isLoading = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email resent successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            });
          },
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : Text(
                  'Resend Email',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ).animate()
          .fade(duration: 600.ms, delay: 1000.ms),
        
        const SizedBox(height: 32),
        
        // Back to Login
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'BACK TO LOGIN',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ).animate()
          .fade(duration: 600.ms, delay: 1200.ms)
          .slideY(begin: 0.2, end: 0, duration: 600.ms),
      ],
    );
  }
}