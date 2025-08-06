import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

Future<void> populateShopItems() async {
  final firestore = FirebaseFirestore.instance;

  await firestore.collection('shop').doc('item1').set({
    'id': 'item1',
    'name': 'Golden Cat',
    'description': 'A shiny cat pet',
    'icono': '🐱',
    'price': 150,
    'isOffer': false,
    'isBundle': false,
    'content': [
      {
        'id': 'item1',
        'nombre': 'Golden Cat',
        'descripcion': 'A shiny cat pet',
        'icono': '🐱',
        'category': 'mascota',
        'cantidad': 1,
      },
    ],
  });

  await firestore.collection('shop').doc('item2').set({
    'id': 'item2',
    'name': 'Forest Background',
    'description': 'A lush forest scene',
    'icono': '🌳',
    'price': 200,
    'isOffer': true,
    'isBundle': false,
    'content': [
      {
        'id': 'item2',
        'nombre': 'Forest Background',
        'descripcion': 'A lush forest scene',
        'icono': '🌳',
        'category': 'fondo',
        'cantidad': 1,
      },
    ],
  });
}

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    return ref.read(userProvider(user.uid).future);
  });
});
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    await populateShopItems(); // Only run in debug mode
  }
  //await uploadConfigData();
  runApp(const ProviderScope(child: FirebaseReadyApp()));
}

/// 🔰 Primera pantalla que espera y luego lanza la app real
class FirebaseReadyApp extends StatelessWidget {
  const FirebaseReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashLoadingScreen(),
    );
  }
}

/// ⏳ Pantalla de carga inicial segura
class SplashLoadingScreen extends StatefulWidget {
  const SplashLoadingScreen({super.key});

  @override
  State<SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<SplashLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(seconds: 0));
    // ✅ Después del splash, lanza la app real (MyApp)
    runApp(const ProviderScope(child: MyApp()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
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
