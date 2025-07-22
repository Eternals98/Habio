import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:per_habit/devtools/config_uploader.dart';
import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:per_habit/core/routes/app_routes.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';
import 'package:per_habit/features/user/data/models/user_profile_model.dart';

// Define the UserProfile provider
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    // Replace with your actual repository logic (e.g., Firestore fetch)
    return UserProfileModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      bio: '',
      photoUrl: user.photoURL ?? '',
      inventario: Inventario(),
    );
  });
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await uploadConfigData();
  runApp(const ProviderScope(child: FirebaseReadyApp()));
}

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
    await Future.delayed(const Duration(seconds: 2));
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
