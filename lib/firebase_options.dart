import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_wyWTADeXqZaBpNvofGFbQ5187VGstJ8',
    appId: '1:615728327231:web:108450bced656e4e94668a',
    messagingSenderId: '615728327231',
    projectId: 'sam-messenger-210d6',
    authDomain: 'sam-messenger-210d6.firebaseapp.com',
    storageBucket: 'sam-messenger-210d6.appspot.com',
    measurementId: 'G-34L5VNYDP4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGnFV8XT51epdUZj_xop--AecEs6Tkj_8',
    appId: '1:615728327231:android:7d4b249a1d3a8ac594668a',
    messagingSenderId: '615728327231',
    projectId: 'sam-messenger-210d6',
    storageBucket: 'sam-messenger-210d6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtPrSMVkmsU_48TWx0GTm71Qr9rJWlkh8',
    appId: '1:615728327231:ios:dade9018e59109aa94668a',
    messagingSenderId: '615728327231',
    projectId: 'sam-messenger-210d6',
    storageBucket: 'sam-messenger-210d6.appspot.com',
    iosBundleId: 'com.example.sam',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = web;
}
