import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_page.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/onboarding/presentation/persona_page.dart';
import '../../features/onboarding/presentation/welcome_page.dart';

final _routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier(0);
  ref.listen(authStateProvider, (_, _) => notifier.value++);
  ref.listen(currentPersonaProvider, (_, _) => notifier.value++);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshProvider);

  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final persona = ref.read(currentPersonaProvider);
      if (auth.isLoading) return null;
      final signedIn = auth.value?.session != null;
      final path = state.matchedLocation;
      final onboardingPath =
          path == '/welcome' || path == '/persona' || path == '/auth';
      if (!signedIn) return onboardingPath ? null : '/welcome';
      if (persona.isLoading) return null;
      if (persona.value == null) {
        return path == '/persona' ? null : '/persona';
      }
      return path == '/home' ? null : '/home';
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/persona',
        builder: (context, state) => const PersonaPage(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    ],
  );
});
