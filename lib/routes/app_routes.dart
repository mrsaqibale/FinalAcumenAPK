import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/auth/email_confirmation_screen.dart';
import '../screens/auth/create_new_password_screen.dart';
import '../screens/career/career_counseling_screen.dart';
import '../screens/mentors/mentors_screen.dart';
import '../screens/messaging/chats_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/dashboard/admin_dashboard_screen.dart';

class AppRoutes {
  // Route names as constants
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String dashboard = '/dashboard';
  static const String emailConfirmation = '/email-confirmation';
  static const String createNewPassword = '/create-new-password';
  static const String careerCounseling = '/career-counseling';
  static const String mentors = '/mentors';
  static const String chats = '/chats';
  static const String notifications = '/notifications';
  static const String adminDashboard = '/admin-dashboard';

  // Get all routes
  static Map<String, WidgetBuilder> getRoutes(bool onboardingComplete) {
    return {
      splash: (context) => SplashScreen(onboardingComplete: onboardingComplete),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      emailVerification: (context) => const EmailVerificationScreen(),
      dashboard: (context) => const DashboardScreen(),
      emailConfirmation: (context) => const EmailConfirmationScreen(),
      createNewPassword: (context) => const CreateNewPasswordScreen(),
      careerCounseling: (context) => const CareerCounselingScreen(),
      mentors: (context) => const MentorsScreen(),
      chats: (context) => const ChatsScreen(),
      notifications: (context) => const NotificationsScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
    };
  }
} 
