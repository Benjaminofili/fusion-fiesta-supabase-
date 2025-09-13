import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
// ...existing code...
import 'package:lottie/lottie.dart';

import 'package:fusion_fiesta/core/constants/app_constants.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isVerifying = false;
  bool _isResending = false;
  bool _isVerified = false;
  int _resendTimer = 60;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // Add listeners to focus nodes and controllers
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        setState(() {});
      });

      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 5) {
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resendCode() {
    if (_resendTimer > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isResending = false;
        _resendTimer = 60;
        _startResendTimer();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code resent to ${widget.email}'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _verifyCode() {
    // Get the full code
    final code = _controllers.map((c) => c.text).join();

    // Check if code is complete
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    // Simulate verification API call
    // For demo purposes, we'll consider '123456' as the valid code
    Future.delayed(const Duration(seconds: 2), () {
      if (code == '123456') {
        setState(() {
          _isVerifying = false;
          _isVerified = true;
        });

        // Show success animation and navigate to appropriate dashboard
        Future.delayed(const Duration(seconds: 2), () {
          // Navigate to login screen after verification
          Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
        });
      } else {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Invalid verification code. Please try again.';
          
          // Clear all fields
          for (var controller in _controllers) {
            controller.clear();
          }
          
          // Focus on first field
          FocusScope.of(context).requestFocus(_focusNodes[0]);
        });
      }
    });
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
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.02),
                
                // Animation
                _isVerified
                    ? Lottie.network(
                        'https://assets10.lottiefiles.com/packages/lf20_s6bvy00q.json',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        repeat: false,
                      )
                    : Lottie.network(
                        'https://assets2.lottiefiles.com/packages/lf20_k9wsvmgz.json',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                
                SizedBox(height: size.height * 0.03),
                
                // Title
                Text(
                  _isVerified ? 'Email Verified!' : 'Email Verification',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ).animate()
                  .fade(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms),
                
                SizedBox(height: size.height * 0.02),
                
                // Subtitle
                Text(
                  _isVerified
                      ? 'Your email has been successfully verified. Redirecting to dashboard...'
                      : 'We have sent a verification code to',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ).animate()
                  .fade(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms),
                
                if (!_isVerified) ...[  
                  const SizedBox(height: 8),
                  
                  // Email
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ).animate()
                    .fade(duration: 500.ms, delay: 400.ms),
                  
                  SizedBox(height: size.height * 0.04),
                  
                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (index) => _buildOtpTextField(index),
                    ),
                  ).animate()
                    .fade(duration: 500.ms, delay: 600.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms),
                  
                  SizedBox(height: size.height * 0.02),
                  
                  // Error Message
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ).animate()
                      .fade(duration: 300.ms),
                  
                  SizedBox(height: size.height * 0.04),
                  
                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isVerifying
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Verify'),
                    ),
                  ).animate()
                    .fade(duration: 500.ms, delay: 800.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms),
                  
                  SizedBox(height: size.height * 0.03),
                  
                  // Resend Code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      _resendTimer > 0
                          ? Text(
                              "Resend in ${_resendTimer}s",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary.withOpacity(0.7),
                              ),
                            )
                          : _isResending
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: _resendCode,
                                  child: Text(
                                    "Resend",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                    ],
                  ).animate()
                    .fade(duration: 500.ms, delay: 1000.ms),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpTextField(int index) {
    final theme = Theme.of(context);
    final isFocused = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;

    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: isFocused
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused
              ? theme.colorScheme.primary
              : hasValue
                  ? theme.colorScheme.primary.withOpacity(0.5)
                  : theme.colorScheme.outline.withOpacity(0.3),
          width: isFocused ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
          
          // Auto-verify when all fields are filled
          if (value.isNotEmpty && index == 5) {
            bool allFilled = true;
            for (var controller in _controllers) {
              if (controller.text.isEmpty) {
                allFilled = false;
                break;
              }
            }
            
            if (allFilled) {
              _verifyCode();
            }
          }
        },
      ),
    );
  }
}