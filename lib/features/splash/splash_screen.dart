import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 3 సెకన్ల తర్వాత హోమ్ స్క్రీన్ కి వెళ్తుంది
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) context.go('/home');
    });

    return const Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Text(
          "CHURCH APP\nSplash Screen",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}