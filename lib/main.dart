import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'package:fusion_fiesta/core/theme/app_theme.dart';
import 'package:fusion_fiesta/core/constants/app_constants.dart';

import 'package:fusion_fiesta/features/splash/splash_screen.dart';
import 'package:fusion_fiesta/features/onboarding/onboarding_screen.dart';
import 'package:fusion_fiesta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fusion_fiesta/features/events/presentation/bloc/events_bloc.dart';
import 'package:fusion_fiesta/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fusion_fiesta/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fusion_fiesta/features/certificates/presentation/bloc/certificates_bloc.dart';
import 'package:fusion_fiesta/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:fusion_fiesta/features/feedback/presentation/bloc/feedback_bloc.dart';

// import 'features/auth/login_screen.dart';
import 'package:fusion_fiesta/core/navigation/app_router.dart';

import 'core/services/app_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppService.initialize();
    print('✅ App initialized successfully');
  } catch (e) {
    print('❌ App initialization failed: $e');
  }
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
            BlocProvider<EventsBloc>(create: (context) => EventsBloc()),
            BlocProvider<DashboardBloc>(create: (context) => DashboardBloc()),
            BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()),
            BlocProvider<CertificatesBloc>(create: (context) => CertificatesBloc()),
            BlocProvider<GalleryBloc>(create: (context) => GalleryBloc()),
            BlocProvider<FeedbackBloc>(create: (context) => FeedbackBloc()),
          ],
          child: MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            builder: (context, child) {
              return ResponsiveBreakpoints.builder(
                child: child!,
                breakpoints: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 800, name: TABLET),
                  const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                ],
              );
            },
            initialRoute: AppConstants.splashRoute,
            onGenerateRoute: AppRouter.generateRoute,
          ),
        );
      },
    );
  }
}
