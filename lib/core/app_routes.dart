import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/bible/bible_home.dart';
import '../features/bible/bible_reader.dart';
import '../features/bible/bible_search.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/admin/admin_albums.dart'; // కొత్తగా యాడ్ చేసిన అడ్మిన్ ఆల్బమ్స్ స్క్రీన్

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes:[
    // 1. Splash & Home
    GoRoute(
      path: '/', 
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home', 
      builder: (context, state) => const HomeScreen(),
    ),

    // 2. Bible Section
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

    // 3. Admin Section
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