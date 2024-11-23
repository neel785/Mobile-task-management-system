import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();

    navigateToMainScreen();
  }

  Future<void> navigateToMainScreen() async {
    await Future.delayed(Duration(seconds: 5));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyAppContent()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _opacityAnimation,
              child: Image.asset('assets/logo.png', height: 110),
            ),
            SizedBox(height: 16),
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Text(
                    'Welcome To Task Management App',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
