import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/bible/bible_home.dart';
import '../features/bible/bible_reader.dart';
import '../features/bible/bible_search.dart';
import '../features/admin/admin_dashboard.dart'; // అడ్మిన్ ప్యానెల్ ఇంపోర్ట్

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes:[
    // పాతవి అన్నీ అలాగే ఉన్నాయి
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/bible', builder: (context, state) => const BibleHome()),
    
    GoRoute(
      path: '/search',
      builder: (context, state) => BibleSearch(initialBook: state.uri.queryParameters['book']),
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

    // అడ్మిన్ రూట్స్ ఇక్కడ (లిస్ట్ లోపల) ఉండాలి
    GoRoute(path: '/admin-login', builder: (context, state) => const AdminLoginScreen()),
    GoRoute(path: '/admin-dashboard', builder: (context, state) => const AdminDashboard()),
  ],
);