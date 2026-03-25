import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/bible/bible_home.dart';
import '../features/bible/bible_reader.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/bible', builder: (context, state) => const BibleHome()),
    GoRoute(
      path: '/bible-reader/:name', // ఇక్కడ name అని మార్చాం
      builder: (context, state) {
        final name = state.pathParameters['name']!;
        return BibleReader(bookName: name);
      },
    ),
  ],
);