import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/profile/controllers/user_controller.dart';
import 'features/chat/controllers/chat_controller.dart';
import 'features/notification/controllers/notification_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/chat/models/chat_message_model.dart';
import 'features/chat/models/chat_conversation_model.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'package:acumen/services/image_cache_service.dart';
import 'firebase_options.dart';
import 'package:acumen/features/chat/services/chat_service.dart';

void main() async {
  // Ensure Flutter is initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();  // Ensure that widget binding is initialized
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ChatMessageAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ChatConversationAdapter());
  }
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize services
  await ImageCacheService.init();
  await ChatService.init();
  
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: MaterialApp(
        title: 'Acumen Connectify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.getRoutes(onboardingComplete),
      ),
    );
  }
}
