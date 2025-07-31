// lib/main.dart
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // <-- NEW
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // <-- NEW

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/status_screen.dart';
import 'screens/add_status.dart';

/* ────────── Local-notification helper ────────── */
final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

// 🔔 Background message handler (MUST be top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔕 Background Message: ${message.messageId}');
}

Future<void> _setupFirebaseMessaging() async {
  // Ask permission (iOS/Web); Android auto-granted.
  await FirebaseMessaging.instance.requestPermission();

  // Init local notifications (Android)
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await _fln.initialize(initSettings);

  // 🔔 Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
    final notif = msg.notification;
    final android = notif?.android;

    if (notif != null && android != null) {
      _fln.show(
        notif.hashCode,
        notif.title,
        notif.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id', // channel ID
            'Messages', // channel name
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
}
/* ─────────────────────────────────────────────── */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bool shouldUseFirebase =
      kIsWeb ||
      [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  if (shouldUseFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ✅ Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ✅ Setup FCM for foreground
    await _setupFirebaseMessaging();
  }

  runApp(SamApp(useFirebase: shouldUseFirebase));
}

class SamApp extends StatelessWidget {
  final bool useFirebase;
  const SamApp({super.key, required this.useFirebase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAM Messenger',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      // ─── Light theme ───────────────────────────────
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        primaryColor: const Color(0xFF3B82F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF111827),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      // ─── Dark theme ────────────────────────────────
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF6366F1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      routes: {
        '/addStatus': (_) => const AddStatusScreen(), // 🆕 uploader
        '/statuses': (_) => const StatusScreen(), // 🆕 flex‑hub feed
      },
      // ─── Root route ────────────────────────────────
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: useFirebase
            ? const SplashScreen()
            : const UnsupportedPlatformScreen(),
      ),
    );
  }
}

class UnsupportedPlatformScreen extends StatelessWidget {
  const UnsupportedPlatformScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1F2937),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            '🚫 Firebase is not supported on this platform.\nPlease run on Android, iOS, Web, or macOS.',
            style: TextStyle(color: Colors.white70, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
