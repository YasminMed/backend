import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'package:skillora/providers/theme_provider.dart';

import 'package:skillora/screens/auth/forgot_password_screen.dart';
import 'package:skillora/screens/auth/login_screen.dart';
import 'package:skillora/screens/auth/reset_password_screen.dart';
import 'package:skillora/screens/auth/signup_screen.dart';
import 'package:skillora/screens/auth/splash.dart';
import 'package:skillora/screens/auth/submit_code_screen.dart';
import 'package:skillora/screens/career/career_main_layout.dart';
import 'package:skillora/screens/career/career_profile_screen.dart';
import 'package:skillora/screens/career/cv_analyzer_screen.dart';
import 'package:skillora/screens/career/salary_estimation_screen.dart';

import 'package:skillora/screens/auth/path_selection_screen.dart';
import 'package:skillora/screens/study/student_main_screen.dart';
import 'package:skillora/screens/study/study_profile_screen.dart';

import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';
import 'screens/auth/welcome_screen.dart';

import 'package:skillora/providers/auth_provider.dart';
import 'package:skillora/providers/course_provider.dart';
import 'package:skillora/providers/goal_provider.dart';
import 'package:skillora/providers/note_provider.dart';
import 'package:skillora/providers/journey_provider.dart';
import 'package:skillora/providers/milestone_provider.dart';
import 'package:skillora/providers/activity_provider.dart';
import 'package:skillora/providers/portfolio_provider.dart';
import 'package:skillora/providers/roadmap_provider.dart';

import 'package:skillora/providers/career_nav_provider.dart';
import 'package:skillora/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CourseProvider>(
          create: (context) => CourseProvider(),
          update: (context, auth, courseProvider) =>
              courseProvider!..updateUser(auth.currentUserModel),
        ),
        ChangeNotifierProvider(create: (context) => GoalProvider()),
        ChangeNotifierProvider(create: (context) => NoteProvider()),
        ChangeNotifierProvider(create: (context) => JourneyProvider()),
        ChangeNotifierProvider(create: (context) => MilestoneProvider()),
        ChangeNotifierProvider(create: (context) => ActivityProvider()),
        ChangeNotifierProvider(create: (context) => PortfolioProvider()),
        ChangeNotifierProvider(create: (context) => RoadmapProvider()),
        ChangeNotifierProvider(create: (context) => CareerNavProvider()),
      ],
      child: const CareerPathApp(),
    ),
  );
}

class CareerPathApp extends StatelessWidget {
  const CareerPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Skillora',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            primaryColor: AppColors.getMainColor(context),
            scaffoldBackgroundColor: Colors.white,
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.getMainColor(context),
              elevation: 0,
              titleTextStyle: AppTextStyles.h2.copyWith(color: Colors.white),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            colorScheme: ColorScheme.light(
              primary: AppColors.getMainColor(context),
              secondary: AppColors.getMainColor(context),
            ),
            textTheme: TextTheme(
              headlineLarge: AppTextStyles.h1,
              headlineMedium: AppTextStyles.h2,
              bodyMedium: AppTextStyles.body,
              bodySmall: AppTextStyles.small,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            primaryColor: AppColors.getMainColor(context),
            scaffoldBackgroundColor: Colors.black,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(
              primary: AppColors.getMainColor(context),
              surface: const Color(0xFF121212),
              onSurface: Colors.white,
              onPrimary: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              elevation: 0,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF121212),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            textTheme: TextTheme(
              headlineLarge: AppTextStyles.h1.copyWith(color: Colors.white),
              headlineMedium: AppTextStyles.h2.copyWith(color: Colors.white),
              bodyMedium: AppTextStyles.body.copyWith(color: Colors.white),
              bodySmall: AppTextStyles.small.copyWith(color: Colors.white),
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/splash': (context) => const SkilloraSplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/forgot_password': (context) => const ForgotPasswordEmailScreen(),
            '/code_submit': (context) => const SubmitCodeScreen(),
            '/reset_pass': (context) => const ResetPasswordScreen(),
            '/modes': (context) => const PathSelectionScreen(),
            '/student_main': (context) => const StudentMainScreen(),
            '/student_profile': (context) => const StudyProfileWidget(),
            '/career_main': (context) => const CareerMainLayout(),
            '/career_profile': (context) => const CareerProfileScreen(),
            '/cv_analyzer': (context) => const CVAnalyzerWidget(),
            '/salary_estimator': (context) => const SalaryEstimationWidget(),
          },
        );
      },
    );
  }
}
