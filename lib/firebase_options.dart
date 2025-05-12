import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Default Firebase configuration options for the current platform
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Since we don't have the actual Firebase configuration,
    // we'll use a generic configuration that will be replaced
    // with the actual values when Firebase.initializeApp is called
    // without options parameter
    return const FirebaseOptions(
      apiKey: 'placeholder-api-key',
      appId: 'placeholder-app-id',
      messagingSenderId: 'placeholder-sender-id',
      projectId: 'placeholder-project-id',
    );
  }
} 