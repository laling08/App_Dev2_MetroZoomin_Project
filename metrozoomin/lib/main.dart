import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metrozoomin/screens/onboarding_screen.dart';
import 'package:metrozoomin/screens/mainscreens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metrozoomin/services/notification_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  // This is required for the splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keep the splash screen visible until initialization is complete
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAQY1AeEplQCsgDYl_On9YCmCb4utjD0Lw",
      appId: "225122880864",
      messagingSenderId: "225122880864",
      projectId: "metrozoomin-bd5b3",
    ),
  );

  // Initialize notification service
  await NotificationService().init();

  // Remove the splash screen when initialization is done
  FlutterNativeSplash.remove();

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
        // If loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Always show OnboardingScreen if not logged in
        if (!snapshot.hasData) {
          return OnboardingScreen();
        }

        // If logged in, show the HomeScreen
        return const HomeScreen();
      },
    );
  }
}
