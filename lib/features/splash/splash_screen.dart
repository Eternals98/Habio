// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndRedirect();
  }

  Future<void> _checkLoginAndRedirect() async {
    try {
      // Esperar al primer evento del stream para que Firebase restaure sesión en web
      final User? user = await FirebaseAuth.instance.authStateChanges().first;

      // Pequeña pausa para que el splash se vea y evitar parpadeos
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      if (user != null) {
        // Ya autenticado -> home
        context.go('/home');
      } else {
        // No autenticado -> login
        context.go('/login');
      }
    } catch (e) {
      // En caso de error, ir a login
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}
