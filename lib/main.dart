import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

// Routes (నావిగేషన్) సెటప్ - ఇది వెబ్ లో ఫాస్ట్ గా పనిచేస్తుంది
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Church App',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

// తాత్కాలికంగా ఇక్కడే Splash Screen రాస్తున్నాను
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () => context.go('/home'));
    return const Scaffold(
      body: Center(child: Text("SPLASH SCREEN", style: TextStyle(fontSize: 24))),
    );
  }
}

// తాత్కాలికంగా ఇక్కడే Home Screen రాస్తున్నాను
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Screen")),
      drawer: const Drawer(child: Center(child: Text("Side Menu"))),
      body: const Center(child: Text("Welcome to Church App")),
    );
  }
}