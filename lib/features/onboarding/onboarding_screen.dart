import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to FusionFiesta',
      description: 'Your one-stop solution for all college events and activities',
      animationPath: AppConstants.welcomeAnimation,
      backgroundColor: const Color(0xFF6C63FF),
    ),
    OnboardingPage(
      title: 'Register & Participate',
      description: 'Seamlessly register for events, receive notifications, and track your participation',
      animationPath: AppConstants.registerAnimation,
      backgroundColor: const Color(0xFFFF5722),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
          _isLastPage = _currentPage == _pages.length - 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_isLastPage) {
      _onGetStartedPressed();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onGetStartedPressed() {
    // Change this if you don't have login, replace with registerRoute
    Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
  }

  void _onSkipPressed() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            // Background and page content
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              color: _pages[_currentPage].backgroundColor,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], size, theme);
                },
              ),
            ),

            // Bottom navigation controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip button
                    AnimatedOpacity(
                      opacity: _isLastPage ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: TextButton(
                        onPressed: _isLastPage ? null : _onSkipPressed,
                        child: Text(
                          'Skip',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Page indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                        spacing: 6,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white.withOpacity(0.5),
                      ),
                    ),

                    // Next/Get Started button
                    ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _pages[_currentPage].backgroundColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isLastPage ? 'Get Started' : 'Next',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, Size size, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animation
          Expanded(
            flex: 5,
            child: Lottie.asset(
              page.animationPath,
              width: size.width * 0.8,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, color: Colors.white, size: size.width * 0.5);
              },
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ).animate()
              .fade(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate()
              .fade(duration: 400.ms, delay: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String animationPath;
  final Color backgroundColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.animationPath,
    required this.backgroundColor,
  });
}
