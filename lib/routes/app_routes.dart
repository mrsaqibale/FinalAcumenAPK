import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/email_verification_screen.dart';
import '../features/auth/screens/mentor_login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/auth/screens/email_confirmation_screen.dart';
import '../features/auth/screens/mentor_email_confirmation_screen.dart';
import '../features/auth/screens/create_new_password_screen.dart';
import '../features/business/screens/career_counseling_screen.dart';
import '../features/profile/screens/mentors_screen.dart';
import '../features/chat/screens/chats_screen.dart';
import '../features/notification/screens/notifications_screen.dart';
import '../features/onboard/screens/splash_screen.dart';
import '../features/onboard/screens/onboarding_screen.dart';
import '../features/dashboard/screens/admin_dashboard_screen.dart';
import '../features/dashboard/screens/mentor_dashboard_screen.dart';
import '../features/auth/screens/mentor_approval_screen.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/settings/screens/settings_screen.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  // Route names as constants
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String mentorDashboard = '/mentor-dashboard';
  static const String emailConfirmation = '/email-confirmation';
  static const String createNewPassword = '/create-new-password';
  static const String careerCounseling = '/career-counseling';
  static const String mentors = '/mentors';
  static const String chats = '/chats';
  static const String notifications = '/notifications';
  static const String adminDashboard = '/admin-dashboard';
  static const String mentorLogin = '/mentor-login';
  static const String mentorApproval = '/mentor-approval';
  static const String settings = '/settings';

  // Get all routes
  static Map<String, WidgetBuilder> getRoutes(bool onboardingComplete) {
    return {
      splash: (context) => SplashScreen(onboardingComplete: onboardingComplete),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      dashboard: (context) => const DashboardScreen(),
      mentorDashboard: (context) => const MentorDashboardScreen(),
      createNewPassword: (context) => const CreateNewPasswordScreen(),
      careerCounseling: (context) => const CareerCounselingScreen(),
      mentors: (context) => const MentorsScreen(),
      chats: (context) => const ChatsScreen(),
      notifications: (context) => const NotificationsScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
      mentorLogin: (context) => const MentorLoginScreen(),
      mentorApproval: (context) => MentorApprovalScreen(email: Provider.of<AuthController>(context, listen: false).currentUser?.email ?? ''),
      emailConfirmation: (context) => EmailConfirmationScreen(email: Provider.of<AuthController>(context, listen: false).currentUser?.email ?? ''),
      settings: (context) => const SettingsScreen(),
    };
  }

  // Navigate to email verification screen
  static void navigateToEmailVerification(BuildContext context, String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmailVerificationScreen(email: email),
      ),
    );
  }

  // Navigate to email confirmation screen
  static void navigateToEmailConfirmation(BuildContext context, String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmailConfirmationScreen(email: email),
      ),
    );
  }

  // Navigate to mentor email confirmation screen
  static void navigateToMentorEmailConfirmation(BuildContext context, String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MentorEmailConfirmationScreen(email: email),
      ),
    );
  }

  // Navigate to mentor approval screen
  static void navigateToMentorApproval(BuildContext context, String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MentorApprovalScreen(email: email),
      ),
    );
  }
} 
