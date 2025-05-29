import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/profile/controllers/user_controller.dart';
import 'features/chat/controllers/chat_controller.dart';
import 'features/notification/controllers/notification_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/events/controllers/event_controller.dart';
import 'features/chat/models/chat_message_model.dart';
import 'features/chat/models/chat_conversation_model.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'package:acumen/services/image_cache_service.dart';
import 'package:acumen/features/chat/services/chat_service.dart';
import 'package:acumen/services/session_timeout_service.dart';
import 'package:acumen/features/business/controllers/quiz_results_controller.dart';
import 'package:acumen/features/chat/screens/community_chat_screen.dart';
import 'package:acumen/features/profile/screens/user_profile_screen.dart';
import 'package:acumen/features/resources/screens/resource_detail_screen.dart';
import 'package:acumen/features/resources/models/resource_item.dart';
import 'package:acumen/features/events/screens/event_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Global Navigator key for accessing navigator from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter is initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that widget binding is initialized

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

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    // Use debug provider for development
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

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

  const MyApp({super.key, required this.onboardingComplete});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => EventController()),
      ],
      child: MaterialApp(
        title: 'Acumen Connectify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.getRoutes(onboardingComplete),
        navigatorKey: navigatorKey,
        onGenerateRoute: (settings) {
          // Handle dynamic routes
          final uri = Uri.parse(settings.name ?? '');
          final pathSegments = uri.pathSegments;

          if (pathSegments.isEmpty) return null;

          // Handle community routes
          if (pathSegments[0] == 'community' && pathSegments.length > 1) {
            return MaterialPageRoute(
              builder:
                  (context) => FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('communities')
                            .doc(pathSegments[1])
                            .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return Scaffold(
                          body: Center(
                            child: Text(
                              'Error: ${snapshot.error ?? "Community not found"}',
                            ),
                          ),
                        );
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return CommunityChatScreen(
                        communityId: pathSegments[1],
                        communityName: data['name'] ?? 'Unknown Community',
                        memberIds:
                            (data['members'] as List<dynamic>?)?.cast<String>(),
                        imageUrl: data['imageUrl'],
                      );
                    },
                  ),
            );
          }

          // Handle profile routes
          if (pathSegments[0] == 'profile' && pathSegments.length > 1) {
            return MaterialPageRoute(
              builder:
                  (context) => FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(pathSegments[1])
                            .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return Scaffold(
                          body: Center(
                            child: Text(
                              'Error: ${snapshot.error ?? "User not found"}',
                            ),
                          ),
                        );
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return UserProfileScreen(
                        name: data['name'] ?? 'Unknown User',
                        email: data['email'] ?? '',
                        bio: data['bio'] ?? '',
                        skills: List<String>.from(data['skills'] ?? []),
                        imageUrl: data['photoUrl'] ?? '',
                      );
                    },
                  ),
            );
          }

          // Handle resource routes
          if (pathSegments[0] == 'resource' && pathSegments.length > 1) {
            return MaterialPageRoute(
              builder:
                  (context) => FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('resources')
                            .doc(pathSegments[1])
                            .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return Scaffold(
                          body: Center(
                            child: Text(
                              'Error: ${snapshot.error ?? "Resource not found"}',
                            ),
                          ),
                        );
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return ResourceDetailScreen(
                        resource: ResourceItem.fromFirestore(snapshot.data!),
                      );
                    },
                  ),
            );
          }

          // Handle event routes
          if (pathSegments[0] == 'event' && pathSegments.length > 1) {
            return MaterialPageRoute(
              builder:
                  (context) => FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('events')
                            .doc(pathSegments[1])
                            .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return Scaffold(
                          body: Center(
                            child: Text(
                              'Error: ${snapshot.error ?? "Event not found"}',
                            ),
                          ),
                        );
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return EventDetailScreen(
                        eventId: pathSegments[1],
                        event: data,
                      );
                    },
                  ),
            );
          }

          return null;
        },
        builder: (context, child) {
          // Initialize session timeout service
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SessionTimeoutService.init(context);
          });

          // Update user activity on any interaction
          return GestureDetector(
            onTap: () => SessionTimeoutService.updateUserActivity(),
            onPanDown: (_) => SessionTimeoutService.updateUserActivity(),
            onScaleStart: (_) => SessionTimeoutService.updateUserActivity(),
            child: child!,
          );
        },
      ),
    );
  }
}
