import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:per_habit/core/theme/app_colors.dart';
import 'package:per_habit/features/auth/presentation/controllers/auth_providers.dart';

class RegisterForm extends ConsumerWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    final emailFocus = FocusNode();
    final passwordFocus = FocusNode();
    final confirmFocus = FocusNode();

    final formKey = GlobalKey<FormState>();

    Future<void> handleRegister() async {
      if (!formKey.currentState!.validate()) return;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      await authController.register(email, password);
      final user = ref.read(authControllerProvider).user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
        );
        context.go('/login');
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
            'Crea tu cuenta',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Regístrate para empezar',
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

          // Contraseña
          TextFormField(
            controller: passwordController,
            focusNode: passwordFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted:
                (_) => FocusScope.of(context).requestFocus(confirmFocus),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa una contraseña';
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
          const SizedBox(height: 16),

          // Confirmar contraseña
          TextFormField(
            controller: confirmController,
            focusNode: confirmFocus,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => handleRegister(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (value != passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
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

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authState.loading ? null : handleRegister,
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
                        'Registrarse',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
            ),
          ),

          const SizedBox(height: 20),

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
                '¿Ya tienes cuenta? ',
                style: TextStyle(color: Colors.black54),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text(
                  'Inicia sesión',
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
