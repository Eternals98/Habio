import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:per_habit/core/routes/go_router_refresh.dart';
import 'package:per_habit/features/inventary/presentation/screens/inventary_screen.dart';
import 'package:per_habit/features/navigation/presentation/screens/navigation_shell.dart';
import 'package:per_habit/features/room/presentation/screens/room_detail_screen.dart';

import 'package:per_habit/features/splash/splash_screen.dart';
import 'package:per_habit/features/auth/presentation/screens/login_screen.dart';
import 'package:per_habit/features/auth/presentation/screens/register_screen.dart';
import 'package:per_habit/features/room/presentation/screens/home_screen.dart';
import 'package:per_habit/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:per_habit/features/store/presentation/screens/store_screen.dart';
import 'package:per_habit/features/user/presentation/screens/user_profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/', // Ruta inicial es SplashScreen
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.uri.toString();

      // ✅ Permitir que SplashScreen maneje la navegación inicial
      if (location == '/') return null;

      final isLoggingIn = location == '/login' || location == '/register';

      // 🔒 Si no ha iniciado sesión, redirige a login (excepto en splash)
      if (user == null && !isLoggingIn) {
        return '/login';
      }

      // ✅ Si ya está logueado, evita que acceda a login/register
      if (user != null && isLoggingIn) {
        return '/home';
      }

      return null; // Sin redirección
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
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => NavigationShell(child: const HomeScreen()),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder:
            (context, state) =>
                NavigationShell(child: const UserProfileScreen()),
      ),
      GoRoute(
        path: '/room/:id',
        name: 'room-details',
        builder: (context, state) {
          final roomId = state.pathParameters['id']!;
          return RoomDetailsScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/store',
        builder:
            (context, state) => NavigationShell(child: const StoreScreen()),
      ),
      GoRoute(
        path: '/inventary',
        builder:
            (context, state) => NavigationShell(child: const InventaryScreen()),
      ),
    ],
  );
}
