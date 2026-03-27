import 'package:flutter/material.dart';
import 'core/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Luminous Word',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Pure Dark
        fontFamily: 'BalooTammudu2',
        cardColor: const Color(0xFF161616), // Graphite Gray Cards
      ),
    );
  }
}
