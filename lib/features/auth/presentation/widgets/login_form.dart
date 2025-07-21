import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:per_habit/core/theme/app_colors.dart';
import 'package:per_habit/features/auth/presentation/controllers/auth_providers.dart';

class LoginForm extends ConsumerWidget {
  final bool isLogin;

  const LoginForm({super.key, this.isLogin = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Future<void> handleAuth() async {
      if (!formKey.currentState!.validate()) return;
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (isLogin) {
        await authController.login(email, password);
        if (ref.read(authControllerProvider).user != null) {
          context.goNamed('home');
        }
      } else {
        await authController.register(email, password);
        if (ref.read(authControllerProvider).user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
          );
          context.go('/login'); // Puedes ajustar esto según tu GoRouter
        }
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
            isLogin ? 'Bienvenido de nuevo' : 'Crea tu cuenta',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isLogin
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
            controller: emailController,
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

          if (isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed:
                    authState.loading
                        ? null
                        : () {
                          context.push(
                            '/reset-password',
                          ); // <-- Asegúrate de tener esta ruta en GoRouter
                        },
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Botón de login/register
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
                      : Text(
                        isLogin ? 'Iniciar sesión' : 'Registrarse',
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

          // Social (decorativo)
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
                icon: const FaIcon(FontAwesomeIcons.apple, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes cuenta? ',
                style: const TextStyle(color: Colors.black54),
              ),
              TextButton(
                onPressed: () {
                  final target = isLogin ? '/register' : '/login';
                  context.go(target);
                },
                child: Text(
                  isLogin ? 'Regístrate' : 'Inicia sesión',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // Mostrar error
          if (authState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                authState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
