import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Default Firebase configuration options for the current platform
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyCc-2MB4pItAmLQREVp7S6-IEMMhWdNTSo',
          appId: '1:320837688409:android:690ee6a94453e63bdbe548',
          messagingSenderId: '320837688409',
          projectId: 'acumen-connectify-cb686',
          storageBucket: 'acumen-connectify-cb686.firebasestorage.app',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
} 