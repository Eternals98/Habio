// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:per_habit/core/theme/app_colors.dart';
import 'package:per_habit/features/auth/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isLogin = true;
  bool _loading = false;

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      UserCredential? user;
      if (_isLogin) {
        user = await AuthService().signInWithEmail(email, password);
      } else {
        user = await AuthService().registerWithEmail(email, password);
      }

      if (user is User) {
        if (_isLogin) {
          context.goNamed('home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro exitoso, ahora inicia sesión.'),
            ),
          );
          setState(() {
            _isLogin = true;
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error inesperado';
      if (e.code == 'user-not-found') message = 'Usuario no encontrado';
      if (e.code == 'wrong-password') message = 'Contraseña incorrecta';
      if (e.code == 'email-already-in-use') {
        message = 'Este correo ya está registrado';
      }
      if (e.code == 'invalid-email') message = 'Correo no válido';
      if (e.code == 'weak-password') message = 'Contraseña demasiado débil';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.primaryBackgroundDark : AppColors.primaryBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Habbito',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isLogin ? 'Bienvenido de nuevo' : 'Crea tu cuenta',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isLogin
                      ? 'Inicia sesión para continuar'
                      : 'Regístrate para empezar',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 32),

                // Email
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  onFieldSubmitted:
                      (_) =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu correo';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: true,
                  onFieldSubmitted: (_) => _handleAuth(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    if (value.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón iniciar sesión / registrarse
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        _loading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              _isLogin ? 'Iniciar sesión' : 'Registrarse',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),

                // Divider
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('o continúa con'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Social buttons (decorativos)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.facebook,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.apple,
                        color: Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Alternar login/registro
                TextButton(
                  onPressed:
                      _loading
                          ? null
                          : () {
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
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}
