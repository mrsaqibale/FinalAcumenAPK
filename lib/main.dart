import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() async {
  // Ensure Flutter is initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Check if onboarding has been completed before
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
  
  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;
  
  const MyApp({
    super.key,
    required this.onboardingComplete,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acumen Connectify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.getRoutes(onboardingComplete),
    );
  }
}
