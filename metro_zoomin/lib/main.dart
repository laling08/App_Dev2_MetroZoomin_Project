import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metro_zoomin/screens/onboarding_screen.dart';
import 'package:metro_zoomin/screens/auth_screen.dart';
import 'package:metro_zoomin/screens/mainscreens.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBZj8d_zxoynqhGQkAnI82ylTKCg4evwOc",
      appId: "1:404026903399:android:2231d4538b5b89211a7dc2",
      messagingSenderId: "404026903399",
      projectId: "metro-zoomin",
      storageBucket: "metro-zoomin.firebasestorage.app",
    ),
  );

  runApp(const MetroZoominApp());
}

class MetroZoominApp extends StatelessWidget {
  const MetroZoominApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetroZoomin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the user has seen onboarding
        final bool hasSeenOnboarding = true; // Replace with actual preference check

        // If loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If not logged in
        if (!snapshot.hasData) {
          return hasSeenOnboarding ? AuthScreen() : OnboardingScreen();
        }

        // If logged in
        return const HomeScreen();
      },
    );
  }
}
