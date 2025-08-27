import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:per_habit/firebase_options.dart';
import 'package:per_habit/core/routes/app_routes.dart'; // GoRouter configurado en tu app
import 'package:per_habit/features/notification/data/notification_services.dart'; // LocalNotifications
import 'package:per_habit/features/user/domain/entities/user_profile.dart';
import 'package:per_habit/features/store/presentation/controllers/shop_provider.dart'; // si lo necesitas en arranque

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

  // 1) Inicializa Local Notifications con callback opcional para taps
  await LocalNotifications.init(
    onSelectNotification: (payload) {
      // Si quieres navegar al tocar la notificación, puedes usar GoRouter así:
      // if (payload != null && payload.isNotEmpty) {
      //   AppRouter.router.go(payload); // p.ej. '/spin' o '/room?id=...&habit=...'
      // }
    },
  );

  // 2) Pide permisos de notificaciones en ambas plataformas
  await LocalNotifications.requestPermissions();

  // 3) Enlaza el estado de auth para programar/cancelar la ruleta diaria automáticamente.
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user != null) {
      // Programa un recordatorio diario a las 9:00 con payload para deep-link
      await LocalNotifications.scheduleDailyWheelReminder(
        uid: user.uid,
        at: const TimeOfDay(hour: 9, minute: 0),
        payload: '/spin',
      );
    } else {
      // Limpia notificaciones al cerrar sesión
      await LocalNotifications.cancelAll();
    }
  });

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
