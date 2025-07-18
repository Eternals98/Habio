import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:per_habit/core/routes/go_router_refresh.dart';

import 'package:per_habit/features/splash/splash_screen.dart';
import 'package:per_habit/features/auth/presentation/screens/login_screen.dart';
import 'package:per_habit/features/auth/presentation/screens/register_screen.dart';
import 'package:per_habit/features/room/screens/home_screen.dart';
import 'package:per_habit/features/auth/presentation/profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.uri.toString();
      final isLoggingIn = location == '/login' || location == '/register';

      if (user == null && !isLoggingIn) {
        return '/login';
      }

      if (user != null && isLoggingIn) {
        return '/home';
      }

      return null; // no redirección
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
    ],
  );
}
