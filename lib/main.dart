import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:per_habit/core/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: unused_import
import 'package:per_habit/devtools/config_uploader.dart';
import 'package:per_habit/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 👈 para web/mobile
  );
  //await uploadConfigData();
  runApp(ProviderScope(child: MyApp()));
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
