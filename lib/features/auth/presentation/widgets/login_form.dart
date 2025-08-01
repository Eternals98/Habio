import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:per_habit/core/theme/app_colors.dart';
import 'package:per_habit/features/auth/presentation/controllers/auth_providers.dart';

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final emailFocus = FocusNode();
    final passwordFocus = FocusNode();
    final formKey = GlobalKey<FormState>();

    Future<void> handleAuth() async {
      if (!formKey.currentState!.validate()) return;
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      await authController.login(email, password);
      final user = ref.read(authControllerProvider).user;
      final error = ref.read(authControllerProvider).error;

      if (user != null) {
        context.goNamed('home');
      } else if (error != null &&
          error.toLowerCase().contains('invalid-credential')) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Ups 😥'),
                content: const Text(
                  'Usuario no encontrado.\nVerifica tu correo o regístrate.',
                ),
                actions: [
                  TextButton(
                    child: const Text('Registrarme'),
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/register');
                    },
                  ),
                  TextButton(
                    child: const Text('Volver'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
        );
      }
    }

    return Form(
      key: formKey,
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
            'Bienvenido de nuevo',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Inicia sesión para continuar',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 32),

          // Email
          TextFormField(
            controller: emailController,
            focusNode: emailFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted:
                (_) => FocusScope.of(context).requestFocus(passwordFocus),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Ingresa tu correo';
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
            controller: passwordController,
            focusNode: passwordFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => handleAuth(),
            obscureText: true,
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

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed:
                  authState.loading
                      ? null
                      : () => context.push('/reset-password'),
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authState.loading ? null : handleAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child:
                  authState.loading
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
                      : const Text(
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('o continúa con'),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          // Social buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              FaIcon(FontAwesomeIcons.google, color: Colors.redAccent),
              SizedBox(width: 16),
              FaIcon(FontAwesomeIcons.facebook, color: Colors.blueAccent),
              SizedBox(width: 16),
              FaIcon(FontAwesomeIcons.apple, color: Colors.black),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿No tienes cuenta? ',
                style: TextStyle(color: Colors.black54),
              ),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text(
                  'Regístrate',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
