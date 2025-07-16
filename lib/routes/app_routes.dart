import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/habits/create_habit_screen.dart'; // 👈 Import nuevo

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
    createHabit: (context) => const CreateHabitScreen(), // 👈 Mapa nuevo
  };
}
