import 'package:flutter/material.dart';
import 'package:per_habit/features/room/screens/home_screen.dart';
import 'package:per_habit/features/auth/screens/login_screen.dart';
import 'package:per_habit/features/splash/splash_screen.dart';
import '../../features/auth/screens/register_screen.dart';

/// Archivo donde defines las rutas y pantallas asociadas.
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String register = '/register';
  static const String createHabit = '/create-habit'; // 👈 Ruta nueva

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    register: (context) => const RegisterScreen(),
  };
}
