import 'package:go_router/go_router.dart';

// --- Imports (అన్ని స్క్రీన్స్ ఇక్కడ లింక్ చేయబడ్డాయి) ---
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';

import '../features/bible/bible_home.dart';
import '../features/bible/bible_reader.dart';
import '../features/bible/bible_search.dart';

import '../features/music/music_home.dart';
import '../features/music/music_player.dart';

import '../features/admin/admin_dashboard.dart';
import '../features/admin/admin_albums.dart';


// --- Router Configuration ---
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes:[
    // 1. Splash & Home Screens
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

    // 3. Music Section (కొత్తగా యాడ్ చేసినవి)
    GoRoute(
      path: '/music', 
      builder: (context, state) => const MusicHome(),
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) {
        // MusicPlayer కు డేటా పంపించడానికి extra వాడుతున్నాం
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return MusicPlayerScreen(
          songs: extra['songs'] ?? [],
          initialIndex: extra['index'] ?? 0,
          albumCover: extra['albumCover'] ?? '',
        );
      },
    ),

    // 4. Admin Section
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
