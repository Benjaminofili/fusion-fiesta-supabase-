import 'package:flutter/material.dart';

// Screens
import '../../features/certificates/certificates_screen.dart';
import '../../features/events/event_list_screen.dart';
import '../../features/feedback/feedback_screen.dart';
import '../../features/gallery/gallery_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/dashboard/student_dashboard.dart';
import '../../features/dashboard/organizer_dashboard.dart';
import '../../features/dashboard/admin_dashboard.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/events/event_details_screen.dart';
import '../../features/help/help_screen.dart';
import '../../features/about/about_screen.dart';
import '../../features/my_events/my_events_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';

// Constants
import '../constants/app_constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint("AppRouter: Requested route: '${settings.name ?? ''}'");

    switch (settings.name) {
      // 🔹 Splash & Onboarding
      case AppConstants.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppConstants.onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      // 🔹 Authentication
      case AppConstants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppConstants.registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppConstants.forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppConstants.verifyEmailRoute:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: email),
        );

      // 🔹 Dashboards
      case AppConstants.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppConstants.studentRoute:
        return MaterialPageRoute(builder: (_) => const StudentDashboard());
      case AppConstants.organizerRoute:
        return MaterialPageRoute(builder: (_) => const OrganizerDashboard());
      case AppConstants.adminRoute:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      // 🔹 Core Features
      case AppConstants.notificationsRoute:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case AppConstants.eventGalleryRoute:
        return MaterialPageRoute(builder: (_) => const GalleryScreen());
      case AppConstants.helpRoute:
        return MaterialPageRoute(builder: (_) => const HelpScreen());
      case AppConstants.aboutRoute:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case AppConstants.feedbackRoute:
        return MaterialPageRoute(builder: (_) => const FeedbackScreen());
      case AppConstants.eventsRoute:
        return MaterialPageRoute(builder: (_) => const EventListScreen());
      case AppConstants.eventDetailsRoute:
        final eventId = settings.arguments as String? ?? '1';
        return MaterialPageRoute(
          builder: (_) => EventDetailsScreen(eventId: eventId),
        );
      case AppConstants.myEventsRoute:
        return MaterialPageRoute(builder: (_) => const MyEventsScreen());

      // 🔹 Profile & Certificates
      case AppConstants.profileRoute:
        final userId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(userId: userId),
        );
      case AppConstants.certificatesRoute:
        return MaterialPageRoute(builder: (_) => const CertificatesScreen());

        // 🔹 Additional Routes from AppConstants getters
        case AppConstants.galleryRoute:
          return MaterialPageRoute(builder: (_) => const GalleryScreen());
        case AppConstants.mediaGalleryRoute:
          return MaterialPageRoute(builder: (_) => const GalleryScreen());
        case AppConstants.feedbackManagementRoute:
          return MaterialPageRoute(builder: (_) => const FeedbackScreen());
        case AppConstants.systemSettingsRoute:
          return MaterialPageRoute(builder: (_) => const SettingsScreen());
        case AppConstants.userDetailsRoute:
          return MaterialPageRoute(builder: (_) => const ProfileScreen(userId: ''));
        case AppConstants.eventManagementRoute:
          return MaterialPageRoute(builder: (_) => const EventListScreen());
        case AppConstants.createEventRoute:
          return MaterialPageRoute(builder: (_) => const EventListScreen());
        case AppConstants.certificateManagementRoute:
          return MaterialPageRoute(builder: (_) => const CertificatesScreen());
        case AppConstants.participantsRoute:
          return MaterialPageRoute(builder: (_) => const MyEventsScreen());
      // 🔹 Settings
      case AppConstants.settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      // 🔹 Default (error)
      default:
        return errorRoute(settings.name);
    }
  }
}

Route<dynamic> errorRoute([String? routeName]) {
  return MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text(
          routeName != null
              ? '❌ Route not found: $routeName'
              : '❌ Route not found!',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    ),
  );
}
