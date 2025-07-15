import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/register/register_screen.dart';

/// Archivo donde defines las rutas y pantallas asociadas.
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String register = '/register';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    register: (context) => const RegisterScreen(),
  };
}
