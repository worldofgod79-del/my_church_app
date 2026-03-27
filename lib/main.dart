import 'package:flutter/material.dart';
import 'core/app_routes.dart';

// Dark Mode Toggle కోసం ఒక Global Notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp.router(
          title: 'Luminous Word',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          themeMode: mode,
          // Light Theme (Optional - Grayish)
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF8B0000), // Crimson Red
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            fontFamily: 'BalooTammudu2',
          ),
          // అసలైన Crimson Dark Theme
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF8B0000),
            scaffoldBackgroundColor: const Color(0xFF000000), // Pure Black
            cardColor: const Color(0xFF1A1A1A), // Dark Gray Cards
            hintColor: const Color(0xFFA00000), // Lighter Crimson
            fontFamily: 'BalooTammudu2',
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF000000), elevation: 0),
          ),
        );
      },
    );
  }
}