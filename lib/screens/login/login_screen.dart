// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import '../../app_colors.dart'; // Importamos los colores centralizados
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode(); // Foco para el campo de email
  final FocusNode _passwordFocus =
      FocusNode(); // Foco para el campo de contraseña
  bool _isLogin = true; // true = login, false = register

  /// Método para normalizar el email: si no tiene @, le agrega @habio.com
  String normalizeEmail(String input) {
    if (input.contains('@')) {
      return input.trim();
    } else {
      return '${input.trim()}@habio.com';
    }
  }

  /// Manejar login
  Future<void> _handleLogin() async {
    final email = normalizeEmail(_emailController.text);
    final password = _passwordController.text;
    UserCredential? success = await AuthService().signInWithEmail(
      email,
      password,
    );

    if (success != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al iniciar sesión')));
    }
  }

  /// Manejar registro
  Future<void> _handleRegister() async {
    final email = normalizeEmail(_emailController.text);
    final password = _passwordController.text;
    UserCredential? success = await AuthService().registerWithEmail(
      email,
      password,
    );

    if (success != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso, ahora inicia sesión.')),
      );
      setState(() {
        _isLogin = true;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al registrarse')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/logo.png', height: 120),
              const SizedBox(height: 24),

              // Título
              Text(
                _isLogin ? 'Bienvenido a Habio' : 'Crea tu cuenta',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Campo usuario/email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Usuario o Email',
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo contraseña
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botón principal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLogin ? _handleLogin : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isLogin ? 'Iniciar sesión' : 'Registrarse',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón para cambiar modo
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin
                      ? '¿No tienes cuenta? Regístrate'
                      : '¿Ya tienes cuenta? Inicia sesión',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose(); // Libera el controlador del email
    _passwordController.dispose(); // Libera el controlador de la contraseña
    _emailFocus.dispose(); // Libera el nodo de foco del email
    _passwordFocus.dispose(); // Libera el nodo de foco de la contraseña
    super.dispose();
  }
}
