import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/bible/bible_home.dart';
import '../features/bible/bible_reader.dart';
import '../features/bible/bible_search.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
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
  ],
);
