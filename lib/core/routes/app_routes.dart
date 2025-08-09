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
import 'package:per_habit/features/store/presentation/screens/shop_screen.dart';
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

      // Rutas públicas que permitimos sin auth
      final isPublicRoute =
          location == '/' ||
          location == '/login' ||
          location == '/register' ||
          location == '/reset-password';

      // Si no está autenticado y no está en ruta pública, enviar a login
      if (user == null && !isPublicRoute) {
        return '/login';
      }

      // Si está autenticado y está en login/register, evitarlo y mandarlo al home
      final isAuthRoute = location == '/login' || location == '/register';
      if (user != null && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash (siempre pública)
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),

      // Rutas públicas
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (_, __) => const ResetPasswordScreen(),
      ),

      // Rutas privadas (protegidas globalmente por redirect)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => NavigationShell(child: const HomeScreen()),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => NavigationShell(child: const UserProfileScreen()),
      ),
      GoRoute(
        path: '/room/:id',
        name: 'room-details',
        builder: (_, state) {
          final roomId = state.pathParameters['id']!;
          return RoomDetailsScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/store',
        name: 'store',
        builder: (_, __) => NavigationShell(child: const ShopScreen()),
      ),

      // Inventary: necesitamos el inventario del perfil -> usamos Consumer para obtenerlo y pasar el parámetro requerido
      GoRoute(
        path: '/inventary',
        name: 'inventary',
        builder:
            (_, __) => Consumer(
              builder: (context, ref, _) {
                final userState = ref.watch(userControllerProvider);
                return userState.when(
                  data: (userProfile) {
                    if (userProfile == null) {
                      // Si perfil no existe por alguna razón, mandamos al login
                      return const LoginScreen();
                    }
                    // Pasamos el inventario al widget que lo necesita
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
                      (_, __) => const Scaffold(
                        body: Center(child: Text('Error loading profile')),
                      ),
                );
              },
            ),
      ),
    ],
  );
}
