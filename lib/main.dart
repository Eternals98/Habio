import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: unused_import
import 'package:per_habit/devtools/config_uploader.dart';
import 'package:per_habit/features/store/presentation/controllers/shop_provider.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';
import 'package:per_habit/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🌱 App real con GoRouter y lógica de autenticación
import 'package:per_habit/core/routes/app_routes.dart';

/// Proveedor global que expone el perfil de usuario autenticado
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    return ref.read(userProvider(user.uid).future);
  });
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Habio',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
