import 'package:flutter/material.dart';
import 'package:metrozoomin/screens/auth_screen.dart';

import 'mainscreens.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Splash screen delay for three seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == 1;
            });
          },
          children: [
            // First splash screen
            SplashPage(
              imagePath: 'assets/images/metro_logo.png',
              backgroundColor: Colors.white,
              showStars: true,
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Skip button
            TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AuthScreen()),
              ),
              child: Text(
                'Skip',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            // Page indicator
            Center(
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !isLastPage ? Colors.blue : Colors.grey.shade400,
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLastPage ? Colors.blue : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            // Next or Get Started button
            isLastPage
                ? TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AuthScreen()),
              ),
              child: Text(
                'Get Started',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
                : TextButton(
              onPressed: () => _pageController.nextPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  final String imagePath;
  final Color backgroundColor;
  final bool showStars;

  const SplashPage({
    Key? key,
    required this.imagePath,
    required this.backgroundColor,
    this.showStars = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Stack(
        children: [
          if (showStars) ...[
            // Stars and dots decoration
            Positioned(
              top: 100,
              left: 50,
              child: Icon(Icons.star, color: Colors.grey.shade300, size: 20),
            ),
            Positioned(
              top: 180,
              right: 70,
              child: Icon(Icons.star, color: Colors.grey.shade300, size: 20),
            ),
            Positioned(
              bottom: 150,
              right: 100,
              child: Icon(Icons.star, color: Colors.grey.shade300, size: 20),
            ),
            Positioned(
              top: 120,
              right: 120,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 250,
              left: 80,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              left: 60,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      imagePath,
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                // Pin pointer triangle
                Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                    // transform: Matrix4.rotationZ(0.785398), // 45 degrees
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}