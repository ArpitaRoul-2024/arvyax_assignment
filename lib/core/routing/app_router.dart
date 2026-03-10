import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import screens (we'll create these next)
 import '../../features/ambience/screens/details_screen.dart';
 import '../../features/ambience/screens/home_screen.dart';
import '../../features/journal/screens/entry_details_screen.dart';
import '../../features/journal/screens/reflection_screen.dart';
import '../../features/journal/screens/history_screen.dart';
import '../../features/players/screens/players_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/details/:id',
        name: 'details',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DetailsScreen(ambienceId: id);
        },
      ),
      GoRoute(
        path: '/player/:id',
        name: 'player',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PlayerScreen(ambienceId: id);
        },
      ),
      GoRoute(
        path: '/reflection',
        name: 'reflection',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ReflectionScreen(
            ambienceId: extra?['ambienceId'] ?? '',
            ambienceTitle: extra?['ambienceTitle'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/entry/:id',
        name: 'entryDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return EntryDetailScreen(entryId: id);
        },
      ),
    ],
  );
});