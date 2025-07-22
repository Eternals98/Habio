import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
import 'package:per_habit/features/user/presentation/controllers/user_provider.dart';
import 'package:per_habit/features/user/presentation/screens/user_profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.uri.toString();

      if (location == '/') return null;

      final isLoggingIn = location == '/login' || location == '/register';

      if (user == null && !isLoggingIn) {
        return '/login';
      }

      if (user != null && isLoggingIn) {
        return '/home';
      }

      return null;
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
            (context, state) => Consumer(
              builder: (context, ref, _) {
                final userState = ref.watch(userControllerProvider);
                return userState.when(
                  data: (userProfile) {
                    if (userProfile == null) {
                      return const LoginScreen();
                    }
                    return NavigationShell(
                      child: InventaryScreen(
                        inventario: userProfile.inventario,
                      ),
                    );
                  },
                  loading:
                      () => const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                  error:
                      (error, _) => const Scaffold(
                        body: Center(child: Text('Error loading profile')),
                      ),
                );
              },
            ),
      ),
    ],
  );
}
