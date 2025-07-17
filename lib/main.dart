import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:per_habit/core/routes/app_routes.dart';
import 'package:per_habit/firebase_options.dart'; // Asegúrate de tener este archivo generado por Firebase CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 👈 para web/mobile
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Habio',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      routerConfig: AppRouter.router,
    );
  }
}
