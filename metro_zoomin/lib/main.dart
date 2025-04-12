import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

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
    );
  }
}
