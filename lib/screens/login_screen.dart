import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui_auth;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import 'complete_profile_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<bool> _doesUserExist(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return ui_auth.SignInScreen(
      providers: [
        ui_auth.EmailAuthProvider(),
        GoogleProvider(
          clientId:
              '734118059703-59picbt3iavuh22jo1ujuggemr55j5in.apps.googleusercontent.com',
        ),
      ],
      actions: [
        ui_auth.AuthStateChangeAction<ui_auth.SignedIn>((context, state) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return;

          final exists = await _doesUserExist(user.uid);

          if (exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
            );
          }
        }),
      ],
    );
  }
}
