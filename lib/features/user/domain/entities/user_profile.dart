import 'package:per_habit/features/inventary/data/models/inventory.dart';

class UserProfile {
  final String id;
  String email;
  final String displayName;
  final String bio;
  final String photoUrl;
  final bool onboardingCompleted;
  Inventario inventario;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.bio,
    required this.photoUrl,
    this.onboardingCompleted = false,
    Inventario? inventario,
  }) : inventario = inventario ?? Inventario();
}
