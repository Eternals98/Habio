// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';

// Definición del widget principal de la pantalla de login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Estado del widget, donde se maneja la lógica y los elementos de la UI
class _LoginScreenState extends State<LoginScreen> {
  // Clave para identificar y validar el formulario
  final _formKey = GlobalKey<FormState>();
  // Controladores para los campos de texto
  final TextEditingController _emailController =
      TextEditingController(); // Para el campo de email
  final TextEditingController _passwordController =
      TextEditingController(); // Para el campo de contraseña
  // Nodos para manejar el foco entre los campos
  final FocusNode _emailFocus = FocusNode(); // Foco para el campo de email
  final FocusNode _passwordFocus =
      FocusNode(); // Foco para el campo de contraseña
  bool _isLoading = false; // Estado para mostrar el indicador de carga

  // Función para manejar el inicio de sesión
  Future<void> _login(BuildContext context) async {
    // Valida el formulario antes de proceder
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Muestra el indicador de carga

    try {
      // Intenta iniciar sesión con Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navega a la pantalla principal si el login es exitoso
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      // Muestra un mensaje de error si falla el login
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Error inesperado')));
    } finally {
      setState(() => _isLoading = false); // Oculta el indicador de carga
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.deepPurple; // Color principal para la UI

    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco de la pantalla
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), // Espaciado alrededor del contenido
        child: Form(
          key: _formKey, // Asocia el formulario con la clave
          child: Column(
            children: [
              // Espacio superior
              const SizedBox(height: 80),
              // Logo de la aplicación
              Image.asset('assets/images/logo.png', height: 150, width: 150),
              const SizedBox(height: 24),
              // Texto de bienvenida
              Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 40),
              // Campo de texto para el email
              TextFormField(
                controller: _emailController, // Controlador del campo de email
                focusNode: _emailFocus, // Foco para el campo de email
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email,
                    color: themeColor,
                  ), // Icono de email
                  labelText: 'Email', // Etiqueta del campo
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Bordes redondeados
                  ),
                ),
                validator: (value) {
                  // Validaciones para el campo de email
                  if (value == null || value.isEmpty) return 'Ingresa tu email';
                  if (!value.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Campo de texto para la contraseña
              TextFormField(
                controller:
                    _passwordController, // Controlador del campo de contraseña
                focusNode: _passwordFocus, // Foco para el campo de contraseña
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock,
                    color: themeColor,
                  ), // Icono de candado
                  labelText: 'Contraseña', // Etiqueta del campo
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Bordes redondeados
                  ),
                ),
                obscureText: true, // Oculta el texto de la contraseña
                validator: (value) {
                  // Validaciones para el campo de contraseña
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
                onFieldSubmitted:
                    (_) => _login(context), // Ejecuta login al presionar Enter
              ),
              const SizedBox(height: 30),
              // Botón de inicio de sesión
              SizedBox(
                width: double.infinity, // Ocupa todo el ancho
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () =>
                              _login(context), // Ejecuta login al hacer clic
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor, // Color del botón (morado)
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ), // Espaciado interno
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Bordes redondeados
                    ),
                  ),
                  child: SizedBox(
                    height: 24, // Altura fija para el contenido del botón
                    child: Center(
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth:
                                      2, // Grosor del indicador más fino
                                ),
                              )
                              : const Text(
                                'Iniciar Sesión', // Texto del botón
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Colors
                                          .white, // Color explícito para el texto
                                ),
                              ),
                    ),
                  ),
                ),
              ),
              // Botón para ir a la pantalla de registro
              TextButton(
                onPressed:
                    () => Navigator.pushNamed(context, AppRoutes.register),
                child: const Text("¿No tienes cuenta? Regístrate"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Liberación de recursos cuando el widget se elimina
  @override
  void dispose() {
    _emailController.dispose(); // Libera el controlador del email
    _passwordController.dispose(); // Libera el controlador de la contraseña
    _emailFocus.dispose(); // Libera el nodo de foco del email
    _passwordFocus.dispose(); // Libera el nodo de foco de la contraseña
    super.dispose();
  }
}
