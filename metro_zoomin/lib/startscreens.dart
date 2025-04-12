import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'registerscreens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // we must initialise the firebase platform to seamlessly connect with MyApp
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBZj8d_zxoynqhGQkAnI82ylTKCg4evwOc",
          appId: "404026903399",
          messagingSenderId: "404026903399",
          projectId: "metro-zoomin")
  );

  runApp(const MetroZoomin());
}

class MetroZoomin extends StatelessWidget {
  const MetroZoomin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      routes: {
        '/landing': (context) => LandingScreen(),
        '/register': (context) => RegisterScreen(),
      },
      theme: ThemeData(
          primarySwatch: Colors.grey // subject to change
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Splash screen delay for three seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/landing');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.heart_broken), // placeholder
            ],
          ),
        ),
      ),
    );
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    // Sends user to sign in / sign up page, but with a cool transition
    // (feel free to change the transition)
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0, 1);
            const end = Offset.zero;
            final tween = Tween<Offset>(begin: begin, end: end);
            final slideAnimation = animation.drive(tween);

            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.heart_broken_outlined), // placeholder
            ],
          ),
        ),
      ),
    );
  }
}

