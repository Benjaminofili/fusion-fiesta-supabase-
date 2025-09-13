import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:fusion_fiesta/core/theme/app_theme.dart';
import 'package:fusion_fiesta/features/auth/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    
    // Navigate to login screen after animation completes
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo animation
            Lottie.asset(
              'assets/animations/splash_animation.json',
              controller: _controller,
              height: size.height * 0.3,
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..forward();
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.celebration,
                  size: 120,
                  color: theme.colorScheme.primary,
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // App name
            Text(
              'FusionFiesta',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ).animate()
              .fade(duration: 600.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
            
            const SizedBox(height: 16),
            
            // Tagline
            Text(
              'Where College Events Come Alive',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ).animate()
              .fade(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
            
            const SizedBox(height: 64),
            
            // Loading indicator
            SizedBox(
              width: size.width * 0.4,
              child: LinearProgressIndicator(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                color: theme.colorScheme.primary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
              ),
            ).animate()
              .fade(duration: 600.ms, delay: 900.ms)
              .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
          ],
        ),
      ),
    );
  }
}