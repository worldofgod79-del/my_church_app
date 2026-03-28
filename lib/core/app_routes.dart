import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- Imports (Feature Screens) ---
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';

// Bible Features
import '../features/bible/bible_home.dart';
import '../features/bible/bible_reader.dart';
import '../features/bible/bible_search.dart';

// Music Features
import '../features/music/music_player.dart';

// Admin Features
import '../features/admin/admin_dashboard.dart';
import '../features/admin/admin_albums.dart';

// --- Router Configuration ---
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    // 1. ప్రాథమిక స్క్రీన్స్ (Splash & Main Home)
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(), // ఇక్కడే Bottom Nav Tabs ఉంటాయి
    ),

    // 2. బైబిల్ సెక్షన్ (బైబిల్ మెయిన్ గ్రిడ్, రీడర్ మరియు సెర్చ్)
    GoRoute(
      path: '/bible',
      builder: (context, state) => const BibleHome(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => BibleSearch(
        initialBook: state.uri.queryParameters['book'],
      ),
    ),
    GoRoute(
      path: '/bible-reader/:name',
      builder: (context, state) {
        return BibleReader(
          bookName: state.pathParameters['name']!,
          initialChapter: state.uri.queryParameters['chapter'],
          initialVerse: state.uri.queryParameters['verse'],
        );
      },
    ),

    // 3. మ్యూజిక్ ప్లేయర్ (ఇది ఫుల్ స్క్రీన్ లో ఓపెన్ అవుతుంది)
    GoRoute(
      path: '/player',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return MusicPlayerScreen(
          songs: extra['songs'] ?? [],
          initialIndex: extra['index'] ?? 0,
          albumCover: extra['albumCover'] ?? '',
        );
      },
    ),

    // 4. అడ్మిన్ ప్యానెల్ (సెక్యూరిటీ లాగిన్ తో కూడినది)
    GoRoute(
      path: '/admin-login',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/admin-albums',
      builder: (context, state) => const AdminAlbumsScreen(),
    ),
  ],
);